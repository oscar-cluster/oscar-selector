DESTDIR=
PKGDEST=
PKG=oscar-selector

include ./Config.mk

BACKEND_SUBDIRS := bin doc lib

all:
	for dir in ${BACKEND_SUBDIRS} ; do ( cd $$dir ; ${MAKE} all ) ; done

install:
	for dir in ${BACKEND_SUBDIRS} ; do ( cd $$dir ; ${MAKE} install ) ; done

uninstall:
	for dir in ${BACKEND_SUBDIRS} ; do ( cd $$dir ; ${MAKE} uninstall ) ; done

clean:
	@rm -f build-stamp configure-stamp
	@rm -rf debian/$(PKG) debian/$(PKG)-x11
	@rm -f debian/files debian/oscar-selector.debhelper.log
	@rm -f $(PKG).tar.gz
	for dir in ${BACKEND_SUBDIRS} ; do ( cd $$dir ; ${MAKE} clean ) ; done
	for dir in ${GUI_SUBDIRS} ; do ( cd $$dir ; ${MAKE} clean ) ; done

dist: clean
	@rm -rf ./tmp/$(PKG)
	@mkdir -p ./tmp/$(PKG)
	tar --exclude=tmp --exclude=.git -cvf - . | (cd ./tmp/$(PKG) && tar xvf -)
	@cd ./tmp; tar czf $(PKG).tar.gz $(PKG)
	@mv -f ./tmp/$(PKG).tar.gz .
	@rm -rf ./tmp/$(PKG)/

rpm: dist
	cp $(PKG).tar.gz `rpm --eval '%_sourcedir'`
	rpmbuild -bb ./$(PKG).spec
	@if [ -n "$(PKGDEST)" ]; then \
        mv `rpm --eval '%{_topdir}'`/RPMS/noarch/$(PKG)-*.noarch.rpm $(PKGDEST); \
    fi

deb:
	@if [ -n "$$UNSIGNED_OSCAR_PKG" ]; then \
        echo "dpkg-buildpackage -rfakeroot -us -uc"; \
        dpkg-buildpackage -rfakeroot -us -uc; \
    else \
        echo "dpkg-buildpackage -rfakeroot"; \
        dpkg-buildpackage -rfakeroot; \
    fi
	@if [ -n "$(PKGDEST)" ]; then \
        mv ../$(PKG)*.deb $(PKGDEST); \
    fi
