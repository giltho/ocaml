#!/bin/zsh

COMMIT_HASH=$(git rev-parse HEAD)

function switch_back () {
  opam switch 4.11.1
  opam switch remove $COMMIT_HASH -y
}

opam switch create $COMMIT_HASH --empty
eval $(opam env)
opam install . -y --working-dir

cd /Users/sacha/Prog/work/Gillian

echo "INSTALLING OPAM DEPS"
opam install . -y --deps-only --unlock-base


RUNTIME_PATH=/Users/sacha/Prog/work/Gillian/_build/install/default/share/gillian-js
Z3LIB=/Users/sacha/.opam/$COMMIT_HASH/lib/z3


echo "COMPUTING AMAZON TIME"
TIME=$(DYLD_LIBRARY_PATH=$Z3LIB LD_LIBRARY_PATH=$Z3LIB GILLIAN_JS_RUNTIME_PATH=$RUNTIME_PATH opam exec -- dune exec Gillian-JS/bin/gillian_js.exe -- verify Gillian-JS/Examples/Amazon/deserialize_factory.js -l disabled --no-lemma-proof --amazon | tail -1 | awk -F ": " '{print $2}') || exit 125

echo "TIME IS: $TIME"

re='^[0-9]+[.][0-9]+'
if ! [[ $TIME =~ $re ]]; then
  switch_back
  exit 125
fi

if (( $TIME > 45 )); then
  switch_back
  exit 1
fi

switch_back