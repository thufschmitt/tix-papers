Contrairement à la plupart des langages, il n'existe pas de type « liste » dans
nix-light, mais les listes constituent simplement un ensemble de types générés
par une syntaxe particulière.
En effet, les listes ne sont pas monomorphes comme c'est le cas en général,
donc quand bien même le système de types aurait une notion de polymorphisme, il
serait impossible d'exprimer le type des listes comme un type paramétré.

Les types de liste sont les types engendrés par la grammaire
suivante\footnote{Par simplicité, nous ne parlons ici que de types graduels. Le
même discours peut être tenu en considérant exclusivement des types concrets} :

```
<l> ::= Nil
  | Cons(<τ>, <l>)
  | let <x> = <l> in <x>
  | <l> AND <l> | <l> $\vee$ <l>
  | ?
```

Ces types sont un encodage des types listes de Nix qui sont les types de la
forme `[ R ]`.

### Compilation

Il est possible de façon assez naturelle de passer d'un type liste au sens de
Nix à un type liste au sens de Nix-light. Les règles de cette compilation sont
disponibles en figure \pref{typage::listes::compilation}.
Cette compilation est analogue à la compilation d'expressions régulières vers
une machine à état.

\input{typage/compilation-listes}
