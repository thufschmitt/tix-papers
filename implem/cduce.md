\newcommand{\cduce}{CDuce}
Instead of implementing our own implementation of types and of the subtyping
algorithm, we reused the one used in the implementation of the \cduce
language[@Ball03].

\cduce is a language specialized in the manipulation of XML documents which
features a type-system based on the set-theoretic types of @Fri04 (on which
this work is itself based).
Although its type-system is obviously not the same as the one presented here,
its types form a supertype of ours (with the exception of the gradual type
which is absent in \cduce but may be encoded as a distinguished type constant),
so we could reuse its representation.

We also wanted to reuse its subtyping algorithm (since implementing it would
have taken way too much time), but this was more difficult, as it implements a
subtyping algorithm in the context of a strict semantic and static types.
Fortunately, both the adaptation to a lazy semantic and the extension to
gradual subtyping may be expressed simply by an encoding of the types (thus
without modifying the algorithm itself).

### Lazy subtyping

As @CP17 explain, the lazy subtyping algorithm may be reduced to the strict one
by an encoding of the types.
The idea is to encode directly into the types the differences in the
set-theoretic interpretation: instead of giving ourselves a distinguished
element $\bot$ of the domain and adding it to some of the sets representing the
types, we give ourselves a distinguished type $\bot$ (which has an empty
intersection with any other basic type) and rewrite the types as follows:

\newcommand{\interpr}[1]{\llbracket #1 \rrbracket}
\begin{align*}
  \interpr{b} &= b \\
  \interpr{c} &= c \\
  \interpr{\Empty} &= \Empty \\
  \interpr{\Any} &= \Any \\
  \interpr{Cons(\τ, \sigma)} &= Cons(\interpr{\τ} \vee \bot, \interpr{\sigma} \vee \bot) \\
  \interpr{\τ \rightarrow \sigma} &= (\interpr{\τ} \vee \bot) \rightarrow \sigma \\
  \interpr{\τ \vee \sigma} &= \interpr{\τ} \vee \interpr{\sigma} \\
  \interpr{\τ \wedge \sigma} &= \interpr{\τ} \wedge \interpr{\sigma} \\
  \interpr{\lnot t} &= \lnot (\interpr{t} \vee \bot) \\
  \interpr{\{ x_1 = \τ_1; \cdots; x_n = \τ_n; \_ = \τ \}} &=
    \{ x_1 = \interpr{\τ_1} \vee \bot; \cdots; x_n = \interpr{\τ_n} \vee \bot;
      \_ = \interpr{\τ} \vee \bot \}
\end{align*}

### Gradual subtyping

The very definition of the gradual subtyping relation as given by @CL17 uses
the static subtyping relation *via* an encoding of the types.
This definition can be expressed as:

> $\τ_1 \subtypeG \τ_2$ if $\τ_1^\Downarrow \subtype \τ_2^\Uparrow$

Where $\τ^\Downarrow$ (resp. $\τ^\Uparrow$) is obtained by replacing every
covariant occurrence of `?` in $\τ$ by $\Any$ (resp. $\Empty$) and every
contravariant occurrence of `?` by $\Empty$ (resp. $\Any$).
