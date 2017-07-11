### Description générale
\label{typage::lambda-calcul::description-generale}

Dans cette partie, nous considérons une restriction du langage à un
sous-ensemble consistant en un lambda-calcul avec typecase (c'est-à-dire en
excluant les enregistrements et les listes,  et toutes les opérations s'y
rapportant).

Le système de types est divisé en deux parties : un système dit d'« inférence »
et un système dit de « check ».
Le premier correspond à une inférence de type classique « bottom-up »
(l'inférence est très locale : les types des arguments des fonctions en
particulier doivent être explicitement annotés).
Le second correspond à un système « top-down » qui ne fait pas d'inférence mais
cherche juste à vérifier qu'une expression accepte bien un type donné.
Ce double système est une extension naturelle de l'utilisation des annotations
de type pour l'inférence qui permet de les utiliser de façon moins locale. Dans
de nombreux langages, il est possible d'obtenir le même résultat en effectuant
d'abord une première passe qui va propager les annotations de type (c'est ce
qui est fait par exemple on OCaml pour ne pas être obligé d'annoter le type de
retour d'un pattern-matching sur un GADT juste à l'endroit où il est effectué,
mais pouvoir simplement annoter l'expression à top-level). Cependant, la
présence de types union et intersection rend certaines expressions impossibles
à annoter dans la mesure où elles se voient affecter différents types sous
différents environnements.
Par exemple, considérons l'expression suivante :

```
let f =
  λcond.λx.
    (_ = cond tin true) ? x + 1 : not x
in f
```

Dans cette expression, `x` doit avoir le type `Int` si `cond` vaut `true` et
`Bool` sinon.
Il est donc impossible de l'annoter (à part par le type `Int AND Bool` qui est
équivalent à `Empty` ou un type graduel).
Il est aussi impossible pour la même raison de propager une éventuelle
annotation de type de plus haut dans l'AST.

En revanche, le système de check permet, si l'on annote `f` avec le type `(true
-> Int -> Int) AND (false -> Bool -> Bool)` de vérifier que l'expression admet
les deux types `true -> Int -> Int` et `false -> Bool -> Bool`, et donc
l'intersection des deux.

### Typage des motifs

Pour cette restriction du langage, les seuls motifs possibles sont `<var>` ou
`<var>:<tau>`.

\newcommand{\accept}[1]{\lbag{}#1\rbag{}}
\newcommand{\tmatch}[2]{\sfrac{#2}{#1}}

On définit deux opérateurs $\accept{p}$ et $\tmatch{\tau}{p}$ correspondant
respectivement au type accepté par un motif $p$ et l'environnement de typage
produit par la confrontation du type $\tau$ au motif $p$ par :

\begin{align\*}
  \accept{x} &= \grad \\\\
  \accept{x:\tau} &= \tau
\end{align\*}

et

\begin{align\*}
  \tmatch{\tau}{x} &= x : \tau \\\\
  \tmatch{\sigma}{x:\tau} &= \sigma \cap \tau
\end{align\*}

Par défaut (en l'absence d'annotation), le type accepté par un motif est le
type graduel.

### Règles de typage

\newcommand{\tcheck}{\vdash^{\Downarrow}}
\newcommand{\tinfer}{\vdash^{\Uparrow}}
Le jugement $\Gamma \tinfer e : \tau$ correspond au système d'inférence et le
jugement $\Gamma \tcheck e : \tau$ au système de check.

Les règles pour les deux systèmes sont données par la
figure \pref{typing::lambda-calculus}.

#### Constantes et variables

\newcommand{\Bt}{\mathcal{B}}
On suppose l'existence d'une fonction $\Bt$ qui à toute constante $c$ associe
son type $\Bt(c)$.

#### Lambda-abstractions

Les arguments devant être annotés explicitement, l'inférence du type d'une
lambda-abstraction est assez simple et naturelle.

Le check est un peu plus délicat : L'idée pour vérifier qu'une expression
$\lambda p.e$ admet le type $\tau$ sous l'hypothèse $\Gamma$ est de, pour
chaque type flèche $\sigma\_1 \rightarrow \sigma\_2$ « contenue » dans le type
$\tau$ (sous réserve que $\tau$ est un sous-type − non graduel − de `Empty ->
Any`), vérifier que ce type est bien admis par l'expression, c'est-à-dire que
sous l'hypothèses $\Gamma; \tmatch{\sigma\_1}{p}$, $e$ admet le type
$\sigma\_2$.

\newcommand{\A}{\mathcal{A}}
La définition de l'ensemble des flèches « contenues » dans un type $\tau$ est
donnée par la fonction $\A$ construite comme suit :

Si $\tau$ est sous la forme

\begin{displaymath}
  \tau = \bigvee\limits\_{i\in I}\left(
    \bigwedge\limits\_{p\in P\_i} (\sigma\_p \rightarrow \tau\_p)
    \wedge \bigwedge\limits\_{n \in N\_i} \lnot (\sigma\_n \rightarrow \tau\_n)
  \right)
\end{displaymath}

alors $\A(\tau)$ est défini comme

\begin{displaymath}
  \A(\tau) = \bigsqcup\limits\_{i \in I} \\{ \sigma\_p \rightarrow \tau\_p | p \in P\_i \\}
\end{displaymath}

où $\sqcup$ est défini comme


\begin{displaymath}
  \\{ \sigma\_i \rightarrow \tau\_i \| i \in I \\} \sqcup \\{ \sigma\_j \rightarrow \tau\_j \| j \in J \\} =
    \\{ (\sigma\_i \wedge \sigma\_j) \rightarrow (\tau\_i \vee \tau\_j) \| i \in I, j \in J \\}
\end{displaymath}.

Il est montré dans @Fri04 qu'il est toujours possible de mettre $\tau$ sous la
forme précédente (cette possibilité est d'ailleurs fondamentale dans
l'algorithme de sous-typage, comme expliqué dans @Cas15).

Dans l'exemple de la section \ref{typage::lambda-calcul::description-generale}
le type $\tau$ est égal à `(true -> Int -> Int) AND (false -> Bool -> Bool)`,
donc $\A(\tau)$ vaut $\\{ \text{`true -> Int -> Int`}; \text{`false -> Bool ->
Bool`} \\}$.

\input{typage/lambda-inference-rules.tex}
