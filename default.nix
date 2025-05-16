{
  lib,
  config,
  dream2nix,
  ...
}:
{
  imports = [
    dream2nix.modules.dream2nix.nodejs-package-json-v3
    dream2nix.modules.dream2nix.nodejs-granular-v3
  ];

  deps =
    { nixpkgs, ... }:
    {
      inherit nixpkgs;
      inherit (nixpkgs)
        gnugrep
        stdenv
        typescript
        ;
    };

  nodejs-granular-v3 = {
    runBuild = false;
  };

  name = lib.mkForce "prisma-language-server";
  version = lib.mkForce "6.8.1";

  mkDerivation = {
    src =
      config.deps.nixpkgs.runCommand "prisma-language-server-src"
        {
          inherit (config.deps.nixpkgs)
            bash
            coreutils
            gnutar
            gzip
            ;
          srcTarball = builtins.fetchurl {
            url = "https://registry.npmjs.org/@prisma/language-server/-/language-server-6.8.1.tgz";
            sha256 = "sha256:0jq41zciivam63yqsd9xdbnng7xplmlgmssc3xh3snh4hz3vvm4r";
          };
        }
        ''
          mkdir -p $out
          tar -xzf $srcTarball --strip-components=1 -C $out
          touch $out/.extracted
        '';
    # dontBuild = true;
    installPhase = ''
      chmod +x $out/bin/prisma-language-server
    '';

    postInstall = ''
      patchShebangs $out
    '';
  };
}
