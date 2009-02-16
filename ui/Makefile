DESTDIR=

TOPDIR=..
include $(TOPDIR)/Config.mk

FILES := 
SUBDIRS := lib

all:
	for dir in ${SUBDIRS} ; do ( cd $$dir ; ${MAKE} all ) ; done

install:
	for dir in ${SUBDIRS} ; do ( cd $$dir ; ${MAKE} install ) ; done

uninstall:
	for dir in ${SUBDIRS} ; do ( cd $$dir ; ${MAKE} uninstall ) ; done

clean:
	for dir in ${SUBDIRS} ; do ( cd $$dir ; ${MAKE} clean ) ; done
