# GITALAB-CI - gitlab-runner

> [!WARNING]
> **DEPRECATED** - This method of deploying a gitlab-runner was deprecated in Gitlab 16.x

There are, at least, two aims for setting up a gitlab-runner locally:
1. Test gitlab-ci configuration (It is very limited)
2. Using it as gitlab-runner for a project 

## Run gitlab-runner locally
> **Warning**
> gitlab-runner running locally (non registration required) only supports a single job
> https://gitlab.com/gitlab-org/gitlab-runner/-/issues/2797

```bash
# Start gitlab-runner container using docker-compose
docker-compose up -d --build

# Exec gitlab-ci pipeline using gitlab-runner
# docker-compose exec -w <MAIN_DIRECTORY> <DOCKER_COMPOSE_SERVICE> exec docker <GITLAB_JOB>
## MAIN_DIRECTORY = directory containing .gitlab-ci.yml
## DOCKER_COMPOSE_SERVICE = name given to gitlab-runner service within `docker-compose.yaml`
## GITLAB_JOB = name of the gitlab job to run
docker-compose exec -w $PWD/gitlab-project-mock gitlab-runner gitlab-runner exec docker test-job1
```

## Register gitlab-runner in Gitlab 
If we want the gitlab-runner running within a Gitlab project, we need to register it
```bash
# The first step is to register a new gitlab-runner for the project in Gitlab
# Settings > CI/CD > Runners > Projects runners > New project runner
# - Platform: Linux
# Copy the configuration token

# Second, register gitlab-runner
docker-compose exec gitlab-runner gitlab-runner register

# Restart gitlab-runner to take new config (config.toml)
docker-compose exec gitlab-runner gitlab-runner restart
```


## Additional notes
- gitlab-ci config file needs to be named `.gitlab-ci.yml` (Note the suffix `.yml` instead of `.yaml`)
- gitlab-runner brings up a new docker container in the docker server of the host
    - We need to specify the absolute path where `gitlab-ci.yml` is stored so the new container can mount it
- One of the limitations of gitlab-runner exec is that it can only run one job, not full pipelines with all stages
- A `git` configuration should exist within the mocked project folder
