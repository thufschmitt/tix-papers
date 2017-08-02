#### Compilation

The program is compiled according to the rules of the
\Cref{nix-light::compilation} (except for the type annotations whose
compilation is covered by the \Cref{typing::structures::listes}).

Both languages are quite similar, hence most transformations are simply a
transposition of a given structure to the same structure in the other language.

The if construct construct is compiled to a typecase, with two separate rules
depending on the form of the form of the condition:

- The general case is to compile `if e0 then e1 else e2` to `(x = (e0 : Bool)
  tin true ? e1 : e2)`.
  The semantic of the target expression is slightly larger than the one we
  expect from the source one, as it is defined even if `e0` evaluates to
  something other than a boolean. However, the type annotation `e0 : Bool`
  enforces that (if the expression is well-typed) `e0` evaluates to a boolean.
  Hence, the semantic coincides for well-typed terms.

- If `e0` is of the form `isT x` where `isT` is a discriminant of the type `t`
  (i.e. a builtin function that returns `true` if its argument is of type `t`
  and `false` otherwise), then the expression will be compiled to
  `(x = x tin t) ? e1 : e2`.
  It is easy to check that this has the same semantic as the expression that
  would have been obtained without this special case.

The compilation of records is slightly complex, for two reasons:

- The first one is that Nix has a special construct for recursive records,
  whereas Nix-light doesn't, which means this construct has to be encoded (using
  a let-binding as they are recursive).

- The second one is that Nix has a shortcut for writing nested records.
  For example, `{ x.y = 1; x.z = 2; }` is equivalent to
  `{ x = { y = 1; z = 2; }; }`.
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
  restrictive, we at least don't introduce an incorrect behaviour for well
  typed programs.

\input{nix-light/compilation-rules}
