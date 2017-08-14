\begin{figure}[H]
  \small
  \begin{lstlisting}
<expr> ::= <ident> | <constant>
  | <expr>.<expr> | <expr>.<expr> or <expr>
  | λ <pattern>.<expr> | <expr> <expr>
  | let <var-pattern> = <expr>; $\cdots{}$; <var-pattern> = <expr>; in <expr>
  | Cons (<expr>, <expr>)
  | { <ident> = <expr>; ...; <ident> = <expr> }
  | (<ident> = <expr> $\in$ <$\hat{t}$>) ? <expr> : <expr>
  | <operator>
  | <expr>:<τ>

<constant> ::= <string> | <int> | <bool> | Nil

<operator> ::=
  | <expr> <infix-op> <expr>
  | Head(<expr>) | Tail(<expr>)

<infix-op> ::= + | - | * | / | // | ++ | $\cdots$

<pattern> ::= <record-pattern> | <record-pattern>@<ident>
  | <var-pattern>

<record-pattern> ::= <record-pattern>:τ
  | { <record-pattern-field>, $\cdots$, <record-pattern-field> }
  | { <record-pattern-field>, $\cdots$, <record-pattern-field>, … }

<record-pattern-field> ::= <var-pattern> | <var-pattern> ? <constant>

<var-pattern> ::= <ident> | <ident>:<τ>

<basetype> ::= Bool | Int | String | Any | Empty

<t> ::= <constant> | <basetype>
  | <t> $\vee$ <t> | <t> $\wedge$ <t> | $\lnot$ <t>
  | <t> $\rightarrow$ <t>
  | Cons(<t>, <t>) | let <ident> = <t>; $\cdots$; <ident> = <t> in <t>
  | { <ident> = <t>; $\cdots$; <ident> = <t>; _ = <t> }

<τ> ::= <constant> | <basetype> | <t> | ?
  | <τ> $\vee$ <τ> | <τ> $\wedge$ <τ>
  | <τ> $\rightarrow$ <τ>
  | Cons(<τ>, <τ>) | let <ident> = <τ>; $\cdots$; <ident> = <τ> in <τ>
  | { <ident> = <τ>; $\cdots$; <ident> = <τ>; _ = <τ> }

<$\hat{t}$> ::= <constant> | <basetype>
  | <$\hat{t}$> $\vee$ <$\hat{t}$> | <$\hat{t}$> $\wedge$ <$\hat{t}$> | $\lnot$ <$\hat{t}$>
  | Empty $\rightarrow$ Any
  | Cons(Any, Any)
  | { <ident> = Any; $\cdots$; <ident> = Any; _ = Any$\vee \nabla$ }
  \end{lstlisting}
  \caption{Nix-light grammar for expressions\label{nix-light::grammar}}
\end{figure}

\begin{figure}[H]
  \begin{lstlisting}
<value> ::=
  | <constant>
  | Cons(<expr>, <expr>)
  | { <ident> = <expr>; $\cdots$; <ident> = <expr>; }
  | λ<pattern>.<expr>
  \end{lstlisting}
  \caption{Nix-light grammar for values\label{nix-light::grammar::values}}
\end{figure}

