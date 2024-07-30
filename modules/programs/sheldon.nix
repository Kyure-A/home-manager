{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.sheldon;
  tomlFormat = pkgs.formats.toml { };
  cmd = "${config.home.profileDirectory}/bin/sheldon";
in {
  meta.maintainers = [ maintainers.Kyure-A ];

  options.programs.sheldon = {
    enable = mkEnableOption "sheldon";

    package = mkOption {
      type = types.package;
      default = pkgs.sheldon;
      defaultText = literalExpression "pkgs.sheldon";
      description = "The package to use for the sheldon binary.";
    };

    settings = mkOption {
      inherit (tomlFormat) type;
      default = { };
      description = "";
      example = literalExpression "";
    };

    enableZshCompletions = mkEnableOption "Zsh completions" // {
      default = false;
    };

    enableBashCompletions = mkEnableOption "Bash completions" // {
      default = false;
    };

    enableFishCompletions = mkEnableOption "Fish completions" // {
      default = false;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."sheldon/plugins.toml" = mkIf (cfg.settings != { }) {
      source = tomlFormat.generate "sheldon-config" cfg.settings;
    };

    programs.bash.initExtra = mkIf (cfg.settings != { }) ''
      eval "$(sheldon source)"
    '' + mkIf cfg.enableBashCompletions ''
      if [[ $TERM != "dumb" ]]; then
         eval "$(${cmd} completions --shell=bash)"
      fi
    '';

    programs.zsh.initExtra = mkIf (cfg.settings != { }) ''
      eval "$(sheldon source)"
    '' + mkIf cfg.enableZshCompletions ''
      if [[ $TERM != "dumb" ]]; then
         eval "$(${cmd} completions --shell=zsh)"
      fi
    '';

    programs.fish.interactiveShellInit = mkIf (cfg.settings != { }) ''
      eval "$(sheldon source)"
    '' + mkIf cfg.enableFishCompletions ''
      if test "$TERM" != "dumb"
         eval "$(${cmd} completions --shell=fish)"
      end
    '';
  };
}
