%define version     2.0
%define release     3

Summary:        OSCAR Package Selector.
Name:           oscar-selector
Version:        %version
Release:        1%{?dist}
Vendor:         Open Cluster Group <http://OSCAR.OpenClusterGroup.org/>
Distribution:   OSCAR
Packager:       DAOlivier Lahaye <olivier.lahaye@cea.fr>
License:        GPL
Group:          Applications/System
Source:         %{name}.tar.gz
BuildArch:      noarch
Requires:	liboscar-server >= 6.3
Requires:	orm
#BuildRequires:	dblatex, sgmltools-lite

BuildRoot:      %{_localstatedir}/tmp/%{name}-root

%package gui
Summary:        OSCAR Package Selector Qt GUI
Group:          Applications/System
Requires:       perl-GUIDeFATE-tk
Requires:	oscar-selector

%description
Set of scripts and Perl modules for the selection of OSCAR package in order to set the software configuration of an OSCAR cluster.

%description gui
X11 graphical user interface for OSCAR Selector.

%prep
%setup -n %{name}

%install
%__make install DESTDIR=$RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%{_bindir}/*
%exclude %{_bindir}/oscar-selector-gui
%{perl_vendorlib}/OSCAR/*
%{_mandir}/*

%files gui
%defattr(-,root,root)
%{_bindir}/oscar-selector-gui
%exclude %{perl_vendorlib}/Qt/SelectorTableItem.pm
%exclude %{perl_vendorlib}/Qt/SelectorCheckTableItem.pm


%changelog
* Wed Jun 29 2022 Olivier Lahaye <olivier.lahaye@cea.fr> 2.0-1
- New version
* Mon Jun 13 2022 Olivier Lahaye <olivier.lahaye@cea.fr> 1.2.7-5
- adapt deps to new oscar package
* Sat Dec 14 2013 Olivier Lahaye <olivier.lahaye@cea.fr> 1.2.7-4
- excluded SelectorTableItem.pm SelectorCheckTableItem.pm (unused Qt3 stuffs)
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
* Tue Nov 11 2008 Geoffroy Vallee <valleegr@ornl.gov> 1.0-2
- clean up the spec file.
* Thu Sep 11 2008 Geoffroy Vallee <valleegr@ornl.gov> 1.0-1
- new upstream version (see ChangeLog for more details).
