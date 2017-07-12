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

\begin{align*}
  \accept{x} &= \grad \\
  \accept{x:\tau} &= \tau
\end{align*}

et

\begin{align*}
  \tmatch{\tau}{x} &= x : \tau \\
  \tmatch{\sigma}{x:\tau} &= \sigma \cap \tau
\end{align*}

Par défaut (en l'absence d'annotation), le type accepté par un motif est le
type graduel.

### Règles de typage

Le jugement $\Gamma \tinfer e : \tau$ correspond au système d'inférence et le
jugement $\Gamma \tcheck e : \tau$ au système de check.
La notation $\Gamma \tIC e : \tau$ signifie au choix $\Gamma \tinfer e : \tau$
ou $\Gamma \tcheck e : \tau$ (mais toujours le même dans une même règle
d'inférence).

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
chaque type flèche $\sigma_1 \rightarrow \sigma_2$ « contenue » dans le type
$\tau$ (sous réserve que $\tau$ est un sous-type − non graduel − de `Empty ->
Any`), vérifier que ce type est bien admis par l'expression, c'est-à-dire que
sous l'hypothèses $\Gamma; \tmatch{\sigma_1}{p}$, $e$ admet le type
$\sigma_2$.

\newcommand{\A}{\mathcal{A}}
La définition de l'ensemble des flèches « contenues » dans un type $\tau$ est
donnée par la fonction $\A$ construite comme suit :

Si $\tau$ est sous la forme

\begin{displaymath}
  \tau = \bigvee\limits_{i\in I}\left(
    \bigwedge\limits_{p\in P_i} (\sigma_p \rightarrow \tau_p)
    \wedge \bigwedge\limits_{n \in N_i} \lnot (\sigma_n \rightarrow \tau_n)
  \right)
\end{displaymath}

alors $\A(\tau)$ est défini comme

\begin{displaymath}
  \A(\tau) = \bigsqcup\limits_{i \in I} \{ \sigma_p \rightarrow \tau_p | p \in P_i \}
\end{displaymath}

où $\sqcup$ est défini comme


\begin{displaymath}
  \{ \sigma_i \rightarrow \tau_i \| i \in I \} \sqcup \{ \sigma_j \rightarrow \tau_j \| j \in J \} =
    \{ (\sigma_i \wedge \sigma_j) \rightarrow (\tau_i \vee \tau_j) \| i \in I, j \in J \}
\end{displaymath}.

Il est montré dans @Fri04 qu'il est toujours possible de mettre $\tau$ sous la
forme précédente (cette possibilité est d'ailleurs fondamentale dans
l'algorithme de sous-typage, comme expliqué dans @Cas15).

Dans l'exemple de la section \ref{typage::lambda-calcul::description-generale}
le type $\tau$ est égal à `(true -> Int -> Int) AND (false -> Bool -> Bool)`,
donc $\A(\tau)$ vaut $\\{ \text{`true -> Int -> Int`}; \text{`false -> Bool ->
Bool`} \\}$.

#### Application

\newcommand{\dom}{\tilde{\operatorname{Dom}}}
\newcommand{\image}{\tilde{\circ}}

La règle d'inférence de l'application est elle aussi légèrement différente de
celle utilisée dans le lambda calcul simplement typé : la présence de type
union et intersection fait que les types de fonction ne sont pas nécessairement
des types flèche (syntaxiquement), mais sont tous les sous-types du type `Empty
-> Any`.
La définition du domaine et du codomaine d'un type de fonction est donc plus
complexe.
Nous reprenons les définitions des opérateurs $\dom$ et $\image$ définis dans
@CL17, en donnant simplement les intuitions suivantes pour ces opérateurs :
$\dom(\tau)$ correspond au domaine des fonctions de type $\tau$ (en supposant
que $\tau$ est un type de fonction), et $\tau \image \sigma$ correspond à
l'image de l'ensemble des éléments de type $\sigma$ par les fonctions de type
$\tau$.

La règle de check est plus simple mais nécessite d'utiliser un peu d'inférence,
dans la mesure ou le type de l'argument n'est pas donné. Pour vérifier que
$\Gamma \tcheck e_1 e_2 : \tau$, il faut donc inférer que $e_2$ a un
certain type $\sigma$ et ensuite vérifier que $e_1$ a le type $\sigma
\rightarrow \tau$ (on pourrait aussi vouloir inférer le type $\sigma$ de
$e_1$, et en déduire le type que doit avoir $e_2$ comme l'image inverse de
$\tau$ par $\sigma$, mais cette approche est nettement plus complexe et semble
moins utile en pratique).

#### Let-bindings

Les let-bindings sont les endroits où le système passe de mode inférence au
mode check : pour chaque variable, si elle est annotée, alors on vérifie que sa
définition a le bon type, sinon on infère le type de sa définition.
Dans le mesure ou les let-bindings sont récursifs, il faut attribuer un type
par défaut aux variables non annotées pour typer les définitions. Ce type est
choisi comme étant `?` (mais l'inférence ou le check du type de l'expression
finale utilise le type inféré pour ces variables, et pas `?`).
Cette règle est assez lourde, mais présente l'avantage d'être très générale. En
particulier, elle permet de typer les let-bindings qui ne sont pas récursifs
sans nécessiter d'annotation et sans perte de généralité.

#### Typecase

Le typage du typecase utilise l'« occurence typing », c'est-à-dire que pour
typer l'expression `(x = e tin T) ? e1 : e2`, le type de `x` est raffiné
dans chacune des branches.
De plus, si le système arrive à déterminer que `x` est toujours de type `T` (ou
`not T`), alors la branche inutilisée n'est pas typée. Cette caractéristique se
justifie si l'on considère l'exemple présenté
en \ref{typage::lambda-calcul::description-generale}. En effet, on veut que
l'expression `(y = cond tin true) ? x + 1 : not x` soit bien typée sous les
hypothèses `cond : true; x : Int` (resp. `cond: false; x : Bool`) alors que
`not x` (resp. `x + 1`) ne l'est pas.
Enfin, il n'est pas nécessaire d'inférer le même type pour les deux branches
puisque le type final est l'union des types de chaque branche. Cette
possibilité est nécessaire à cause du sous-typage (puisque le type obtenu pour
une des branches peut être trop précis : par exemple, on veut accepter
l'expression `(x = e tin T) ? 1 : 2` alors que la première branche a le type
`1` et la seconde le type `2`).

Même pour vérifier le type d'un typecase, il faut inférer le type
de l'expression testée puisqu'on n'a pas d'information sur son type.

\input{typage/lambda-inference-rules.tex}
