{ outputs, inputs }:

{
  flake-inputs = final: _: {
    inputs = builtins.mapAttrs (
      _: flake:
      let
        legacyPackages = ((flake.legacyPackages or { }).${final.stdenv.hostPlatform.system} or { });
        packages = ((flake.packages or { }).${final.stdenv.hostPlatform.system} or { });
      in
      if legacyPackages != { } then legacyPackages else packages
    ) inputs;
  };

  nix-colors = final: _: {
    nodePackages = {
      sass = final.dar;
    };
  };

  additions = final: prev: import ../pkgs { pkgs = final; };
}
