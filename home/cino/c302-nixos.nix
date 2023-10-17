{ inputs, ... }:

{
  imports =
    [ ./global ./features/desktop ./features/desktop/optional/telegram.nix ];

  colorscheme = inputs.nix-colors.colorschemes.material;
}
