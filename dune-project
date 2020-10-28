(lang dune 2.7)
(generate_opam_files true)

(name demo)
(version 0.0.1)

(authors
  "Josef Erben"
  "Aron Erben"
  "Miko Nieminen")

(source (github oxidizing/sihl-demo))
(license MIT)
(maintainers "josef@oxidizing.io")
(homepage "https://github.com/oxidizing/sihl-demo")
(bug_reports "https://github.com/oxidizing/sihl-demo/issues")
(documentation "https://oxidizing.github.io/sihl/")

(package
 (name demo)
 (synopsis "A small demo application written in Sihl")
 (description "This demo showcases all aspects of Sihl and gives examples for each feature.")
 (depends
  ;; General system dependencies
  (dune (>= 2.7))
  (ocaml (>= 4.08.0))
  (sihl (>= 0.1.5))))
