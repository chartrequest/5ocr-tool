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

## Installation

Download the 5ocr-tool file to your `/usr/local/bin` or `~/.local/bin` directory. Make it executable by running `chmod 755 /usr/local/bin/5ocr-tool` or `chmod 755 ~/.local/bin/5ocr-tool`

## Usage

The command currently offers the following operation modes: login, ssh, logs, config

### 5ocr-tool login

**Syntax:** `5ocr-tool login`

**Description:** The *login* operation checks if the user AWS access key is valid, if it is not it will obtain short lived keys by requesting the users's login and password

### 5ocr-tool logs

**Syntax:** `5ocr-tool logs --environment preproduction|staging --container web|sidekiq|cron`

**Description:** The *logs* operation shows the selected container logs

### 5ocr-tool ssh
 
**Syntax:** `5ocr-tool ssh --environment preproduction|staging --container web|sidekiq|cron`

**Description:** The *ssh* operations opens a shell inside the selected container. To exit the container, type `exit`.

### 5ocr-tool config

**Syntax:** `5ocr-tool config --environment preproduction|staging --container web|sidekiq|cron`

**Description:** The *config* operation show the selected container enviroment variables.
 