{
  config,
  pkgs,
  ...
}: let
  zshInitExtra = ''
    # export PATH="${config.home.homeDirectory}/.local/bin:$PATH"

    source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

    enable_iamlive_csm() {
      export AWS_CSM_ENABLED=true
      export AWS_CSM_PORT=31000
      export AWS_CSM_HOST=127.0.0.1
    }

    enable_iamlive_proxy() {
      export HTTP_PROXY=http://127.0.0.1:10080
      export HTTPS_PROXY=http://127.0.0.1:10080
      export AWS_CA_BUNDLE=~/.iamlive/ca.pem
    }

    disable_iamlive() {
      unset AWS_CSM_ENABLED
      unset AWS_CSM_PORT
      unset AWS_CSM_HOST
      unset HTTP_PROXY
      unset HTTPS_PROXY
      unset AWS_CA_BUNDLE
    }

    sha256sumbase64() {
      cat $1 | openssl dgst -binary -sha256 | openssl base64
    }

    generate_password() {
      openssl rand -base64 12
    }

    function omz_history {
      local clear list
      zparseopts -E c=clear l=list

      if [[ -n "$clear" ]]; then
        # if -c provided, clobber the history file
        echo -n >| "$HISTFILE"
        fc -p "$HISTFILE"
        echo >&2 History file deleted.
      elif [[ -n "$list" ]]; then
        # if -l provided, run as if calling `fc' directly
        builtin fc "$@"
      else
        # unless a number is provided, show all history events (starting from 1)
        [[ ''${@[-1]-} = *[0-9]* ]] && builtin fc -l "$@" || builtin fc -l "$@" 1
      fi
    }

    export GPG_TTY=$(tty)

    ${pkgs.fortune}/bin/fortune | ${pkgs.cowsay}/bin/cowsay
  '';

  zshProfileExtra = ''
    # prevent duplicate entries in $PATH
    # $path array is tied to $PATH
    typeset -U path PATH

    # not sure what package this was for
    # export LDFLAGS="-L/usr/local/opt/libffi/lib"
    # export PKG_CONFIG_PATH="/usr/local/opt/libffi/lib/pkgconfig"

    # help Gradle find ~/.gradle/gradle.properties
    export GRADLE_USER_HOME="${config.home.homeDirectory}/.gradle"

    # configure golang
    export GOPATH="${config.home.homeDirectory}/go"

    # configure path/PATH
    path=(
      # ~/.cargo/env
      ${config.home.homeDirectory}/.cargo/bin

      # ~/.ghcup/env
      ${config.home.homeDirectory}/.ghcup/bin
      ${config.home.homeDirectory}/.cabal/bin

      # add ~/.local/bin to PATH
      ${config.home.homeDirectory}/.local/bin

      # configure yarn binaries
      # ${config.home.homeDirectory}/.yarn/bin
      ${config.home.homeDirectory}/.config/yarn/global/node_modules/.bin

      # gcloud SDK (unused)
      # ${config.home.homeDirectory}/google-cloud-sdk/bin

      # prefer openssl installed by brew
      # /usr/local/opt/openssl/bin

      # Configure unversioned symlinks (`python`, `pip`, etc.)
      # /usr/local/opt/python@3/libexec/bin

      $path

      # go
      $GOPATH/bin
    )
  '';
in {
  programs = {
    bash = {
      enable = true;
      enableCompletion = true;
      historyControl = ["ignoredups" "ignorespace"];
    };
    direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
    };
    eza = {
      enable = true;
      enableAliases = true;
    };
    fzf = {
      enableZshIntegration = true;
      enableBashIntegration = true;
    };
    starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      dotDir = builtins.replaceStrings ["${config.home.homeDirectory}"] [""] "${config.xdg.configHome}/zsh";
      history = {
        path = "${config.xdg.dataHome}/zsh/zsh_history";
        expireDuplicatesFirst = true;
        extended = true;
        ignoreDups = true;
        ignoreSpace = true;
        share = true;
        save = 100000;
        size = 100000;
      };
      # oh-my-zsh = {
      #   enable = true;
      #   plugins = [
      #     "aws"
      #     "docker"
      #     "docker-compose"
      #     "git"
      #     # "gradle"
      #     # "sdk"
      #     "rust"
      #     "terraform"
      #   ];
      #   theme = "clean";
      # };
      shellAliases = {
        # cat on steroids
        cat = "bat";

        # use locally built terraform with aws-sdk-go v1.44.298 installed for SSO support
        # - remove when Terraform 1.6 released
        # https://github.com/hashicorp/terraform/pull/33607
        terraform = "$GOPATH/bin/terraform";

        history = "omz_history";
      };
      syntaxHighlighting.enable = true;
      initExtra = zshInitExtra;
      profileExtra = zshProfileExtra;
    };
  };
}
