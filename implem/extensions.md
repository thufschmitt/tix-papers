The language we until here referred to as Nix was only a subset of the actual
Nix language.

We here present some parts of the language that have been omitted until now.

### The import statement

The import statement^[Which is just a function in Nix, but with a very special
semantic] allows importing other files. Its syntax is `import e` where `e`
should evaluate to a string representing an absolute path.
The semantic of this is that if the body of the file `s` reduces to a value
`v`, then `import s` reduces to `v` (so this isn't a textual inclusion: the
current scope isn't available in the imported file).

We here restrict ourselves to the cases where the argument of import is a
literal string (which means that the included file is statically known).

The syntax of Nix-light operators is extended as follows:

```
<operators> :: = ... | import (<expr>)
```

Where the expression in argument is the content of the imported file.
This means that we also add a compilation rule of the form:

\begin{displaymath}
  °(|import s|)° = °import(e)° \text{ where } °e° = \operatorname{PARSE}(°s°)
\end{displaymath}

Where "PARSE" is a (meta-)function which parses the file at the given location.

We also add a reduction rule

\begin{displaymath}
  °import(e)° \rightsquigarrow °e°
\end{displaymath}

and the convention that variable substitutions don't propagate under the
`import` operator.
