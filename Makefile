# borrowed from
# http://tex.stackexchange.com/questions/40738/how-to-properly-make-a-latex-project

.PHONY: all clean

all: combined/main.pdf

%.pdf: %.tex common/header.tex FORCE
	latexmk -output-directory=out -pdf -xelatex -pv -use-make $<

clean:
	latexmk -CA

# Fore some reasons that are far behind my understanding of make, The PHONY
# rule doesn't work for the "%.pdf" rule, so let's use this old trick to
# force-rebuild them every time.
FORCE:
