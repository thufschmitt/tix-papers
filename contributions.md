This works makes several technical contributions. In particular:

- the compilation of if constructs into typecases to account for occurrence
  typing,

- the addition of bidirectional typing to set-theoretic type-systems.
  In particular, a technique to propagate type informations through the
  syntactic tree (and in particular through lambdas thanks to the $\mathcal{A}$
  function which decomposes a function type into the set of its toplevel
  arrows),

- a new way of typing records with dynamic labels extending the formalism of
  @Fri04 with static records,

- an extension of the gradual type-system of @CL17 with records,

- \vdots


But besides these technical aspects, the most important contribution of
this work is, by far, that it brings together and integrates into a unique
system five different typing techniques that hitherto lived in
isolation one from the other, that is:

1. gradual typing

2. occurrence typing

3. set-theoretic types

4. bidirectional typing techniques

5. dynamic records

The important distinctive aspect that characterizes our study is that
this integration was studied not for some *ad hoc* toy/idealized
academic language, but for an existing programming language with an important
community of programmers, with thousands of lines of existing code,
and, last but surely not least, which was designed not having types in
mind, far from that. The choice of the language dictated the adoption
of the five characteristics above: gradual typing was the solution we
chose to inject the flexibility needed to accept already existing code
that would not fit standard static typing discipline; occurrence typing was
needed to account for common usage patterns in which programmers use
distinct piece of codes according to dynamic type-checks of some
expressions; set-theoretic types were chosen because they provide both
intersection types (we need them to precisely type overloaded
functions which, typically, appear when occurrence typing is
performed on a parameter of a function) and union types (we need them to
give maximum flexibility for occurrence typing, which can typed by
calculating the least upper bound of the different alternatives);
bidirectional typing was adopted to allow the programmer to specify
overloaded types for functions via a simple explicit annotation,
without resorting to the heavy annotation that characterise functions
in CDuce; dynamic records were forced on us by the insanely great
flexibility that Nix designer have decided to give to their language.

Choosing an existing language also forced us to privilege practical
aspects over theoretical ones − with the drawbacks and the advantages that this
choice implies. The main drawback is that we gave up having a system that is
formally proved to be sound. For instance, we could have designed a type system
in which record field selections are statically ensured always to succeed, but
this would have meant to reject nearly all programs that use dynamic labels
(which are many); likewise, gradual typing is used to shunt the type system
rather than to insert explicit casts that dynamically check the soundness of
programs as @ST06 do: in that sense we completely adhere to the philosophy of
Typed Racked that wants to annotate and document existing code but not modify
(or, worse, reject) any of it.
The implementation of this type system is the most important practical
contribution of this work. To this and to the design of how practically
integrate types in Nix we dedicated an important part of the time spent on this
internship.

