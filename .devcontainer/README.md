# VSCode setup

## Requirements

This project is setup to run in a DevContainer. Ensure requirements to run in a DevContainer:

1. [Docker](/Technologies/Docker) installed
1. [Visual Studio Code](https://code.visualstudio.com/) (VS Code) installed
1. VS Code Extension [Remote Container](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) installed

## Start DevContainer

- Before starting the devcontainer make sure `DATABASE_URL` is deleted, commented or the host is set to `database` (instead of localhost) in `.env` file.

Click on the icon similar to "><" in the bottom left corner and select `Remote-Containers: Reopen in Container`.
If any changes were made to files in `.devcontainer` folder the Container should be rebuilt (`Remote-Containers: Rebuild Container`)

## Quickstart

1. Run migrations:

    ```
    make sihl migrate
    ```

1. Run the development server:

    ```
    make dev
    ```

1. Open Browser on `localhost:3000`

[Back to main README](../README.md)
