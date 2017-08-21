Because the Nix language has grown away from any idea of typing, a lot of
constructs that require a special treatment from the type-system are not
syntactically distinct.
In particular, the conditionals that discriminate on the type of a variable
(*e.g.* `if isInt x then e else e'`) need some special treatment although they
are just some particular instances of a more general construct.
Some builtin functions also can not be given an useful type, but their
application can, hence it is useful to give them separate typing rules. For
example, there is a `mapAttr` function which takes as argument a record `r` 
and a function `f` and applies `f` to all the values of `r`.
This function alone can not be given any type more interesting than the one of a
function that takes as argument a record and a function from `Any` (the
supertype of all types) to `Any` and returns a record.
However, the application of this function to a record and a function can be
typed in a way more precise way.
For example, the whole expression `mapAttr (λx. x + 1) { x = 1; }` can be given
the type `{ x = Int }`.
Thanks to the use of overloaded functions, we can even give a useful typing to
more complex applications. If `f` is of type
`(Int -> Bool) AND (String -> String)` (i.e., `f` is an overloaded function
which is both a function of type `Int -> Bool` and a function of type
`String -> String`), we can give the type `{ x = Bool; y = String }` to the
expression `mapAttr f { x = 1; y = "foo"; }`.
But these two expressions corresponds to two incompatibles types for `mapAttr`
(namely `(Int -> Int) -> { x = Int } -> { x = Int }` and
`(Int -> Bool AND String -> String) -> { x = Int; y = String } -> { x = Bool; y = String }`).

Because of this, it is quite hard to reason on Nix.
Thus, we decided not to work on Nix itself, but on a simpler language,
Nix-light, to which Nix (or at least a large enough subset of it) can be
compiled.
