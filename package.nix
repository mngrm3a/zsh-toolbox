{ mkDerivation, base, directory, filepath, hspec, hspec-discover
, lib, process, unix
}:
mkDerivation {
  pname = "zsh-toolbox";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [ base directory filepath process unix ];
  executableHaskellDepends = [
    base directory filepath process unix
  ];
  testHaskellDepends = [
    base directory filepath hspec process unix
  ];
  testToolDepends = [ hspec-discover ];
  homepage = "https://github.com/mngrm3a/zsh-toolbox#readme";
  license = lib.licenses.bsd3;
  mainProgram = "zsh-toolbox-exe";
}
