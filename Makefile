VERSION:=0.0
DESTDIR:=
PREFIX:=/usr

.DEFAULT: xmirror
.PHONY: install clean deploy

.help:
	awk '/^```help/ { in_block=1; next } /^```/ { exit } in_block { print }' README.md > .help

xmirror: .help
	sed -e "s/@@VERSION@@/$(VERSION)/g" xmirror.in > xmirror
	sed -e "/@@HELP@@/r .help" -i xmirror
	sed -e "/@@HELP@@/d" -i xmirror

install: xmirror
	install -Dm 755 xmirror -t $(DESTDIR)$(PREFIX)/bin
	install -Dm 644 mirrors.lst -t $(DESTDIR)$(PREFIX)/share/xmirror
	install -Dm 644 completions/_xmirror -t $(DESTDIR)$(PREFIX)/share/zsh/site-functions

clean:
	rm -rf xmirror .help _site

deploy:
	mkdir -p _site/raw
	cp mirrors.lst _site/raw/
