# DigiCop

[![CircleCI](https://circleci.com/gh/ministryofjustice/opg-digicop/tree/master.svg?style=svg&circle-token=79410497f5cde03ffb512d50e427dea8a272ff0b)](https://circleci.com/gh/ministryofjustice/opg-digicop/tree/master)

Symfony 3.4 & PHP 7.2

# Prerequisites
Software to download and install
- [docker](https://docs.docker.com/install/)
- [docker-compose](https://docs.docker.com/compose/install/)
- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

# Usage
## Build
Launch all the following commands from the project directory
```bash
# Vendor php dependencies
docker-compose run --rm composer

# Generate static assets
docker-compose run --rm npm

# Build app
docker-compose up -d --build web
# --build Build images before starting containers
# -d Detached mode: Run containers in the background

# Migrate database
docker-compose run --rm app php app/console doctrine:schema:update --force
```

View logs
```bash
docker-compose logs -f
```

The app will be available locally at:
> [https://localhost:8888](https://localhost:8888/)

# Testing
DigiCOP uses PHPUnit and Behats to test the application

## Unit Testing
Run php unit
```bash
docker-compose run --rm phpunit
```

## Integration Testing
```bash
# Load Fixtures
docker-compose run --rm app php app/console doctrine:fixtures:load --append

# Run Behat
docker-compose run --rm behat
```

# Debugging
Login to Database
```bash
docker-compose exec postgres psql -U digicop
```

Clear Cache
```bash
docker-compose exec app rm -rf /var/www/var/cache /tmp/app-cache
```

# Front end assets

```bash
# Gulp tasks
# Bash into the npm container
docker-compose run npm bash
# Then run any gulp tasks from there, ie:
gulp watch
```

# Utilities


```bash
#Copy a file into the container
docker cp web/app.php opg-digicop_app_1:/var/www/web/app.php

# prod mode
docker-compose exec app touch /var/www/.enableProdMode

# dev mode
docker-compose exec app rm /var/www/.enableProdMode

```


# Launch specific behat feature
comment out "entrypoint" and "command" in behat container
docker-compose up behat
docker-compose exec behat sh
bin/behat -c tests/behat/behat.yml tests/behat/features/03-cases.feature


# Quality Analysis Tools
The Docker image `jakzal/phpqa` contains many useful QA tools
To list the available tools run:
```shell
docker-compose run --rm qa
```

A recommended set of checks is as follows:
- phpcs
  ```bash
  docker-compose run --rm qa phpcs src
  ```
- phpstan
  ```bash
  docker-compose run --rm qa phpstan analyse -l 4 src
  ```
- lint
  ```bash
  docker-compose run --rm qa parallel-lint src web app tests
  ```
- security-checker
  ```bash
  docker-compose run --rm qa security-checker security:check
  ```

A convenience script is provided for the above set:
```bash
docker-compose run --rm qa ./default_qa_checks.sh
```
