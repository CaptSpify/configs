#!/bin/bash -e
# export the restart/reload/etc of functions variable for services.mgmt
function services() {
  action="$1"
  service="$2"

  if [ -n "${action}" ] && [ -n "${service}" ];
  then
    export "${action}_${service}"=1
  fi
}
export -f services

# delete a file
function rrm {
  source_file=$1

  if [ -f "${source_file}" ];
  then
    rm "${source_file}"

    if [ -n $3 ];
    then
      services "$3" "$4"
    fi
  fi
}
export -f rrm

# change perms
function cch {
  source_file=$1
  perms=$2

  existing_perms=$(stat "${source_file}" | grep Access | head -n1 | tr '/' ' ' | tr -d '('| awk '{print $2;}')
  if [ "${existing_perms}" != "${perms}" ];
  then

    if [ "$3" == "recursive" ];
    then 
      recursive='-R'
      /bin/chmod "${recursive}" "${perms}" "${source_file}"
    else
      recursive=''
      /bin/chmod "${perms}" "${source_file}"
    fi

    if [ -n $4 ];
    then
      services "$3" "$4"
    fi
  fi
}
export -f cch

# change perms
function cch {
  source_file=$1
  perms=$2

  existing_perms=$(stat "${source_file}" | grep Access | head -n1 | tr '/' ' ' | tr -d '('| awk '{print $2;}')
  if [ "${existing_perms}" != "${perms}" ];
  then

    if [ "$3" == "recursive" ];
    then 
      recursive='-R'
      /bin/chmod "${recursive}" "${perms}" "${source_file}"
    else
      recursive=''
      /bin/chmod "${perms}" "${source_file}"
    fi

    if [ -n $4 ];
    then
      services "$3" "$4"
    fi
  fi
}
export -f cch

# create symlinks
function lln {
  actual_file=$1
  link_file=$2

  if [ ! -h "${link_file}" ] || [ ! -e "${actual_file}" ] || ! diff "${actual_file}" "${link_file}";
  then
    rm "${link_file}" 2>&1 | grep -vE "^rm: cannot remove ‘${link_file}’: No such file or directory$"
    ln -s "${actual_file}" "${link_file}"

    if [ -n $3 ];
    then
      services "$3" "$4"
    fi
  fi
}
export -f lln

# define file and contents
function ttp {
  actual_file="$1"

  if [ ! -f "${actual_file}" ];
  then
    touch "${actual_file}"

    if [ -n $3 ];
    then
      services "$3" "$4"
    fi
  fi
}
export -f ttp

# define file and contents
function ccp {
  config_file="$1"
  actual_file="$2"

  # if files differ
  if ! diff ${configs_dir}/files/${config_file} ${actual_file} || [ ! -f "${actual_file}" ];
  then
    cp "${configs_dir}/files/${config_file}" "${actual_file}"

    if [ -n $3 ];
    then
      services "$3" "$4"
    fi
  fi
}
export -f ccp

# We have to wrap this into a function, because bash doesn't allow subshells to override their parent's variables, even with export
function scripts {
  for script in ${scripts};
  do
    source "${configs_dir}/scripts/${script}.sh"
  done
}

export -f scripts

function mmount {
  remote="$1"
  local="$2"
  
  if [ ! -d "/mnt/${local}" ];
  then
    mkdir -p "/mnt/${local}"
  fi

  if ! grep "${local}" /etc/fstab >/dev/null;
  then
    echo "storage1.thekyel.com:/data/${remote}/ /mnt/${local} nfs intr,nfsvers=3,soft" >> /etc/fstab
    mount -av
  
    if [ $? -ne 0 ]
    then
      echo "could not mount ${remote} on ${local}"
    fi
  fi
}
export -f mmount
