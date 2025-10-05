{
  stdenv,
  lib,
  zlib,
  autoPatchelfHook,
  gcc-unwrapped,
  libxml2,
  ...
}:
stdenv.mkDerivation {
  name = "llvm-snippy";
  version = "2.0";
  src = builtins.fetchurl {
    url = "https://github.com/syntacore/snippy/releases/download/snippy-2.0/snippy-2.0.tar.gz";
    sha256 = "sha256:0zda58ajx43kam9h6cdk6hiwzq7bnb97cqhya06yj4brvr6hbx12";
  };
  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [
    zlib
    gcc-unwrapped
    libxml2.out
  ];
  installPhase = ''
    mkdir -p $out/lib
    ln -sf ${libxml2.out}/lib/libxml2.so $out/lib/libxml2.so.2
    tar xzf $src
    install -D -m755 llvm-snippy $out/bin/llvm-snippy
    install -D -m755 ld.lld $out/bin/ld.lld
  '';
  meta.mainProgram = "llvm-snippy";
}
