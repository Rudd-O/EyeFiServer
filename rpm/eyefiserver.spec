%define debug_package %{nil}
%define srveyefi /srv/eyefi

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
# variables must be kept in sync with install
make DESTDIR=$RPM_BUILD_ROOT BINDIR=%{_bindir} SYSCONFDIR=%{_sysconfdir} \
INITDDIR=%{_initddir} MANDIR=%{_mandir} USERUNITDIR=%{_userunitdir} \
DESKTOPDIR=%{_datadir}/applications \
UNITDIR=%{_unitdir} \
UPLOADDIR=%srveyefi \

%install
rm -rf $RPM_BUILD_ROOT
# variables must be kept in sync with build
make install DESTDIR=$RPM_BUILD_ROOT BINDIR=%{_bindir} SYSCONFDIR=%{_sysconfdir} \
INITDDIR=%{_initddir} MANDIR=%{_mandir} USERUNITDIR=%{_userunitdir} \
DESKTOPDIR=%{_datadir}/applications \
UNITDIR=%{_unitdir} \
UPLOADDIR=%srveyefi \

mkdir -p $RPM_BUILD_ROOT%srveyefi

rm -rf $RPM_BUILD_ROOT/%{_initddir}/

%pre
if [ $1 -eq 1 ] ; then
  # Create eyefi gid as long as it does not already exist
  cat /etc/group | cut -d':' -f 1 | grep --quiet '^eyefi$' 2>/dev/null
  if [ "$?" -eq 1 ]; then
    # Initial installation
    /usr/sbin/groupadd -r eyefi >/dev/null 2>&1 || :
  fi

  # Create eyefi uid as long as it does not already exist.
  cat /etc/passwd | cut -d':' -f 1 | grep --quiet '^eyefi$' 2>/dev/null
  if [ "$?" -eq 1 ]; then
    # Initial installation
    /usr/sbin/useradd -l -c "Eye-Fi server user" -r -g eyefi \
        -s /sbin/nologin -r -d %srveyefi eyefi >/dev/null 2>&1 || :
  fi
fi

%post
if [ $1 -eq 1 ] ; then
    # Initial installation
    systemctl preset eyefiserver >/dev/null 2>&1 || :
fi

%preun
if [ $1 -eq 0 ] ; then
        # Package removal, not upgrade
        systemctl --no-reload disable eyefiserver.service > /dev/null 2>&1 || :
        systemctl stop eyefiserver.service > /dev/null 2>&1 || :
fi

%postun
systemctl daemon-reload >/dev/null 2>&1 || :
if [ $1 -ge 1 ] ; then
        # Package upgrade, not uninstall
        systemctl try-restart eyefiserver.service >/dev/null 2>&1 || :
fi

%files
%{_bindir}/eyefiserver*
%attr(400, eyefi, root) %config(noreplace) %{_sysconfdir}/eyefiserver.conf
%{_userunitdir}/*.service
%{_unitdir}/*.service
%{_datadir}/applications/*.desktop
%{_mandir}/man?/*.gz
%attr(2770, eyefi, eyefi) %verify() %srveyefi

%doc doc/* LICENSE README changelog

%changelog
* Mon Feb  8 2016 Skyler Leigh Amador
- Packaging the most current release of eyefiserver from github
