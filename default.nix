{
  stdenv,
  lib,
  makeWrapper,
  dtc,
  which,
  gnugrep,
  zlib,
  openssl,
  pkgs,
  snippy,
  ...
}:
let
  versionList = builtins.match "#define SPIKE_VERSION \"(.*)\"\n" (builtins.readFile ./VERSION);
  spikeVersion = if isNull versionList then null else builtins.head versionList;
  riscv-pk = pkgs.pkgsCross.riscv64.riscv-pk;
  riscv-gcc = pkgs.pkgsCross.riscv64.pkgsStatic.stdenv.cc;
  buildTests = !stdenv.hostPlatform.isDarwin;
in
assert spikeVersion != null;
stdenv.mkDerivation {
  pname = "riscv-isa-sim";
  version = spikeVersion;
  src = lib.cleanSource ./.;
  postUnpack = ''
    patchShebangs .
  '';
  nativeBuildInputs = [
    dtc
    makeWrapper
  ];
  postInstall = ''
    wrapProgram $out/bin/spike --set PATH "${lib.getBin dtc}:$PATH"
  '';
  enableParallelBuilding = true;
  doCheck = buildTests;
  nativeCheckInputs = lib.optionals buildTests [
    which
    riscv-gcc
    gnugrep
  ];
  checkInputs = lib.optionals buildTests [
    riscv-pk
    openssl
    zlib
    snippy
  ];
  checkPhase = lib.optional buildTests ''
    runHook preCheck
    substituteInPlace "$NIX_BUILD_TOP/source/ci-tests/test-spike" \
      --replace "riscv64-linux-gnu-gcc" "${lib.getExe riscv-gcc}" \
      --replace "./llvm-snippy" "${lib.getExe snippy}" \
      --replace "git rev-parse --show-toplevel" "echo $(pwd)"
    substituteInPlace "$NIX_BUILD_TOP/source/ci-tests/generate-snippy-test.sh" \
      --replace "riscv64-linux-gnu-gcc" "${lib.getExe riscv-gcc}" \
      --replace "./llvm-snippy" "${lib.getExe snippy}" \
      --replace "git rev-parse --show-toplevel" "echo $(pwd)"
    substituteInPlace "$NIX_BUILD_TOP/source/ci-tests/generate-snippy-tests.sh" \
      --replace "riscv64-linux-gnu-gcc" "${lib.getExe riscv-gcc}" \
      --replace "./llvm-snippy" "${lib.getExe snippy}" \
      --replace "git rev-parse --show-toplevel" "echo $(pwd)"
    ROOTDIR=$NIX_BUILD_TOP/source
    llvm-snippy --version
    $ROOTDIR/ci-tests/test-spike $ROOTDIR $(pwd)
    runHook postCheck
  '';
}
