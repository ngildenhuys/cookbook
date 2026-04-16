# cookbook

A recipe book written and managed like code. Each recipe added should be something that was actually
made by a contributor before being added. The commit log acts as a history of the recipe, changes
made by others should follow the same rule, it must be made before merged.
If you want to add a recipe that you haven't made, then add it to the `recipes/Drafts` directory.

## Contributing

Feel free to contribute...just fork the repo make your changes, put up a merge request.
I will try to be diligent on reviews and adding new content. There is no CI at the moment, but
if you have nix and direnv installed then you should get the pre-commit hooks which are good enough for now.

## Developing

This project used Nix to build and check things, so your "build" command is `nix build`.
Checks are `nix flake check`. To get a devshell it is `nix develop`, etc.
