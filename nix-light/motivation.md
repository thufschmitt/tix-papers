Le langage Nix ayant évolué en l'absence de toute idée de typage, beaucoup de
constructions qui nécessiteraient un traitement spécial de la part du sytème de
type (en particulier les if-then-else qui peuvent discriminer selon le type ou
certaines fonctions qui ne peuvent pas être typées telles quelles mais dont
l'application est typable) ne sont pas syntaxiquement différenciées.

Ainsi, la fonction `hasAttr` qui prend en argument une chaîne de caractère `s`
et un enregistrement `r` renvoie `true` si `s` est une étiquette de `s` n'a pas
de type propre, seule son application `hasAttr s` peut être typée.

Il est donc très difficile de raisonner directement sur ce langage, dans la
mesure où les règles ne peuvent pas être uniquement dictées par la syntaxe.
Nous avons donc choisis de ne pas travailler directement sur Nix, mais sur un
langage plus simple vers lequel Nix (ou du moins un sous-ensemble de Nix) peut
être compilé.
