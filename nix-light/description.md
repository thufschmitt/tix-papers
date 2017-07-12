#### Grammaire

Ce langage reprend essentiellement toutes les caractéristiques de Nix, mais en
rendant syntaxiquement reconnaissable les éléments qui nécessitent un traitement
spécial au typage.

Ainsi, le if-then-else est remplacé par le plus général « typecase » de la
forme `(x = e0 tin t) ? e1 : e2` (qui s'évalue en `e1` si `e0` s'évalue en une
value de type `t` et en `e2` sinon). Le cas général `if e0 then e1 else e2`
peut ainsi être compilé en `(x = e0 tin true) ? e1 : e2` (ou `x` n'apparait pas
libre dans `e1` et `e2`), alors qu'un cas particulier comme
`if isInt x then e1 else e2` sera compilé vers `(x = x tin Int) ? e1 : e2`.
Cela permet de reléguer la reconnaissance des éléments particuliers à une phase
de compilation préalable au typage, et permet du coup d'alléger le système de
types. En contrepartie, cela diminue la puissance du système de types,
puisqu'une expression comme `let f = isInt; in if f x then x else 1` ne pourra
pas être reconnue par le compilateur dans la mesure où celui-ci n'a pas
d'information de type pour savoir que `f` doit être considérée comme un
prédicat sur les types.

La grammaire de Nix-light est donnée en figure \pref{nix-light::grammar}.
La construction `<$\hat{t}$>` est similaire à la construction `<t>`, mais le
seul type flèche autorisé à apparaitre dedans est le type `Empty -> Any`.
L'opérateur `<>` définit la concaténation de records.
Dans toute la suite, on suppose que cet opérateur est commutatif. En
conséquence, on s'autorise à réordonner arbitrairement les termes d'une
expression de la forme `<e> <> ... <> <e>` (resp. d'un type de la forme `<t> <>
... <> <t>` ou `<τ> <> ... <> <τ>`).
On s'autorise de plus à écrire `LB x1 = e1; ...; xn = en RB` à la place de `LB
x1 = e1 RB <> ... <> LB xn = en RB`, et de même pour les types enregistrement.

\begin{figure}
  \begin{lstlisting}
    <e> ::=
        <x> | <c>
      | <e>.<a> | <e>.<a> or <e>
      | $\lambda$<p>.<e> | <e> <e>
      | let <vr> = <e>; $\cdots{}$; <vr> = <e>; in <e>
      | Cons (<e>, <e>)
      | { <x> = <e> } | {} | <e> <> ... <> <e>
      | (<x> = <e> $\in$ <$\hat{t}$>) ? <e> : <e>
      | <e>:<τ>

    <c> ::= <s> | <i> | <b> | Nil

    <p> ::= <rp> | <rp>@<x> | <vr>

    <rp> ::= <rp>:τ
      | { <rpf>, $\cdots$, <rpf> }
      | { <rpf>, $\cdots$, <rpf>, … }

    <rpf> ::= <vr> | <vr> ? <c>

    <vr> ::= <x> | <x>:<τ>

    <basetype> ::= Bool | Int | String | Any | Empty | Nil

    <t> ::= <c> | <t> $\rightarrow$ <t>
      | <t> $\vee$ <t> | <t> $\wedge$ <t> | $\lnot$ <t>
      | Cons(<t>, <t>) | let <x> = <t>; $\cdots$; <x> = <t> in <t>
      | { <x> = <t> } | {} | { … } | <t> <> ... <> <t>
      | <basetype>

    <τ> ::= <c> | <τ> $\rightarrow$ <τ>
      | <τ> $\vee$ <τ> | <τ> $\wedge$ <τ>
      | Cons(<τ>, <τ>) | let <x> = <τ>; $\cdots$; <x> = <τ> in <τ>
      | { <x> = <τ> } | {} | { … } | <τ> <> <τ>
      | <basetype> | ?
      | t
  \end{lstlisting}
  \caption{Grammaire de Nix-light\label{nix-light::grammar}}
\end{figure}

#### Sémantique

##### Pattern-matching

Le pattern-matching dans Nix-light a une sémantique classique pour un langage à
évaluation paresseuse, avec cette simplification que, les motifs n'étant pas
récursifs, l'argument est soit non-évalué, soit uniquement évalué en forme
normale de tête.

\newcommand{\var}{\mathcal{V}}
Si `r` est un pattern de variable (correspondant à la règle de production
`<variable-pattern>`, donc de la forme `x` ou `x:τ` où `x` est une variable et
`τ` un type), on définit la variable représentée par `r` (notée $\var(r)$)
comme $\var(x) = \var(x:\tau) = x$.
`l` désigne une construction de la forme `r` ou `r ? c` (avec `r` un pattern de
variable et `c` une constante).

Pour un motif `p` et une valeur `v` (resp. une expression `e`), on définit
$\sfrac{p}{v}$ (resp. $\sfrac{p}{e}$) la substitution générée par la
confrontation de `v` (resp. `e`) à `p` de la façon suivante :

\begin{align*}
  \sfrac{x}{e}    &= x := e \\
  \sfrac{p:\τ}{e}  &= \sfrac{p}{e} \\
  \sfrac{q@x}{v}  &= x := e; \sfrac{q}{e} \\
  \sfrac{\{..\}}{\{\cdots\}} &= \varnothing\\
  \sfrac{\{\}}{\{\}} &= \varnothing \\
  \sfrac{\{ r_1, l_1, \cdots, l_m\}}{\{ x_1 = e_1; \cdots; x_n = e_n; \}}
    &= \sfrac{r_1}{e_1};
       \sfrac{\{ l_1, \cdots, l_m\}}{\{ x_2 = e_2; \cdots; x_n = e_n; \}}
       \text{ if } x_1 = \var(r_1) \\
  \sfrac{\{ r_1, l_1, \cdots, l_m, .. \}}{\{ x_1 = e_1; \cdots; x_n = e_n; \}}
    &= \sfrac{r_1}{e_1};
       \sfrac{\{ l_1, \cdots, l_m, .. \}}{\{ x_2 = e_2; \cdots; x_n = e_n; \}}
       \text{ if } x_1 = \var(r_1) \\
  \sfrac{\{ r_1 ? c, l_1, \cdots, l_m\}}{\{ x_1 = e_1; \cdots; x_n = e_n; \}}
    &= \sfrac{r_1}{e_1};
       \sfrac{\{ l_1, \cdots, l_m\}}{\{ x_2 = e_2; \cdots; x_n = e_n; \}}
       \text{ if } x_1 = \var(r_1) \\
  \sfrac{\{ r_1 ? c, l_1, \cdots, l_m, .. \}}{\{ x_1 = e_1; \cdots; x_n = e_n; \}}
    &= \sfrac{r_1}{e_1};
       \sfrac{\{ l_1, \cdots, l_m, .. \}}{\{ x_2 = e_2; \cdots; x_n = e_n; \}}
       \text{ if } x_1 = \var(r_1) \\
  \sfrac{\{ r_1 ? c, l_1, \cdots, l_m\}}{\{ x_1 = e_1; \cdots; x_n = e_n; \}}
    &= \sfrac{r_1}{c};
       \sfrac{\{ l_1, \cdots, l_m\}}{\{ x_1 = e_1; \cdots; x_n = e_n; \}}
       \text{ if } \forall i \in \{1 .. n\}, x_i \neq \var(r_i) \\
  \sfrac{\{ r_1 ? c, l_1, \cdots, l_m, ..\}}{\{ x_1 = e_1; \cdots; x_n = e_n; \}}
    &= \sfrac{r_1}{c};
       \sfrac{\{ l_1, \cdots, l_m, ..\}}{\{ x_1 = e_1; \cdots; x_n = e_n; \}}
       \text{ if } \forall i \in \{1 .. n\}, x_i \neq \var(r_i) \\
\end{align*}

##### Sémantique opérationnelle

La sémantique complète de Nix-light est donnée par la
figure \pref{nix-light::semantics}.

La majorité de cette sémantique est très classique. Quelques points méritent
cependant un peu plus d'attention :

<!--- XXX: Should this really appear here ? --->
- Contrairement à de nombreux langages (Perl, Python, …), un enregistrement
  littéral dans lequel un même label apparait plusieurs fois est invalide et
  son évaluation renvoie une erreur^[Le langage Nix offre ici un comportement
  assez peu cohérent, dans la mesure où si deux champs sont définis
  statiquement avec la même étiquette (par exemple `LB x = 1; x = 2; RB`),
  alors l'expression sera considérée comme invalide durant une phase de test
  avant l'évaluation − donc le programme ne sera pas évalué −, alors que si les
  champs sont définis dynamiquement (par exemple `let x = "x"; in LB
  DOLLARLBxRB = 1; DOLLARLBxRB = 2; RB`) la collision ne pourra être détectée
  qu'à l'execution. D'un point de vue sémantique, cela signifie donc que la
  première forme est une expression invalide, alors que la seconde peut être
  vue comme une expression valide qui renvoie une erreur à l'exécution].

- Déjà évoqué précédemment, le typecase est une construction suffisamment rare
  pour méritée d'être citée.
  Bien que cela ne soit pas explicité dans la grammaire pour des questions de
  lisibilité, la syntaxe du type utilisé dans un typecase est limitée : le seul
  type flèche qui peut y apparaitre est la flèche `Empty -> Any`.
  En effet, autoriser des flèches arbitraires rendraient cette construction
  indécidable pour le système de type dans certains cas.

\input{nix-light/semantics}
