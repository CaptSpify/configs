#!/bin/bash -e
ln -s "${configs_dir}/files/init.sh" /usr/local/sbin/ 2>&1 | grep -vE "^ln: failed to create symbolic link ‘/usr/local/sbin/init.sh’: File exists\$"

cp "${configs_dir}/files/update.configs.sh" /usr/local/sbin/
chmod 755 /usr/local/sbin/update.configs.sh

cp "${configs_dir}/files/configs.cron" /etc/cron.d/configs
chmod 755 /etc/cron.d/configs
