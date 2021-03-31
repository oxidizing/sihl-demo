# ocaml/opam post create script

sudo chown -R opam: _build

# remove and update default ocaml remote
# make sure that opam finds latest package versions
# (b.c. alcotest latest version is 1.1.0 instead of 1.2.1)
opam remote remove --all default
opam remote add default https://opam.ocaml.org

# Pins
# opam pin add -yn ocaml-lsp-server https://github.com/ocaml/ocaml-lsp.git

# install opam packages
# e.g. when developing with emax, add also: utop merlin ocamlformat
opam install caqti-driver-postgresql ocamlformat ocaml-lsp-server.1.4.0 sihl alcotest-lwt

# install project dependancies
# pin package
opam pin add pizza.dev . --no-action
# Query and install external dependencies
opam depext pizza --yes --with-doc
# install dependencies
OPAMSOLVERTIMEOUT=180 opam install . --deps-only --with-doc --with-test --locked --unlock-base
opam install ocamlformat --skip-updates
# upgrade dependencies
opam upgrade --fixup

# initialize project and update environmemnt
opam init
eval $(opam env)
