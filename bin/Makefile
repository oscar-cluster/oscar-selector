DESTDIR=

TOPDIR=..
include $(TOPDIR)/Config.mk

SCRIPTS := oscar-selector oscar-selector-gui
POD_FILES := oscar-selector
SUBDIRS :=

man:
	install -d -m 0755 $(DESTDIR)$(MANDIR)/man1/
	for bin in ${POD_FILES} ; do ( pod2man --section=1 $$bin $(DESTDIR)$(MANDIR)/man1/$$bin.1 ) ; done

all:
	for dir in ${SUBDIRS} ; do ( cd $$dir ; ${MAKE} all ) ; done

install: man
	install -d -m 0755 $(DESTDIR)/usr/bin
	install    -m 0755 $(SCRIPTS) $(DESTDIR)/usr/bin
	for dir in ${SUBDIRS} ; do ( cd $$dir ; ${MAKE} install ) ; done

uninstall:
	cd $(DESTDIR)/usr/bin; rm -f $(SCRIPTS)
	for dir in ${SUBDIRS} ; do ( cd $$dir ; ${MAKE} uninstall ) ; done

clean:
