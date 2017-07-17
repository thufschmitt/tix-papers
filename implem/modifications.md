We here presented a fixed type-system. However several rules may be modified
depending on the exact notion of safety we want to achieve.
For example, we may consider that trying to access an undefined field of a
record is an invalid operation that our type-system has to catch, or that it is
a valid operation that raises a runtime error.
We here adopted the first point of view, but taking the second one is possible
by replacing the *RAccess* rule with the two rules from
figure \ref{implem::lax-records}:

\begin{figure}
  \begin{mathpar}
    \inferrule{%
      \Gamma \vdash e_1 : \τ \\
      \Gamma \vdash e_2 : \bigvee\limits_{i=1}^n s_i \\
      \τ \subtypeG \left\{ .. \right\} \\
    }{%
      \Gamma \vdash e_1 . e_2 : \left(
        \bigvee\limits_{i=1}^n \τ(s_i)
      \right) \backslash \undefr
    }\lbl{RAccessFinite}

    \and\inferrule{%
      \Gamma \vdash e_1 : \τ \\
      \Gamma \vdash e_2 : \sigma \\
      \sigma \subtype \text{String} \\
      \τ \subtypeG \left\{ .. \right\} \\
    }{%
        \Gamma \vdash e_1 . e_2 :
        \left( \defr(\τ) \vee
          \bigvee\limits_{s \in \dom(\τ)} \τ(s) \right) \backslash \undefr
    }\lbl{RAccessInfinite}
  \end{mathpar}
  \caption{More permissive rules for the typing of record access\label{implem::lax-records}}
\end{figure}

The same can also be done for the definition of records (considering that the
same field appearing twice is a runtime error not covered by the typechecker).
