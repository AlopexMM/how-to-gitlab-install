# Preconfiguraciones

Se requiere que se encuentre instalado docker y docker-compose, puede buscar la información en:
[Documentacion Docker](https://docs.docker.com/engine/install/#server)

# Corriendo Gitlab

1. Se debe crear un archivo .env con las siguientes variables de entorno

HOSTNAME: Contiene el nombre de la pagina "example@dominio.com"

GITLAB_HOME: direccion donde se van a crear los directorios config, logs, ssl y data

TAG: Para especificar la versión de gitlab que se va a usar

> GITLAB_OMNIBUS_CONFIG
>
> Debajo de esa variable en el archivo docker-compose se encuentra las configuraciones que se impactaran en el archivo gitlab.rb

2. Creamos los directorios de la aplicacion y las llaves ssl

```bash

 # mkdir -p /srv/gitlab/{config/ssl,logs,backups,data}

 # apt install -y certbot
 
 # mkdir -p /srv/gitlab/{config/ssl,logs,data,backups}
 
 # certbot certonly --rsa-key-size 2048 --standalone --agree-tos --no-eff-email --email example@dominio.com -d gitlab.dominio.com
 
 # openssl dhparam -out /srv/gitlab/config/ssl/dhparams.pem 2048
 
 # cp /etc/letsencrypt/live/gitlab.dominio.com/privkey.pem /srv/gitlab/config/ssl/
 
 # cp /etc/letsencrypt/live/gitlab.dominio.com/fullchain.pem /srv/gitlab/config/ssl/

```

3. Una vez que configuramos las variables de entorno ejecutamos 

```bash

# source .env

# docker-compose up -d

```

> Se puede transmitir el proyecto copiando la carpeta con scp o utilizando rsync
>
> Ejemplo:
>
> ```bash
>
> $ tar czf gitlab_install.tar.gz gitlab_install
>
> $ scp gitlab_install.tar.gz [USER]@[IP ADDRESS]:[PATH]
>
> ```

Una vez que esta corriendo con status healthy revisamos la clave de root con el comando

```bash

 # docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password

```

# Backup

> IMPORTANTE
>
> Siempre se debe utilizar en la misma versión los backups en caso de ser vieja la versión
>
>  se debe recuperar primero con la vieja versión y luego se traslada el container a la nueva versión
> 
> Podemos revisar la versión dentro del container ejecutando el comando 
> 
> ```bash
>
>  # docker exec -it <container name> gitlab-rake gitlab:env:info
>
> ```

Para ejecutar el backup realizamos el siguiente comando

```bash

 # docker exec -t <container name> gitlab-backup create BACKUP=$(date +'%Y-%m-%d')

 # docker stop <container name>

 # tar czf gitlab_secrets_$(date +'%Y-%m-%d').tar.gz /srv/gitlab/config/{gitlab.rb,gitlab-secrets.json}

 # docker start <container name>

```

Se puede poner un cron para que se ejecuten esos comandos o crear un script que los ejecute

> Como buena practica se recomienda guardar los backups en un servidor diferente

# Restore

Iniciamos un contenedor de gitlab, aqui no es necesario hacer los pasos de certbot y dhparam

Apagar los procesos que se encutran conectados la base de datos

```bash

 # docker exec -it <name of container> gitlab-ctl stop puma

 # docker exec -it <name of container> gitlab-ctl stop sidekiq

```

Verificar que todos los procesos estan apagados

```bash

 # docker exec -it <name of container> gitlab-ctl status

```

Correr la recuperacion. 

> NOTA: fijarse que "_gitlab_backup.tar" se omite del nombre

```bash

 # docker exec -it <name of container> gitlab-backup restore BACKUP=<nombre del archivo>

```

> NOTA: puede que devuelva error de permisos, con chmod puede modificarlos

Copiamos archivos secrets

```bash

 # cp gitlab.rb gitlab-secrets.json /srv/gitlab/config

```

Reiniciar Gitlab

```bash

 # docker restart <name of container>

```

Verificas GitLab

```bash

 # docker exec -it <name of container> gitlab-rake gitlab:check SANITIZE=true

```
