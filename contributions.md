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
