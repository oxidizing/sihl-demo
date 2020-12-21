# Sihl Demo Application

This is a simple demo application showcasing the web framework [Sihl](https://github.com/oxidizing/sihl). This project is meant to be clicked through to give a general sense of the folder and file structure of a typical Sihl project. This project aims to cover all aspects of Sihl comprehensively. It can also be used as a starter to kindle your own Sihl project!

## Installation
If you want to run this demo application locally, you will need `dune` and `opam`.

1. Clone the repository and run
   ```
   dune build
   ```
2. Install all dependencies as proposed by `dune`. If you want to install all dependencies manually, run
   ```
   opam install -y . --deps-only --with-doc --with-test --locked --unlock-base
   ```

### VSCode setup

#### Requirements

This project is setup to run in a DevContainer. Ensure requirements to run in a DevContainer:

1. [Docker](/Technologies/Docker) installed
1. [Visual Studio Code](https://code.visualstudio.com/) (VS Code) installed
1. VS Code Extension [Remote Container](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) installed

#### Start DevContainer

Click on the icon similar to "><" in the bottom left corner and select `Remote-Containers: Reopen in Container`.
If any changes were made to files in `.devcontainer` folder the Container should be rebuilt (`Remote-Containers: Rebuild Container`)

## TODO
- Makefile commands
- Docker commands
- Postgres dependencies

## Why pizza?
Why not? :)

