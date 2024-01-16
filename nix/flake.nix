{
  description = "A flake";
  outputs = { self, nixpkgs }: {
    devShells.x86_64-darwin = {
      default = nixpkgs.legacyPackages.x86_64-darwin.mkShell {
        buildInputs = [
          nixpkgs.legacyPackages.x86_64-darwin.erlangR26
          nixpkgs.legacyPackages.x86_64-darwin.elixir_1_16
          nixpkgs.legacyPackages.x86_64-darwin.postgresql_15
        ];
      };
    };
  };
}
