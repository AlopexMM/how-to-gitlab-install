#!/bin/bash

secrets_file="$HOME/gitlab_secrets.tar.gz"
last_gitlab_backup="$HOME/last_gitlab_backup"

docker exec -t <container name> gitlab-backup create BACKUP=$(date +'%Y-%m-%d')
echo "$(date +'%Y-%m-%d')_gitlab_backup.tar" > $last_gitlab_backup

tar czf  $secrets_file /srv/gitlab/config/gitlab.rb /srv/gitlab/config/gitlab-secrets.json

#scp $secrets_file <name of connection on config file of ssh>:/to/path
#scp $(cat $last_gitlab_backup) <name of connection on config file of ssh>:/to/path 
