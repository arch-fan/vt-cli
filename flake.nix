{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      perSystem =
        { pkgs, ... }:
        let
          go = pkgs.go;
        in
        {
          devShells.default = pkgs.mkShell {
            packages = [
              pkgs.gnumake
              go
            ];
          };

          packages.default = pkgs.buildGoModule (finalAttrs: {
            inherit go;

            pname = "vt-cli";
            version = "1.2.0";

            modVendor = true;
            vendorHash = "sha256-/pLcwSuKZmuvQxBPpY6zGWk/dQL4eayZ+1tlLPO0jzg=";
            src = inputs.self;

            ldflags = [ "-X github.com/VirusTotal/vt-cli/cmd.Version=${finalAttrs.version}" ];

            subPackages = [ "vt" ];

            meta = with pkgs.lib; {
              description = "VirusTotal Command Line Interface";
              longDescription = ''
                Welcome to the VirusTotal CLI, a tool designed for those who love both VirusTotal and command-line interfaces.
                With this tool you can do everything you'd normally do using VirusTotal's web page, including:

                - Retrieve information about files, URLs, domains, IPs, etc.
                - Search for files and URLs using VirusTotal Intelligence query syntax.
                - Download files.
                - Manage LiveHunt YARA rules.
                - Launch Retrohunt jobs and retrieve results.

                Documentation:
                https://github.com/VirusTotal/vt-cli/tree/master/doc
              '';
              homepage = "https://github.com/VirusTotal/vt-cli";
              changelog = "https://github.com/VirusTotal/vt-cli/releases/tag/${finalAttrs.version}";
              downloadPage = changelog;
              license = licenses.asl20;
              platforms = with platforms; unix ++ windows;
              mainProgram = "vt";
            };
          });
        };
    };
}
