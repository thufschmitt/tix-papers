The characteristics of the language enforce several restrictions on the
type-system. In particular :

- Because of the important base of (untyped) existing code, the system needs to
  be flexible enough to accept as many expressions as possible, possibly
  sacrificing some security guaranties.

- It has to handle anonymous records with dynamic labels, as well as several
  operations on those records (adding or removing a field, merging records,
  etc..)

- As shown above, the presence of expressions such as `if isInt x then x else 1`
  requires the type-system to perform some occurrence typing.

- Related to the occurrence typing, the type-system should also handle some
  form of union types, so that an expression such as
  `λx. if isInt x then x==1 else not x` can be typed (with type
  `Int $\vee$ Bool -> Bool`).

Several existing type-systems already try to satisfy these requirements.  The
most well-known one is probably the type-system of Typed Racket (@FH08), which
already implements at an industrial level most of what is needed in the context
of the Scheme language.

The approach we choose here is based on the work of @Fri04 and @Cas15 on
set-theoretic types, with extensions brought by @phdkim and @CL17.

The system is based on a set-theoretic interpretation of types as a sets of
values, which provides a natural interpretation for union, intersection or
difference (as the corresponding operations on the underlying sets).
This interpretation also provides a natural definition of a subtyping relation
which corresponds to the inclusion relation on the interpretations as sets.
Moreover, this relation is decidable.
The work of @CL17 adds gradual typing to this system, which solves even more
efficiently the requirement for a flexible type system. Unfortunately, this
graduality forbids us from using polymorphism, but a recent extension (@Call18)
opens new perspectives on this subject.

This system offers thus more flexibility than most alternatives (allowing in
particular arbitrary intersection types, which are a must-have as they allow
a precise typing of the overloading of functions^[A form of overloading has
been recently added to Typed Racket, but not as powerful as the one that
intersection types gives us]), although the (hopefully temporary) sacrifice of
polymorphism is a huge price to pay.
