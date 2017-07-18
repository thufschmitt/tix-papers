# borrowed from
# http://tex.stackexchange.com/questions/40738/how-to-properly-make-a-latex-project

VIEWER=evince

.PHONY: clean main.pdf

GENERATED_LATEX=$(shell find . -name '*.md' | sed 's_./\(.*\).md_out/generated/\1.tex_g')

all: main.pdf

view: main.pdf
	$(VIEWER) out/main.pdf

check: FORCE
	chktex -g0 -l .chktexrc main.tex

main.pdf: main.tex $(GENERATED_LATEX)
	latexmk \
	  -output-directory=out \
	  -pdf \
	  -xelatex \
	  -bibtex \
	  -use-make \
	  -interaction=nonstopmode \
	  $<

out/generated/%.tex: %.md
	mkdir -p $(shell dirname $@)
	pandoc \
	  --from markdown-auto_identifiers \
	  --listings \
	  --biblatex \
	  $< \
	  -o $@

clean:
	rm -r out

# Fore some reasons that are far behind my understanding of make, The PHONY
# rule doesn't work for the "%.pdf" rule, so let's use this old trick to
# force-rebuild them every time.
FORCE:
