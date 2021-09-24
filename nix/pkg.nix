{ mkDerivation, async, base, bitfinex-client, bytestring
, containers, envparse, esqueleto, extra, hpack, hspec, katip, lib
, monad-logger, persistent, persistent-postgresql, resource-pool
, stm, template-haskell, text, time, transformers, unbounded-delays
, universum, unliftio, witch
}:
mkDerivation {
  pname = "reckless-trading-bot";
  version = "0.1.0.0";
  src = ./..;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    async base bitfinex-client bytestring containers envparse esqueleto
    extra katip monad-logger persistent persistent-postgresql
    resource-pool stm template-haskell text time transformers
    unbounded-delays universum unliftio witch
  ];
  libraryToolDepends = [ hpack ];
  executableHaskellDepends = [
    base bytestring esqueleto katip monad-logger persistent
    persistent-postgresql template-haskell text time unbounded-delays
    universum
  ];
  testHaskellDepends = [
    base bytestring esqueleto hspec katip monad-logger persistent
    persistent-postgresql template-haskell text time unbounded-delays
    universum
  ];
  prePatch = "hpack";
  homepage = "https://github.com/tkachuk-labs/reckless-trading-bot#readme";
  license = lib.licenses.bsd3;
}
