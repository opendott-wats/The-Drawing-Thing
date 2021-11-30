# Make sure you change the filename from Paper.md to something meaningful.
SOURCE := ReadMe.md
TARGET_NAME := "D2.3 Documentation of Prototype"

HTML := $(patsubst %.md,index.html, $(SOURCE))
PDF := $(patsubst %.md,%.pdf, $(SOURCE))
DOCX := $(patsubst %.md,%.docx, $(SOURCE))

# STYLE := _pandoc/pandoc.css
# Source: https://gist.github.com/killercup/5917178
# Make sure you save this in the same directory as shown or change the path.

OPTS :=  --from=markdown+smart+simple_tables+table_captions+yaml_metadata_block+smart

ARGS := \
	--citeproc \
	--filter pandoc-crossref \
	--csl=.styles/acm-sig-proceedings-long-author-list.csl \
	--toc

.PHONY : archive
archive:
	git archive -o $(TARGET_NAME).zip HEAD
	git submodule --quiet foreach 'cd "$$toplevel"; zip -ru $(TARGET_NAME).zip "$$sm_path"'

.PHONY : info
info:
	@echo --- Input ---
	@echo $(SOURCE)
	@echo --- Output ---
	@echo $(PDF)
	@echo $(HTML)
	@echo $(DOCX)


.PHONY : watch
watch:
	@echo ------ Building on file changes -----
	@ls *.md | entr make acm

.PHONY : all
all : $(HTML) $(PDF) $(DOCX)

.PHONY : html
html: $(HTML)
$(HTML) : $(SOURCE)
	@echo --- Generating HTML ---
	@pandoc $(OPTS)+ascii_identifiers $(ARGS) -s -w html \
		--self-contained \
		--default-image-extension=png \
		--mathjax \
		--metadata link-citations=true \
		--metadata linkReferences=true \
		-o $@ $<

.PHONY : pdf
pdf : $(PDF)
$(PDF) : $(SOURCE)
	@echo --- Generating PDF ---
	@pandoc $(OPTS)+raw_tex $(ARGS) -t pdf \
		--shift-heading-level-by=0 \
		--default-image-extension=pdf \
		-V papersize:a4 \
		--pdf-engine xelatex \
		-o $@ $<

.PHONY : doc
doc: $(DOCX)
$(DOCX) : $(SOURCE)
	@echo --- Generating DOCX ---
	@pandoc $(OPTS) $(ARGS) -w docx \
		--katex \
		--default-image-extension=png \
		--reference-doc=_pandoc/base.docx \
		-o $@ $<


.PHONY : clean
clean :
	@echo --- Deleting generated files ---
	@-rm $(HTML) $(PDF) $(DOCX)