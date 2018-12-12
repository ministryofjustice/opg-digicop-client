# Serve OPG

[![CircleCI](https://circleci.com/gh/ministryofjustice/serve-opg/tree/master.svg?style=svg&circle-token=79410497f5cde03ffb512d50e427dea8a272ff0b)](https://circleci.com/gh/ministryofjustice/serve-opg/tree/master)

Symfony 3.4 & PHP 7.2

# Prerequisites
Software to download and install
-   [docker](https://docs.docker.com/install/)
-   [docker-compose](https://docs.docker.com/compose/install/)
-   [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

# Usage
## Build
Launch all the following commands from the project directory
```bash

git config core.autocrlf true

# Generate self-signed certificate for the local loadbalancer
./generate_certs.sh

# Add certificate to your local trust store to avoid browser warnings
sudo security add-trusted-cert -d -r trustRoot \
-k /Library/Keychains/System.keychain certs/web.crt

# Create aws resources for localstack
docker-compose run --rm aws --endpoint-url=http://localstack:4569 s3 mb s3://sirius_test_bucket
docker-compose run --rm aws --endpoint-url=http://localstack:4569 s3 mb s3://test_bucket
# API token to send email only to the team
docker-compose run --rm aws --region eu-west-1 --endpoint-url=http://secretsmanager:5000 secretsmanager create-secret --name notification_api_key --secret-string "local-dc0ef8aa-ffdf-4bfb-9c47-30ea20362eb1-6b44c7a0-00dc-4d55-9fc4-69bcb0d67738"

# Vendor php dependencies
docker-compose run --rm composer

# Generate static assets
docker-compose run --rm npm

# Build app
docker-compose up -d --build --remove-orphans loadbalancer
# --build Build images before starting containers
# -d Detached mode: Run containers in the background

# Add sample users and cases (local env only).
# See docker-compose.yml app container, DC_FIXURES_USERS variable
docker-compose run --rm app php app/console doctrine:fixtures:load --append

# Generates status of migrations
docker-compose run --rm app php app/console doctrine:migrations:status

# enable dev mode (local development only)
docker-compose exec app touch /var/www/.enableDevMode

# To disable dev mode and re-enable prod mode (default):
docker-compose exec app rm /var/www/.enableDevMode
```

View logs
```bash
docker-compose logs -f
```

The app will be available locally at:
> [https://localhost](https://localhost/)




# Dev and prod mode
```bash
# dev mode
docker-compose exec app touch /var/www/.enableDevMode

# prod mode (default)
docker-compose exec app rm /var/www/.enableDevMode

```

# Testing
Serve OPG uses PHPUnit and Behats to test the application

## Unit Testing
Run php unit
```bash
docker-compose run --rm phpunit

# specific test
docker-compose run --rm --entrypoint="bin/phpunit -c tests/phpunit/ tests/phpunit/Service/UserProviderTest.php" phpunit

```

## Integration Testing
```bash
# Load Fixtures
docker-compose run --rm app php app/console doctrine:fixtures:load --append

# Load Fixtures truncating existing data (users, client, orders, deputies)
docker-compose run --rm app php app/console doctrine:fixtures:load --purge-with-truncate

# Run Behat
docker-compose run --rm behat
```

### Notify mocking
Notify is mocked via a custom script.
Requests to the service can be seen at

`http://localhost:8081/mock-data`

Behat `NotifyTrait` takes care of resetting / accessing those emails from steps in the behat context.

# Debugging
Login to Database
```bash
docker-compose exec postgres psql -U serve-opg
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

# Database Migrations
```bash
# Database migrations
# Generate migration script between entities and schema
docker-compose run --rm app php app/console doctrine:migrations:diff

# Generate blank migration script
docker-compose run --rm app php app/console doctrine:migrations:generate

# Example: run migration version 20181019141515
docker-compose run --rm app php app/console doctrine:migrations:execute 20181019141515
```

# Utilities


```bash
#Copy a file into the container
docker cp web/app.php serve-opg_app_1:/var/www/web/app.php

# Drop the data before schema update (mainl during local development)
docker-compose run --rm app php app/console doctrine:schema:drop --force

```


# Launch specific behat feature

```
docker-compose run --rm --entrypoint="bin/behat -c tests/behat/behat.yml tests/behat/features/00-security.feature:18" behat
```

# Quality Analysis Tools
The Docker image `jakzal/phpqa` contains many useful QA tools
To list the available tools run:
```shell
docker-compose run --rm qa
```

A recommended set of checks is as follows:
-   phpcs
    ```bash
    docker-compose run --rm qa phpcs src
    ```
-   phpstan
    ```bash
    docker-compose run --rm qa phpstan analyse -l 4 src
    ```
-   lint
    ```bash
    docker-compose run --rm qa parallel-lint src web app tests
    ```
-   security-checker
    ```bash
    docker-compose run --rm qa security-checker security:check
    ```

A convenience script is provided for the above set:
```bash
docker-compose run --rm qa ./default_qa_checks.sh
```
