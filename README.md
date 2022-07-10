# Github Scripts
An assortment of GitHub related scripts for general maintenance and such.

## Future Enhancement Ideas
### `github-tag-clean.sh`
* Utilize `curl` and GitHub [REST](https://docs.github.com/en/rest)/[GraphQL API](https://docs.github.com/en/graphql)s to more efficiently gather the tags then clone only when we are actually going to do the removals. (Would need to investigate further to find if we can get all info needed.)
* Use a [unit testing system](https://github.com/bats-core/bats-core).
* Batch Mode - Multiple repos with the same date as input, then an organization wide clean up could be made and ran within a GitHub Workflow.

## Useful VS Code Extensions
* [Bash Beautify](https://marketplace.visualstudio.com/items?itemName=shakram02.bash-beautify) - This was handy to make the scripts look nicer.
* [Bash Debug](https://marketplace.visualstudio.com/items?itemName=rogalmic.bash-debug) - Really handy runner/debugger.