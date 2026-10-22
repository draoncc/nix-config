{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  inherit (import ./lua.nix { inherit lib; }) hyprctlDispatch toLua;
  rgb = color: "rgb(${color})";
  rgba = color: alpha: "rgba(${color}${alpha})";
  palette = config.lib.stylix.colors;
  inherit (config.stylix) fonts;

  settings = {
    # Local colors
    bar_color = rgba palette.base00 "dd";
    col.text = rgb palette.base01;
    bar_height = 25;
    bar_text_font = fonts.sansSerif.name;
    bar_text_size = builtins.floor (fonts.sizes.desktop * 1.4);
    bar_part_of_window = false;
    bar_precedence_over_border = false;
  };

  buttons =
    let
      closeAction = hyprctlDispatch "hl.dsp.window.close()";

      isOnSpecial = ''hyprctl activewindow -j | jq -re 'select(.workspace.name == "special")' >/dev/null'';
      moveToSpecial = hyprctlDispatch ''hl.dsp.window.move({ workspace = "special", follow = false })'';
      moveToActive = ''hyprctl dispatch "hl.dsp.window.move({ workspace = '$(hyprctl -j activeworkspace | jq -re '.id')', follow = false })"'';
      minimizeAction = "${isOnSpecial} && ${moveToActive} || ${moveToSpecial}";

      maximizeAction = hyprctlDispatch ''hl.dsp.window.fullscreen({ mode = "maximized" })'';

      button = color: action: {
        bg_color = rgb color;
        fg_color = rgb palette.base00;
        size = 12;
        icon = "";
        inherit action;
      };
    in
    [
      # Red close button
      (button palette.base08 closeAction)
      # Yellow "minimize" (send to special workspace) button
      (button palette.base08 minimizeAction)
      # Green "maximize" (fullscreen) button
      (button palette.base05 maximizeAction)
    ];

  windowRules = [
    # Disable bars in floating pinned windows
    {
      match = {
        float = 1;
        pin = 1;
      };
      "hyprbars:no_bar" = "on";
    }

    # Local colors (this host's colors)
    {
      match.focus = 0;
      "hyprbars:bar_color" = rgba palette.base00 "dd";
      "hyprbars:title_color" = rgb palette.base01;
    }
    # Local focused colors
    {
      match.focus = 1;
      "hyprbars:bar_color" = rgba palette.base02 "ee";
      "hyprbars:title_color" = rgb palette.base04;
    }
  ];
in
{
  wayland.windowManager.hyprland = {
    plugins = [ inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprbars ];

    # Plugins load after the first config pass (which then reloads), so
    # hyprbars' options, rule effects and functions only exist from then on.
    extraConfig = ''
      if hl.plugin.hyprbars then
        hl.config({ plugin = { hyprbars = ${toLua settings} } })
        for _, button in ipairs(${toLua buttons}) do
          hl.plugin.hyprbars.add_button(button)
        end
        for _, rule in ipairs(${toLua windowRules}) do
          hl.window_rule(rule)
        end
      end
    '';
  };
}
