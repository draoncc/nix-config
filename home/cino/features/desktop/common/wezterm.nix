{ pkgs, ... }:

{
  home.packages = with pkgs; [ wezterm ];

  home.sessionVariables = {
    TERM = "wezterm";
    TERMINAL = "wezterm";
  };

  xdg.configFile."wezterm/wezterm.lua".text = ''
    local wezterm = require 'wezterm'

    local my_framer = wezterm.color.get_builtin_schemes()['Framer (base16)']
    my_framer.cursor_fg = '#181818'
    my_framer.cursor_bg = '#EEEEEE'
    my_framer.compose_cursor = '#20BCFC'

    return {
      font_size = 14,
      window_background_opacity = 0.85,
      hide_tab_bar_if_only_one_tab = true,
      default_cursor_style = "BlinkingUnderline",
      cursor_blink_rate = 600,

      color_schemes = {
        ['My Framer'] = my_framer,
      },

      color_scheme = 'My Framer',
    }
  '';
}
