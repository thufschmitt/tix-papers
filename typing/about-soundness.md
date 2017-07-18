The definition of soundness in the presence of gradual types is usually the
soundness of an intermediate language in which explicit casts have been added
in place of the gradual type.

This however only makes sense as far as the gradually typed language is
compiled to something else.
However in our case, we did not want to do so (for backward compatibility
reasons with the original language), so stating such a property wouldn't make
sense.

The only notion of safety that we may state is that the language is safe (in
the classical sense of "every well-typed expression either reduces to a value
of the same type either infinitely reduces") as far as the gradual type isn't
involved, or more clearly stated:

> If a closed expression `e` can be checked to be well-typed of type `τ` and
> the gradual type `?` does never appear in the typing derivation of
> $\tcheck e:τ$, then either `e` reduces to a value `v` of type `τ`, either
> any sequence of reductions starting from `e` is infinite.

Even this property however is hard to prove.
The main difficulty is that the union types don't behave well at all with
call-by-name (although they do with lazyness), and the property of type
preservation doesn't hold at all.
For example, the expression `(λx.[x x]) e` can be checked to be of type
`[Int Int] | [Bool Bool]` if `e` is of type `Int | Bool`.
However, it reduces to `[e e]` which can only be checked to be of type
`[Int|Bool Int|Bool]` (which is less precise).
A lazy semantic would most probably solve this, but we unfortunately didn't
have time to come up with a proof of this.
