{ stdenv, fetchurl }:
stdenv.mkDerivation {
  pname = "rtk";
  version = "0.42.4";
  src = fetchurl {
    url = "https://github.com/rtk-ai/rtk/releases/download/v0.42.4/rtk-aarch64-apple-darwin.tar.gz";
    sha256 = "00k8b1pc113frsm1dbp8ncjkxfcjr8s1vg3r4q0ay582983wl8zj";
  };
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/bin
    tar -xzf $src -C $out/bin
    chmod +x $out/bin/rtk
  '';
}
