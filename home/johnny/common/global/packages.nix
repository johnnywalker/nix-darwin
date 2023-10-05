{pkgs, ...}: {
  home.packages = with pkgs;
    [
      act
      age
      age-plugin-yubikey
      alejandra
      awscli2
      cargo
      cargo-udeps
      clipboard-jh
      curl
      dig
      docker
      docker-compose
      gdb
      gnupg
      go
      htop
      jetbrains-mono
      jq
      moreutils
      nil
      nodejs
      openssl
      packer
      python3
      ripgrep
      rover
      rustc
      rustfmt
      unzip
      vips # for sharp
      wget
      yarn
      yq
      zip
    ]
    ++ (with nodePackages; [
      node-gyp
      prettier
      typescript-language-server
    ])
    ++ (with pkgs.haskellPackages; [
      apply-refact
      # haskell-language-server
      hasktags
      hlint
      hoogle
      stylish-haskell
    ]);
}
