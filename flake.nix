{
  description = "Your personal jsonresume built with Nix";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.jsonresume-nix = {
    url = "github:TaserudConsulting/jsonresume-nix";
    inputs.flake-utils.follows = "flake-utils";
  };

  outputs = {
    jsonresume-nix,
    self,
    flake-utils,
    nixpkgs,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;
      themeName = "kendall";
      themePkg = let
        pname = "jsonresume-theme-kendall";
        version = "0.2.0";
      in
        with pkgs;
          buildNpmPackage {
            inherit pname version;

            src = fetchFromGitHub {
              owner = "LinuxBozo";
              repo = pname;
              rev = "90438746fd64fc8184f439d5731a7d118660ab7a";
              hash = "sha256-BBtU55k1J7M5nfhgXkmY69zx+ffnhlFiNbNvp8rUeBM=";
            };

            npmDepsHash = "sha256-n3waeDunWnhGrVAliWwcJ3QKb2Oy0K+5rt+aZsmSmuA=";
            dontNpmBuild = true;

            meta = {
              description = "A theme for jsonresume";
              homepage = "https://github.com/LinuxBozo/jsonresume-theme-kendall";
            };
          };
    in {
      formatter = pkgs.alejandra;
      packages = {
        default = pkgs.stdenv.mkDerivation {
          name = "pakjsdf";
          src = ./.;
          buildPhase = ''
            set -eou pipefail
            ${pkgs.resumed}/bin/resumed render \
              --theme ${themePkg}/lib/node_modules/jsonresume-theme-${themeName}/index.js \
              ./resume.json

            mkdir -p $out
            cp ./resume.html $out/index.html
          '';
        };
      };
    })
    // {inherit inputs;};
}
