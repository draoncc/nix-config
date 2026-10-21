{pkgs, config, ...}: let
  inherit (config.colorscheme) palette;
in {
  services.swayosd = {
    enable = true;
    stylePath = pkgs.writeText "style.css" ''
      window {
        padding: 0 1em;
        border: 10em;
        border-radius: 10em;
        background-color: ${palette.base00};
        opacity: 0.7;
      }
      #container {
        margin: 1em;
      }

      image {
        color: ${palette.base01};
        opacity: 0.9;
      }
      image:disabled {
        color: ${palette.base04};
        opacity: 0.8;
      }
      label {
        color: ${palette.base04};
        opacity: 1;
      }

      progress {
        min-height: inherit;
        border-radius: inherit;
        border: none;
        background-color: ${palette.base01};
        opacity: 0.9;
      }
      progressbar {
        min-height: 0.5em;
        border-radius: 100em;
        background-color: transparent;
        border: none;
        opacity: 0.9;
      }
      progressbar:disabled {
        opacity: 0.5;
      }

      trough {
        min-height: inherit;
        border-radius: inherit;
        border: none;
        background-color: ${palette.base02};
        opacity: 1;
      }
    '';
  };
}
