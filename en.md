
This is a setup guide for more information read [Gitlab Docs](https://docs.gitlab.com/ee/)

# Pre configs

It has to be install docker and docker-compose, you can see the installation process in:
[Docker docs](https://docs.docker.com/engine/install/#server)

# Running Gitlab

1. First create .env file with the next enviroment variables

HOSTNAME: here goes the canonical name "example.dominio.com"

GITLAB_HOME: here goes the path where you find config, logs, ssl, data and backup

TAG: this has the version tag of Gitlab

Example of .env file:

```

HOSTNAME=gitlab.dominio.com

GITLAB_HOME=/srv/gitlab

TAG=14.2.1-ce.0

```

> GITLAB_OMNIBUS_CONFIG
>
> down of this environment variable goes the configurations of gitlab.rb

2. Create the directories for the app

```bash

 # apt install -y certbot
 
 # mkdir -p /srv/gitlab/{config/ssl,logs,data,backups}
 
 # certbot certonly --rsa-key-size 2048 --standalone --agree-tos --no-eff-email --email example@dominio.com -d gitlab.dominio.com
 
 # openssl dhparam -out /srv/gitlab/config/ssl/dhparams.pem 2048
 
 # cp /etc/letsencrypt/live/gitlab.dominio.com/privkey.pem /srv/gitlab/config/ssl/
 
 # cp /etc/letsencrypt/live/gitlab.dominio.com/fullchain.pem /srv/gitlab/config/ssl/

```

3. When we have the environment variables config on the file we run the next commands 

```bash

# source .env

# docker-compose up -d

```

When the status healthy in the container we check the root key with the command:

```bash

 # docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password

```

# Backup

> IMPORTANT
>
> Always use the same version of gitlab
>
>  if you need to restore a backup in a new server first do the restore with the old version and then change this
> 
> We can check the version with the command:
> 
> ```bash
>
>  # docker exec -it <container name> gitlab-rake gitlab:env:info
>
> ```

To execute the backup we need to execute the command:

```bash

 # docker exec -t <container name> gitlab-backup create BACKUP=$(date +'%Y-%m-%d')

 # tar czf gitlab_secrets_$(date +'%Y-%m-%d').tar.gz /srv/gitlab/config/gitlab.rb /srv/gitlab/config/gitlab-secrets.json

```

In the repo i add a script to manage this

> As best practices i recomend save the backups in another server

# Restore

Init gitlab, here we do not need to run the steps of certbot and dhparam

Shutdown the process connected to data base

```bash

 # docker exec -it <name of container> gitlab-ctl stop puma

 # docker exec -it <name of container> gitlab-ctl stop sidekiq

```

Check if the process are down

```bash

 # docker exec -it <name of container> gitlab-ctl status

```

Run the restore

> NOTE: see that we omited the "_gitlab_backup.tar" name part.

```bash

 # docker exec -it <name of container> gitlab-backup restore BACKUP=<name of file>

```

> NOTA: It could promt permission error, use chmod to modified it.

Copy secrets files

```bash

 # cp gitlab.rb gitlab-secrets.json /srv/gitlab/config

```

Restart Gitlab

```bash

 # docker restart <name of container>

```

Verify GitLab

```bash

 # docker exec -it <name of container> gitlab-rake gitlab:check SANITIZE=true

```
