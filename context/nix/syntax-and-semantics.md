The language we study is not the whole Nix language, but a simplified version
of it (ommiting some minor features without importance for the type system and
some other that will be dicussed in \Cref{implem::extensions}), to which we
add type annotations. In this document, every reference to Nix is intended to
refer to this variation of the language.

The full syntax is given in appendix in the \Cref{nix::syntax,nix::types}.
Its semantic is informally described below (the formal semantic is given in
\Cref{sec:nix-light}).

This language is lazily-evaluated a lambda calculus, with some additions,
namely:

- Constants, let-bindings (always recursive), some (hardcoded) infix operators
  and if construct's.

- Lists, defined by the `[<expr> $\cdots$ <expr>]` syntax.

- Records, defined by the `{ <record-field>; ... <record-field>; }` syntax.
  The labels of record fields may be dynamically defined as the result of
  arbitrary expressions (the only limitation being that those expressions must
  evaluate to string values).
  In any case, all the labels have to be distinct in order for the record to be
  well-defined.
  The records may be recursively defined (using the `rec` keyword), in which
  case, fields may depend one from another.
  For example, the expression `rec { x = 1; y = x; }` is equivalent to `{ x =
  1; y = 1; }`.

- A syntax for accessing record fields, of the form `<expr>.<access-path>`.
    Like for the definition of record litterals, the field names may be arbitrary
    expressions.
    If the field is not present in the record then a runtime error is thrown,
    unless a default value is provided (using the
    `<expr>.<access-path> or <expr>`) syntax.

    For example, `{ x = { y = 1; }; }.x.y` evaluates as `1`,
    `{ x = { y = 1; }; }.x.z or 2` evaluates as `2` and `{ x = { y = 2; }; }.y`
    raises an error.

- Lambda-abstractions can be defined with patterns.
    Patterns only exists for records and are of the form
    `{ <pattern-field>, $\cdots$, <pattern-field> }`
    or
    `{ <pattern-field>, $\cdots$, <pattern-field>, "..." }`, with the
    `<pattern-field>` construct of the form `<ident>` or `<ident> ? <expr>`
    (which specifies a default value in case the field is absent).

    Contrary to most languages where the capture variable may be different
    from the name of the field (for example in OCaml, a pattern matching e
    record would be of the form `{ x = fieldname1; y = fieldname2; }` and the
    pattern `{ x; y }` is nothing but syntactic sugar for `{ x = x; y = y }`),
    Nix requires the name of the capture variable to be the same as the name of
    the field.

- Type annotations (absent in the actual language but added for this work).
    These annotations have been added as they are required by the typechecker.
    There are two productions for types: the concrete types (noted `<t>`) and
    the abstract types (noted `<τ>`). A distinction between both is mandatory
    because the negation of a gradual type is not defined.
    The meaning of the types will be presented in \Cref{sec:typing}.

    The constructions `<R>` and `<ρ>` represents type regular exepressions
    which will be presented in \Cref{typing::structures::listes}.

In addition to these syntactic constructions, a lot of the expressiveness of
the language resides in some predefined functions.
For example, some functions do some advanced operations on records, like the
`attNames` function, which when applied to a record returns the list of the
labels of this record (as strings).
Another important class of functions is the set of functions that discriminate
over a type, that is functions such as `isInt`, `isString`, `isBool`, and so on,
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
has a particular form, that needs a particular treatment).
