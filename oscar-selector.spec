%define version     1.2.7
%define release     3

Summary:        OSCAR Package Selector.
Name:           oscar-selector
Version:        1.2.7
Release:        3
Vendor:         Open Cluster Group <http://OSCAR.OpenClusterGroup.org/>
Distribution:   OSCAR
Packager:       Geoffroy Vallee <valleegr@ornl.gov>
License:        GPL
Group:          Applications/System
Source:         %{name}.tar.gz
BuildArch:      noarch
Requires:	oscar-base-lib
Requires:	orm
BuildRequires:	perl
#BuildRequires:	dblatex, sgmltools-lite

BuildRoot:      %{_localstatedir}/tmp/%{name}-root

%package x11
Summary:        OSCAR Package Selector Qt GUI
Group:          Applications/System
Requires:       perl-Qt
Requires:	oscar-selector

%description
Set of scripts and Perl modules for the selection of OSCAR package in order to set the software configuration of an OSCAR cluster.

%description x11
Qt graphical user interface for OSCAR Selector.

%prep
%setup -n %{name}

%install
%__make install-cli DESTDIR=$RPM_BUILD_ROOT
%__make install-gui DESTDIR=$RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%{_bindir}/*
%{perl_vendorlib}/OSCAR/*
%{_mandir}/*

%files x11
%defattr(-,root,root)
%{perl_vendorlib}/Qt/*

%changelog
* Sat Dec 14 2013 Olivier Lahaye <olivier.lahaye@cea.fr> 1.2.7-3
- Re-enabled automatic dependancies generator.
* Tue Jun 18 2013 Olivier Lahaye <olivier.lahaye@cea.fr> 1.2.7-2
- Added Build requires (perl for pod2man)
- Missing build dep: dblatex and sgmltools-lite for doc generation.
* Wed Nov 14 2012 Olivier Lahaye <olivier.lahaye@cea.fr> 1.2.7-1
- New upstream version.
- Use rpm macro for paths.
- Simplify spec file.
* Tue Feb 08 2011 Geoffroy Vallee <valleegr@ornl.gov> 1.2.6-1
- New upstream version.
* Tue Nov 24 2009 Geoffroy Vallee <valleegr@ornl.gov> 1.2.5-1
- New upstream version.
* Fri Sep 25 2009 Geoffroy Vallee <valleegr@ornl.gov> 1.2.4-1
- New upstream version.
* Wed Aug 05 2009 Geoffroy Vallee <valleegr@ornl.gov> 1.2.3-1
- New upstream version.
* Thu Jul 16 2009 Geoffroy Vallee <valleegr@ornl.gov> 1.2.2-1
- New upstream version.
* Mon Apr 27 2009 Geoffroy Vallee <valleegr@ornl.gov> 1.2.1-1
- New upstream version.
* Thu Apr 23 2009 Geoffroy Vallee <valleegr@ornl.gov> 1.2-1
- New upstream version.
* Fri Feb 13 2009 Geoffroy Vallee <valleegr@ornl.gov> 1.1.1-1
- New upstream version.
* Thu Feb 12 2009 Geoffroy Vallee <valleegr@ornl.gov> 1.1-1
- New upstream version.
* Thu Feb 12 2009 Geoffroy Vallee <valleegr@ornl.gov> 1.0.4-1
- New upstream version.
* Tue Feb 10 2009 Geoffroy Vallee <valleegr@ornl.gov> 1.0.3-1
- New upstream version.
* Mon Jan 19 2009 Geoffroy Vallee <valleegr@ornl.gov> 1.0.2-1
- New upstream version.
* Mon Dec 22 2008 Geoffroy Vallee <valleegr@ornl.gov> 1.0.1-1
- New upstream version.
* Thu Dec 04 2008 Geoffroy Vallee <valleegr@ornl.gov> 1.0-4
- Move the libraries into a noarch directory.
* Fri Nov 28 2008 Geoffroy Vallee <valleegr@ornl.gov> 1.0-3
- Disable automatic dependencies.
* Wed Nov 11 2008 Geoffroy Vallee <valleegr@ornl.gov> 1.0-2
- clean up the spec file.
* Thu Sep 11 2008 Geoffroy Vallee <valleegr@ornl.gov> 1.0-1
- new upstream version (see ChangeLog for more details).
