{
  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config = {
          cudaSupport = true;
          allowUnfree = true;
        };
        overlays = [ (_: final: { cudaPackages = final.cudaPackages_12_3; }) ];
      };

      python_env = pkgs.python3.withPackages (
        ps: with ps; [
          GitPython
          pillow
          accelerate

          # blendmodes
          (pkgs.python3Packages.buildPythonPackage rec {
            pname = "blendmodes";
            version = "2024.1.1";
            pyproject = true;

            src = pkgs.fetchPypi {
              inherit pname version;
              hash = "sha256-pARiphBO19gklFVzrHVwcUKe5/o+3tJ71pfR06D11Hc=";
            };
            buildInputs = [ pkgs.python3Packages.poetry-core ];
            checkInputs = with pkgs.python3Packages; [
              pillow
              aenum
              numpy
            ];
          })

          clean-fid
          diskcache
          einops
          # facexlib
          fastapi
          gradio
          inflection
          jsonmerge
          kornia
          lark
          numpy
          omegaconf
          open-clip-torch

          piexif
          protobuf
          psutil
          pytorch-lightning
          requests
          resize-right

          safetensors
          scikit-image

          # tomesd
          (pkgs.python3Packages.buildPythonPackage rec {
            pname = "tomesd";
            version = "v0.1.3";
            src = pkgs.fetchFromGitHub {
              repo = pname;
              owner = "dbolya";
              rev = version;
              hash = "sha256-U3LN6KmQx/ulepFxjWgYHJl5g8j1U3HIGunpjcZBcos=";
            };
          })

          torch
          torchdiffeq
          torchsde
          transformers

          # pillow-avif-plugin
          (pkgs.python3Packages.buildPythonPackage rec {
            pname = "pillow-avif-plugin";
            version = "v1.4.6";
            src = pkgs.fetchFromGitHub {
              repo = pname;
              owner = "fdintino";
              rev = version;
              hash = "sha256-fppFgGrtj5c6eR3B3vodM9sicSHcKdpL7tUPL9PDUD0=";
            };

            buildInputs = [ pkgs.libavif ];
          })

          opencv4
          dctorch
          clip
          xformers
          aenum

          ipython

        ]
      );
    in
    {
      devShells.x86_64-linux.default = pkgs.mkShell { buildInputs = [ python_env ]; };
      packages.x86_64-linux.opencv4 = pkgs.python3Packages.opencv4;
    };
}
