VERSION   ?= 0.4.1
DESTDIR   ?=
PREFIX    ?= /usr/local
MIRRORURL ?= https://xmirror.voidlinux.org/raw/mirrors.lst
PYTHON    ?= python3

.PHONY: all completions install clean deploy

all: xmirror completions deploy

xmirror: xmirror.in
	sed -e "s/@@VERSION@@/$(VERSION)/g; s,@@MIRRORURL@@,$(MIRRORURL),g" $< >$@+
	chmod +x $@+
	mv $@+ $@

completions: completions/_xmirror completions/xmirror.fish completions/xmirror.bash

completions/%: completions/%.in
	sed -e "s,@@PREFIX@@,$(PREFIX),g" $< >$@

install: all
	install -Dm 755 xmirror -t $(DESTDIR)$(PREFIX)/bin
	install -Dm 644 _site/raw/mirrors.lst -t $(DESTDIR)$(PREFIX)/share/xmirror
	install -Dm 644 completions/_xmirror -t $(DESTDIR)$(PREFIX)/share/zsh/site-functions
	install -Dm 644 completions/xmirror.fish -t $(DESTDIR)$(PREFIX)/share/fish/vendor_completions.d
	install -Dm 644 completions/xmirror.bash -t $(DESTDIR)$(PREFIX)/share/bash-completion/completions
	install -Dm 644 xmirror.1 -t $(DESTDIR)$(PREFIX)/share/man/man1

clean:
	rm -rf xmirror _site completions/_xmirror completions/xmirror.fish completions/xmirror.bash

README: xmirror.1
	mandoc -Tutf8 $< | col -bx >$@

deploy: mirrors.yaml web/index.html.in
	$(PYTHON) web/generate-site.py _site
