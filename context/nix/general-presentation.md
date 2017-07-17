#### The package manager

Nix \cite{phdeelco} is a package manager for Unix-like systems which tries to
apply to package management some concepts coming from the world of programing
languages (functional ones in particular).

Conventional package managers (such as APT, Yum, or Pacman) treat the file
system as one giant shared mutable data structure.
Installing or removing a package means updating this structure in-place.
Such modifications are really hard to control − especially given the fact that
parts of those are often delegated to shell scripts whose semantic is
notoriously hard to understand^[An ANR project has been recently funded to
check bash scripts for this exact use-case − see
https://www.irif.fr/~treinen/colis/].

In practice, this model presents several problems. For example, updates can't
be made atomic, so the state is incoherent during updates, and an unexpected
interruption (electric failure, user interrupt, \ldots) can leave the system in
a state where it isn't able to even boot.
Moreover, the state of the system is hardly reproducible: several machines with
the same set of installed packages may be in totally different states
(depending on the exact sequence of actions that led to having that given set
of packages). In particular, installing and then uninstalling a package may not
get the system back to its original state.

Nix proposes a radically different approach: From the point of view of the
user, the configuration of the system is fully determined as the result of the
evaluation of an expression in a pure functional language (also called Nix).
Coupled with an on-disk memoïsation system, this approach brings several
improvements. In particular:

Reproducibility
:   This declarative specification ensures that the configuration doesn't
    depend of any previous state of the system.
    Moreover, every "derivation" (the Nix equivalent of packages) is
    instanciated in an isolated environment containing only its required
    dependencies. This ensures the absence of implicit dependency which on some
    other systems sometimes leads to reproducibility issues.

Rollbacks for free
:   Because of the way Nix works, an update isn't destructive, but it just
    consists of instanciating the new configuration alongside previous ones,
    and then make the current system point to it.
    Rolling back to a previous configuration simply resorts to changing the
    pointer of the current system.
    Moreover, the memoïsation system is way more granular than most other
    systems which allows for rollbacks (like e.g. Docker), so less has to be
    rebuilt, and older generations takes much less disk space.
    A garbage collector may be run to get rid of older generations.

Atomic updates
:   An update in Nix consists of two phases: first the new generation is built
    (which may be interrupted and restarted without consequence as it doesn't
    touch the actual system at all), and only after it is fully built, the
    configuration becomes pointed by the current system, which is essentially
    an atomic operation.
    So there is no threat of having the system left in an inconsistent state

Local environments
:   Nix's way of working allows to install packages with a limited scope. For
    example, it is trivial to allow users to install package in their own
    profile, while still benefitting of all the sharing possibilities of Nix.

    Furthermore, packages may be installed in an even more limited scope, like
    being only available in a shell.
    This feature is one of Nix's great strenghts as it allows configuring for
    example the development environment for a software in one simple command,
    and have all that is needed at hand (without having to globally install any
    dependency).

#### The Nix language

A huge part of the system relies on the language used to describe the system.

This language is essentially a lazy lambda-calculus, with lists,
records and a notion of type at runtime (with functions such as `isInt` which
returns `true` if and only if its argument is an integer).
Additionally, it is untyped (not really by choice, but more because of a lack
of time at its beginning. The original author itself considers that "Nix won't
be complete until it has static typing" [@nixIssue14].

Adding a type-system to this language has several objectives:


- \texttt{nixpkgs}, the Nix package collection is today several hundreds of
  thousands of lines of code, which a sometimes very complex structure.
  The absence of typing makes every non-trivial modification particularly
  complicated and dangerous.

- Related to its very fast grow, the project suffers from a huge lack of
  documentation. In particular, a lot of complex internal abstractions are used
  but undocumented at all.
  A type-system would reduce the impact of this problem.

- Nix explores some really interesting ideas by applying to system management
  some principles coming from programing. Adding a type-system to it opens new
  opportunities in this field.
  Although this type-system is strictly restricted to the language itself
  without any interaction with the "package management" part, it offers an
  opportunity for such an extension.

The language presents many characteristics that constraint a type-system for it:

- It is possible to know at runtime the type of a value. This functionality is
  used a lot in practice and requires a notion of union types to be useful.

- The fields of the records may have dynamically defined labels (i.e., they may
  be defined as the result of the evaluation of an arbitrary expression −
  provided it evaluates to a string).

- The language has existed for ten years without a type-system. Hence, several
  idiomatic constructs are hard to type.
