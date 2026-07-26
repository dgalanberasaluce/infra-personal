# Forgejo

Git clone from virtual machine
1. Generate ssh key 
```bash
ssh-keygen -t ed25519 -C "srv-prod-01"
```

2. Change permission of the keys
```bash
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

3. Add the public key to the Forgejo Repository
- Go to the repository
- Settings > Deploy Keys > Add deploy key


## Forgejo Backup

Requirements:

- Forgejo running as a binary (not docker)
- Machine with enough disk space to store the backup and with docker

Take backup of the Forgejo instance using the following command:
```bash
runuser -u git -- forgejo dump -c /etc/forgejo/app.ini -w /var/lib/forgejo/  -d sqlite3 -f /tmp/backup-$(date +%Y%m%d).zip
```

Copy the file on the backup machine
```bash
scp user@forgejo-server:/tmp/backup-$(date +%Y%m%d).zip /path/to/backup/
```

Uncompress the backup file on the backup machine into a workspace directory (e.g `~/workspace`)
```bash
unzip /path/to/backup/backup-$(date +%Y%m%d).zip -d ~/workspace/forgejo-test
```

Generate the following `app.ini` file on the backup machine (`~/workspace/forgejo/app.ini`)

:::warning

The following `app.ini` file was provided by Gemini 3.5 Flash-Lite. It worked on forgejo version 1.13

:::

```ini
APP_NAME = Forgejo: Beyond coding. Together.
RUN_USER = git
RUN_MODE = prod
WORK_PATH = /data

[database]
DB_TYPE  = sqlite3
HOST     = 127.0.0.1:3306
NAME     = gitea
USER     = gitea
PASSWD   = 
PATH     = /data/gitea.db
SSL_MODE = disable
LOG_SQL  = false

[server]
PROTOCOL         = http
DOMAIN           = localhost
ROOT_URL         = http://localhost:3000/
HTTP_ADDR        = 0.0.0.0
HTTP_PORT        = 3000
DISABLE_SSH      = false
SSH_PORT         = 2222
SSH_LISTEN_PORT  = 22
LFS_START_SERVER = true

APP_DATA_PATH    = /data/data
LFS_CONTENT_PATH = /data/git/lfs

[repository]
ROOT = /data/git/repositories
MAX_CREATABLE_NOTE_SIZE = 2048
DEFAULT_BRANCH = main

[repository.editor]
LINE_WRAP = true

[repository.local]
LOCAL_COPY_PATH = /data/data/tmp/local-repo

[lfs]
PATH = /data/git/lfs

[security]
# Set to 'true' to prevent the web installation wizard from being reopened
INSTALL_LOCK                      = true
SECRET_KEY                        = GeneraOModificaEstaClaveAleatoria123456
REVERSE_PROXY_AUTHENTICATION_USER = X-WEBAUTH-USER
PASSWORD_HASH_ALGO                = pbkdf2

[session]
PROVIDER        = file
PROVIDER_CONFIG = /data/data/sessions

[log]
MODE      = console
LEVEL     = Info
ROOT_PATH = /data/gitea/log

[attachment]
PATH         = /data/data/attachments
MAX_SIZE     = 2048
MAX_FILES    = 5
ENABLED      = true

[picture]
AVATAR_UPLOAD_PATH      = /data/data/avatars
REPOSITORY_AVATAR_FALLBACK = none
DISABLE_GRAVATAR        = false
ENABLE_FEDERATED_AVATAR = true

[mailer]
ENABLED = false

[indexer]
ISSUE_INDEXER_PATH = /data/data/indexers/issues.bleve

[queue]
TYPE = leveldb
DATADIR = /data/data/queues
```

Copy `forgejo-test/repos` to `forgejo/git/repositories` and `forgejo-test/data/forgejo.db` to `forgejo/gitea.db`

```bash
cp -r ~/workspace/forgejo-test/repos/* ~/workspace/forgejo/git/repositories/
cp ~/workspace/forgejo-test/data/forgejo.db ~/workspace/forgejo/gitea.db
```

Create the following `docker-compose.yml` file on the backup machine to run the backup command in a docker container:
```yaml
services:
  server:
    image: codeberg.org/forgejo/forgejo:{FORGEJO_VERSION}
    container_name: forgejo-app-test
    restart: always
    environment:
      - USER_UID=501
      - USER_GID=20
      - GITEA_APP_INI=/etc/forgejo/app.ini
    ports:
      - "3000:3000"
      - "2222:22"
    volumes:
      - ./forgejo:/data
      - ./forgejo/app.ini:/etc/forgejo/app.ini
      - /etc/localtime:/etc/localtime:ro
```

:::info

- Try with `<version>-rootless` if the not rootless version does not work.
- Use `USER_UID=501` and `USER_GID=20` if running from macos and docker desktop (Use the *uid** and **gid** provided by the `id` command).

:::

Run `docker-compose up -d` to start the container and login to the web interface.