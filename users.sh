#!/bin/bash -e
name=${1}

source "${configs_dir}/configs/users/${name}.config"

# Allow individual scripts to override
if [ -n "${2}" ] && [ "${2}" == 'active' ];
then
  active='true'
fi

if [ "${active}" == 'true' ];
then
  # We have to add groups first
  # primary
  /usr/sbin/groupadd -g "${gid}" ${system} "${username}" 2>&1 | grep -vE "^groupadd: group '${username}' already exists\$"
  /usr/sbin/groupmod -g "${gid}" -n "${username}" "${username}"

  # secondary
  for group in $(echo "${groups}" | tr ',' ' ');
  do
    /usr/sbin/groupadd -f -r "${group}" 2>&1 | grep -vE "^groupadd: group '${username}' already exists\$"
  done

  # Now the user
  /usr/sbin/useradd -d "${homedir}" -g "${gid}" -G "${groups}" ${create_home} -s "${shell}" -u "${uid}" ${system} "${username}" 2>&1 | grep -vE "^useradd: user '${username}' already exists\$|^useradd: warning: the home directory already exists.$|^Not copying any file from skel directory into it.$"

  usermod_return=$(/usr/sbin/usermod -d "${homedir}" -g "${gid}" -G "${groups}" ${create_home} -s "${shell}" -u "${uid}" "${username}" 2>&1)
  look_for="user .* is currently used by process [0-9]*"

  # this part totally doesn't match, btw. Need to figure out why
  if [[ ${usermod_return} =~ ${look_for} ]];
  then
    case "$(echo ${usermod_return} | awk '{print $9;}')" in
      mpd ) export stop_mpd=1
      ;;
      nrpe ) export nagios_nrpe_server_stop=1
      ;;
    esac

    bash "${configs_dir}/scripts/services.mgmt.sh"
    /usr/sbin/usermod -d "${homedir}" -g "${gid}" -G "${groups}" ${create_home} -s "${shell}" -u "${uid}" "${username}"
  fi

  if [[ "${usermod_return}" =~ "${look_for}" ]];
  then
    case "$(echo ${usermod_return} | awk '{print $9;}')" in
      mpd ) export start_mpd=1
      ;;
      nrpe ) export nagios_nrpe_server_start=1
      ;;
    esac
    bash "${configs_dir}/scripts/services.mgmt.sh"
  fi

  # Now the dirs
  for config_dir in .ssh .subversion;
  do
    mkdir -p "${homedir}/${config_dir}"
  done

  # Now the files
  echo -n "${public_ssh_key}" > "${homedir}/.ssh/authorized_keys"
  echo -n "${private_ssh_key}" > "${homedir}/.ssh/private"
  echo -e "${subversion_config}" > "${homedir}/.subversion/config"

  for rc_file in vimrc bashrc;
  do
    if [ -f "${configs_dir}/files/${username}.${rc_file}" ];
    then
      chown "${username}:${username}" "${homedir}/.${rc_file}"
      cp "${configs_dir}/files/${username}.${rc_file}" "${homedir}/.${rc_file}"
      chmod -R 700 "${homedir}/.${rc_file}"
    fi
  done

  if [ -d "${homedir}/.subversion" ];
  then
    chown -R "${username}:${username}" "${homedir}/.subversion"
    chmod -R 700 "${homedir}/.subversion"
  fi

  if [ -d "${homedir}/.ssh" ];
  then
    chown -R "${username}:${username}" "${homedir}/.ssh"
    chmod -R 700 "${homedir}/.ssh"
  fi

  cp "${configs_dir}/files/profile" /etc/profile
fi
