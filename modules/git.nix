{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user.name  = "James Fosburgh";
      user.email = "james@resin.co";
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };

  programs.lazygit.enable = true;
}
