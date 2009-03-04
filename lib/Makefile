DESTDIR=

TOPDIR=..
include $(TOPDIR)/Config.mk

FILES := PackageSet.pm SelectorCommon.pm
SUBDIRS := 

all:
	for dir in ${SUBDIRS} ; do ( cd $$dir ; ${MAKE} all ) ; done

install:
	install -d -m 0755 $(DESTDIR)$(LIBDIR)/OSCAR
	install    -m 755 ${FILES} $(DESTDIR)$(LIBDIR)/OSCAR
	for dir in ${SUBDIRS} ; do ( cd $$dir ; ${MAKE} install ) ; done

uninstall:
	cd $(DESTDIR)$(LIBDIR)/OSCAR; rm -f $(FILES)
	for dir in ${SUBDIRS} ; do ( cd $$dir ; ${MAKE} uninstall ) ; done

clean:
