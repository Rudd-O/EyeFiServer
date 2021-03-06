BINDIR=/usr/bin
MANDIR=/usr/share/man
SYSCONFDIR=/etc
INITDDIR=/etc/init.d
DESKTOPDIR=/usr/share/applications
USERUNITDIR=/usr/lib/systemd/user
UNITDIR=/usr/lib/systemd/system
UPLOADDIR=~/eyefi/%Y/%Y%m%d
DESTDIR=

all: doc/eyefiserver.1.gz doc/eyefiserver.conf.5.gz etc/eyefiserver.conf systemd/system/eyefiserver.service systemd/user/eyefiserver.service desktop/eyefiserver-prefs.desktop

dist: clean
	DIR=EyeFiServer-`awk '/^Version:/ {print $$2}' rpm/eyefiserver.spec` && FILENAME=$$DIR.tar.gz && tar cvzf "$$FILENAME" --exclude "$$FILENAME" --exclude .git --exclude .gitignore -X .gitignore --transform="s|^|$$DIR/|" --show-transformed *

rpm: dist
	T=`mktemp -d` && rpmbuild --define "_topdir $$T" -ta EyeFiServer-`awk '/^Version:/ {print $$2}' rpm/eyefiserver.spec`.tar.gz || { rm -rf "$$T"; exit 1; } && mv "$$T"/RPMS/noarch/* "$$T"/SRPMS/* . || { rm -rf "$$T"; exit 1; } && rm -rf "$$T"

install: all
	install -Dm 755 src/eyefiserver -t $(DESTDIR)/$(BINDIR)/
	install -Dm 755 src/eyefiserver-prefs -t $(DESTDIR)/$(BINDIR)/
	install -Dm 600 etc/eyefiserver.conf -t $(DESTDIR)/$(SYSCONFDIR)/
	install -Dm 644 desktop/eyefiserver-prefs.desktop -t $(DESTDIR)/$(DESKTOPDIR)/
	install -Dm 644 systemd/system/eyefiserver.service -t $(DESTDIR)/$(UNITDIR)/
	install -Dm 644 systemd/user/eyefiserver.service -t $(DESTDIR)/$(USERUNITDIR)/
	install -Dm 755 etc/init.d/eyefiserver -t $(DESTDIR)/$(INITDDIR)/
	install -Dm 644 doc/eyefiserver.1.gz -t $(DESTDIR)/$(MANDIR)/man1/
	install -Dm 644 doc/eyefiserver.conf.5.gz -t $(DESTDIR)/$(MANDIR)/man5/

doc/eyefiserver.1.gz: doc/eyefiserver.txt
	txt2man -t eyefiserver -r "eyefiserver" -s 1 -v "Executable programs or shell commands" -I file doc/eyefiserver.txt > doc/eyefiserver.1
	gzip doc/eyefiserver.1

doc/eyefiserver.conf.5.gz: doc/eyefiserver.txt
	txt2man -t eyefiserver.conf -r "eyefiserver %{version}" -s 5 -v "File formats and conventions" doc/eyefiserver.conf.txt > doc/eyefiserver.conf.5
	gzip doc/eyefiserver.conf.5

systemd/user/eyefiserver.service: systemd/user/eyefiserver.service.in
	sed 's|@BINDIR@|$(BINDIR)|g' < $< > $@

systemd/system/eyefiserver.service: systemd/system/eyefiserver.service.in
	sed -e 's|@BINDIR@|$(BINDIR)|g' -e 's|@SYSCONFDIR@|$(SYSCONFDIR)|g' < $< > $@

etc/eyefiserver.conf: etc/eyefiserver.conf.in
	sed 's|@UPLOADDIR@|$(UPLOADDIR)|g' < $< > $@

desktop/eyefiserver-prefs.desktop: desktop/eyefiserver-prefs.desktop.in
	sed 's|@BINDIR@|$(BINDIR)|g' < $< > $@

clean:
	rm -f doc/*.gz etc/eyefiserver.conf systemd/system/eyefiserver.service systemd/user/eyefiserver.service desktop/eyefiserver-prefs.desktop

gitclean:
	LANG=C git status | grep -q 'orking directory clean' && { git clean -fxd ; } || { git status ; read -p "Some of these changes will be lost.  Hit ENTER to confirm, Ctrl+C to cancel. " ; git clean -fxd ; }

.PHONY: install clean
