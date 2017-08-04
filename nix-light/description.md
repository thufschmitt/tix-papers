#### Grammar

This language is really similar to Nix, but makes syntactically distinct all
the elements which requires a special treatment from the typechecker.

The differences are:

- The if construct is replaced by the more general "typecase" construct of the
  form `(x = e0 tin t) ? e1 : e2` (which evaluates to `e1` if `e0` evaluates to
  a value of type `t` and to `e2` otherwise).
  The general case `if e0 then e1 else e2` will be compiled to
  `(x = (e0 : Bool) tin true) ? e1 : e2` (where `x` is a fresh variable),
  whereas particular cases such as `if isInt x then e1 else e2` will be compiled
  to specialized versions such as `(x = x tin Int) ? e1 : e2`.
  This lightens the type-system as both forms can be treated with the same rule.
  However, this reduces the expressiveness, as an expression such as `let f =
  isInt in if f x then x else 1` will not be recognized by the compiler
  (because it has no type information, so can not see that `f` is the same
  predicate over types as `isInt` and thus should be treated the same
  way)^[Typed racket [@FH08] does some tracking of type predicates in the
  type-system itself by annotating arrows. This can also be achieved (and in a
  less intrusive way) using this type-system and has in fact been implemented.
  This will be discussed in \Cref{implem::extensions}].
  <!--- TODO: This tracking isn't explained yet --->

- The definition of records is simplified: Nix has a specific syntax to
  define nested records (for example `{ x.y = 1; x.z = 2; }` is equivalent to
  `{ x = { y = 1; z = 2; }; }`) which is absent in Nix-light.

- Recursive record definitions are not allowed either, they have to be encoded
  using a (recursive) let-binding.

- List types are replaced by the `Nil` and `Cons($\cdot$, $\cdot$)`
  constructors. The encoding is explained in \Cref{typing::structures::listes}.

Nix-light's grammar is given in
\Cref{nix-light::grammar,nix-light::grammar::values}.
The construct `<$\hat{t}$>` (defining the types that appears in a typecase) is
a non-recursive version of `<t>` (so the typecase is in reallity more somethifg
like a "kind-case" which just checks for the head constuctor). The type
`Any$\vee \nabla$` represents an optional field (the reason for this notation
is explained in \Cref{typing::structures::records}).

\begin{figure}
  \small
  \begin{lstlisting}
<expr> ::= <ident> | <constant>
  | <expr>.<expr> | <expr>.<expr> or <expr>
  | λ <pattern>.<expr> | <expr> <expr>
  | let <var-pattern> = <expr>; $\cdots{}$; <var-pattern> = <expr>; in <expr>
  | Cons (<expr>, <expr>)
  | { <ident> = <expr>; ...; <ident> = <expr> }
  | (<ident> = <expr> $\in$ <$\hat{t}$>) ? <expr> : <expr>
  | <operator>
  | <expr>:<τ>

<constant> ::= <string> | <int> | <bool> | Nil

<operator> ::=
  | <expr> <infix-op> <expr>

<infix-op> ::= + | - | * | / | // | ++ | $\cdots$

<pattern> ::= <record-pattern> | <record-pattern>@<ident>
  | <var-pattern>

<record-pattern> ::= <record-pattern>:τ
  | { <record-pattern-field>, $\cdots$, <record-pattern-field> }
  | { <record-pattern-field>, $\cdots$, <record-pattern-field>, … }

<record-pattern-field> ::= <var-pattern> | <var-pattern> ? <constant>

<var-pattern> ::= <ident> | <ident>:<τ>

<basetype> ::= Bool | Int | String | Any | Empty

<t> ::= <constant> | <basetype>
  | <t> $\vee$ <t> | <t> $\wedge$ <t> | $\lnot$ <t>
  | <t> $\rightarrow$ <t>
  | Cons(<t>, <t>) | let <ident> = <t>; $\cdots$; <ident> = <t> in <t>
  | { <ident> = <t>; $\cdots$; <ident> = <t>; _ = <t> }

<τ> ::= <constant> | <basetype> | <t> | ?
  | <τ> $\vee$ <τ> | <τ> $\wedge$ <τ>
  | <τ> $\rightarrow$ <τ>
  | Cons(<τ>, <τ>) | let <ident> = <τ>; $\cdots$; <ident> = <τ> in <τ>
  | { <ident> = <τ>; $\cdots$; <ident> = <τ>; _ = <τ> }

<$\hat{t}$> ::= <constant> | <basetype>
  | <$\hat{t}$> $\vee$ <$\hat{t}$> | <$\hat{t}$> $\wedge$ <$\hat{t}$> | $\lnot$ <$\hat{t}$>
  | Empty $\rightarrow$ Any
  | Cons(Any, Any)
  | { <ident> = Any; $\cdots$; <ident> = Any; _ = Any$\vee \nabla$ }
  \end{lstlisting}
  \caption{Nix-light grammar for expressions\label{nix-light::grammar}}
\end{figure}

\begin{figure}
  \begin{lstlisting}
<value> ::=
  | <constant>
  | Cons(<value>, <value>)
  | { <ident> = <value>; $\cdots$; <ident> = <value>; }
  | λ<pattern>.<expr>
  \end{lstlisting}
  \caption{Nix-light grammar for values\label{nix-light::grammar::values}}
\end{figure}

#### Semantic

##### Pattern-matching

The pattern-matching in Nix-light has a rather classical semantic for a lazy
language, with the simplification that as patterns are not recursive, the
argument is either non-evaluated at all, either evaluated in head normal form.

\newcommand{\var}{\mathcal{V}}
If `r` is a variable pattern − hence in the form `x` or `x:τ` where `x` is an
ident and `τ` a type − we define the variable represented by `r` (that we note
$\var(r)$) as $\var(x) = \var(x:τ) = x$.
We extend this defintion to a record pattern field `l` (of the form `r` or
`r?c` where `c` is a constant) by stating that $\var(r ? c) = \var(r)$.
In what follows, `l` denotes a record-pattern field of the form `r` or `r?c`
(where `c` is a constant).

For a pattern `p` and a value `v` (resp. an expression `e`), we note
$\sfrac{p}{v}$ the substitution generated by the matching of `v` (resp. `e`)
against `p`.
It is defined in \Cref{nix-light::pattern-matching}.

\begin{figure}
  \begin{align*}
    \sfrac{x}{e}    &= x := e \\
    \sfrac{p:τ}{e}  &= \sfrac{p}{e} \\
    \sfrac{q@x}{v}  &= x := v; \sfrac{q}{v} \\
    \sfrac{\{..\}}{\{\cdots\}} &= \varnothing\\
    \sfrac{\{\}}{\{\}} &= \varnothing \\
    \sfrac{\{ l, \seq{l_i,}{i \in I}\}}{\{ x = e; \seq{x_j = e_j;}{j \in J} \}}
      &= \sfrac{l}{e};
        \sfrac{\{ \seq{l_i,}{i \in I}\}}{\{ \seq{x_j = e_j;}{j \in J}\}}
        \quad\text{ if } x = \var(l) \\
    \sfrac{\{ l, \seq{l_i,}{i \in I}, l_m, .. \}}{\{ x = e; \seq{x_j = e_j;}{j \in J}\}}
      &= \sfrac{l}{e};
        \sfrac{\{ \seq{l_i,}{i \in I}, .. \}}{\{ \seq{x_j = e_j;}{j \in J}\}}
        \quad\text{ if } x = \var(l) \\
    \sfrac{\{ r ? c, \seq{l_i,}{i \in I} \}}{\{ \seq{x_j = e_j;}{j \in J} \}}
      &= \sfrac{r}{c};
        \sfrac{\{ \seq{l_i,}{i \in I} \}}{\{ \seq{x_j = e_j;}{j \in J} \}}
        \quad\text{ if } \forall j \in J, x_j \neq \var(r) \\
    \sfrac{\{ r ? c, \seq{l_i,}{i \in I}, .. \}}{\{ \seq{x_j = e_j;}{j \in J} \}}
      &= \sfrac{r}{c};
        \sfrac{\{ \seq{l_i,}{i \in I}, .. \}}{\{ \seq{x_j = e_j;}{j \in J} \}}
        \quad\text{ if } \forall j \in J, x_j \neq \var(r) \\
  \end{align*}
  \caption{Semantic of the pattern-matching in Nix-light\label{nix-light::pattern-matching}}
\end{figure}

##### Operational semantic

The full semantic is given at the \Cref{nix-light::semantics}.

The reduction rules should be self-explanatory.
The only worth mentioning are tho two rules for the typecase, which involve a
typing judgement (and thus make the semantics typing dependent). This typing
judgement is however very simple at it simply checks the toplevel constructor
of the given value. Its definition is given in annex at the
\Cref{nix-light::typecase-typing}.
<!--- TODO: Find a way to express the restriction that record fields need to be
distincts --->

\input{nix-light/semantics}
