# Contexte
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

### Syntaxe et sémantique
<!-- Expliquer au passage les points problématiques pour le typage -->
\input{contexte/nix/syntaxe-et-semantique}

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
\markdownInput{nix-light/motivation.md}

## Description
<!--  Description du langage, grammaire + sémantique -->
\markdownInput{nix-light/description.md}

## De Nix à Nix-light
<!--  Compilation -->
\markdownInput{nix-light/compilation.md}

# Typage

## Types et sous-typage
<!--  Présentation des types utilisés -->
<!--  Discussion autour du sous-typage lazy -->
<!--  Sous-typage graduel -->
\markdownInput{typage/types.md}

## Lambda-calcul
<!--  Typage du langage sans records et sans listes -->
\markdownInput{typage/lambda-calcul.md}

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
\markdownInput{typage/listes.md}

### Records
<!--  Typage des records. Probablement plein de choses à dire ici. -->

# Soundness du typage
<!--  Difficulté de définir la soundness avec le type graduel -->
<!--  Blablater sur la difficulté des preuves. -->

# Implémentation
<!--  Tout ce qui concerne l'implémentation. Probablement des choses à dire -->
