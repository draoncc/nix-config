{ pkgs, lib, ... }:

let
  mod = "Mod1";
  left = "h";
  down = "t";
  up = "n";
  right = "s";
in {
  imports = [ ./rofi ./polybar ./picom ];

  home.packages = with pkgs; [ xsecurelock ];

  xsession.enable = true;
  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;

    config = {
      modifier = mod;
      bars = [ ];
      floating.modifier = mod;

      window = {
        titlebar = false;
        hideEdgeBorders = "none";
      };

      focus = {
        followMouse = false;
        newWindow = "urgent";
      };

      fonts = {
        names = [ "Noto Mono for Powerline 11" ];
        size = 13.0;
      };

      gaps = {
        inner = 12;
        outer = -12;
        smartGaps = true;
        smartBorders = "on";
      };

      colors = {
        focused = {
          border = "#82aaff";
          background = "#82aaff";
          text = "#37474f";
          indicator = "#c3e88d";
          childBorder = "#82aaff";
        };
        focusedInactive = {
          border = "#263238";
          background = "#263238";
          text = "#eeffff";
          indicator = "#263238";
          childBorder = "#263238";
        };
        unfocused = {
          border = "#151515cc";
          background = "#151515cc";
          text = "#00000000";
          indicator = "#151515cc";
          childBorder = "#151515cc";
        };
        urgent = {
          border = "#ff5370";
          background = "#ff5370";
          text = "#37474f";
          indicator = "#c3e88d";
          childBorder = "#ff5370";
        };
      };

      assigns = {
        "2" = [{ class = "^Google Chrome$"; }];
        "3" = [{ class = "^wezterm$"; }];
      };

      keybindings = lib.mkDefault {
        "${mod}+Return" = "exec $TERMINAL";
        "${mod}+e" = ''exec "$HOME/.config/rofi/scripts/launcher.sh"'';
        "${mod}+l" = "exec xsecurelock";
        "${mod}+c" =
          ''exec "rofi -show calc -modi calc -no-show-match -no-sort"'';
        "${mod}+Control+s" = "exec rofi-screenshot";
        "${mod}+v" = ''exec "rofi -modi emoji -show emoji"'';

        "${mod}+Shift+semicolon" = "kill";
        "${mod}+Shift+j" = "reload";
        "${mod}+Shift+period" = "exit";

        # Moving around
        "${mod}+${left}" = "focus left";
        "${mod}+${down}" = "focus down";
        "${mod}+${up}" = "focus up";
        "${mod}+${right}" = "focus right";

        "${mod}+Shift+${left}" = "move left";
        "${mod}+Shift+${down}" = "move down";
        "${mod}+Shift+${up}" = "move up";
        "${mod}+Shift+${right}" = "move right";

        # Workspaces
        "${mod}+ampersand" = "workspace 1";
        "${mod}+bracketleft" = "workspace 2";
        "${mod}+braceleft" = "workspace 3";
        "${mod}+braceright" = "workspace 4";
        "${mod}+parenleft" = "workspace 5";
        "${mod}+equal" = "workspace 6";
        "${mod}+asterisk" = "workspace 7";
        "${mod}+parenright" = "workspace 8";
        "${mod}+plus" = "workspace 9";
        "${mod}+bracketright" = "workspace 10";

        "${mod}+Shift+ampersand" = "move container to workspace 1";
        "${mod}+Shift+bracketleft" = "move container to workspace 2";
        "${mod}+Shift+braceleft" = "move container to workspace 3";
        "${mod}+Shift+braceright" = "move container to workspace 4";
        "${mod}+Shift+1" = "move container to workspace 5";
        "${mod}+Shift+9" = "move container to workspace 6";
        "${mod}+Shift+0" = "move container to workspace 7";
        "${mod}+Shift+2" = "move container to workspace 8";
        "${mod}+Shift+4" = "move container to workspace 9";
        "${mod}+Shift+bracketright" = "move container to workspace 10";

        # Layouting
        "${mod}+d" = "splith";
        "${mod}+k" = "splitv";
        "${mod}+o" = "layout stacking";
        "${mod}+comma" = "layout tabbed";
        "${mod}+period" = "layout toggle split";
        "${mod}+u" = "fullscreen";
        "${mod}+p" = ''mode "resize"'';

        "${mod}+Shift+space" = "floating toggle";
        "${mod}+space" = "focus mode_toggle";

        # Scratchpad
        "${mod}+Shift+minus" = "move scratchpad";
        "${mod}+minus" = "scratchpad show";
      };

      modes = {
        rezize = {
          "${left}" = "resize shrink width 10 px or 10 ppt";
          "${down}" = "resize grow height 10 px or 10 ppt";
          "${up}" = "resize shrink height 10 px or 10 ppt";
          "${right}" = "resize grow width 10 px or 10 ppt";
        };
      };
    };
  };
}
