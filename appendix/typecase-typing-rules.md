\begin{figure}[H]
  \begin{mathpar}
    \inferrule{ }{\vdash c : \Bt(c)}
    \and
    \inferrule{ }{\vdash λx.e : \Empty \rightarrow \Any}
    \and
    \inferrule{ }{\vdash \{ x_1 = e_1; \cdots; x_n = e_n; \} : \{ x_1 = \Any; \cdots; x_n = \Any; \} }
    \and
    \inferrule{ }{\vdash \cons(e_1, e_2) : \cons(\Any, \Any)}
  \end{mathpar}
  \caption{Typing judgement of the typecase\label{nix-light::typecase-typing}}
\end{figure}

