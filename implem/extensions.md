The language we studied was only a subset of the actual Nix language.

We present here some parts of the language that have been omitted until now and
an informal typing for them.

### Special operators on lists and records

We quickly talked in \Cref{sec:nix-light} of the `mapAttrs` function which can
not be given a generic enough type by itself but needs to be considered as a
special operator with a custom typing rule.
Several other functions go into this category. Even the `map` function on lists
can not be typed in a useful way with heterogeneous lists.

Here is for example a possible pair of rules fore the `mapAttrs` function
with atomic record types (the real rules need of course to be extended to
arbitrary record types):

\begin{mathpar}
  \newcommand{\mapA}{\operatorname{mapAttrs}}
  \inferrule{
    Γ \tinfer e : \left\{ \seq{s_i = τ_i;}{i \in I} \right\} \\
    Γ \tinfer f : τ_f \\
    \forall i \in I, τ_f \image τ_i = σ_i \\
  }{
    Γ \tinfer \mapA(f, e) : \left\{ \seq{s_i = σ_i;}{i \in I} \right\}
  }
  \and\inferrule{
    Γ \tinfer e : \left\{ \seq{s_i = τ_i;}{i \in I} \right\} \\
    \forall i \in I, Γ \tcheck f : τ_i \rightarrow σ_i \\
  }{
    Γ \tcheck \mapA(f, e) : \left\{ \seq{s_i = σ_i;}{i \in I} \right\}
  }
\end{mathpar}

### Tracking of the predicates on types

In the formalism we present here, we compile the `if` constructs differently
depending on their form using a hardcoded list of predicates on types.
This is not fully satisfactory as this only works at a syntactic-level,
and will not even detect some simple modifications such as the aliasing of a
predicate. So `if isInt x then x+1 else 1` will typecheck (under the hypothesis
that `x` is defined of course), while `let f = isInt; in if f x then x+1 else x`
will not.

It is possible to get more flexibility by recognizing that the notion of a
predicate on a type `t` is a function of type
`(t -> true) AND ($\lnot$t -> false)`.
We can thus modify the Nix-light language by removing the typecase and
replacing it with an if construct, and replace the associated typing rules by
the following ones:

\begin{mathpar}
  \inferrule{
    Γ \tinfer x : τ_x \\
    Γ \tinfer f : (τ \rightarrow true) \wedge (\lnot τ \rightarrow false) \\
    τ_x \notsubtype \lnot τ \Rightarrow Γ; x : τ \wedge τ_x \tinfer e_1 : σ_1 \\
    τ_x \notsubtype τ \Rightarrow Γ; x : \lnot τ \wedge τ_x \tinfer e_2 : σ_2
  }{
    Γ \tinfer \text{if } f x \text{ then } e_1 \text{ else } e_2 : σ_1 \vee σ_2
  }

\and\inferrule{
  Γ \tinfer e_0 : τ \\
    τ \notsubtype \text{true} \Rightarrow Γ \vdash e_1 : σ_1 \\
    τ \notsubtype \text{false} \Rightarrow Γ \vdash e_2 : σ_2 \\
    e_0 \text{ not of the form } f x \text { with } f \text{ a predicate on types}
}{
  Γ \tinfer \text{if } f x \text{ then } e_1 \text{ else } e_2 : σ_1 \vee σ_2
}
\end{mathpar}

The (theoretical) drawback of this approach is that instead of having a clean
set of typing rules with one unified rule for the typecase and putting the
ad-hoc part (the recognition of some special if constructs) into the
preliminary compilation phase, we need to have a new ad-hoc rule for the
if-then-else's (so the system is slightly more difficult to understand and
modify).

This has however been implemented as it gives much more flexibility to the
system.

### The with construct

Nix accepts expressions of the form `with <expr>; <expr>`.
The meaning of this is that, provided that the first expression evaluates to a
record `{ x1 = e1; $\cdots$; xn = en }`, then the second one is evaluated with
the content of the record in scope, which is with the new variables `x1`,
\ldots, `xn` available with value respectivly `e1`, \ldots, `en`.
Moreover, if a variable is already in the scope, then it can not be shadowed by a
`with` construct.

Given its weird semantic and the difficulty to type it (greatly improved by the
high versatility of the records in Nix), this construct is not presented at all
here.
It should be possible however to type it in some simple enough contexts.

### Throw/assert and tryEval

Nix has a notion of exceptions (although their exact nature is not documented at
all).
In particular, ther exists a `throw` function (which raises an exception with a
given message) and an `assert` construct (of the form `assert <expr>; <expr>`)
which exists with an error if the first expression does not evaluates to `true`
and evaluates the second one otherwise.
The `throw` function can be directly compiled to a function of type
`String -> Any` and `assert e1; e2`; can be compiled to
`if e1 then e2 else throw "assertion failed`.

The `tryEval` function implements a form of exception catching: if its argument
raises an exception, it evaluates to `{ success = false; value = false; }`.
Otherwise, if its arguments evaluates to a value `v`, it evaluates to
`{ success = true; value = v; }`.
As long as we do not try to track exceptions, a reasonable rule for this is:

\begin{displaymath}
  \inferrule{Γ \tIC e : τ}{%
    Γ \tIC \operatorname{tryEval}(e) : \{ success = \text{Bool}; value = \text{false} \vee τ \}}
\end{displaymath}

(note that in presence of polymorphism, it would have been enough to type
`tryEval` as a function of type
`$\forall \alpha$. $\alpha$ -> { success = Bool; value = $\alpha$ $\vee$ false}`).
