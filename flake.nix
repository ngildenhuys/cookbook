{
  description = "Cookbook of actually made recipes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    pre-commit-hooks,
  } @ inputs: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];

    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
  in {
    packages = forAllSystems (system: {
      default = nixpkgs.legacyPackages.${system}.stdenv.mkDerivation {
        pname = "cookbook";
        version = "1.0";
        src = ./.;
        installPhase = ''
          mkdir -p $out
          cp -r recipes/ $out/
        '';
      };
    });

    devShell = forAllSystems (system:
      nixpkgs.legacyPackages.${system}.mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;
        buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
        packages = with nixpkgs.legacyPackages.${system}; [
          cook-cli
        ];
      });

    checks = forAllSystems (system: {
      pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          typos.enable = true;
          cooklang-doctor = {
            name = "cooklang-doctor";
            enable = true;
            entry = "${nixpkgs.legacyPackages.${system}.cook-cli}/bin/cook doctor validate --strict --base-path recipes";
            files = "\\.(cook)";
            types = ["file"];
            excludes = [];
            language = "system";
            pass_filenames = false;
            stages = ["pre-commit"];
          };
        };
      };
    });

    apps = forAllSystems (system: {
      default = {
        type = "app";
        program = "${nixpkgs.legacyPackages.${system}.writeShellScript "serve-recipes" ''
          cd ${self}
          exec ${nixpkgs.legacyPackages.${system}.cook-cli}/bin/cook server ${self.packages.${system}.default}/recipes
        ''}";
      };
    });
  };
}
