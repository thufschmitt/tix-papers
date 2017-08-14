This type-system has been implemented as an OCaml program.
The sources are available at
[https://www.github.com/regnat/tix](https://www.github.com/regnat/tix).

The figure \Cref{examples} shows some runs of the typechecker.
Note that the concrete syntax of Nix different from the syntax we gave here:
The lambdas are defined with the syntax `<pattern>:<expr>` and the type
annotations with the syntax `/*: τ */`^[This has been chosen because it is
syntactically a comment in nix, so annotated code can be understood by the
original Nix program, which is a requirement of our work].
