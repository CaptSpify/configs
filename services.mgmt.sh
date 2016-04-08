#!/bin/bash -e
if [ -n "${start_mpd}" ] && [[ "${start_mpd}" -ne 0 ]];
then
  /etc/init.d/mpd start
fi

if [ -n "${stop_mpd}" ] && [[ "${stop_mpd}" -ne 0 ]];
then
  /etc/init.d/mpd stop
fi

if [ -n "${restart_mpd}" ] && [[ "${restart_mpd}" -ne 0 ]];
then
  /etc/init.d/mpd restart
fi

if [ -n "${restart_dovecot}" ] && [[ "${restart_dovecot}" -ne 0 ]];
then
  /etc/init.d/dovecot restart
fi

if [ -n "${restart_postfix}" ] && [[ "${restart_postfix}" -ne 0 ]];
then
  /etc/init.d/postfix restart
fi

if [ -n "${restart_ganeti}" ] && [[ "${restart_ganeti}" -ne 0 ]];
then
  /etc/init.d/ganeti restart
fi

if [ -n "${restart_lvm}" ] && [[ "${restart_lvm}" -ne 0 ]];
then
  /etc/init.d/lvm2 restart
fi

if [ -n "${restart_xen}" ] && [[ "${restart_xen}" -ne 0 ]];
then
  /etc/init.d/xen restart
fi

if [ -n "${restart_xendomains}" ] && [[ "${restart_xendomains}" -ne 0 ]];
then
  /etc/init.d/xendomains restart
fi

if [ -n "${reload_apache}" ] && [[ "${reload_apache}" -ne 0 ]];
then
  /etc/init.d/apache2 reload
fi

if [ -n "${restart_apache}" ] && [[ "${restart_apache}" -ne 0 ]];
then
  /etc/init.d/apache2 restart
fi

if [ -n "${stop_nagios_nrpe_server}" ] && [[ "${stop_nagios_nrpe_server}" -ne 0 ]];
then
  /etc/init.d/nagios-nrpe-server stop
fi

if [ -n "${stop_nagios_nrpe_server}" ] && [[ "${stop_nagios_nrpe_server}" -ne 0 ]];
then
  /etc/init.d/nagios-nrpe-server stop
fi

if [ -n "${restart_nagios_nrpe_server}" ] && [[ "${restart_nagios_nrpe_server}" -ne 0 ]];
then
  /etc/init.d/nagios-nrpe-server restart
fi

if [ -n "${reload_nagios}" ] && [[ "${reload_nagios}" -ne 0 ]];
then
  /etc/init.d/nagios3 reload
fi

if [ -n "${restart_bind9}" ] && [[ "${restart_bind9}" -ne 0 ]];
then
  /etc/init.d/bind9 restart
fi

if [ -n "${restart_rsyslog}" ] && [[ "${restart_rsyslog}" -ne 0 ]];
then
  /etc/init.d/rsyslog restart
fi

if [ -n "${update_initram}" ] && [[ "${update_initram}" -ne 0 ]];
then
  /usr/sbin/update-initramfs -u
fi

if [ -n "${update_aliases}" ] && [[ "${update_aliases}" -ne 0 ]];
then
  /usr/bin/newaliases
fi

if [ -n "${update_grub}" ] && [[ "${update_grub}" -ne 0 ]];
then
  /usr/sbin/update-grub
fi

if [ -n "${exportfs_reexport}" ] && [[ "${exportfs_reexport}" -ne 0 ]];
then
  /usr/sbin/exportfs -a
fi

if [ -n "${exportfs_reexport}" ] && [[ "${exportfs_reexport}" -ne 0 ]];
then
  /usr/sbin/service nfs-kernel-server restart
fi
