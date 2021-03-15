# Sihl demo app

A restaurant serving pizza and sometimes lasagna, delicious lasagna.

This is an app that demonstrates the usage of the web framework [Sihl](https://github.com/oxidizing/sihl/). The goal is to showcase every feature of Sihl.

1. Clone the repository and run
   ```
   dune build
   ```
2. Install all dependencies as proposed by `dune`. If you want to install all dependencies manually, run
   ```
   opam install -y . --deps-only --with-doc --with-test --locked --unlock-base
   ```

## TODO
- Makefile commands
- Docker commands
- Postgres dependencies
## Quickstart

1. After cloning the repository, create an opam switch:

```
make switch
```

2. Start the database using docker:

```
make db
```

3. Run migrations:

```
make sihl migrate
```

4. Run the development server:

```
make dev
```

5. Go to localhost:3000

## VSCode setup

### Requirements

This project is setup to run in a DevContainer. Ensure requirements to run in a DevContainer:

1. [Docker](/Technologies/Docker) installed
1. [Visual Studio Code](https://code.visualstudio.com/) (VS Code) installed
1. VS Code Extension [Remote Container](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) installed

### Start DevContainer

Click on the icon similar to "><" in the bottom left corner and select `Remote-Containers: Reopen in Container`.
If any changes were made to files in `.devcontainer` folder the Container should be rebuilt (`Remote-Containers: Rebuild Container`)

## Contributing

Take a look at our [Contributing Guide](CONTRIBUTING.md).
