# Context
<!-- État de l'art, motivation du stage -->

## Nix
<!--
  Description de Nix et de toutes les horreurs qu'il contient
  Explication rapide de ce qui est nécessaire pour le typer à peu près
  raisonnablement
 -->

### Présentation générale
<!--
  Explication de son utilisation et justification de la volonté de le typer
-->
\input{contexte/nix/presentation-generale}

### Syntax and semantics
\input{generated/context/nix/syntax-and-semantics}

## Types ensemblistes
<!--  Présentation de l'interprétation ensembliste des types -->
<!--  Justification informelle de pourquoi le système convient à Nix -->
\input{contexte/types-ensemblistes}

# Nix-light <!--  TODO: find another name for this -->
\label{sec:nix-light}

## Motivation
<!--
  Explication de pourquoi nix est trop permissif et pourquoi il vaut mieux
  bosser sur autre chose.
-->
\input{generated/nix-light/motivation.tex}

## Description
<!--  Description du langage, grammaire + sémantique -->
\input{generated/nix-light/description.tex}

## De Nix à Nix-light
<!--  Compilation -->
\input{generated/nix-light/compilation.tex}

# Typage

## Types et sous-typage
<!--  Présentation des types utilisés -->
<!--  Discussion autour du sous-typage lazy -->
<!--  Sous-typage graduel -->
\input{generated/typage/types.tex}

## Lambda-calcul
<!--  Typage du langage sans records et sans listes -->
\input{generated/typage/lambda-calcul.tex}

## Structures de données
<!--  Description du typage des deux structures de données de Nix -->

### Listes
<!--
  Typage des listes. Rien de très compliqué, mais les regexp-lists nécessitent
  peut-être un peu d'explication. À voir si on garde comme une sous-partie ou
  si on merge dans la section "lambda-calcul", vu que c'est ni central ni
  original (mais joli par contre)
-->
\label{typage/structures/listes}
\input{generated/typage/listes.tex}

### Records
<!--  Typage des records. Probablement plein de choses à dire ici. -->

# Soundness du typage
<!--  Difficulté de définir la soundness avec le type graduel -->
<!--  Blablater sur la difficulté des preuves. -->

# Implémentation
<!--  Tout ce qui concerne l'implémentation. Probablement des choses à dire -->
