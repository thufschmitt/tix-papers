The language we study isn't exactly the Nix language, but a simplified version
of it (ommiting some minor features without importance for the type system and
some other that will be dicussed in part \ref{implem::extensions}), to which we
add some type annotations.  In all this document, every reference to Nix points
to this language.

The full syntax is given in the figure \pref{nix::syntax}.
Its semantic is informally described below (a complete semantic is given in
Section \ref{sec:nix-light}).

This language is a lambda calculus, with some additions, namely :

- Constants, let-bindings (always recursive), some (hardcoded) infix operators
  and if construct's.

- Lists, defined by the `[<expr> $\cdots$ <expr>]` syntax.

- Records, defined by the `{ <record-field>; ... <record-field>; }` syntax.
  The labels of record fields may be dynamically defined as the result of
  arbitrary expressions (the only limitation being that those expressions must
  evaluate to string values).
  The records may be recursively defined (using the `rec` keyword), in which
  case, fields may depend one from another.
  For example, the expression `rec { x = 1; y = x; }` is equivalent to `{ x =
  1; y = 1; }`.

- A syntax for accessing record fields, of the form `<expr>.<access-path>`.
    Like for the definition of record litterals, the field names may be arbitrary
    expressions.
    If the field isn't present in the record then a runtime error is thrown,
    unless a default value is provided (using the
    `<expr>.<access-path> or <expr>`) syntax.

    For example, `{ x = { y = 1; }; }.x.y` evaluates as `1`,
    `{ x = { y = 1; }; }.x.z or 2` evaluates as `2` and `{ x = { y = 2; }; }.y`
    raises an error.

- Lambda-abstractions can be defined with patterns.
    Those patterns only exists for records and are of the form
    `{ <pattern-field>, $\cdots$, <pattern-field> }`
    or
    `{ <pattern-field>, $\cdots$, <pattern-field>, "..." }`, with the
    `<pattern-field>` construct of the form `<ident>` or `<ident> ? <expr>`
    (which specifies a default value in case the field is absent).

    In contrary to most languages where the capture variable may be different
    from the name of the field (for example in OCaml, a pattern matching e
    record would be of the form `{ x = fieldname1; y = fieldname2; }` and the
    pattern `{ x; y }` is nothing but syntactic sugar for `{ x = x; y = y }`),
    Nix requires the name of the capture variable to be the same as the name of
    the field.

In addition to those syntactic constructions, a lot of the expressivity of the
language is hidden behind some predefined functions.
For example, some functions do some advanced operations on records, like the
`attNames` function, which when applied to a record returns the list of the
labels of this record (as strings).
Another important class of functions is the set of functions that discriminate
over a type, i.e. functions such as `isInt`, `isString`, `isBool`, and so on,
which return `true` if their argument is an integer (resp. a string or a
boolean), and `false` otherwise.
When used with a if construct, those functions allow an expression to have a
different behaviour depending on the type of an expression. The type system
must be able to express this feature.

For example, we want to give the type `Int` to an expression such as

\begin{lstlisting}
if isInt x then x else 1
\end{lstlisting}

The type-system thus has to be aware of the fact that, in the `then` branch, the
`x` variable has the type `Int` (and in particular recognize that the condition
has a particular form, that needs a particular treatement).

\begin{figure}
  \small
  \begin{lstlisting}
<expr> ::=
  <ident> | <constant>
  | $\lambda$ <pattern>.<expr> | <expr> <expr>
  | let <var-pattern> = <expr>; $\cdots$; <var-pattern> = <expr>; in <expr>
  | [ <expr> $\cdots$ <expr> ]
  | { <record-field>; $\cdots$; <record-field>; }
  | rec { <record-field>; $\cdots$; <record-field>; }
  | if <expr> then <expr> else <expr>
  | <expr>.<acces-path>
  | <expr>.<acces-path> or <expr>
  | <expr> <infix-op> <expr>
  | <expr> : <τ>

<constant> ::= <string> | <integer> | <boolean> | <paths>

<record-field> ::= inherit <ident> $\cdots$ <ident>
  | inherit (<expr>) <ident> <ident>
  | <access-path> = <expr> | <access-path> : <τ> = <expr>

<pattern> ::= <record-pattern> | <record-pattern>@<ident>
  | <var-pattern>

<var-pattern> ::= <ident> | <ident> : <τ>

<record-pattern> ::=
  | { <record-pattern-field>, $\cdots$, <record-pattern-field> }
  | { <record-pattern-field>, $\cdots$, <record-pattern-field>, ... }

<record-pattern-field> ::= <var-pattern> | <var-pattern> ? <expr>

<access-path> ::= <access-path-item>. $\cdots$ . <access-path-item>

<access-path-item> ::= <ident> | { <expr> }

<infix-op> ::= + | - | * | / | // | ++ | $\cdots$

<basetype> ::= Bool | Int | String | Any | Empty

<t> ::= <constant> | <t> $\rightarrow$ <t>
  | <t> $\vee$ <t> | <t> $\wedge$ <t> | $\lnot$ <t>
  | [<R>]
  | { <ident> = <t>; $\cdots$; <ident> = <t>; _ = <t> }
  | <basetype>

<R> ::= <t> | <R>+ | <R>* | <R>?
  | <R> <R> | <R> ¦ <R>

<τ> ::= <t> | <τ> $\rightarrow$ <τ>
  | <τ> $\vee$ <τ> | <τ> $\wedge$ <τ>
  | [<ρ>] | [<ρ> ?? ]
  | { <ident> = <τ>; $\cdots$; <ident> = <τ>; _ = <τ> }
  | ?

<ρ> ::= <τ> | <ρ>+ | <ρ>* | <ρ>?
  | <ρ> <ρ> | <ρ> ¦ <ρ>
  \end{lstlisting}
  \caption{Syntax of the Nix language\label{nix::syntax}}
\end{figure}
