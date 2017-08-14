### Presentation of the types

The types are inspired by the set-theoretic types used in the CDuce language
and described by @Fri04.
Their syntax is given alongside Nix-light's grammar in
\Cref{nix-light::grammar}.

We distinguish two type productions: the static types (noted by roman letters:
$t, s, \ldots$) and the gradual types (in greek letters: $τ, σ, \ldots$).
These productions essentially corresponds to the types presented by @CL17,
with as addition the record and list types which are similar to the ones
presented in [@Fri04].

A type `t` is interpreted as the set of all the values of type `t`.
The union ($\vee$), intersection ($\wedge$) and difference ($\backslash$)
connectives corresponds respectively to the set-theoretic union ($\cup$),
intersection ($\cap$) and difference ($\backslash$). So an expression of type
`t1 OR t2` is an expression that can be either of type `t1` or of type `t2`; an
expression of type `t1 AND t2` is an expression that is both of type `t1` and
of type `t2` and an expression of type `t1 \ t2` is an expression that is of
type `t1` but not of type `t2`.

Following the work of @Fri04, the types also contain singleton types (i.e., for
every constant `c`, there exists a type `c` such that `c` is the only value of
type `c`).
For example, the type `Bool` is not a builtin type, but is the type `true OR
false` (where the types `true` and `false` are the singleton types associated
to the constants `true` and `false`).

### Subtyping

Like in [@CL17], the subtyping relation $\subtype$ on static types is extended
into a relation $\subtypeG$ on gradual types.
However, the subtyping relation is not the same. Indeed, the relation used in
[@CL17] − which is the relation established in [@Fri04] − is based on an
interpretation of types as sets of values, and used directly cause some safety
problems on a lazy semantic.
The reason for this is that the interpretation supposes fully evaluated values,
while a lazy language manipulates possibly non-evaluated expressions, whose
evaluation may never finish if forced. In particular, the `Empty` types behaves
differently: there exists no value of this type (so its interpretation as set
is naturally the empty set), but there may be expressions of this type, which
themselves may appear inside values in a lazy setting.
For example, the type `{ x = Empty }` would be not inhabited in a strict semantic
(so it would itself be a subtype of every other type, the same way as `Empty`
itself), whereas in a lazy semantic such as the one of Nix-light, it is
inhabited for example by `{ x = let y = y in y; }`.

It is possible to modify this interpretation to take this difference into
account, by adding at some places a special constant (noted $\bot$) to the
interpretation of the types.
For example, let's assume for a moment that our types contains a product
constructor $\cdot \times \cdot$.
The interpretation $\llbracket A \times B \rrbracket$ of the type $A \times B$
is $\llbracket A \rrbracket \times \llbracket B \rrbracket$ in the
interpretation of @Fri04.  Here, it becomes $\left(\llbracket A \rrbracket \cup
\bot \right) \times \left(\llbracket B \rrbracket \cup \bot \right)$.

This new interpretation (which is described by @CP17) entails a new subtyping
algorithm that fits the requirements of a lazy semantic.
