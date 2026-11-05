{ pkgs, ... }:

{
  home.packages = with pkgs; [
    rustup # Toolchains and rust-analyzer via `rustup component add`
    gcc # Linker
    lldb # Debug adapter
  ];

  home.sessionPath = [ "$HOME/.cargo/bin" ];

  home.persistence."/persist".directories = [
    ".rustup" # Toolchains
    ".cargo" # Registry cache and installed binaries
  ];

  programs.helix.languages.language = [
    {
      name = "rust";
      auto-format = true;
    }
  ];
}
