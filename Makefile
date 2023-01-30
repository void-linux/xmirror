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
	install -Dm 644 xmirror.1 -t $(DESTDIR)$(PREFIX)/share/man/man1

clean:
	rm -rf xmirror .help _site

deploy:
	mkdir -p _site/raw
	# a hacky but simple homepage that redirects to the manpage
	@echo 'generating redirect page at _site/index.html'
	@printf '<!DOCTYPE html><html><head><meta http-equiv="refresh" content="0; url=' > _site/index.html
	@printf "'https://man.voidlinux.org/xmirror.1'" >> _site/index.html
	@printf '" /></head>' >> _site/index.html
	@printf '<body><p><a href="https://man.voidlinux.org/xmirror.1">Redirect</a></p></body>' >> _site/index.html
	@printf '</html>\n' >> _site/index.html
	cp mirrors.lst _site/raw/
