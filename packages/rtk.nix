{ stdenv, fetchurl }:
stdenv.mkDerivation {
  pname = "rtk";
  version = "0.45.0";
  src = fetchurl {
    url = "https://github.com/rtk-ai/rtk/releases/download/v0.45.0/rtk-aarch64-apple-darwin.tar.gz";
    sha256 = "1x63gxhawgixii1lqkjkhdg9970vwkr0lsmh23c282ymqb7m2h86";
  };
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/bin
    tar -xzf $src -C $out/bin
    chmod +x $out/bin/rtk
  '';
}
