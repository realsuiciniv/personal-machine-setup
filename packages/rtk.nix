{ stdenv, fetchurl }:
stdenv.mkDerivation {
  pname = "rtk";
  version = "0.38.0";
  src = fetchurl {
    url = "https://github.com/rtk-ai/rtk/releases/download/v0.38.0/rtk-aarch64-apple-darwin.tar.gz";
    sha256 = "0ypr50wwfvb5h9wbz8rqx7j3agr3d6aimsc8mpd1sr027p2ci5iq";
  };
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/bin
    tar -xzf $src -C $out/bin
    chmod +x $out/bin/rtk
  '';
}
