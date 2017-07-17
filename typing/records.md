Typing anonymous records is always a rather complicated task.
Nix (and as consequence Nix-light) pushes this to its limits by making them
insanely flexible.
It is thus impossible to type the records with enough accuracy to cover every
usage case, so one important thing to know is how they are used in practice to
understand in which direction to go.

In Nix, there are two main uses of records

- Static records: This is the classical use of records as they are used in
  statically typed languages: some predefined fields contain various
  informations about a structure.
  In this setting, the labels are all statically defined as litteral
  strings^[For some shameful reasons, it sometimes happens that those are
  defined as a finite union of literal strings, so the rules should also support
  this use-case] and the different fields are likely to contain values of
  different types.

- Dynamic maps: In this case, the record is used to store arbitrary key-value associations
  (where the key is a string).
  The labels here may be defined as arbitrary expressions, however most of the
  time the values will all be of the same type.

@Cas15 presents a powerful formalism to handle them in absence of dynamic
labels.

We use here an extension of this formalism to allow dynamic labels, which lets
us nicely handle both use-cases. (we also slightly modify it to meet the
requirements of lazy evaluation and gradual typing).
\newcommand{\undefr}{\nabla}
We assume the existence of a distinguished constant type `$\undefr$` which
represent an absent field in a record type.

We write `{ $x_1$ = $\τ_1$; $\cdots$; $x_n$ = $\τ_n$; }` as a shorthand for
`{ $x_1$ = $\τ_1$; $\cdots$; $x_n$ = $\τ_n$; _ = $\undefr$ }` and
`{ $x_1$ = $\τ_1$; $\cdots$; $x_n$ = $\τ_n$; ... }` for
`{ $x_1$ = $\τ_1$; $\cdots$; $x_n$ = $\τ_n$; _ = Any }`
An optional field of type `τ` is a field of type `$\τ \vee \undefr$`.
We write `x =? τ` as a shorthand for `x = $\τ \vee \undefr$`.

In this formalism, $t(x)$ is the type associated to $x$ in the record type $t$.

Record types are (as shown by @Cas15) unions of atomic record types.
All the operations that we define on atomic record types may be extended to
those unions.
We also extend them to gradual types by identifying `?` and `{ _ = ? }`.

The typing of records is done in three steps: we first define the typing of
unary records, and we then define the typing of merge operations (in particular
the `<>` operator) to type more complex records. Finally, we define the typing
of field access.

The rules are given in figure \pref{typing::records}.

#### Unary records

We have two rules for the unary records, corresponding to the two use-cases of
records:

- The *RFinite* rule handles the case of static records.
  Their type is just defined as the union of all possible record types.

- The *RInfinite* rule handles the case of dynamic maps. In this case, we don't
  try to track all the elements of the record, we just give it the type we
  would assign e.g. to a `Map` in OCaml.

#### Concatenation of records

We consider two distinct merge operations `+` and `<>`.
They differ in how they behave when a field may be defined on both sides.
Saying that the field $x$ may be defined in the record type $t$ means that
$t(x) \wedge \undefr \not\subtype \Empty$.

If $\τ_1$ and $\τ_2$ are atomic record types then $\τ_1 + \τ_2$ is defined by:

\begin{displaymath}
  (\τ_1 + \τ_2)(x) =
  \begin{cases}
    \τ_1(x) &\quad \text{if } \τ_1(x) \wedge \undefr \subtype \Empty \\
    (\τ_1(x)\backslash \undefr) \vee \τ_2(x) &\quad \text{otherwise}
  \end{cases}
\end{displaymath}

There are in fact three possible cases for this:

- If $\τ_1(x)$ does not contain $\undefr$, the field is always defined in
  $\τ_1$, and we take its type for $(\τ_1 + \τ_2)(x)$.

- If $\τ_1(x)$ is  $\undefr$, then the field is always undefined in $\τ_1$ and
  the type of $(\τ_1 + \τ_2)(x)$ is the type of $\τ_2(x)$.

- Else, the field may be defined and $\τ_1(x) = \τ_x \vee \undefr$ for some
  type $\τ_x$. The type of the result may be $\τ_x$

\newcommand{\orthmerge}{\diamond}
\newcommand{\domr}{\operatorname{dom}}
The $\diamond$ operator is defined as the restriction of `+` to cases where the
fields of both records do not overlap. More precisely,let
$\domr_\undefr(\cdot)$ be the operator which to each record type associates the
set of all the fields whose type do not contain $\undefr$ (this operator is
given by the interpretation of [@Cas15]). Then $\τ_1 \orthmerge \τ_2$ is
defined as $\τ_1 + \τ_2$ if and only if $\domr_\undefr(\τ_1) \cap
\domr_\undefr(\τ_2) = \varnothing$.

#### Field access

\newcommand{\defr}{\operatorname{def}}
For a record type $\τ = \{ x_1 = \τ_1; \cdots; x_n = \τ_n; \_ = \τ_0 \}$, we
refer to $\τ_0$ by $\defr(\τ)$.

We have two rules depending on whether a default value is provided or not.

For the case where a default value is provided, we distinguish the case where
the name of the accessed field is statically known from the case where it isn't.
Making such a distinction doesn't really make sense if no default value is
provided, as when the accessed field is unknown there is no way to ensure that
the accessed field indeed exists.

\input{typing/record-typing-rules.tex}
