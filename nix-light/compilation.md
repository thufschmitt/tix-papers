#### Compilation

A Nix program `p` is compiled to a Nix-light program `(|p|)` according to the
rules of the \Cref{nix-light::compilation} (except for the type annotations
whose compilation is covered in \Cref{typing::structures::listes}).

Both languages are quite similar, hence most transformations are simply a
transposition of a given structure to the same structure in the other language.

The if construct construct is compiled to a typecase, with two separate rules
depending on the form of the form of the condition:

- The general case is to compile `if e0 then e1 else e2` to
  `(x = (e0 : Bool) tin true) ? e1 : e2`.
  The semantics of the target expression is defined on a larger domain than the
  one we expect from the source one, as it is defined even if `e0` evaluates to
  something other than a boolean. However, the type annotation `e0 : Bool`
  enforces that (if the expression is well-typed) `e0` evaluates to a boolean.
  Hence, the semantic coincides for well-typed terms.

- If `e0` is of the form `isT x` where `isT` is a discriminant of the type `t`
  (i.e., a builtin function that returns `true` if its argument is of type `t`
  and `false` otherwise), then the expression will be compiled to
  `(x = x tin t) ? e1 : e2`.
  It is easy to check that this has the same semantics as the expression that
  would have been obtained without this special case.

The compilation of records is slightly complex, for two reasons:

- The first one is that Nix has a special construct for recursive records,
  whereas Nix-light does not, which means this construct has to be encoded
  (using a let-binding as they are recursive).

- The second is the Nix shortcut for writing nested records (
  `{ x.y = 1; x.z = 2; }` which is equivalent to `{ x = { y = 1; z = 2; }; }`).
  As this syntax has been removed in Nix-light, we have to transform it into
  the explicit form.

    The real problem arises when this syntax is mixed with dynamic labels,
    because it is then no longer possible to statically determine the shape of
    the record.
    For example, the record `{ DOLLAR{e1}.x = 1; DOLLAR{e2}.y = 2; }` may be
    either of the form `{ z = { x = 1; y = 2; }; }` or
    `{ z1 = { x = 1; }; z2 = { x = 2; }; }` depending on whether `e1` and `e2`
    evaluate to the same value or not.
    It is then impossible to compile this exactly.

    The solution we use here is to always assume that they are different.
    If the type-checker confirms this, then everything is fine.
    Otherwise, the program won't correctly typecheck, so while this is too
    restrictive, we at least do not introduce an incorrect behaviour for well
    typed programs.

\newcommand{\flatten}{\operatorname{flatten}}
We define a function $\flatten$ to transform a non recursive record
`{ ap1 = e1; ...; apn = en }` into a record without the nested records syntax
(which we call a "flattened" record definition).
Its definition is given in the \Cref{compilation::flatten}.

The definition is quite contrived but is simply the generalisation of the
idea that we want to transform `{ x.y = 1; x.z = 2; }` into
`{ x = { y = 1; z = 2 }; }`

\newcommand{\derec}{\operatorname{derec}}
To translate a recursive record definition, we first flatten it using the
$\flatten$ function defined above.
A flattened recursive record definition `rec { x1 = e1; ...; xn = en; }` is
then translated to a non-recursive one by the $\derec$ function defined in
\Cref{compilation::derec}

\input{nix-light/compilation-rules}
