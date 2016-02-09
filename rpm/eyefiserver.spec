%define debug_package %{nil}

Name:           EyeFiServer
Version:        2.4
Release:        1%{?dist}
Summary:        An open source Eye-Fi server

License:        GPLv3+
URL:            https://github.com/nirgal/EyeFiServer
Source0:	Source0: https://github.com/shiinee/%{name}/archive/{%version}.tar.gz#/%{name}-%{version}.tar.gz

BuildRequires:  txt2man
BuildArch:	noarch
Requires:       python2, gobject-introspection, gtk3, pygobject3

%description
eyefiserver is a daemon that accepts connections and receives files from Eye-Fi
brand wireless SD devices.

%prep
%setup -q

%build
make

%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT BINDIR=%{_bindir} SYSCONFDIR=%{_sysconfdir} \
INITDDIR=%{_initddir} MANDIR=%{_mandir} USERUNITDIR=%{_userunitdir} \
DESKTOPDIR=%{_datadir}/applications \

rm -rf $RPM_BUILD_ROOT/%{_initddir}/

%files
%{_bindir}/eyefiserver*
%config(noreplace) %{_sysconfdir}/eyefiserver.conf
%{_userunitdir}/*.service
%{_datadir}/applications/*.desktop
%{_mandir}/man?/*.gz

%doc doc/* LICENSE README changelog

%changelog
* Mon Feb  8 2016 Skyler Leigh Amador
- Packaging the most current release of eyefiserver from github
