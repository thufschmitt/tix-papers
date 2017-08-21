#### Compilation

A Nix program `p` is compiled to a Nix-light program `(|p|)` according to the
rules of \Cref{nix-light::compilation} (except for the type annotations).
The type annotations are exactly the same in Nix and Nix-light, and the
compilation is just an identity mapping, except for the lists types which
differ. The syntax of regular expression lists as well as their compilation to
a combination of `Cons` and `Nil` types is covered by @Fri04 (the basic idea of
this compilation is reminded in \Cref{typing::structures::listes}).

Both languages are quite similar, hence most transformations are simply a
transposition of a given structure to the same structure in the other language.

The if construct is compiled to a typecase, with two separate rules
depending on the form of the form of the condition:

- The general case is to compile `if e0 then e1 else e2` to
  `(x = (e0 : Bool) tin true) ? e1 : e2` with `x` a fresh variable.
  The semantics of the target expression is defined on a larger domain than the
  one we expect from the source one, as it is defined even if `e0` evaluates to
  something other than a boolean. However, the type annotation `e0 : Bool`
  enforces that (if the expression is well-typed) `e0` evaluates to a boolean.
  Hence, the semantic coincides for well-typed terms.
  <!-- TODO: if e1 | e2 then ... -->

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
    evaluate to the same value `z` or not.
    It is then impossible to compile this exactly.

    The solution we use here is to always assume that they are different.
    If the type-checker confirms this, then everything is fine.
    Otherwise, the program will not correctly typecheck, so while this is too
    restrictive, we at least do not introduce an incorrect behaviour for well
    typed programs.

\newcommand{\flatten}{\operatorname{flatten}}
We define a function $\flatten$ to transform a non recursive record
`{ ap1 = e1; ...; apn = en }` into a record without the nested records syntax
(which we call a "flattened" record definition).
Its definition is given in \Cref{compilation::flatten}.

The definition is quite contrived but is simply the generalisation of the
idea that we want to transform `{ x.y = 1; x.z = 2; }` into
`{ x = { y = 1; z = 2 }; }`

\newcommand{\derec}{\operatorname{derec}}
To translate a recursive record definition, we first flatten it using the
$\flatten$ function defined above.
A flattened recursive record definition `rec { x1 = e1; ...; xn = en; }` is
then translated to a non-recursive one by the $\derec$ function defined as
\begin{displaymath}
  \derec\left(\text{ rec }\left\{ \seq{x_i = e_i }{i \in I} \right\}\right) =
    \text{let } \seq{x_i = e_i}{i \in I} \text{ in }
    \left\{ \seq{x_i = x_i}{i \in I} \right\}
\end{displaymath}

The source Nix program is preprocessed before this compilation to make the
compilation of conditionals more precise: we want for example the expression
`if (isInt x | isBool x) then x else false` (where `|` is the boolean
disjunction) to be given the type `Int OR Bool`, but the compilation process
will compile it as `(y = (isInt x | isBool x) tin true) ? x : false`, so we
will not be able to perform occurrence typing on `x`.
A simple pre-processing however is sufficient here, as this expression is
semantically equivalent to
`if isInt x then x else (if isBool x then x else false)`, and the latter will
be compiled to the Nix-light expression
`(x = x tin Int) ? x : ((x = x tin Bool) ? x : false)`, on which we will be
able to perform occurrence typing for `x`.
This pre-processing can be done for any boolean combination of expressions in
the `if` clause thanks to the rewriting rules of
\Cref{nix-light::preprocessing}.
