The language we studied was only a subset of the actual Nix language.

We here present some parts of the language that have been omitted until now and
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

In the formalism we present here, we compile the if constructs differently
depending on their form using a hardcoded list of predicates on types.
This is not fully satisfactory as this only works at a syntactic-only level,
and won't even detect some simple modifications such as the aliasing of a
predicate. So `if isInt x then x+1 else 1` will typecheck (under the hypothesis
that `x` is defined of course), while `let f = isInt; in if f x then x+1 else x`
will not.

It is possible to get more flexibility by recognizing that the notion of a
predicate on a type `t` is a function of type
`(t -> true) AND ($\lnot$t -> false)`.
We can thus modify the Nix-light language by replacing the typecase and
replacing it with a if construct, and replace the typecase rules by the
following ones:

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

### The import function

The import statement^[Which is just a function in Nix, but with a very special
semantic] allows importing other files. Its syntax is `import e` where `e`
should evaluate to a string representing an absolute path.
The semantic of this is that if the body of the file `s` reduces to a value
`v`, then `import s` reduces to `v` (so this isn't a textual inclusion: the
current scope isn't available in the imported file).

We here restrict ourselves to the cases where the argument of import is a
literal string (which means that the included file is statically known).

The syntax of Nix-light operators is extended as follows:

```
<operators> :: = ... | import (<expr>)
```

Where the expression in argument is the content of the imported file.
This means that we also add a compilation rule of the form:

\begin{displaymath}
  °(|import s|)° = °import(e)° \text{ where } °e° = \operatorname{PARSE}(°s°)
\end{displaymath}

Where "PARSE" is a (meta-)function which parses the file at the given location.

We also add a reduction rule

\begin{displaymath}
  °import(e)° \rightsquigarrow °e° \quad \text{ if \lstinline!e! has no free variable }
\end{displaymath}

and the convention that variable substitutions don't propagate under the
`import` operator.

The typing rule for this operator is rather simple:

\begin{displaymath}
\inferrule{\tIC e : τ}{Γ \tIC \operatorname{import}(e): τ}
\end{displaymath}

### The with construct

Nix accepts expressions of the form `with <expr>; <expr>`.
The meaning of this is that, provided that the first expression evaluates to a
record `{ x1 = e1; $\cdots$; xn = en }`, then the second one is evaluated with
the content of the record in scope, which is with the new variables `x1`,
\ldots, `xn` available with value respectivly `e1`, \ldots, `en`.
Moreover, if a variable is already in the scope, then it can't be shadowed by a
`with` construct.

Given its weird semantic and the difficulty to type it (greatly improved by the
high versatility of the records in Nix), this construct isn't presented at all
here.
It should be possible however to type it in some simple enough contexts.

### Throw/assert and tryEval

Nix has a notion of exceptions (although their exact nature isn't documented at
all).
In particular, ther exists a `throw` function (which raises an exception with a
given message) and an `assert` construct (of the form `assert <expr>; <expr>`)
which exists with an error if the first expression doesn't evaluates to `true`
and evaluates the second one otherwise.
The `throw` function can be directly compiled to a function of type
`String -> Any` and `assert e1; e2`; can be compiled to
`if e1 then e2 else throw "assertion failed`.

The `tryEval` function implements a form of exception catching: if its argument
raises an exception, it evaluates to `{ success = false; value = false; }`.
Otherwise, if its arguments evaluates to a value `v`, it evaluates to
`{ success = true; value = v; }`.
As long as we don't try to track exceptions, a reasonable rule for this is:

\begin{displaymath}
  \inferrule{Γ \vdash e : τ}{%
    Γ \vdash \operatorname{tryEval}(e) : \{ success = \text{Bool}; value = \text{Bool} \vee τ \}}
\end{displaymath}

(note that in presence of polymorphism, it would have been enough to type
`tryEval` as a function of type
`$\forall \alpha$. $\alpha$ -> { success = Bool; value = $\alpha$ | Bool}`).
