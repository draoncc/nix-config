# Stylix owns colours and fonts; its targets are opt-in

Stylix is imported as a NixOS module in `hosts/common/global` and sets the scheme and fonts once for every host. Home-manager follows it through Stylix's auto-import. `stylix.autoEnable` is off, so each themed program has a target that was enabled on purpose. Configs that no Stylix target can theme read the palette from `config.lib.stylix.colors` and the fonts from `config.stylix.fonts`. That covers the Hyprland config, which is Lua while Stylix writes hyprlang, plus hyprlock, waybar's hand-written CSS, swayosd and hyprbars.

The scheme is a composite: material-darker (base16) for `base00–0F`, with material-dark's (base24) `base10–17` added. The two are different palettes by different authors, not two sizes of one scheme. So the extra slots only show where a target reads them, such as starship's `bright-*` colours.

## Considered Options

- **`autoEnable = true`, switching off the targets that break.** Rejected: any program added later would be themed without anyone noticing, and the Lua Hyprland config would need a standing opt-out.
- **Home-manager module only**, as nix-colors was. Rejected: the tty console, Plymouth and regreet should match the desktop.

## Consequences

- systemd-boot can't be themed (Stylix handles only grub and limine), so the boot menu stays plain.
- wezterm keeps its own builtin Framer scheme until its config moves to `programs.wezterm`. Until then, the starship prompt's colours don't match the terminal's.
