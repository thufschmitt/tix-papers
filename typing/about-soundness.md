The definition of soundness in the presence of gradual types is usually the
soundness of an intermediate language in which explicit casts have been added
in place of the gradual type.

This however only makes sense as far as the gradually typed language is
compiled to something else.
However in our case, we did not want to do so (for backward compatibility
reasons with the original language), so stating such a property wouldn't make
sense.

The only notion of safety that we could state is that the language is safe (in
the classical sense of "every well-typed expression either reduces to a value
of the same type either infinitely reduces") as far as the gradual type isn't
involved.
But even this property does not hold because of records (as said in
\Cref{typing::structures::records}, we deliberately allow some unsoundness for
the records).

This is however not a real problem as our goal is not to provide an ideal
theoretical type-system but rather a practical tool to make the development
easier, so perfect soundness is not required.
