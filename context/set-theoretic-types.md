The characteristics of the language enforce several restrictions on the
type-system. In particular :

- Because of the huge base of (untyped) existing code, the system needs to be
  flexible enough to accept as many expressions as possible, without
  sacrificing the security guaranties.

- It has to handle anonymous records with dynamic labels, as well as several
  operations on those records (adding or removing a field, merging records,
  etc..)

- Because of the predicates on types, the type-system must have union types, as
  well as being able to efficiently handle a typecase operation.

Several existing type-systems already try to satisfy those requirements.
The most famous one is probably the type-system of Typed Racket (@FH08), which
already implements at an industrial level most of what is needed in the context
of the Scheme language.

The approach we choose here is based of the works of Alain Frisch and Giuseppe
Castagna on set-theoretic types (@Fri04 and @Cas15), with extensions brought by
Kim Nguyễn (@phdkim) and Giuseppe Castagna and Victor Lanvin (@CL17).

This system is based on a set-theoretic interpretation of types as a sets of
values, which provides a natural interpretation for union, intersection or
difference (as the corresponding operations on the underlying sets).
This interpretation also provides a natural definition of a subtyping relation
which corresponds to the inclusion relation on the interpretations as sets.
Moreover, all those operations are decidable.
The work of @CL17 adds gradual typing to this system, which solves even more
efficiently the first point. Unfortunately, this graduallity forbids us from
using polymorphism, but a recent extension (@Call18) opens new perspectives on
this subject.

This system offers thus more flexibility than most alternatives (allowing in
particular arbitrary intersection types, which are a must-have as they allow
the overloading of functions^[A form of overloading has been recently added to
Typed Racket, but not as powerful as the one that intersection types gives
us]), although the (hopefully temporary) sacrifice of polymorphism is a huge
price to pay.
