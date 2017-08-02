\begin{figure}[H]
  \newcommand{\imp}[1]{\texttt{\color{red}#1}}
  \small
  \begin{lstlisting}
<expr> ::=
  <ident> | <constant>
  | λ <pattern>.<expr> | <expr> <expr>
  | let <var-pattern> = <expr>; $\cdots$; <var-pattern> = <expr>; in <expr>
  | [ <expr> $\cdots$ <expr> ]
  | { <record-field>; $\cdots$; <record-field>; }
  | rec { <record-field>; $\cdots$; <record-field>; }
  | if <expr> then <expr> else <expr>
  | <expr>.<acces-path>
  | <expr>.<acces-path> or <expr>
  | <expr> <infix-op> <expr>
  | //* \imp{<expr> : <τ> } *//

<constant> ::= <string> | <integer> | <boolean> | <paths>

<record-field> ::= inherit <ident> $\cdots$ <ident>
  | inherit (<expr>) <ident> <ident>
  | <access-path> = <expr> | //* \imp{<access-path> : <τ> = <expr>}*//

<pattern> ::= <record-pattern> | <record-pattern>@<ident>
  | <var-pattern>

<var-pattern> ::= <ident> | //* \imp{<ident> : <τ>}*//

<record-pattern> ::=
  | { <record-pattern-field>, $\cdots$, <record-pattern-field> }
  | { <record-pattern-field>, $\cdots$, <record-pattern-field>, ... }

<record-pattern-field> ::= <var-pattern> | <var-pattern> ? <expr>

<access-path> ::= <access-path-item>. $\cdots$ . <access-path-item>

<access-path-item> ::= <ident> | { <expr> }

<infix-op> ::= + | - | * | / | // | ++ | $\cdots$
  \end{lstlisting}
  \caption{Syntax of the Nix language\label{nix::syntax}}
\end{figure}

\begin{figure}[H]
  \begin{lstlisting}
<basetype> ::= Bool | Int | String | Any | Empty

<t> ::= <constant> | <t> $\rightarrow$ <t>
  | <t> $\vee$ <t> | <t> $\wedge$ <t> | $\lnot$ <t>
  | [<R>]
  | { <ident> = <t>; $\cdots$; <ident> = <t>; _ = <t> }
  | <basetype>

<R> ::= <t> | <R>+ | <R>* | <R>?
  | <R> <R> | <R> ¦ <R>

<τ> ::= <t> | <τ> $\rightarrow$ <τ>
  | <τ> $\vee$ <τ> | <τ> $\wedge$ <τ>
  | [<ρ>] | [<ρ> ?? ]
  | { <ident> = <τ>; $\cdots$; <ident> = <τ>; _ = <τ> }
  | ?

<ρ> ::= <τ> | <ρ>+ | <ρ>* | <ρ>?
  | <ρ> <ρ> | <ρ> ¦ <ρ>
  \end{lstlisting}
  \caption{Syntax of Nix types\label{nix::types}}
\end{figure}
