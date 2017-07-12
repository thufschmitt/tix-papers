Because the Nix language has grown away from any idea of typing, a lot of
constructs that requires a special theatment from the type-system aren't
syntactically distinct.
In particular, the if-then-else's that discriminate on the type of a variable
(e.g. `if isInt x then e else e'`) needs some special treatment although they
are just some particular instances of a more general construct.
Some builtin functions also can't be given an useful type, but their
application may, hence it is useful to give them separate typing rules. For
example, there is a `mapAttr` function which takes as argument a record `r` 
and a function `f` and applies `f` to all the elements of `r`.
This function alone can't be given any more interesting type than the one of a
function that takes as argument a record and a function from `Any` (the
supertype of all types) to `Any` and returns a record.
However, the application of this function to a record and an function can be
typed in a way more precise way.

Because of this, it is quite hard to reason on Nix, as the rules can't be
simply syntax-directed.
Thus, we decided not to work on Nix itself, but on a simpler language, to which
Nix (or at least a large enough subset of it) can be compiled.
