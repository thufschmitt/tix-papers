# borrowed from
# http://tex.stackexchange.com/questions/40738/how-to-properly-make-a-latex-project

VIEWER=evince

.PHONY: all clean

all: main.pdf

view: main.pdf
	$(VIEWER) out/main.pdf

check: FORCE
	chktex -g0 -l .chktexrc main.tex

%.pdf: %.tex FORCE
	latexmk -output-directory=out -pdf -xelatex -use-make $<

clean:
	rm -r out

# Fore some reasons that are far behind my understanding of make, The PHONY
# rule doesn't work for the "%.pdf" rule, so let's use this old trick to
# force-rebuild them every time.
FORCE:
