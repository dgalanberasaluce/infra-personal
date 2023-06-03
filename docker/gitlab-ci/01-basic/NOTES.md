# GITALAB-CI - gitlab-runner

```bash
# Start gitlab-runner container using docker-compose
docker-compose up -d --build

# Register gitlab-runner
# It is required a gitlab project and a gitlab ci configuration token 
docker-compose exec gitlab-runner gitlab-runner register

# Exec gitlab-ci pipeline using gitlab-runner
# docker-compose exec -w <MAIN_DIRECTORY> <DOCKER_COMPOSE_SERVICE> exec docker <GITLAB_JOB>
## MAIN_DIRECTORY = directory containing .gitlab-ci.yml
## DOCKER_COMPOSE_SERVICE = name given to gitlab-runner service within `docker-compose.yaml`
## GITLAB_JOB = name of the gitlab job to run
docker-compose exec -w $PWD/gitlab-project-mock gitlab-runner gitlab-runner exec docker test-job1

# Restart gitlab-runner to take new config (config.toml)
docker-compose exec gitlab-runner gitlab-runner restart
```

## Additional notes
- gitlab-ci config file needs to be named `.gitlab-ci.yml` (Note the suffix `.yml` instead of `.yaml`)
- gitlab-runner brings up a new docker container in the docker server of the host
    - We need to specify the absolute path where `gitlab-ci.yml` is stored so the new container can mount it
- One of the limitations of gitlab-runner exec is that it can only run one job, not full pipelines with all stages
- A git configuration should exist within the mocked project folder
