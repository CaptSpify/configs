#!/bin/bash
export configs_dir="/whatever/dir"
export PATH=$PATH:/bin:/usr/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/sbin:$HOME/scripts
export DEBIAN_FRONTEND=noninteractive
export shortname=`hostname -s`

# Get basic info
export cpu=$(uname -m)
case ${cpu} in
  armv6l ) export arch="rpi"
    ;;
  x86_64 ) export arch="amd64"
    ;;
esac
export packages="${packages} linux-image-3.16.0-4-${arch}"
export hosts=$(ls "${configs_dir}/configs/hosts" | sed 's/.config//g');
export users=$(ls "${configs_dir}/configs/users" | sed 's/.config//g');

# source the configs
source "${configs_dir}/base.config"
source "${configs_dir}/configs/hosts/${shortname}.config"
for template in ${templates};
do
  source "${configs_dir}/configs/templates/${template}.config"
done

# get shortcuts
source "${configs_dir}/scripts/functions.sh"

ln -s "${configs_dir}/init.sh" /usr/local/sbin/configs.sh 2>&1 | grep -vE "^ln: failed to create symbolic link ‘/usr/local/sbin/configs.sh’: File exists\$"
chmod +x "${configs_dir}/init.sh"

# call scripts from functions.sh
scripts

# Just want to do this once and get all packages
apt-get -qq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"  install --yes ${packages} 2>&1 | grep -vE "^Selecting previously unselected package mlocate.$|Reading database"
apt-get -qq purge --yes --force-yes ${purge_packages} 2>&1 | grep -vE "^E: Unable to locate package.*"
# Need to test this out with everything before pulling the trigger
# dpkg --remove ${purge_packages} 2>&1 | grep -vE "^dpkg: warning: ignoring request to remove .* which isn't installed"

for user in ${users};
do
    if [[ "${active_users}" == *"${user}"* ]];
    then
      bash "${configs_dir}/scripts/users.sh" "${user}" "active"
    else
      bash "${configs_dir}/scripts/users.sh" "${user}"
    fi
done

bash "${configs_dir}/scripts/services.mgmt.sh"

