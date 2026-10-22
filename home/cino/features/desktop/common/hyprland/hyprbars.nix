{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  rgb = color: "rgb(${lib.removePrefix "#" color})";
  rgba = color: alpha: "rgba(${lib.removePrefix "#" color}${alpha})";
  palette = config.colorscheme.palette;
in
{
  wayland.windowManager.hyprland = {
    plugins = [ inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprbars ];
    settings = {
      plugin.hyprbars = {
        # Local colors
        bar_color = rgba palette.base00 "dd";
        "col.text" = rgb palette.base01;
        bar_height = 25;
        bar_text_font = config.fontProfiles.regular.family;
        bar_text_size = builtins.floor (12 * 1.4);
        bar_part_of_window = false;
        bar_precedence_over_border = false;
        hyprbars-button =
          let
            closeAction = "hyprctl dispatch killactive";

            isOnSpecial = ''hyprctl activewindow -j | jq -re 'select(.workspace.name == "special")' >/dev/null'';
            moveToSpecial = "hyprctl dispatch movetoworkspacesilent special";
            moveToActive = "hyprctl dispatch movetoworkspacesilent $(hyprctl -j activeworkspace | jq -re '.id')";
            minimizeAction = "${isOnSpecial} && ${moveToActive} || ${moveToSpecial}";

            maximizeAction = "hyprctl dispatch fullscreen 1";
          in
          [
            # Red close button
            "${rgb palette.base08},12,,${closeAction}"
            # Yellow "minimize" (send to special workspace) button
            "${rgb palette.base08},12,,${minimizeAction}"
            # Green "maximize" (fullscreen) button
            "${rgb palette.base05},12,,${maximizeAction}"
          ];
      };

      windowrule = [
        # Disable bars in floating pinned windows
        "hyprbars:no_bar on, match:float 1, match:pin 1"

        # Local colors (this host's colors)
        "hyprbars:bar_color ${rgba palette.base00 "dd"}, match:focus 0"
        "hyprbars:title_color ${rgb palette.base01}, match:focus 0"
        # Local focused colors
        "hyprbars:bar_color ${rgba palette.base02 "ee"}, match:focus 1"
        "hyprbars:title_color ${rgb palette.base04}, match:focus 1"
      ];
    };
  };
}
