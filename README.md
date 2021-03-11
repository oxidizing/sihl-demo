# Sihl demo app

A restaurant serving pizza and sometimes lasagna, delicious lasagna.

This is an app that demonstrates the usage of the web framework [Sihl](https://github.com/oxidizing/sihl/). The goal is to showcase every feature of Sihl.

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

## Contributing

Take a look at our [Contributing Guide](CONTRIBUTING.md).
