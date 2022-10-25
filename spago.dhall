{-
Welcome to a Spago project!
You can edit this file as you like.

Need help? See the following resources:
- Spago documentation: https://github.com/purescript/spago
- Dhall language tour: https://docs.dhall-lang.org/tutorials/Language-Tour.html

When creating a new Spago project, you can use
`spago init --no-comments` or `spago init -C`
to generate this file without the comments in this block.
-}
{ name = "cardano-teal-fe"
, dependencies =
  [ "aff"
  , "aff-promise"
  , "affjax"
  , "affjax-node"
  , "affjax-web"
  , "argonaut"
  , "argonaut-codecs"
  , "argonaut-core"
  , "arrays"
  , "bifunctors"
  , "console"
  , "control"
  , "datetime"
  , "debug"
  , "effect"
  , "either"
  , "exceptions"
  , "foldable-traversable"
  , "foreign"
  , "foreign-object"
  , "heterogeneous"
  , "integers"
  , "maybe"
  , "newtype"
  , "now"
  , "numbers"
  , "ordered-collections"
  , "pairs"
  , "parallel"
  , "prelude"
  , "record"
  , "strings"
  , "transformers"
  , "tuples"
  , "typelevel"
  , "typescript-bridge"
  ]
, packages = ./packages.dhall
, sources = [ "pkgs/purs/src/**/*.purs", "pkgs/purs/test/**/*.purs" ]
}
