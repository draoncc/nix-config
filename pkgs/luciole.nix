{ lib, stdenvNoCC, fetchzip }:

stdenvNoCC.mkDerivation rec {
  pname = "luciole";
  version = "1.0";

  src = fetchzip {
    url = "https://www.luciole-vision.com/Fichiers/Luciole_webfonts.zip";
    sha256 = "sha256-67yd5U8RmTX+zf9qnmrnZ4WITV674DJcYWovXaS402Y=";
    stripRoot = false;
  };

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  doCheck = false;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    install -Dm644 -t $out/share/fonts/truetype/ Luciole_webfonts/Luciole-*/*.ttf
    runHook postInstall
  '';

  meta = with lib; {
    description =
      "A typeface developed explicitly for visually impaired people.";
    homepage = "https://www.luciole-vision.com/luciole-en.html";
    license = licenses.cc-by-40;
    platforms = platforms.all;
  };
}
