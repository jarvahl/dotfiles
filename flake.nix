{
  description = "Dotfiles";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
    let
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      apps = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };

          stowWrapper = pkgs.writeShellApplication {
            name = "stow";

            runtimeInputs = [
              pkgs.coreutils
              pkgs.git
            ];

            text = ''
              set -euo pipefail

              repo="$(git rev-parse --show-toplevel)"

              if (($# == 0)); then
                packages=(pi)
              else
                packages=("$@")
              fi

              for package in "''${packages[@]}"; do
                packageDir="$repo/$package"
                hook="$packageDir/.stow"

                if [[ ! -d "$packageDir" ]]; then
                  printf 'Unknown package: %s\n' "$package" >&2
                  exit 1
                fi

                if [[ ! -r "$hook" ]]; then
                  printf 'Missing hook: %s\n' "$hook" >&2
                  exit 1
                fi

                # shellcheck disable=SC1090
                source "$hook"
              done

              ${pkgs.stow}/bin/stow \
                --dir "$repo" \
                --target "$HOME" \
                --ignore '^\\.stow$' \
                --restow \
                "''${packages[@]}"
            '';
          };
        in {
          stow = {
            program = "${stowWrapper}/bin/stow";
            type = "app";
          };
        });
    };
}
