BINDIR=/usr/bin
MANDIR=/usr/share/man
SYSCONFDIR=/etc
INITDDIR=/etc/init.d
USERUNITDIR=/usr/lib/systemd/user
DESTDIR=

all: doc/eyefiserver.1.gz doc/eyefiserver.conf.5.gz systemd/user/eyefiserver.service

dist: clean
	DIR=EyeFiServer-`awk '/^Version:/ {print $$2}' rpm/eyefiserver.spec` && FILENAME=$$DIR.tar.gz && tar cvzf "$$FILENAME" --exclude "$$FILENAME" --exclude .git --exclude .gitignore -X .gitignore --transform=s/^\./$$DIR/ --show-transformed .

rpm: dist
	T=`mktemp -d` && rpmbuild --define "_topdir $$T" -ta EyeFiServer-`awk '/^Version:/ {print $$2}' rpm/eyefiserver.spec`.tar.gz || { rm -rf "$$T"; exit 1; } && mv "$$T"/RPMS/noarch/* "$$T"/SRPMS/* . || { rm -rf "$$T"; exit 1; } && rm -rf "$$T"

install: all
	install -Dm 755 src/eyefiserver -t $(DESTDIR)/$(BINDIR)/
	install -Dm 644 etc/eyefiserver.conf -t $(DESTDIR)/$(SYSCONFDIR)/
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

clean:
	rm -f doc/*.gz systemd/user/eyefiserver.service

.PHONY: install clean
