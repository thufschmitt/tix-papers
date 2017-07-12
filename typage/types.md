### Présentation des types

Les types utilisés sont inspirés des types ensemblistes utilisés dans le
langage CDuce et décrits dans @Fri04.

La syntaxe des types est donnée dans la grammaire de Nix-light
(figure \pref{nix-light::grammar}).

On distingue deux productions de types : les types statiques (notés en lettres
romaines $t, s, \ldots$) et les types graduels (en lettres grecques $\τ,
\sigma, \ldots$).

Ces types correspondent essentiellement aux types présentés dans @CL17, avec en
addition des types d'enregistrement et de liste similaire à ceux présents dans
@Fri04.

### Sous-typage

Comme dans @CL17, la relation de sous-typage $\subtype$ sur les types statiques
est étendue en une relation $\subtypeG$ sur les types graduels.
En revanche, la relation de sous-typage n'est pas la même. En effet, la
relation utilisée dans @CL17 (qui est la relation de sous-typage établie dans
@Fri04) se base sur une interprétation ensemblistes des types comme ensemble de
valeurs, qui utilisée directement pose dès problèmes de sûreté du typage avec
une sémantique paresseuse.
La raison est que cette interprétation ensembliste interprète des valeurs
(totalement évaluées), alors que dans un langage paresseux, il faut manipuler
des expressions potentiellement non évaluées, et dont l'évaluation pourrait ne
pas terminer si elle était forcée. En particulier, le type `Empty` se comporte
différemment, dans le mesure où s'il n'existe jamais de valeur de ce type, il
existe des expressions, qui peuvent apparaitre à l'intérieur d'une valeur dans
une sémantique paresseuse.
Par exemple, le type `LB x = Empty; RB` serait inhabité dans une sémantique
stricte (et donc serait sous-type de tous les autres types au même type que le
type `Empty` lui-même), alors que dans la sémantique paresseuse, il est habité
par exemple par la valeur `LB x = let x = x; in x; RB`.

Il est possible de modifier l'interprétation pour tenir compte de cette
différence, en ajoutant à des endroits judicieusement choisis une constante
particulière (notée $\bot$) à l'interprétation des types.
Ainsi, l'interprétation $\llbracket A \times B \rrbracket$ du type $A \times B$
qui est égale à $\llbracket A \rrbracket \times \llbracket B \rrbracket$ dans
l'interprétation stricte devient $\left(\llbracket A \rrbracket \cup \bot
\right) \times \left(\llbracket B \rrbracket \cup \bot \right)$.
De cette nouvelle interprétation découle un nouvel algorithme de sous-typage.

Cette interprétation et ses conséquences sont décrites dans l'article
@CP17 (non publié encore à ce jour).
