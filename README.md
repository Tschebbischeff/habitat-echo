[![License: AGPL-3.0](https://img.shields.io/badge/License-AGPL--3.0-blue?style=flat)](./LICENSE)
![Development: Prototyping](https://img.shields.io/badge/Development-Prototyping-orange?style=flat)
![Version](https://img.shields.io/badge/dynamic/json?label=Version&color=yellow&style=flat&url=https%3A%2F%2Fraw.githubusercontent.com%2Ftschebbischeff%2Fhabitat-echo%2Frefs%2Fheads%2Fmain%2Fmetadata.json&query=%24.version)

# Habitat: Echo

> [!CAUTION]
> **🚧 This project is currently under heavy development, any information may be subject to change. 🚧**

Habitat provides modular functionality for deployment on home lab devices. \
Each of the modules is designed as an opinionated docker stack that can be deployed on its own or together with other modules by sharing the same docker network.

You can check out all officially available modules [here](https://github.com/Tschebbischeff/habitat#officially-available-modules).

## Our Principles

![TODO](https://img.shields.io/badge/TODO-Coming_Soon_(TM)-red?style=flat)

## Module Features

![TODO](https://img.shields.io/badge/TODO-Coming_Soon_(TM)-red?style=flat)

### Planned

![TODO](https://img.shields.io/badge/TODO-Coming_Soon_(TM)-red?style=flat)

## Getting Started

### Requirements

 - [![Habitat-Module: Path](https://img.shields.io/badge/Habitat--Module-Path-_?style=flat&color=gray&labelColor=gray)](https://github.com/Tschebbischeff/habitat-path)

### Configuration

> [!IMPORTANT]
> All habitat modules are designed to be controlled exclusively with environment variables and secrets. \
> Refer to the configuration section of each module for an overview of how to configure it. \
> **This section describes how to configure the module without the help of the [Habitat Deployment Service](https://github.com/Tschebbischeff/habitat). \
> It is highly recommended to use the deployment service for ease of use and skip to the lists of environment variables and secrets for this module.**

 - [List of environment variables](#environment-variables)
 - [List of secrets](#secrets)

#### Shell Exports

The existing [.env](./.env) file contains sane defaults for most necessary environment variables and is designed to let you overwrite any of those environment variables via exports from your shell before running the application.

*Example:*
```sh
export APP_HOST="my-habitat.example.com"
export APP_MODULES="path,scent,vista,chatter,hoard,vigil,sight,stash"
export APP_SESSION_ID="$(cat /proc/sys/kernel/random/uuid)"
export APP_NAME_LABEL="MyHabitat"
export TIMEZONE="Europe/London"
export SECRETS_DIR="/run/secrets"
docker compose up
```

#### Repository _.env File

You can also create the file `_.env` in the root directory of the cloned repository and instruct docker compose to use this file instead via the `--env-file` argument, i.e `docker compose --env-file "./_.env" up` ([Compose documentation](https://docs.docker.com/compose/how-tos/environment-variables/variable-interpolation/)).

> [!TIP]
> The file `_.env` is included in [.gitignore](./.gitignore) and is guaranteed to not interfere with future updates via `git pull`.

> [!IMPORTANT]
> *If this method is used you need to define **all** necessary environment variables from the [.env](./.env) file, as docker compose will not use that file as a fallback, it is therefore recommended to copy the current `.env` file and replace all variable values.*

*Example:* [See .env](./.env)

#### Local .env File

It is also possible to create a `.env` file in an unrelated directory ([Compose documentation](https://docs.docker.com/compose/how-tos/environment-variables/variable-interpolation/#local-env-file-versus-project-directory-env-file)).

> [!NOTE]
> In this case you need to set the additional variable `COMPOSE_FILE` to the path of the repository's compose file and all variables inside the [.env](./.env) file will be loaded as fallback, if your own `.env` file does not define them.

> [!NOTE]
> You do not need to instruct docker compose to use this file as long as you run `docker compose up` from the directory containing your `.env` file.

*Example:*
```sh
# /path/to/your/.env
COMPOSE_FILE="/path/to/repository/compose.yml"
APP_HOST="my-habitat.example.com"
APP_MODULES="path,scent,vista,chatter,hoard,vigil,sight,stash"
APP_SESSION_ID="$(cat /proc/sys/kernel/random/uuid)"
APP_NAME_LABEL="MyHabitat"
TIMEZONE="Europe/Madrid"
SECRETS_DIR="/run/secrets"
```

### Environment Variables

> [!TIP]
> Some environment variables are used commonly throughout all modules, you can check the list [here](https://github.com/Tschebbischeff/habitat#environment-variables-for-modules).

*This module does not require any additional environment variables.*

### Secrets

*This module does not require any secrets.*

<!--
> [!NOTE]
> All secrets are expected to be files within a single folder, each file containing the value of the secret. \
> This folder can be set via environment variable (`SECRETS_DIR`) itself and defaults to `./.secrets` (git-ignored folder). \
> All secrets must be present at run-time.

| (File) Name | Description | Documentation / How to Obtain |
| :-- | :-- | :-- |
|  | This module does not require any secrets |  |
-->

### Run the Application

 - Run `docker compose up` from the root directory of the repository or from the directory containing your `.env` file
 - Run `docker compose logs` and wait for the application to finish first-time setup and settle

## Acknowledgments and Licensing

This project is licensed under the [GNU Affero General Public License v3.0 (AGPL-3.0)](./LICENSE).

Copyright (c) 2026, [Tschebbischeff](https://github.com/Tschebbischeff). \
All rights reserved to the extent permitted by the AGPLv3.

For third-party license details and attribution, please see [Third-Party Licenses](./THIRD-PARTY-LICENSES.md).

With Icons from:
[![SimpleIcons](https://img.shields.io/badge/SimpleIcons-_?style=flat&logo=simpleicons&logoColor=111111&logoSize=auto&color=gray&labelColor=gray)](https://simpleicons.org/)
[![DashboardIcons](https://img.shields.io/badge/DashboardIcons-_?style=flat&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI1MTIiIGhlaWdodD0iNTEyIiB2aWV3Qm94PSIwIDAgMjMyIDIzMiIgcm9sZT0iaW1nIiBhcmlhLWxhYmVsPSJkYXNoYm9hcmQtaWNvbnMgbG9nbyI+DQogIDxyZWN0IHg9IjQiIHk9IjQiIHdpZHRoPSIyMjQiIGhlaWdodD0iMjI0IiByeD0iMzIiIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzAwMCIgc3Ryb2tlLXdpZHRoPSI4IiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz4NCiAgPGcgZmlsbD0ibm9uZSIgc3Ryb2tlPSIjY2NjIiBzdHJva2Utd2lkdGg9IjQiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCI+DQogICAgPHJlY3QgeD0iMjQiIHk9IjI0IiB3aWR0aD0iNDgiIGhlaWdodD0iNDgiIHJ4PSI4IiBzdHJva2U9IiNGQjcxODUiLz4NCiAgICA8cmVjdCB4PSI5MiIgeT0iMjQiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgcng9IjgiIGZpbGw9IiNGREJBNzQiLz4NCiAgICA8cmVjdCB4PSI5MiIgeT0iOTIiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgcng9IjgiIHN0cm9rZT0iI0M0QjVGRCIvPg0KICAgIDxyZWN0IHg9IjE2MCIgeT0iOTIiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgcng9IjgiLz4NCiAgICA8cmVjdCB4PSI5MiIgeT0iMTYwIiB3aWR0aD0iNDgiIGhlaWdodD0iNDgiIHJ4PSI4Ii8+DQogICAgPHJlY3QgeD0iMTYwIiB5PSIxNjAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgcng9IjgiIGZpbGw9IiM5M0M1RkQiLz4NCiAgPC9nPg0KICA8Y2lyY2xlIGN4PSIxODQiIGN5PSI0OCIgcj0iMjYiIGZpbGw9IiM4NkVGQUMiLz4NCiAgPGNpcmNsZSBjeD0iNDgiIGN5PSIxMTYiIHI9IjI2IiBmaWxsPSIjOTNDNUZEIi8+DQogIDxyZWN0IHg9IjI0IiB5PSIxNjAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgcng9IjgiIGZpbGw9IiNGREU2OEEiLz4NCjwvc3ZnPg==&logoColor=F56565&logoSize=auto&color=gray&labelColor=gray)](https://dashboardicons.com/)
[![Lucide](https://img.shields.io/badge/Lucide-_?style=flat&logo=lucide&logoColor=F56565&logoSize=auto&color=gray&labelColor=gray)](https://lucide.dev/)
