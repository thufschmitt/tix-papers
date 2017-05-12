# borrowed from
# http://tex.stackexchange.com/questions/40738/how-to-properly-make-a-latex-project

VIEWER=evince

.PHONY: all clean

all: combined/main.pdf

view: combined/main.pdf
	$(VIEWER) out/main.pdf

check: FORCE
# Warning 11 is \ldots vs \cdots.
# We disable it as we use both in the same context to differentiate
# syntax and meta-syntax
	chktex -g0 -l .chktexrc -n11 combined/main.tex

%.pdf: %.tex common/header.tex FORCE
	latexmk -output-directory=out -pdf -xelatex -use-make $<

clean:
	rm -r out

# Fore some reasons that are far behind my understanding of make, The PHONY
# rule doesn't work for the "%.pdf" rule, so let's use this old trick to
# force-rebuild them every time.
FORCE:
