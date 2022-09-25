PURS_OUTPUT := "pkgs/ts/cardano-fe/core"

spago-build:
  yarn run spago build --purs-args "--stash --censor-lib --censor-codes=WildcardInferredType --output {{PURS_OUTPUT}}"

spago-build-ide:
  yarn run spago build --purs-args "--stash --censor-lib --json-errors --censor-codes=WildcardInferredType --output {{PURS_OUTPUT}}"

generate-types:
  rm -rf output/*/*.d.ts;
  yarn run spago run --main CardanoFe.Modules --node-args "--output-dir {{PURS_OUTPUT}}";