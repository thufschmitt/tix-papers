#### Grammaire

La grammaire de Nix-light est donnée en figure \pref{nix-light::grammar}.

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

\begin{figure}
  ```
    <e> ::=
        <x> | <c>
      | <e>.<a> | <e>.<a> or <e>
      | $\lambda$<p>.<e> | <e> <e>
      | let <vr> = <e>; $\cdots{}$; <vr> = <e>; in <e>
      | Cons (<e>, <e>)
      | (<x> = <e> $\in$ <t>) ? <e> : <e>

    <c> ::= <s> | <i> | <b> | Nil

    <p> ::= <rp> | <rp>@<x> | <vr>

    <rp> ::= <rp>:τ
      | { <rpf>, $\cdots$, <rpf> }
      | { <rpf>, $\cdots$, <rpf>, ... }

    <rpf> ::= <vr> | <vr> ? <c>

    <vr> ::= <x> | <x>:<τ>

    <basetype> ::= Bool | Int | String | Any | Empty

    <t> ::= <c> | <t> $\rightarrow$ <t>
      | <t> $\vee$ <t> | <t> $\wedge$ <t> | $\lnot$ <t>
      | [<R>]
      | <basetype>

    <r> ::= <t> | <r>+ | <r>* | <r>?
      | <r> <r> | <r> ¦ <r>

    <τ> ::= <c> | <τ> $\rightarrow$ <τ>
      | <τ> $\vee$ <τ> | <τ> $\wedge$ <τ>
      | [<R>]
      | <basetype> | ?

    <ρ> ::= <τ> | <ρ>+ | <ρ>* | <ρ>?
      | <ρ> <ρ> | <ρ> ¦ <ρ>
  ```
  \caption{Grammaire de Nix-light\label{nix-light::grammar}}
\end{figure}

#### Sémantique

##### Pattern-matching

Le pattern-matching dans Nix-light a une sémantique classique pour un langage à
évaluation pareusse, avec cette simplification que, les motifs n'étant pas
récursifs, l'argument est soit non-évalué, soit uniquement évalué en forme
normale de tête.

\newcommand{\var}{\mathcal{V}}
Pour une variable (éventuellement annotée) `r`, on définit $\var(r)$ par
$\var(x) = \var(x:\τ) = x$.

Pour un motif `p` et une valeur `v` (resp. une expression `e`), on définit
$\sfrac{p}{v}$ (resp. $\sfrac{p}{e}$) l'ensemble des substitutions générées
par la confrontation de `v` (resp. `e`) à `p` de la façon suivante :

\begin{align\*}
  \sfrac{e}{x}    &= x := e \\\\
  \sfrac{e}{p:\τ}  &= \sfrac{e}{p} \\\\
  \sfrac{v}{q@x}  &= x := e; \sfrac{e}{q} \\\\
  \sfrac{\\{ s = e;\\}}{\\{ x \\}}
   &= \sfrac{r}{e} \text{\quad si } s = \var(r) \\\\
  \sfrac{\\{\cdots\\}}{\\{..\\}} &= \varnothing\\\\
  \sfrac{\\{\\}}{\\{ r\_1 ? c\_1, \cdots, r\_n ? c\_n \\}}
   &= \sfrac{r\_1}{c\_1}; \cdots; \sfrac{r\_n}{c\_n} \\\\
  \sfrac{\\{\cdots\\}}{\\{ r\_1 ? c\_1, \cdots, r\_n ? c\_n, .. \\}}
   &= \sfrac{r\_1}{c\_1}; \cdots; \sfrac{r\_n}{c\_n} \\\\
  \sfrac{\\{ s\_1 = e\_1; \cdots; s\_n = e\_n \\}}
   {\\{ r\_1, \cdots; r\_m \\}}
   &= \sfrac{r\_1}{e\_1}; \sfrac{\\{ s\_2 = e\_2; \cdots; s\_n = e\_n \\}}{
   \\{ r\_2, \cdots, r\_m \\}}
  \text{ si } s\_1 = \var(r\_1) \\\\
  \sfrac{\\{ s\_1 = e\_1; \cdots; s\_n = e\_n \\}}
   {\\{ r\_1, \cdots, r\_m, .. \\}}
   &= \sfrac{r\_1}{e\_1}; \sfrac{\\{ s\_2 = e\_2; \cdots; s\_n = e\_n \\}}{
   \\{ r\_2, \cdots; r\_m, .. \\}}
  \text{ si } s\_1 = \var(r\_1) \\\\
\end{align\*}

##### Sémantique opérationnelle

La sémantique complète de Nix-light est donnée par la
figure \pref{nix-light::semantics}.

La majorité de cette sémantique est très classique. Quelques points méritent
cependant un peu plus d'attention :

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
