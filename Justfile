root := justfile_directory()

export TYPST_ROOT := root

[private]
default:
	@just --list --unsorted

# generate manuals and examples
doc:
	typst compile docs/manual-de.typ docs/manual-de.pdf
	typst compile docs/manual-en.typ docs/manual-en.pdf
	typst compile docs/example-de-thesis.typ docs/example-de-thesis.pdf

# run test suite
test *args:
	tt run {{ args }}

# update test cases
update *args:
	tt update {{ args }}

# package the library into the specified destination folder
package target:
  ./scripts/package "{{target}}"

# install the library with the "@local" prefix
install: (package "@local")

# install the library with the "@preview" prefix (for pre-release testing)
install-preview: (package "@preview")

[private]
remove target:
  ./scripts/uninstall "{{target}}"

# uninstalls the library from the "@local" prefix
uninstall: (remove "@local")

# uninstalls the library from the "@preview" prefix (for pre-release testing)
uninstall-preview: (remove "@preview")

# run ci suite
ci: test doc
