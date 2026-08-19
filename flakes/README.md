### Nix flakes

This directory contains nix flakes that are used for an Orangelight environment.

#### Developing flakes

To test a flake to make sure it builds correctly:

1. `cd` into its directory
1. `nix build --extra-experimental-features flakes`

To see a flake on disk:

1. `ls /nix/store` and find the output that corresponds to your flake
1. If you have been iterating on the flake a lot and have many different
   versions, try `nix-collect-garbage` to remove the old versions and try
   `ls` again.
