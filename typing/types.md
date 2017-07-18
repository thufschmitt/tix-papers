### Presentation of the types

The types are inspired by the set-theoretic types used in the CDuce language
and described by @Fri04.
Their syntax is given alongside Nix-light's grammar in
figure \pref{nix-light::grammar}.

We distinguish two type productions: the static types (noted by roman letters:
$t, s, \ldots$) and the gradual types (in greek letters: $τ, σ, \ldots$).

Those productions essentially corresponds to the types presented by @CL17,
with as addition the record and list types which are similar to the ones
presented in [@Fri04].

### Subtyping

Like in [@CL17], the subtyping relation $\subtype$ on static types is extended
into a relation $\subtypeG$ on gradual types.
However, the subtyping relation isn't the same. Indeed, the relation used in
[@CL17] − which is the relation established in [@Fri04] − is based on an
interpretation of types as sets of values, and as it is raises some safety
issues on a lazy semantic.
The reason for this is that the interpretation supposes fully evaluated values,
while a lazy language manipulates possibly non-evaluated expressions, whose
evaluation may never finish if forced. In particular, the `Empty` types behaves
differently: there exists no value of this type (so its interpretation as set
is naturally the empty set), but there may be expressions of this type, which
themselves may appear inside values in a lazy setting.
For example, the type `{ x = Empty }` would be inhabited in a strict semantic
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
