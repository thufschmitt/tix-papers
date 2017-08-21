Typing anonymous records is often difficult.
Nix (and as consequence Nix-light) pushes this to its limits by making them
insanely flexible.
It is thus impossible to type the records with enough accuracy to cover every
usage case, so one important thing to know is how they are used in practice to
understand in which direction to go.

In Nix, there are two main uses of records

- Static records: This is the classical use of records as they are used in
  statically typed languages: some predefined fields contain various
  informations about a structure.
  In this setting, the labels are all statically defined as expressions whose
  type is type is a singleton string^[For some shameful reasons, it sometimes
  happens that their type is a finite union of singleton strings, but the rules
  are easy to extend to this use-case] and the different fields are likely to
  contain values of different types.

- Dynamic maps: In this case, the record is used to store arbitrary key-value
  associations (where the key is a string).
  The labels here may be defined as arbitrary expressions, however most of the
  time the values will all be of the same type.

@Cas15 presents a powerful formalism to handle them in absence of dynamic
labels.

We use here an extension of this formalism to allow dynamic labels, which lets
us nicely handle both use-case. (we also slightly modify it to meet the
requirements of lazy evaluation and gradual typing).
\newcommand{\undefr}{\nabla}
We assume the existence of a distinguished constant type `$\undefr$` which
represents an absent field in a record type.

`{ $x_1$ = $τ_1$; $\cdots$; $x_n$ = $τ_n$; _ = $τ$ }` is the type of a record
whose fields `$x_1$`, $\cdots$, `$x_n$` are respectively of type `$τ_1$`,
$\cdots$, `$τ_n$` and whose other fields are of type `$τ$` (all these fields
being possibly equal to or containing the special `$\undefr$` field meaning
that they are not defined in the record).
We write `{ $x_1$ = $τ_1$; $\cdots$; $x_n$ = $τ_n$ }` as a shorthand for
`{ $x_1$ = $τ_1$; $\cdots$; $x_n$ = $τ_n$; _ = $\undefr$ }` and
`{ $x_1$ = $τ_1$; $\cdots$; $x_n$ = $τ_n$; .. }` for
`{ $x_1$ = $τ_1$; $\cdots$; $x_n$ = $τ_n$; _ = Any $\vee$ $\undefr$ }`.
The former corresponds to a *closed* record type (i.e., a record of this type
will have *exactly* the listed fields with the given types) while the latter
corresponds to an *open* record type (i.e., a record of this type will have *at
least* the listed fields with the given types).

An optional field of type `τ` is a field of type `$τ \vee \undefr$` (i.e., a
field which may be either of type `τ` or undefined).
We write `x =? τ` as a shorthand for `x = $τ \vee \undefr$`.

In this formalism, $t(x)$ is the type associated to $x$ in the record type $t$.

Record types are (as shown by @Cas15) unions of atomic record types (types of
the form `{ $s_1$ = $τ_1$; ...; $s_n$ = $τ_n$; _ = τ }`).
All the operations that we define on atomic record types may be extended to
those unions.
We also extend them to gradual types by identifying `?` and `{ _ = ? }`.

The typing of records is done in three steps: we first define the typing of
literal records, and we then define the typing of merge operation to type more
complex records. Finally, we define the typing of field access.

The rules are given in \Cref{typing::records}.
In these rules, the $s_i$ denote singleton string types.

#### Literal records

We have two rules for the literal records, corresponding to the two use-cases
of records:

- The *RFinite* rule handles the case of static records.
  It applies when the labels have singleton types  and corresponds to the
  classical typing rule for records in absence of dynamic labels.

- The *IRInfinite* and *CRInfinite* rules handle the case of dynamic maps. In
    this case, we do not try to track all the elements of the record, we just
    give it the type we would assign e.g. to a `Map` in OCaml, which is the
    type of a record whose elements are all of the same type and are all
    optional. We take $\bigvee\limits_{i\in I} σ_i$ as the type of the elements
    as it is the least common subtype of the elements we introduced.

    In this case, we decided to give up safety for more flexibility: as a
    literal record in Nix must have all its labels different^[This is unlike
    most other dynamic programming languages such as Perl or Python. In those
    languages, a field may be defined twice in a literal record, in which case
    the last declaration has precedence over the others], a really safe version
    of the rules would forbid the definition of any non-trivial record with a
    dynamic label (a definition such as `{ e = 1; e' = 2; }` could not be
    accepted as in the general case it is not possible to prove that `e` and
    `e'` will not evaluate to the same value).  We allow this in our system −
    although the implementation may emit a warning (depending on the
    configuration).

#### Concatenation of records

We define the concatenation $r_1 + r_2$ of two record types:

If $τ_1$ and $τ_2$ are atomic record types then $τ_1 + τ_2$ is defined by:

\begin{displaymath}
  (τ_1 + τ_2)(x) =
  \begin{cases}
    τ_1(x) &\quad \text{if } τ_1(x) \wedge \undefr \subtype \Empty \\
    (τ_1(x)\backslash \undefr) \vee τ_2(x) &\quad \text{otherwise}
  \end{cases}
\end{displaymath}

There are in fact three possible cases in this formula:

- If $τ_1(x)$ does not contain $\undefr$, the field is defined in
  $τ_1$, and we take its type $τ_1(x)$ for $(τ_1 + τ_2)(x)$,

- if $τ_1(x)$ is  $\undefr$, then the field is undefined in $τ_1$ and
  the type of $(τ_1 + τ_2)(x)$ is the type of $τ_2(x)$,

- else, the field may be defined and $τ_1(x) = τ_x \vee \undefr$ for some
  type $τ_x$. The type of the result may be $τ_x$ or $τ_2(x)$.

This definition enjoys a natural extension to arbitrary record types (i.e.,
subtypes of `{..}`), as shown by @Cas15: a record type can be expressed as an
union of atomic record types, and we extends the $+$ operator by stating that
\begin{displaymath}
  \left(\bigvee\limits_{i \in I} τ_i\right) + \left(\bigvee\limits_{j \in J} τ_j\right) =
    \bigvee\limits_{i \in I,j \in J} (τ_i + τ_j)
\end{displaymath}

This effectively allows us to type the union of expressions whose types are
arbitrary record types.

#### Field access

We now define the typing of expressions of the form `e1.e2` or `e1.e2 or e3`
(i.e., the access of a field of a record).

\newcommand{\defr}{\operatorname{def}}
For a record type $τ = \{ x_1 = τ_1; \cdots; x_n = τ_n; \_ = τ_0 \}$, we
refer to $τ_0$ by $\defr(τ)$.

We have two sets of rules depending on whether a default value is provided or
not.

For the case where a default value is provided, we distinguish the case where
the name of the accessed field is statically known from the case where it is
not.
Making such a distinction does not really make sense if no default value is
provided, as when the accessed field is unknown there is no way to ensure that
the accessed field indeed exists. We could also here accept some unsoundness
and allow this type of access like we do for literal records, but this pattern
seems less used in practice so we prefer not to add unnecessary unsoundness.

When the name of the accessed field is unknown, the return type is the union of
all the types contained in the record and of the type of the default value,
minus the $\undefr$ type as if the field is undefined then the default value is
returned instead.

#### Record patterns

We also extend the language of patterns to include the record-related ones from
the rules of \Cref{nix-light::grammar}.
We thus also extend the $\accept{p}$ and $\tmatch{τ}{p}$ operators.
For the definition of $\accept{p}$, we need to propagate the type informations
down the pattern because of the rule stating that a non-annotated variable is
given the type `?`.
Indeed, having a general rule $\accept{p:τ} = \accept{p} \wedge τ$ would not
fit our needs because for example, the accepted type for the pattern
`{ x } : { x = Int }` would be `{ x = ? AND Int }` while we want it to be
`{ x = Int }`. So we need a rule implying that the accepting type of
`{ x } : { x = Int }` is the accepted type of `{ x : Int }`. This is what the
rules of \Cref{typing::records::accept} state.
The extension of the $\tmatch{τ}{p}$ operator is given in \Cref{typing::records::tmatch}.

\input{typing/record-typing-rules.tex}
