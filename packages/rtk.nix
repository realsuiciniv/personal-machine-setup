{ stdenv, fetchurl }:
stdenv.mkDerivation {
  pname = "rtk";
  version = "0.42.0";
  src = fetchurl {
    url = "https://github.com/rtk-ai/rtk/releases/download/v0.42.0/rtk-aarch64-apple-darwin.tar.gz";
    sha256 = "092p323jj1lqrx2fm5ajqkgcin96mgka1azb5qsb706z3k8rrp6d";
  };
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/bin
    tar -xzf $src -C $out/bin
    chmod +x $out/bin/rtk
  '';
}
