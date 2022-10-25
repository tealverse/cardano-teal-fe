PURS_OUTPUT := "pkgs/ts/cardano-fe/core"

dev:
  NODE_ENV=development yarn run vite

spago-build:
  yarn run spago build --purs-args "--stash --censor-lib --censor-codes=WildcardInferredType --output {{PURS_OUTPUT}}"

spago-build-ide:
  yarn run spago build --purs-args "--stash --censor-lib --json-errors --censor-codes=WildcardInferredType --output {{PURS_OUTPUT}}"

generate-types: spago-build
  #!/bin/bash
  rm -rf {{PURS_OUTPUT}}/*/*.d.ts;
  DIR=pkgs/node_modules/@emurgo/cardano-serialization-lib-asmjs;
  mkdir -p $DIR;
  echo "exports = {}" > $DIR/index.js ;
  node generate-types.js --output-dir {{PURS_OUTPUT}} ;
  rm -rf pkgs/node_modules ;

spago-repl:
  yarn run spago repl