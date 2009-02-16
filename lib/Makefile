DESTDIR=

TOPDIR=..
include $(TOPDIR)/Config.mk

UI_FILES := SelectorImages.pm SelectorTableItem.pm SelectorAbout.pm \
		SelectorManageSets.pm SelectorTable.pm SelectorCheckTableItem.pm \
		Selector.pl SelectorUtils.pm
FILES := PackageSet.pm
SUBDIRS := 

all:
	for dir in ${SUBDIRS} ; do ( cd $$dir ; ${MAKE} all ) ; done

install-gui:
	install -d -m 0755 $(DESTDIR)$(LIBDIR)/Qt
	install    -m 0755 ${UI_FILES} $(DESTDIR)$(LIBDIR)/Qt

install-backend:
	install -d -m 0755 $(DESTDIR)$(LIBDIR)/OSCAR
	install    -m 755 ${FILES} $(DESTDIR)$(LIBDIR)/OSCAR
	for dir in ${SUBDIRS} ; do ( cd $$dir ; ${MAKE} install ) ; done

install: install-gui install-backend

uninstall:
	cd $(DESTDIR)$(LIBDIR)/Qt; rm -f $(FILES)
	for dir in ${SUBDIRS} ; do ( cd $$dir ; ${MAKE} uninstall ) ; done

clean:
