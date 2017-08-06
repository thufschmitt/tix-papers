\begin{figure}[H]
  \begin{displaymath}
    \flatten\left(\left\{ \seq{ apf_i = e_i;}{i \in I};
      \seq{\seq{apf_j.ap_k = e_k}{k \in K_j}}{j \in J} \right\}\right) =
      \left\{ \seq{ apf_i = e_i;}{i \in I}; \seq{ apf_j =
        \flatten\left(\left\{ \seq{ap_k = e_k;}{k \in K_j} \right\}\right)
        }{j \in J} \right\}
    \end{displaymath}
    \center
    Where the $apf$'s denote constructs of the form °<access-path-field>°
    and the $ap$'s constructs of the form °<access-path>°.
    We furthermore assume that the $apf_i$'s and $apf_j$'s are pairwise distinct
    (we consider that two access paths fields of the form °DOLLAR{e}° are always
     distinct).
    \caption{Definition of the $\flatten$ function on records\label{compilation::flatten}}
\end{figure}
\begin{figure}[H]
  \begin{displaymath}
    \derec\left(\text{ rec }\left\{ \seq{x_i = e_i }{i \in I} \right\}\right) =
      \text{let } \seq{x'_i = e'_i}{i \in I} \text{ in }
      \left\{ \seq{x_i = x'_i}{i \in I} \right\}
  \end{displaymath}

  \center Where the $x'_i$'s are fresh variables and each $e'_i$ is equal to
  $e_i\left[\seq{x_i := x'_i}{i \in I}\right]$.
  \caption{Definition of the $\derec$ function on records\label{compilation::derec}}
\end{figure}

