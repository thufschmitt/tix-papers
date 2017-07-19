The originality of this work is that it brings together several aspects of
typechecking − such as the set-theoretic way of handling gradual typing or
dynamic records − which, although they are all pretty well-known in isolation,
have never been used simultaneously.
This led us to a better understanding of their actual expressiveness in a
real-world context and of the trade-off that are needed to make them behave
well together.

We also extend the possibilities of bidirectional typing in the context of
set-theoretic types by understanding how to propagate type informations through
lambda-abstractions and some data-structures (lists and records).
<!-- XXX: No really nice.
  ''
  We also extend the expressiveness of set-theoretic based type-systems thanks
  to the elaboration of a bidirectional type-system
  '' ?
-->
In particular, we present an original way of checking that a function accepts a
given type, which still works even if the type in question isn't a plain arrow
type (e.g., it may be a combination − unions and intersection − of arrows).

Lastly, we also implemented the presented type-system with the intension to
use it in the large.
Although a part of the implementation is based on the existing implementation
of the CDuce language [@Ball03], it extends it in many ways.



=================


This works makes several technical contributions. In particular:

- the compilation of if into typecases to account for occurence typing

- the definition of a technique to allow generic types in type
  annotations for expressions thanks to the definition of a function A
  that detects the set up toplevel arrows in set-theoretic types.

- [WRITE BETTER WHAT FOLLOWS]
   bidirectional typing ...

- Nix recursion

- dynamic records and nix characteristict

- \vdots


But besides these technical aspects the most important contribution of
this work is, by far, that it brings together and integrates in a unique
system five different typing techniques that hitherto lived in
isolation one from the other, that is:

1. gradual typing

2. occurrence typing

3. set-theoretic types

4. bidirectional typing techniques

5. dynamic records

The important distinctive aspect that characterizes our study is that
this integration was studied not for some \emph{ad hoc} toy/idealized
academic language, but for an existing programming language with an important
community of programmers, with millions of lines of existing code,
and, last but surely not least, which was designed not having types in
mind, far from that. The choice of the language dictated the adoption
of the five characteristics above: gradual typing was the solution we
chose to inject the flexibility needed to accept already existing code
that would not fit any static typing dicipline; occurrence typing was
needed to account for commong usage patterns in which programmer give
distinct piece of codes according to dynamic type-checks of some
expressions; set-theoretic types were chosen because they provide both
intersection types (we need them to precisely type overloaded
functions, that is, which typically appear when occurrenc typing is
done on a parameter of a function) and union types (we need them to
give maximum flexibility for occurrence typing, which can btypied by
calculating the least upper bound of the different alternatives);
bidirectional typing was adopted to allow the programmer to specify
overloaded types for function via a simple explicit annotation,
without resorting to the heavy annotation that characterise functions
in CDuce; dynamic records were forced on us by the insanely great
flexibility that Nix designer have decided to give to their language.

Chosing an existing language also forced us to privilege practical
aspects over theoretical types, and this has drawback as well as
advantages. The main drawback is that we gave up having a system that
is formally proved to be sound. For instance, we could have designed a
type system in which record field selections are statically ensured
always to suceed, but this would have meant to reject nearly all
programs that use dynamic labels (which is a lot); likewise, gradual
typing is used to shunt the type system rather than to insert explicit
casts that dynamically check the soundness of programs as [Siek&Taha] do: in that sense
we completely adhere to the phylosophy of Typed Racked that wants to
annotate and document existing code but not modify (or, worse, reject)
any of it.  The main advantage is that we have implemented this type
system and can be used in practice to document existing code and help
developing new code. The implementation of the type system is the most
important practical contribution of this work. To this and to the
design of how practically integrate types in Nix we dedicated an
important part of the time spent on this internship.


