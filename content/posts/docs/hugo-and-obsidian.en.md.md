---
weight: 4
title: "Using Hugo and Obsidian to build a Portfolio"
description: "Build your own portfolio with Hugo and Obsidian"
date: "2023-02-20"
draft: true
author: "c3rb3ru5d3d53c"
images: []
tags: ["Obsidian", "Hugo", "Portfolio"]
categories: ["Docs"]
lightgallery: true
---

## Introduction

A portfolio website showcases immediate value to employers because it provides a platform to demonstrate your skills, creativity, and achievements. By presenting your best work, you can show employers what you can bring to the table and how you can contribute to their organization. A portfolio website also shows that you are proactive and take pride in your work, which can be attractive to employers who are looking for self-motivated and passionate candidates. In a competitive job market, having a portfolio website can make you stand out from other candidates and give you an edge in the hiring process.

## GitHub

Placeholder

### Create an Account

To create a GitHub account, first go to the GitHub website and click on the "Sign up" button in the upper right corner. You will be prompted to enter your email address, a username, and a password. Then click "Create account". Next, verify your email address by following the instructions in the confirmation email that GitHub sends you. Finally, customize your profile and start using GitHub to create, store, and collaborate on code.

## Create a Repository

To create a GitHub repository, first log in to your GitHub account and click on the "+" icon in the upper right corner, then select "New repository". Next, choose a name for your repository and provide an optional description. Set your repository to be public.

## Hugo

Placeholder

### Installation

The command `sudo apt install -y hugo` installs the `hugo` static site generator on a Debian-based Linux system, while `hugo version` checks the version of the installed Hugo program. We need to identify that we have the `+extended` version of hugo as more advanced themes may require it.

```bash
sudo apt install -y hugo
hugo version | grep -i extended
```

### Create the Site

The commands here create a new Hugo website named `blog` in the current directory, initializes a new Git repository in the `blog` directory, adds the `Ananke` theme from GitHub as a Git submodule, appends the line `theme = 'ananke'"` to the `config.toml` file, and creates a new directory named `.github/workflows/` in the `blog` directory. The `.github/workflows/` directory can be used to store GitHub Actions. The GitHub Actions automates the building and deployment of your site.

```bash
hugo new site blog
cd blog/
git init
git submodule add https://github.com/theNewDynamic/gohugo-theme-ananke themes/ananke
echo "theme = 'ananke'" >> config.toml
mkdir -p .github/workflows/
wget https://raw.githubusercontent.com/c3rb3ru5d3d53c/c3rb3ru5d3d53c.github.io/master/.github/workflows/gh-pages.yml -O .github/workflows/gh-pages.yml
```

### Create a Post

Next, we create a new markdown file named `example.md` using Hugo, and open it in Vim for editing. Although, you can use any editor you wish. Once completed, we change draft from `true` to `false` and add our markdown content.

```bash
hugo new posts/example.md
vim content/posts/example.md
```

### Build and Test

The command `hugo build` generates a static website by compiling content into HTML and CSS files. Whereas, `hugo server` starts a local web server to preview changes made to the website before deployment.

```bash
hugo build
hugo server
```

### Push the Code

Once completed, we can push our code to GitHub, which should begin the build process and serve your site to `<username>.github.io`.

```bash
git add .
git commit -m "First Commit"
git push
```

## Obsidian

Placeholder

## Installation

Placeholder

## Writing your Blog

Placeholder

## Conclusion

In conclusion, building a portfolio website with Hugo and Obsidian is an excellent way to showcase your work to the world. With the flexibility of Hugo and the powerful note-taking capabilities of Obsidian, you can easily create a personalized website that perfectly represents your skills and accomplishments.

Using these tools, you can easily create a portfolio website that is not only beautiful and functional, but also easy to maintain and update. A portfolio website built with Hugo and Obsidian can help you showcase your work to potential clients or employers, and take your career to the next level.

So, if you're looking for an easy and efficient way to build your own portfolio website, then Hugo and Obsidian are definitely worth considering. With a little bit of time and effort, you can create a stunning portfolio that truly represents who you are and what you do.

## References

- [Hugo Quickstart](https://gohugo.io/getting-started/quick-start/)