DESTDIR=

include ./Config.mk

SUBDIRS := bin lib doc

all:
	for dir in ${SUBDIRS} ; do ( cd $$dir ; ${MAKE} all ) ; done

install:
	for dir in ${SUBDIRS} ; do ( cd $$dir ; ${MAKE} install ) ; done

uninstall:
	for dir in ${SUBDIRS} ; do ( cd $$dir ; ${MAKE} uninstall ) ; done

clean:
	@rm -f build-stamp configure-stamp
	@rm -rf debian/oscar-selector
	@rm -f oscar-selector.tar.gz
	@rm -f oscar-selector.spec
	for dir in ${SUBDIRS} ; do ( cd $$dir ; ${MAKE} clean ) ; done

dist: clean
	@rm -rf /tmp/oscar-selector
	@mkdir -p /tmp/oscar-selector
	@cp -rf * /tmp/oscar-selector
	@cd /tmp/oscar-selector; rm -rf `find . -name ".svn"`
	@cd /tmp; tar czf oscar-selector.tar.gz oscar-selector
	@cp -f /tmp/oscar-selector.tar.gz .
	@rm -rf /tmp/oscar-selector/
	@rm -f /tmp/oscar-selector.tar.gz

rpm: dist
	sed -e "s/PERLLIBPATH/$(SEDLIBDIR)/" < oscar-selector.spec.in \
        > oscar-selector.spec
	cp oscar-selector.tar.gz /usr/src/redhat/SOURCES
	rpmbuild -bb ./oscar-selector.spec

deb:
	dpkg-buildpackage -rfakeroot
