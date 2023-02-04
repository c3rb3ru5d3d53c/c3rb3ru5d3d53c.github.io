# Fish as a User Shell in Linux


## Introduction

The purpose of this article is to provide reasoning behind why I'm a `fish` shell user and how to I setup `fish` 🐟 shell on all my Linux machines. Before we begin, we need to understand what `fish` shell is.

> Fish is a Unix shell with a focus on interactivity and usability. Fish is designed to give the user features by default, rather than by configuration. Fish is considered an exotic shell since it does not rigorously adhere to POSIX shell standards, at the discretion of the maintainers. - [Wikipedia](https://en.wikipedia.org/wiki/Fish_(Unix_shell))

As the the quote states `fish` focuses on our interaction with our shell and usability. It provides us features without having to focus on spending much time on customization like `zsh`, `bash` and others. Now let's address some of the common misconceptions in the Linux community regarding `fish` shell.

> But it's not POSIX and you shouldn't use a shell that is POSIX complaint in Linux!

Although you can use `fish` shell as your system shell, it is not recommended or the primary use case for `fish` shell. It is designed to be used as a user shell for tasks you need to perform on your system.

With that in mind, there are many features you get with `fish` shell out of the box.

- Auto suggestions
- Simple Scripting
- Man Page Completions
- 24-bit Color

## Installation

Now that we have the built-in features out of the way, I install `fish` shell from the official Linux repositorys, install [Oh my Fish](https://github.com/oh-my-fish/oh-my-fish) (omf) then the `lambda` theme (Figure 1).

```bash
sudo apt install -y fish git
curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
fish
omf install lambda
```
*Figure 1. Installing `fish` shell with `omf` and `lambda` theme*

Once completed, I update my `gnome` terminal to open `fish` instead of `bash` (Figure 2).

![shell](images/8bb5b5cb465fa4ceaf5acbcab0ef4b83d60982e60747e613424b6a8ee1b418d7.gif)
*Figure 2. Setting Fish as User Shell*

The next small annoyance might be the `fish` shell default greeting. However, we can remove this by performing the command in Figure 3. 

```bash
printf "function fish_greeting\nend" > ~/.config/fish/functions/fish_greeting.fish
```
*Figure 3. Disabling `fish` Greeting*

And... you're done! 🐟🥳

## Conclusion

I use `fish` shell as my user shell in Linux mostly because of it's auto-completions and built-in features. I hope this encourages you to try `fish` shell as your user shell in Linux as well. 😅

## References
- https://fishshell.com/
- https://github.com/oh-my-fish/oh-my-fish
