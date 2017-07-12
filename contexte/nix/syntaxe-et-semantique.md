Le langage étudié est une extension du langage Nix auquel des annotations de
type ont été ajoutées.
Dans toute la suite, toute référence au langage Nix se réfèrera à cette
extension.

La syntaxe complète du langage est donnée par la figure \pref{nix::syntax}.
Sa sémantique est définie informellement ci dessous (une sémantique complète
est donnée en section \ref{sec:nix-light}).

Le langage est un lambda-calcul, avec

Des constantes de base
:   (entiers, chaînes de caractères, booléens et
  paths représentant des chemins d'accès Unix).

Des let-bindings
:   qui sont récursifs par défaut.

Des listes
:   définies par la syntaxe `[ <expr> ... <expr>]`.

Des enregistrements
:   définis par la syntaxe `{ <record-field>; ... <record-field>; }`.

  Les étiquettes des champs peuvent être le résultat d'expressions
  arbitraires − pourvu que ces expressions s'évaluent en une chaîne de
  caractères.

  Ces enregistrements peuvent être définis récursivement (avec le mot clé
  `rec`), auquel cas les champs peuvent dépendre les un des autres.

  Par exemple, l'expression `rec { x = 1; y = x; }` est équivalente à `{ x = 1;
  y = 1; }`.

Des if-then-else
:  .

Une syntaxe d'accès aux chanps des records
:   de la forme `<expr>.<access-path>`.
  Comme pour la définition d'un record, le nom des champs peut être une
  expression arbitraire.
  Si le champ n'est pas présent dans le record, l'évaluation est stoppée.

  Une valeur par défaut en cas de champ absent peut être donnée avec la
  syntaxe `<expr>.<access-path> or <expr>`.

  Par exemle, `{ x = { y = 1; }; }.x.y` s'évalue en `1`,
  `{ x = { y = 1; }; }.x.z or 2` s'évalue en `2` et
  `{ x = { y = 2; }; }.y` renvoie une erreur.

Des patterns
:   (uniquement pour les lambdas).

  Les seuls patterns non-triviaux existant sont les patterns reconaissant un
  enregistrement, de la forme
  `{ <pattern-field>, ..., <pattern-field> }`
  ou
  `{ <pattern-field>, ..., <pattern-field>, "..." }`

  Le motif <pattern-field> est de la forme `<ident>` ou
  `<ident> ? <expr>` pour spécifier une valeur par défaut dans le
  cas où le champ est absent.

  Contrairement à la plupart des langages où la variable de capture est
  indépendante du nom du champ (par exemple en OCaml où un pattern
  reconaissant un enregistrements serait de la forme
  `{ x = fieldname; y = otherfieldname }`, le motif `{ x; y }` n'étant qu'un
  sucre syntaxique pour `{ x = x; y = y }`), Nix impose que les noms des
  champs soient les mêmes que ceux des variables de capture.

Des opérateurs infixes
:   comme `+`, `-`, etc..

En plus de ces constructions syntaxiques, une grande partie de l'expressivité
du langage est caché derrière certaines fonctions prédéfinies.

Par exemple, certaines fonctions permettent des opérations avancées sur les
records comme la fonction `attrNames` qui, appliquée à un
enregistrement, renvoie la liste de ses étiquettes (sous forme de chaînes de
caractères).

Une autre classe de fonctions qui étendent la sémantique du langage sont les
fonctions permettant de discriminer sur le type de leur argument : des
fonctions `isInt`, `isString`, `isBool`, etc..\ qui renvoient `true` si leur
argument est respectivement un entier, une chaîne de caractères ou un booléen,
et `false` sinon.
Combinées avec le if-then-else, ces fonctions permettent à une expression de se
comporter différement selon le type de son argument. Le système de type doit
être capable de rendre compte de cette capacité.

Ainsi, on veut pouvoir donner le type `Int` à une expression telle que

\begin{lstlisting}
if isInt x then x else 1
\end{lstlisting}

ce qui oblige le système de type à être conscient du fait que dans la branche
`then`, `x` est nécessairement de type entier (et donc à reconnaitre que la
condition a une forme particulière qui nécessite un traitement particulier).

\begin{figure}
  \small
  \begin{lstlisting}
<expr> ::=
  <ident> | <constant>
  | $\lambda$ <pattern>.<expr> | <expr> <expr>
  | let <var-pattern> = <expr>; $\cdots$; <var-pattern> = <expr>; in <expr>
  | [ <expr> $\cdots$ <expr> ]
  | { <record-field>; $\cdots$; <record-field>; }
  | rec { <record-field>; $\cdots$; <record-field>; }
  | if <expr> then <expr> else <expr>
  | <expr>.<acces-path>
  | <expr>.<acces-path> or <expr>
  | <expr> <infix-op> <expr>
  | <expr> : <τ>

<constant> ::= <string> | <integer> | <boolean> | <paths>

<record-field> ::= inherit <ident> $\cdots$ <ident>
  | inherit (<expr>) <ident> <ident>
  | <access-path> = <expr> | <access-path> : <τ> = <expr>

<pattern> ::= <record-pattern> | <record-pattern>@<ident>
  | <var-pattern>

<var-pattern> ::= <ident> | <ident> : <τ>

<record-pattern> ::=
  | { <record-pattern-field>, $\cdots$, <record-pattern-field> }
  | { <record-pattern-field>, $\cdots$, <record-pattern-field>, ... }

<record-pattern-field> ::= <var-pattern> | <var-pattern> ? <expr>

<access-path> ::= <access-path-item>. $\cdots$ . <access-path-item>

<access-path-item> ::= <ident> | { <expr> }

<infix-op> ::= + | - | * | / | // | ++ | $\cdots$

<basetype> ::= Bool | Int | String | Any | Empty

<t> ::= <constant> | <t> $\rightarrow$ <t>
  | <t> $\vee$ <t> | <t> $\wedge$ <t> | $\lnot$ <t>
  | [<R>]
  | <basetype>

<R> ::= <t> | <R>+ | <R>* | <R>?
  | <R> <R> | <R> ¦ <R>

<τ> ::= <c> | <τ> $\rightarrow$ <τ>
  | <τ> $\vee$ <τ> | <τ> $\wedge$ <τ>
  | [<ρ>] | [<ρ> ?? ]
  | <basetype> | ?

<ρ> ::= <τ> | <ρ>+ | <ρ>* | <ρ>?
  | <ρ> <ρ> | <ρ> ¦ <ρ>
  \end{lstlisting}
  \caption{Syntaxe du langage Nix\label{nix::syntax}}
\end{figure}


