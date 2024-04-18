This is just another personal `.dotfiles` so I don't lose my config by mistake (ikr, it happens when you tinker a lot ¯\_(ツ)\_/¯)

This is using a git bare repository, no symlinks, here's article you must read before proceeding:

- https://www.atlassian.com/git/tutorials/dotfiles
- https://www.ackama.com/what-we-think/the-best-way-to-store-your-dotfiles-a-bare-git-repository-explained/

In both article above, they use `alias config`, you should use `alias mydotfiles` instead so it's consistent (as that is the alias that I included in `.zshrc`)
