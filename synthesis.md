## General context {-}

Nix \cite{phdeelco} is a package manager for Unix-like systems which tries to
apply concepts coming from the world of programing
languages (functional ones in particular) to package management.
This approach solves in a very elegant way many problems encountered by
conventional package managers (Apt, Pacman, Yum, \ldots).
The state of a machine managed by Nix is (apart from some irreducible mutable
state) entirely described by the result of the evaluation of an expression in a
(purely functional) specialized language also called Nix.

## Problem studied {-}

The Nix language is not typed, although type tests are present at runtime. The
aim of this internship is to design a type-system for this language, and
implement a typechecker for it.
The goal of this type-system is the same as the one of Typed Racket by @FH08:
to add some guaranties to possibly already existing code, while being the least
intrusive as possible.
This means that we have to adapt to the specificities of the language and to
the existing idioms instead of enforcing some new constructs that would be
easier to type.

The lack of a type-system is an issue that is often pointed out, but no one has
so far attempted to design it (mostly because retro-fitting a type-system to an
existing language is a difficult task and the community is still rather small).

## Proposed contributions {-}

This works makes several technical contributions. In particular:

- the compilation of `if-then-else` constructs into typecases to account for
  occurrence typing,
- an improved definition of bidirectional typing for set-theoretic type-systems.
  In particular, a technique to propagate type informations through the
  syntactic tree (especially through lambdas),
- an extension of the gradual type-system of @CL17 with records,
- a new way of typing records with dynamic labels that extends the formalism
  established by @Fri04 in the case of static records.

But besides these technical aspects, the most important contribution of
this work is, by far, that it brings together and integrates into a unique
system five different typing techniques that hitherto lived in
isolation one from the other, that is:

1. gradual typing [@ST06; @CL17]
2. occurrence typing [@FH08]
3. set-theoretic types [@Fri04]
4. bidirectional typing techniques [@HP98; @DN13]
5. dynamic records

The important distinctive aspect that characterizes our study is that this
integration is studied not for some *ad hoc* toy/idealized academic language,
but for an existing programming language with an important community of
programmers, with thousands of lines of existing code, and, last but surely not
least, which was designed not having types in mind, far from that. The choice
of the language dictated the adoption of the five characteristics above:
*gradual typing* was the solution we chose to inject the flexibility needed to
accept already existing code that would not fit standard static typing
disciplines; *occurrence typing* was needed to account for common usage
patterns in which programmers use distinct piece of codes according to dynamic
type-checks of some expressions; *set-theoretic types* were chosen because they
provide both intersection types (we need them to precisely type overloaded
functions which, typically, appear when occurrence typing is performed on a
parameter of a function) and union types (we need them to give maximum
flexibility to occurrence typing, which can typed by calculating the least
upper bound of the different alternatives); *bidirectional typing* was adopted
to allow the programmer to specify overloaded types for functions via a simple
explicit annotation, without resorting to the heavy annotation that
characterise functions in most similar type-systems; *dynamic records* were
forced on us by the insanely great flexibility that Nix designers have decided
to give to their language.

Choosing an existing language also forced us to privilege practical
aspects over theoretical ones − with the drawbacks and the advantages that this
choice implies. The main drawback is that we had to give up having a system
that is formally proved to be sound. For instance, we could have designed a
type system in which record field selections are statically ensured always to
succeed, but this would have meant to reject nearly all programs that use
dynamic labels (which are many); likewise, gradual typing is used to shunt out
the type system rather than to insert explicit casts that dynamically check the
soundness of programs as @ST06 do: in that sense we completely adhere to the
philosophy of Typed Racked that wants to annotate and document existing code
but not to modify (or, worse, reject) any of it.
The implementation of this type system is the most important practical
contribution of this work. To this and to the design of how practically
integrate types in Nix we dedicated an important part of the time spent on this
internship.

## Arguments supporting the validity of these contributions {-}

The implementation is not yet advanced enough to be considered as a finished
product, but it already is more than a simple proof of concept. It is
capable of efficiently typing a lot of constructs with a reasonable amount of
annotations. This was not obviously feasible, as the language is often really
permissive, which raises a lot of problems when trying to type it − see a
session excerpt in \Cref{examples} in the appendix.

The developments made on the theoretical side make the use of the type-system
more expressive and easier to use thanks to the bidirectional typing, and
proved its flexibility by showing that it can easily be adapted to a
call-by-name semantics.
The use of the gradual typing of @CL17 in a more complex type-system also
serves as a proof of the accuracy of their approach.

## Summary and future work {-}

The type-system we designed covers most of the requirements for the
original practical problem, and was an opportunity for developing the framework
of the set-theoretic type-systems.

A logical next step is to develop the implementation further to make it usable
at large. This would prove the relevance of this approach for concrete
applications.

An annoying lack that would deserve to be filled is the absence of polymorphism
in the type system. This was essentially due to the fact that the gradual
typing system of @CL17 was set in a monomorphic type-system. However, a recent
extension by @Call18 adds polymorphism to this system, which may be used here.

#### Note on the language {-}

A large part of this document is intended to be presented in the conference
\<Programming\> 2018^[http://2018.programming-conference.org/], which is
why it is written in English.

