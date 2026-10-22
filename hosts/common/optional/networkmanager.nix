{
  networking.networkmanager.enable = true;

  environment.persistence."/persist".directories = [
    { directory = "/etc/NetworkManager/system-connections"; }
    { directory = "/var/lib/NetworkManager"; }
  ];
}
