We present in \Cref{sec:background} the background for our work: Nix (the
package manager and the language) which is the object of our work, and the
set-theoretic types framework in which the resulting type-system is developped.
The Nix language is difficult to reason about because of its flexibility.
Because of this, we will not work directly on it, but we designed a simplified
version called Nix-light, which will serve as a basis for all the work.
We define this Nix-light language and its semantics in
\Cref{sec:nix-light} and we show that a large subset of Nix can be
embedded into Nix-light via a compilation process that we describe there.
This allows us to backport some properties from Nix-light to Nix. In
particular, the semantics of Nix is entirely defined by the semantics of
Nix-light.
We then present the type-system of Nix-light in \Cref{sec:typing}, first
by studying a restriction to its core calculus and then adding other
constructs.
This system is based on set-theoretic types as presented by @Fri04, with the
extension to gradual types elaborated by @CL17 and adapted to a lazy semantics
as explained by @CP17.
Like for the semantics, the type-system may be transposed back to Nix.
\Cref{sec:implementation} details some aspects of the implementation 
and discusses some possible extensions.
