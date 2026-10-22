{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (import ./lua.nix { inherit lib; })
    keys
    bind
    exec
    ;

  palette = config.lib.stylix.colors;

  mod = "ALT";
  keymaps = {
    e = "code:26";
    q = "code:24";
    s = "code:39";
    f = "code:41";
    minus = "code:20";
    equal = "code:21";
    g = "code:42";
    t = "code:28";
    apostrophe = "code:48";
    u = "code:30";
    v = "code:55";
    b = "code:56";
    w = "code:25";
    x = "code:53";
    d = "code:40";
    semicolon = "code:47";
    P = "code:33";
  };

  swayosd = {
    brightness = "swayosd-client --brightness +0";
    output-volume = "swayosd-client --output-volume +0";
    input-volume = "swayosd-client --input-volume +0";
  };
  grimblast = lib.getExe pkgs.grimblast;

  # Hyprland's systemd integration only *starts* the session (exec-once starts
  # hyprland-session.target); nothing stops it on logout. Since our units are
  # PartOf/WantedBy graphical-session.target, they would leak stale into the
  # next login. Wrap the exported session so start-hyprland's return tears the
  # user session down cleanly.
  hyprPackage = config.wayland.windowManager.hyprland.package;
  hyprSessionLauncher = pkgs.writeShellScript "start-hyprland-session" ''
    ${hyprPackage}/bin/start-hyprland "$@"
    ${pkgs.systemd}/bin/systemctl --user stop hyprland-session.target graphical-session.target
  '';
  hyprSession =
    pkgs.runCommandLocal "hyprland-session"
      {
        passthru.providedSessions = [ "hyprland" ];
      }
      ''
        mkdir -p $out/share/wayland-sessions
        substitute \
          ${hyprPackage}/share/wayland-sessions/hyprland.desktop \
          $out/share/wayland-sessions/hyprland.desktop \
          --replace-fail ${hyprPackage}/bin/start-hyprland ${hyprSessionLauncher}
      '';
in
{
  imports = [
    ../wayland-wm

    ./basic-binds.nix
    ./hyprbars.nix
    ./hyprlock.nix
    ./hypridle.nix
    ./hyprpaper.nix
  ];

  home.packages = [
    pkgs.grimblast
    pkgs.hyprpicker
  ];

  home.exportedSessionPackages = [ hyprSession ];

  home.pointerCursor.hyprcursor.enable = true;

  xdg.portal = {
    extraPortals = [
      (pkgs.xdg-desktop-portal-hyprland.override {
        hyprland = config.wayland.windowManager.hyprland.package;
      })
    ];
    config.hyprland = {
      default = [
        "hyprland"
        "gtk"
      ];
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.inputs.hyprland.hyprland;
    # The hyprland input tracks git main, not a release. It only reads
    # hyprland.lua (hyprland.conf is ignored), and `hyprctl dispatch` takes
    # Lua too, e.g. `hyprctl dispatch 'hl.dsp.exit()'`.
    # Lua API reference (the wiki may lag behind main):
    # - types: ${package}/share/hypr/stubs/hl.meta.lua
    # - dispatcher arguments (stubs leave them untyped):
    #   src/config/lua/bindings/LuaBindingsDispatchers.cpp in the input's source
    # Plugins load after the first config pass, so hl.plugin.<name> is nil
    # until then; guard plugin calls (see hyprbars.nix).
    # Verify changes with `just check` (see checks/default.nix).
    configType = "lua";

    settings = {
      config = {
        general = {
          gaps_in = 15;
          gaps_out = 20;
          border_size = 3;
          col = {
            active_border = "rgb(${palette.base0C})";
            inactive_border = "rgb(${palette.base02})";
          };
        };

        dwindle = {
          split_width_multiplier = 1.35;
        };

        input = {
          kb_layout = "us";
          kb_variant = "dvp";
          kb_options = "eurosign:e,compose:102,numpad:shift3,kpdl:semi,keypad:atm,caps:escape";
          touchpad.disable_while_typing = false;
        };

        debug.vfr = true;

        decoration = {
          active_opacity = 0.92;
          inactive_opacity = 0.75;
          fullscreen_opacity = 1.0;
          rounding = 5;
          blur = {
            enabled = true;
            size = 5;
            passes = 3;
            new_optimizations = true;
            ignore_opacity = true;
          };
          shadow = {
            enabled = true;
            range = 12;
            offset = "3 3";
            color = "rgba(00000044)";
            color_inactive = "rgba(00000066)";
          };
        };

        animations.enabled = true;
      };

      curve =
        lib.mapAttrsToList
          (name: points: {
            _args = [
              name
              {
                type = "bezier";
                inherit points;
              }
            ];
          })
          {
            easein = [
              [
                0.32
                0
              ]
              [
                0.67
                0
              ]
            ]; # cubic
            easeout = [
              [
                0.33
                1
              ]
              [
                0.68
                1
              ]
            ]; # cubic
            easeinback = [
              [
                0.36
                0
              ]
              [
                0.66
                (-0.56)
              ]
            ];
            easeoutback = [
              [
                0.34
                1.56
              ]
              [
                0.64
                1
              ]
            ];
          };

      animation =
        map
          (
            a:
            {
              enabled = true;
              speed = 1;
            }
            // a
          )
          [
            {
              leaf = "windowsIn";
              bezier = "easeout";
              style = "slide";
            }
            {
              leaf = "windowsOut";
              bezier = "easein";
              style = "slide";
            }
            {
              leaf = "windowsMove";
              bezier = "easeout";
            }
            {
              leaf = "workspaces";
              speed = 2;
              bezier = "easeout";
              style = "slide";
            }
            {
              leaf = "fadeIn";
              bezier = "easeout";
            }
            {
              leaf = "fadeOut";
              bezier = "easein";
            }
            {
              leaf = "fadeSwitch";
              bezier = "easeout";
            }
            {
              leaf = "fadeShadow";
              bezier = "easeout";
            }
            {
              leaf = "fadeDim";
              bezier = "easeout";
            }
            {
              leaf = "border";
              bezier = "easeout";
            }
          ];

      bind =
        let
          swaylock = "${config.programs.swaylock.package}/bin/swaylock";
          playerctl = "${config.services.playerctld.package}/bin/playerctl";
          playerctld = "${config.services.playerctld.package}/bin/playerctld";
          makoctl = "${config.services.mako.package}/bin/makoctl";
          wofi = "${config.programs.wofi.package}/bin/wofi";
          pass-wofi = "${
            pkgs.pass-wofi.override {
              pass = config.programs.password-store.package;
            }
          }/bin/pass-wofi";

          pactl = "${pkgs.pulseaudio}/bin/pactl";

          gtk-launch = "${pkgs.gtk3}/bin/gtk-launch";
          xdg-mime = "${pkgs.xdg-utils}/bin/xdg-mime";
          defaultApp = type: "${gtk-launch} $(${xdg-mime} query default ${type})";

          terminal = config.home.sessionVariables.TERMINAL;
          browser = defaultApp "x-scheme-handler/https";
          editor = defaultApp "text/plain";

          execBind =
            mods: key: cmd:
            bind (keys mods key) (exec cmd);
        in
        with keymaps;
        [
          # Program bindings
          (execBind [ mod ] "Return" terminal)
          (execBind [ mod ] e editor)
          (execBind [ mod ] v editor)
          (execBind [ mod ] b browser)

          # Brightness control (only works if the system has brightnessctl)
          (execBind [ ] "XF86MonBrightnessUp" "brightnessctl s +10%; ${swayosd.brightness}")
          (execBind [ ] "XF86MonBrightnessDown" "brightnessctl s -10%; ${swayosd.brightness}")

          # Volume
          (execBind [ ] "XF86AudioRaiseVolume"
            "${pactl} set-sink-volume @DEFAULT_SINK@ +5%; ${swayosd.output-volume}"
          )
          (execBind [ ] "XF86AudioLowerVolume"
            "${pactl} set-sink-volume @DEFAULT_SINK@ -5%; ${swayosd.output-volume}"
          )
          (execBind [ ] "XF86AudioMute"
            "${pactl} set-sink-mute @DEFAULT_SINK@ toggle; ${swayosd.output-volume}"
          )
          (execBind [
            "SHIFT"
          ] "XF86AudioMute" "${pactl} set-source-mute @DEFAULT_SOURCE@ toggle; ${swayosd.input-volume}")
          (execBind [ ] "XF86AudioMicMute"
            "${pactl} set-source-mute @DEFAULT_SOURCE@ toggle; ${swayosd.input-volume}"
          )

          # Screenshotting
          (execBind [ ] "Print" "${grimblast} --notify --freeze copy output")
          (execBind [ "SHIFT" ] "Print" "${grimblast} --notify --freeze copy active")
          (execBind [ "CONTROL" ] "Print" "${grimblast} --notify --freeze copy screen")
          (execBind [ mod ] "Print" "${grimblast} --notify --freeze copy area")

          # Passthrough mode (e.g. for VNC)
          (bind (keys [ mod ] P) ''hl.dsp.submap("passthrough")'')
        ]
        ++

          (lib.optionals config.services.playerctld.enable [
            # Media control
            (execBind [ ] "XF86AudioNext" "${playerctl} next")
            (execBind [ ] "XF86AudioPrev" "${playerctl} previous")
            (execBind [ ] "XF86AudioPlay" "${playerctl} play-pause")
            (execBind [ ] "XF86AudioStop" "${playerctl} stop")
            (execBind [ "ALT" ] "XF86AudioNext" "${playerctld} shift")
            (execBind [ "ALT" ] "XF86AudioPrev" "${playerctld} unshift")
            (execBind [ "ALT" ] "XF86AudioPlay" "systemctl --user restart playerctld")
          ])
        ++

          # Screen lock
          (lib.optionals config.programs.swaylock.enable [
            (execBind [ ] "XF86Launch5" "${swaylock} -i ${config.wallpaper}")
            (execBind [ ] "XF86Launch4" "${swaylock} -i ${config.wallpaper}")
            (execBind [ mod ] "backspace" "${swaylock} -i ${config.wallpaper}")
          ])
        ++

          # Notification manager
          (lib.optionals config.services.mako.enable [ (execBind [ mod ] keymaps.w "${makoctl} dismiss") ])
        ++

          # Launcher
          (
            lib.optionals config.programs.wofi.enable [
              (execBind [ mod ] keymaps.x "${wofi} -S drun -x 10 -y 10 -W 25% -H 60%")
              (execBind [ mod ] keymaps.d "${wofi} -S run")
            ]
            ++ (lib.optionals config.programs.password-store.enable [
              (execBind [ ] "Scroll_Lock" pass-wofi) # fn+k
              (execBind [ ] "XF86Calculator" pass-wofi) # fn+f12
              (execBind [ mod ] keymaps.semicolon "pass-wofi")
            ])
          );

      monitor =
        map (
          m:
          {
            output = m.name;
          }
          // (
            if m.enabled then
              {
                mode = "${toString m.width}x${toString m.height}@${toString m.refreshRate}";
                inherit (m) position scale;
              }
            else
              { disabled = true; }
          )
        ) config.monitors
        # Fallback for monitors not declared above (e.g. a newly plugged-in display)
        ++ [
          {
            output = "";
            mode = "preferred";
            position = "auto";
            scale = 1;
          }
        ];

      workspace_rule = map (m: {
        inherit (m) workspace;
        monitor = m.name;
        default = true;
      }) (lib.filter (m: m.enabled && m.workspace != null) config.monitors);
    };

    submaps.passthrough.settings.bind = [ (bind (keys [ mod ] keymaps.P) ''hl.dsp.submap("reset")'') ];
  };
}
