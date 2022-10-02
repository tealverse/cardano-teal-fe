PURS_OUTPUT := "pkgs/ts/cardano-fe/core"

spago-build:
  yarn run spago build --purs-args "--stash --censor-lib --censor-codes=WildcardInferredType --output {{PURS_OUTPUT}}"

spago-build-ide:
  yarn run spago build --purs-args "--stash --censor-lib --json-errors --censor-codes=WildcardInferredType --output {{PURS_OUTPUT}}"

generate-types: spago-build
  rm -rf {{PURS_OUTPUT}}/*/*.d.ts;
  node generate-types.js --output-dir {{PURS_OUTPUT}}