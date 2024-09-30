{
  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  inputs.poetry2nix.url = "github:cheriimoya/poetry2nix";

  outputs =
    {
      self,
      nixpkgs,
      poetry2nix,
    }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config = {
          cudaSupport = true;
          allowUnfree = true;
        };
        # 12.4 is currently broken
        overlays = [ (_: final: { cudaPackages = final.cudaPackages_12_3; }) ];
      };
      inherit (poetry2nix.lib.mkPoetry2Nix { inherit pkgs; }) mkPoetryEnv overrides;

      python3_env = mkPoetryEnv {
        projectDir = ./.;
        python = pkgs.python311;
        overrides = overrides.withDefaults (
          _: prev: {
            numba = prev.numba.override { preferWheel = true; };
            open-clip-torch = prev.open-clip-torch.override { preferWheel = true; };
            opencv-python = prev.opencv-python.override { preferWheel = true; };
            safetensors = prev.safetensors.override { preferWheel = true; };
            scikit-image = prev.scikit-image.override { preferWheel = true; };
            tokenizers = prev.tokenizers.override { preferWheel = true; };
          }
        );
      };
    in
    {
      devShells.x86_64-linux.default = pkgs.mkShell {
        buildInputs = [ python3_env ];
        runCommand = "LD_LIBRARY_PATH=/run/opengl-driver/lib/:${pkgs.cudaPackages.cudnn.lib}/lib/:$LD_LIBRARY_PATH venv_dir=- ./webui.sh --skip-prepare-environment";
      };
    };
}
