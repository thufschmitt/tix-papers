We present a type-system for the Nix language.
The system merges several theories (gradual typing, bidirectional typing,
typing of dynamic records, …) in order fulfils the requirements explained
in Section \ref{subsec:nix}.

We do not state <!-- XXX: This is false atm, I state one --> any soundness
result for two reasons: First, we use gradual typing, and the soundness results
for gradual type systems usually involve compiling to a language with explicits
casts (and proving the results on that language).
In our case, we want to keep using the existing interpreter directly on the
unmodified source Nix files for practical reasons, so this approach is not
possible.
The second reason for the absence of soundness result is that the system is
known to be unsound − except for a very lax definition of soundness. This
unsoundness is acknowledged and accepted because for certain classes of
constructions (like the records with dynamic labels) it is very hard to
statically recognize valid expressions, so as rejecting everything was not a
realistic option, we had no other choice than to accept everything (this is
similar to the trade-off that most type-systems do by considering exceptions as
a valid behaviour because checking for them is out of their scope).

The Nix language is hard to reason on because of its flexibility.
Because of this, we won't work directly on it, but we designed a simpler one
that called Nix-light, which will serve as a basis for all the work.
We define this Nix-light language and its semantics in
Section \ref{sec:nix-light}, as well as the rules of the compilation from Nix
to Nix-light. This also gives us a semantics for Nix (through the semantics of
Nix-light).
We then present the type-system of Nix-light in Section \ref{sec:typing}.
This system is based on set-theoretic types as presented by @Fri04, with the
extension to gradual types elaborated by @CL17 and adapted to a lazy semantics
as explained by @CP17.
The Section \ref{sec:implementation} details some aspects of the implementation 
and discusses some possible extensions.
