# borrowed from
# http://tex.stackexchange.com/questions/40738/how-to-properly-make-a-latex-project

.PHONY: all clean

all: grammar/grammar.pdf semantics/semantics.pdf typing/records.pdf \
  typing/type-system.pdf

%.pdf: %.tex common/header.tex FORCE
	latexmk -cd -pdf -xelatex -pv -use-make $<

clean:
	latexmk -CA

# Fore some reasons that are far behind my understanding of make, The PHONY
# rule doesn't work for the "%.pdf" rule, so let's use this old trick to
# force-rebuild them every time.
FORCE:
