\begin{figure}[H]
  \begin{align*}
    \interpr{b} &= b \\
    \interpr{c} &= c \\
    \interpr{\Empty} &= \Empty \\
    \interpr{\Any} &= \Any \\
    \interpr{Cons(τ, σ)} &= Cons(\interpr{τ} \vee \bot, \interpr{σ} \vee \bot) \\
    \interpr{τ \rightarrow σ} &= (\interpr{τ} \vee \bot) \rightarrow σ \\
    \interpr{τ \vee σ} &= \interpr{τ} \vee \interpr{σ} \\
    \interpr{τ \wedge σ} &= \interpr{τ} \wedge \interpr{σ} \\
    \interpr{\lnot t} &= \lnot (\interpr{t} \vee \bot) \\
    \interpr{\{ x_1 = τ_1; \cdots; x_n = τ_n; \_ = τ \}} &=
      \{ x_1 = \interpr{τ_1} \vee \bot; \cdots; x_n = \interpr{τ_n} \vee \bot;
        \_ = \interpr{τ} \vee \bot \}
  \end{align*}
  \caption{Rewriting of lazy types into strict ones\label{implem::lazy-rewriting}}
\end{figure}
