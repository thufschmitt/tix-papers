#### Compilation

Le programme Nix est compilé selon les règles de la
figure \pref{nix-light::compilation} (à l'exception de la compilation des types
qui est expliquée en section \ref{typage/structures/listes}).

Les deux langages sont très proches et la plupart des transformations sont de
simples transpositions d'une même construction d'un langage à l'autre.

La construction "if-then-else" est compilée vers un typecase, de deux façons
possibles selon la forme de l'expression testée :

- Le cas général est de compiler `if e0 then e1 else e2` vers `(x = (e0 :
  Bool) tin true) ?  e1 : e2`.
  La sémantique ainsi obtenue est un peu plus large que la sémantique attendue
  (dans la mesure où si `e0` s'évalue vers autre chose qu'un booléen, le
  typecase est bien défini et s'évalue en `e2`), mais l'annotation `e0 : Bool`
  assure que la sémantique coïncide pour des termes bien typés.

- Si `e0` est de la forme `isT x` où `isT` est un discriminant du type `T`,
  alors l'expression sera compilée vers l'expression `(x = x tin T) ? e1 : e2`.
  On vérifie aisément que cette expression a bien la même sémantique que si
  elle avait été compilée avec la règle précédente.

La compilation des enregistrements est un peu plus complexe pour deux raisons :

- La première est que Nix a une construction spéciale pour les enregistrements
  récursifs alors que Nix-light n'en a pas, ce qui veut dire qu'il faut encoder
  cette construction (en utilisant un let-binding qui lui est récursif).

- La seconde raison est que Nix dispose d'un raccourci pour définir des
    enregistrements imbriqués (par exemple `LB x.y = 1; x.z = 2; RB` qui est
    équivalent à `LB x = LB x = 1; z = 2; RB; RB`).  Nix-light ne disposant pas
    de ce sucre syntaxique, il faut transformer cette syntaxe en une syntaxe
    d'enregistrement non-imbriqué.

    En présence de champs définis dynamiquement, ce raccourci est plus qu'un
    simple sucre syntaxique et la forme exacte de l'enregistrement ne peut être
    déterminée qu'à l'exécution.  Par exemple, l'enregistrement `LB
    DOLLARLBe1RB.x = 1; DOLLARLBe2RB.y = 2; RB` peut être de la forme soit `LB
    s = LB x = 1; y = 2; RB; RB` soit `LB s1 = LB x = 1; RB; s2 = LB y = 2; RB;
    RB` selon que `e1` et `e2` s'évaluent ou non en la même valeur.
    Il est donc impossible à la compilation de résoudre de façon exacte un tel
    enregistrement.
    La solution choisie ici est de supposer que les différentes expressions des
    labels s'évaluent toutes vers des valeurs distinctes.
    L'interêt de ce choix est que si il n'est pas possible de prouver au moment
    du typage que cette supposition est vraie, alors une erreur sera renvoyée
    (parce que l'enregistrement aura un même champ défini deux fois).
    Ainsi encore, la sémantique coïncide avec ce qui est attendu pour les
    expressions bien typées.

\input{nix-light/compilation-rules}
