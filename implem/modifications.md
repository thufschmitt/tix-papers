We here presented a fixed type-system. However several rules may be modified
depending on the exact notion of safety we want to achieve.

In particular, we may decide to get rid of the implicit gradual typing (the
fact that an unannotated variable in a pattern is given the type `?`), and
decide that an unannotated variable will be typed with the type `Any`.
This forces the programmer to explicitly annotate the places where he wants the
gradual typing to occur (in fact this forces the programmer to annotate almost
every variable as the type-system does no unification).

We could even go further by locally disabling the gradual typing. In this case,
the gradual type becomes a new distinguished type constant. We still need to
provide a pair of explicit cast functions (a function `fromGrad : ? -> Empty`
and a function `toGrad : Any -> ?`, both implemented as the identity) in order
to be able to use gradual values from the outside world.
