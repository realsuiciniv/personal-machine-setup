{ stdenv, fetchurl }:
stdenv.mkDerivation {
  pname = "rtk";
  version = "0.49.0";
  src = fetchurl {
    url = "https://github.com/rtk-ai/rtk/releases/download/v0.49.0/rtk-aarch64-apple-darwin.tar.gz";
    sha256 = "00df2f705ylfc00bnjp2ibxiclfksnj1lwysh0x9k1i6namypgxv";
  };
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/bin
    tar -xzf $src -C $out/bin
    chmod +x $out/bin/rtk
  '';
}
