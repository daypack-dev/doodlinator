ORG=daypack-dev
NAME=doodlinator
DOCDIR=.gh-pages

all:
	dune build bookmarklet/doodlinator.bc.js web/webpage.bc.js

test:
	dune runtest

clean:
	dune clean
	rm -f web/x.js web/script.js

web: all
	dune build --profile release bookmarklet/doodlinator.bc.js web/webpage.bc.js
	@cp -f _build/default/bookmarklet/doodlinator.bc.js web/x.js
	@cp -f _build/default/web/webpage.bc.js web/script.js

$(DOCDIR)/.git:
	mkdir -p $(DOCDIR)
	cd $(DOCDIR) && (\
		git clone -b gh-pages git@github.com:$(ORG)/$(NAME).git . \
	)

gh-pages: $(DOCDIR)/.git web
	git -C $(DOCDIR) pull
	cp -r www/* $(DOCDIR)/affe/
	git -C $(DOCDIR) add --all 
	git -C $(DOCDIR) commit -a -m "gh-page updates"
	git -C $(DOCDIR) push origin gh-pages
