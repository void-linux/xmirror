VERSION:=0.0
DESTDIR:=
PREFIX:=/usr

.DEFAULT: xmirror
.PHONY: install clean

.help:
	awk '/^```help/ { in_block=1; next } /^```/ { exit } in_block { print }' README.md > .help

xmirror: .help
	sed -e "s/@@VERSION@@/$(VERSION)/g" xmirror.in > xmirror
	sed -e "/@@HELP@@/r .help" -i xmirror
	sed -e "/@@HELP@@/d" -i xmirror

install: xmirror
	install -Dm 755 xmirror -t $(DESTDIR)$(PREFIX)/bin
	install -Dm 644 mirrors.lst -t $(DESTDIR)$(PREFIX)/share/xmirror

clean:
	rm -f xmirror .help
