(lang dune 2.0)

(name pizza)

(documentation "https://oxidizing.github.io/pizza/")

(source
 (github oxidizing/pizza))

(license MIT)

(authors
  "Josef Erben")

(maintainers
  "Josef Erben")

(generate_opam_files true)

(package
 (name pizza)
 (synopsis "A restaurant serving Pizza and sometimes Lasagna")
 (description "\
A restaurant serving Pizza and sometimes Lasagna
")
 (depends
  (ocaml (>= 4.08.0))
  dune
  (sihl (= 0.3.0~rc2))
  (sihl-user (= 0.3.0~rc2))
  (tyxml-ppx (>= 4.4.0))
  (caqti-driver-postgresql (>= 1.2.1))
  (alcotest-lwt :with-test)
  (odoc :with-doc)))
