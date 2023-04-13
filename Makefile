VERSION   ?= 0.1
DESTDIR   ?=
PREFIX    ?= /usr/local
MIRRORURL ?= https://xmirror.voidlinux.org/raw/mirrors.lst

.PHONY: all completions install clean deploy

all: xmirror completions

xmirror: xmirror.in
	sed -e "s/@@VERSION@@/$(VERSION)/g; s,@@MIRRORURL@@,$(MIRRORURL),g" $< >$@+
	chmod +x $@+
	mv $@+ $@

completions: completions/_xmirror completions/xmirror.fish

completions/%: completions/%.in
	sed -e "s,@@PREFIX@@,$(PREFIX),g" $< >$@

install: all
	install -Dm 755 xmirror -t $(DESTDIR)$(PREFIX)/bin
	install -Dm 644 mirrors.lst -t $(DESTDIR)$(PREFIX)/share/xmirror
	install -Dm 644 completions/_xmirror -t $(DESTDIR)$(PREFIX)/share/zsh/site-functions
	install -Dm 644 completions/xmirror.fish -t $(DESTDIR)/$(PREFIX)/share/fish/vendor_completions.d
	install -Dm 644 xmirror.1 -t $(DESTDIR)$(PREFIX)/share/man/man1

clean:
	rm -rf xmirror _site completions/_xmirror completions/xmirror.fish

README: xmirror.1
	mandoc -Tutf8 $< | col -bx >$@

deploy: mirrors.lst
	mkdir -p _site/raw
	# a hacky but simple homepage that redirects to the manpage
	@echo 'generating redirect page at _site/index.html'
	@printf '<!DOCTYPE html><html><head><meta http-equiv="refresh" content="0; url=' > _site/index.html
	@printf "'https://man.voidlinux.org/xmirror.1'" >> _site/index.html
	@printf '" /></head>' >> _site/index.html
	@printf '<body><p><a href="https://man.voidlinux.org/xmirror.1">Redirect</a></p></body>' >> _site/index.html
	@printf '</html>\n' >> _site/index.html
	cp mirrors.lst _site/raw/
