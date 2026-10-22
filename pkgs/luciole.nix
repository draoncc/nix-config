{
  lib,
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation rec {
  pname = "luciole";
  version = "1.0";

  src = fetchzip {
    url = "https://www.luciole-vision.com/fonts/Luciole_webfonts.zip";
    sha256 = "sha256-o/Za6zTEFa8JQA+zOTILxZUY71prTT8uL7ZOOoJ4tn8=";
    stripRoot = false;
  };

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  doCheck = false;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    install -Dm644 -t $out/share/fonts/truetype/ Luciole_webfonts/Luciole-*.ttf
    runHook postInstall
  '';

  meta = with lib; {
    description = "A typeface developed explicitly for visually impaired people.";
    homepage = "https://www.luciole-vision.com/luciole-en.html";
    license = licenses.cc-by-40;
    platforms = platforms.all;
  };
}
