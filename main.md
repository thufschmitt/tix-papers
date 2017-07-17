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
\input{out/generated/context/nix/syntax-and-semantics}

## Set-theoretic types
<!--  Présentation de l'interprétation ensembliste des types -->
<!--  Justification informelle de pourquoi le système convient à Nix -->
\input{out/generated/context/set-theoretic-types}

# Nix-light <!--  TODO: find another name for this -->
\label{sec:nix-light}

## Motivation
<!--
  Explication de pourquoi nix est trop permissif et pourquoi il vaut mieux
  bosser sur autre chose.
-->
\input{out/generated/nix-light/motivation.tex}

## Description
<!--  Description du langage, grammaire + sémantique -->
\input{out/generated/nix-light/description.tex}

## From Nix to Nix-light
<!--  Compilation -->
\input{out/generated/nix-light/compilation.tex}

# Typing

## Types and subtyping
<!--  Présentation des types utilisés -->
<!--  Discussion autour du sous-typage lazy -->
<!--  Sous-typage graduel -->
\input{out/generated/typing/types.tex}

## Lambda-calculus
<!--  Typage du langage sans records et sans listes -->
\input{out/generated/typing/lambda-calculus.tex}

## Data structures
<!--  Description du typage des deux structures de données de Nix -->

### Lists
<!--
  Typage des listes. Rien de très compliqué, mais les regexp-lists nécessitent
  peut-être un peu d'explication. À voir si on garde comme une sous-partie ou
  si on merge dans la section "lambda-calcul", vu que c'est ni central ni
  original (mais joli par contre)
-->
\label{typing::structures::listes}
\input{out/generated/typing/lists.tex}

### Records
<!--  Typage des records. Probablement plein de choses à dire ici. -->
\input{out/generated/typing/records.tex}

## About soundness
<!--  Difficulté de définir la soundness avec le type graduel -->
<!--  Blablater sur la difficulté des preuves. -->
\input{out/generated/typing/about-soundness.tex}

# Implementation
<!--  Tout ce qui concerne l'implémentation. Probablement des choses à dire -->
