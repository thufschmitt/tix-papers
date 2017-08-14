The type-system we designed satisfies our practical requirements. Is is
powerful and flexible enough to adapt itself to the flexibility of the Nix
language, and at the same time can give useful results with a reasonable amount
of annotations.

On a more theoretical aspects, this has been a successful experiment in mixing
together several typechecking techniques. We have been pleased to see that most
of them can be used together without any major limitation (except of course the
necessary abandon of polymorphism because of the gradual typing). In
particular, the development of the bidirectional typing for set-theoretic types
improves their expressiveness and reduces the amount of requested annotations,
which is a huge gain.
We hope that this work will also prove the usability of these techniques in a
real-world setup.

As explained in the synthesis sheet, the next steps are on one hand to
continue the work on the implementation in order to make it more usable in an
enterprise context and on the other hand to develop the type-system further, in
particular to add polymorphism to it.
