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

### Typage

Le typage des listes est présenté à la figure \pref{typage::liste}.

\begin{figure}
  \begin{displaymath}
    \inferrule{
      \Gamma \tIC e_1 : \tau_1 \\\\ \Gamma \tIC e_2 : \tau_2 \\\\
      \tau_2 \subtypeG \cons(\Any, \Any)
    }{
      \Gamma \tIC \cons(e_1, e_2) : \cons(\tau_1, \tau_2)
    }\lbl{Cons}
  \end{displaymath}
  \caption{Règle de typage des listes}\label{typage::liste}
\end{figure}
