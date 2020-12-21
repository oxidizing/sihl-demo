# ocaml/opam post create script

# remove and update default ocaml remote
# make sure that opam finds latest package versions
# (b.c. alcotest latest version is 1.1.0 instead of 1.2.1)
opam remote remove --all default
opam remote add default https://opam.ocaml.org

# Pins
opam pin add -yn ocaml-lsp-server https://github.com/ocaml/ocaml-lsp.git

# install opam packages
# e.g. when developing with emax, add also: utop merlin ocamlformat
opam install caqti-driver-postgresql ocamlformat ocaml-lsp-server sihl

# install project dependancies
opam pin add -y -n demo .
OPAMSOLVERTIMEOUT=180 opam depext -y demo
opam install --deps-only -y demo --with-test
opam install -y alcotest-lwt

# initialize project and update environmemnt
opam init
eval $(opam env)
