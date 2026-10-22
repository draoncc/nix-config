# Coding standards

Judgement calls for review. Mechanical rules are enforced by `checks/` (`just check`), not listed here.

## Theming

- **A Stylix target is enabled in the file that configures its program** (`stylix.targets.mako.enable` sits in `mako.nix`), next to the settings it replaces. `hosts/common/global/stylix.nix` holds only the scheme, fonts, opacity and the system-wide targets (console, fontconfig, font-packages, gtk's dconf). See `docs/adr/0002-stylix-opt-in-targets.md`.
- **A config that reads Stylix's palette takes every colour and font from it.** A literal hex value or font family beside `palette.baseXX` drifts on the next scheme change; transparent or translucent black (`rgba(000000xx)`: masks, shadows) is the exception.

## Modules

- **A module is parked by commenting out its import** (`# ./zathura.nix`), never by leaving it unreferenced. Code that will not come back is deleted. The orphan check counts a commented-out import as parked.
