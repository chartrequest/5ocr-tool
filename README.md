# 5ocr-tool
# A tool to manage 5ocr_app containers on ECS

## Description

5ocr-tool is a script that enables simple access to common ECS functions, like configuration reading and editing, log viewing, remote container access

## Requisites

* The AWS CLI command. To install it, follow the instructions at (https://docs.aws.amazon.com/cli/latest/userguide/install-cliv1.html)
* This tool requires the aws cli Session Manager Plugin. To install it, follow the instructions at (https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html#install-plugin-verify)
* The saml2aws script. To install it, follow the instructions at (https://intranet.chartrequest.com/doku.php?id=development:howtoawskeys)
* The ecs-cli command. To install it, follow the instructions at (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_CLI_installation.html)
* The jq command. Install the corresponding system package. On Ubuntu, run `sudo apt update; sudo apt install jq`
* The psql command. Install the corresponding system package. On Ubuntu, run `sudo apt update; sudo apt install postgresql`

## Installation

`git clone` the 5ocr-tool repository. Enter the repository directory (`cd 5ocr-tool`) and run the `5ocr-tool-install.sh` script with **sudo**, as in `sudo ./5ocr-tool-install.sh`.

## Usage

The command currently offers the following operation modes: login, ssh, logs, config, config:set, db:connect

### 5ocr-tool login

**Syntax:** `5ocr-tool login`

**Description:** The *login* operation checks if the user AWS access key is valid, if it is not it will obtain short lived keys by requesting the users's login and password

### 5ocr-tool logs

**Syntax:** `5ocr-tool logs --environment <environment name> --container web|sidekiq|cron [-f|--follow]`

**Description:** The *logs* operation shows the selected container logs. The optional flag `-f` or `--follow` will display logs continuosly as they are generated

### 5ocr-tool ssh
 
**Syntax:** `5ocr-tool ssh --environment <environment name> --container web|sidekiq|cron`

**Description:** The *ssh* operations opens a shell inside the selected container. To exit the container, type `exit`.

### 5ocr-tool config

**Syntax:** `5ocr-tool config --environment <environment name>`

**Description:** The *config* operation shows the selected enviroment variables.

### 5ocr-tool config:set

**Syntax:** `5ocr-tool config:set --environment <environment name> [VAR1=VAL1] [VAR2=] [...]`

**Description:** The `config:set` operation is used to modify the selected enviroment variables.
To modify or to add an environment variable add its new value on the config:set command line and to delete an enviroment variable, set this variable to an empty value.
It is possible to set or delete more than one variable with a single `config:set` command.

**Example:** `5ocr-tool config:set --environment staging WEB_CONCURRENCY=2 PG_PORT= SECURITY_KEY=xyz`

### 5ocr-tool db:connect 

**Syntax:** `5ocr-tool db:connect --environment <environment name>`

**Description:** The *db:connect* operation opens a connection to the environment's database server.
