DESTDIR=

TOPDIR=../..
include $(TOPDIR)/Config.mk

UI_FILES := SelectorImages.pm SelectorTableItem.pm SelectorAbout.pm \
        SelectorManageSets.pm SelectorTable.pm SelectorCheckTableItem.pm \
        Selector.pl SelectorUtils.pm SelectorWindow.pm
SUBDIRS :=

all:
	for dir in ${SUBDIRS} ; do ( cd $$dir ; ${MAKE} all ) ; done

install:
	install -d -m 0755 $(DESTDIR)$(LIBDIR)/Qt
	install    -m 0755 ${UI_FILES} $(DESTDIR)$(LIBDIR)/Qt

uninstall:
	cd $(DESTDIR)$(LIBDIR)/Qt; rm -f $(FILES)
	for dir in ${SUBDIRS} ; do ( cd $$dir ; ${MAKE} uninstall ) ; done

clean:
	rm -f *~
