# Dotfiles

This repository contains live-edited dotfiles managed with GNU Stow.

Install the default package:

```sh
nix run .#stow
```

Install selected packages:

```sh
nix run .#stow -- pi
```

Each package has a `.stow` hook. The hook prepares target directories before GNU Stow links the package contents.
