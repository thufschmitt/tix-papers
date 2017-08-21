#### The package manager

Nix \cite{phdeelco} − described as "the purely functional package manager" − is
a package manager for Unix-like systems.
It features a radically new approach to package management, taking most of its
inspiration from functional languages:
conventional package managers (such as APT, Yum, or Pacman) treat the file
system as one giant shared mutable data structure.
Installing or removing a package means updating this structure in-place.
Such modifications are really hard to control − especially given the fact that
parts of them are often delegated to shell scripts whose semantic is
notoriously hard to understand^[An ANR project has been recently funded to
check bash scripts for this exact use-case − see
https://www.irif.fr/~treinen/colis/].

In practice, this model presents several problems. For example, updates can not
be made atomic, so the state is incoherent during updates, and an unexpected
interruption (electric failure, user interrupt, \ldots) can leave the system in
a state where it is not even able to boot.
Moreover, the state of the system is hardly reproducible: several machines with
the same set of installed packages may be in totally different states
depending on the exact sequence of actions that led to having that given set
of packages. In particular, installing and then uninstalling a package may not
get the system back to its original state.

Nix proposes a radically different approach: from the point of view of the
user, the configuration of the system is fully determined as the result of the
evaluation of an expression in a pure functional language (also called Nix).
Coupled with an on-disk memoization system, this approach brings many
improvements, like better reproducibility, transparent rollbacks, atomic
upgrades, …

#### The Nix language

A huge part of the relevance of this approach relies on the language used to
describe the system.

This language is essentially a lazy lambda-calculus, with lists,
records and a notion of type at runtime (with functions such as `isInt` which
returns `true` if and only if its argument is an integer).
Additionally, it is untyped (not really by choice, but more because of a lack
of time at its beginning − the original author himself considers that "Nix
won't be complete until it has static typing" [@nixIssue14]).

Adding a type-system to this language would be an improvement on several
aspects:

- \texttt{nixpkgs}, the Nix package collection is today several hundreds of
  thousands of lines of code, with some really complex parts.
  The absence of typing makes every non-trivial modification particularly
  complicated and dangerous;

- Partly because of its very fast grow, the project suffers from a huge lack of
  documentation. In particular, a lot of complex internal abstractions are used
  but not documented at all.
  A type-system would reduce the impact of this problem;

- Nix explores some really interesting ideas by applying to system management
  some principles coming from programing. Adding a type-system to it opens new
  opportunities in this field.
  Although this type-system is strictly restricted to the language itself
  without any interaction with the "package management" part, it offers an
  opportunity for such an extension.

The language presents many characteristics that constrain a type-system for it:

- It is possible to know at runtime the type of a value. This functionality is
  used a lot in practice and requires a notion of union types to be useful, as
  we will see;

- The fields of the records may have dynamically defined labels (i.e., labels
  which are defined as the result of the evaluation of an arbitrary expression
  − provided it evaluates to a string);

- The language has been existing for ten years without a type-system. This
  naturally led to the introduction of several programing patterns are hard to
  type.
