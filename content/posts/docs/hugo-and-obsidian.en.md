---
weight: 4
title: "Using GitHub Hugo and Obsidian to build a Portfolio"
description: "Build your own portfolio with Hugo, Obsidian and GitHub"
date: "2023-02-20"
draft: false
author: "c3rb3ru5d3d53c"
images: []
featuredImage: "images/6d17ce38769beaefe80d161070ef856bac4604fa0000a3d5fb1470b393bd40c0.png"
tags: ["Obsidian", "Hugo", "Portfolio"]
categories: ["Docs"]
lightgallery: true
---

## Introduction

A portfolio website showcases immediate value to employers because it provides a platform to demonstrate your skills, creativity, and achievements. By presenting your best work, you can show employers what you can bring to the table and how you can contribute to their organization. A portfolio website also shows that you are proactive and take pride in your work, which can be attractive to employers who are looking for self-motivated and passionate candidates. In a competitive job market, having a portfolio website can make you stand out from other candidates and give you an edge in the hiring process.

## GitHub

[GitHub](https://github.com/) is a web-based platform for version control and collaborative software development that allows individuals and teams to host and review code, manage projects, and build software in a more organized and efficient way. In this case, we will be using [GitHub](https://github.com/) as a place to save and build our website using [Github Pages](https://pages.github.com/).

[GitHub Pages](https://pages.github.com/) is a free service offered by [GitHub](https://github.com/) that allows users to host static websites and web applications directly from their [GitHub](https://github.com/) repositories. It simplifies the process of publishing content on the web by automatically building and deploying your code changes to a web server, allowing others to access your site via a custom domain or a subdomain of the `github.io` domain.

### Create an Account

To create a [GitHub](https://github.com/) account, first go to the [GitHub](https://github.com/) website and click on the `Sign up` button in the upper right corner. You will be prompted to enter your email address, a username, and a password. Then click `Create account`. Next, verify your email address by following the instructions in the confirmation email that [GitHub](https://github.com/) sends you. Finally, customize your profile and start using [GitHub](https://github.com/) to create, store, and collaborate on code.

### Create a Repository

To create a [GitHub](https://github.com/) repository, first log in to your [GitHub](https://github.com/) account and click on the `+` icon in the upper right corner, then select `New repository`. Next, choose a name for your repository (should be `<username>.github.io`) and provide an optional description. Finally, set your repository to be public.

## Hugo

[Hugo](https://gohugo.io/) is a fast and flexible static site generation tool that allows you to create websites quickly and easily. It uses a simple and intuitive directory structure and provides a wide range of themes and templates to choose from, enabling you to create professional-looking websites with minimal effort.

### Installation

The command `sudo apt install -y hugo` installs the [Hugo](https://gohugo.io/) static site generator on a Debian-based Linux system, while `hugo version` checks its version. We need to identify that we have the `+extended` version of [Hugo](https://gohugo.io/) as more advanced themes may require it.

```bash
sudo apt install -y hugo
hugo version | grep -i extended
```

### Create the Site

The commands here create a new [Hugo](https://gohugo.io/) website named `blog` in the current directory, initializes a new Git repository in the `blog` directory, adds the `Ananke` theme from GitHub as a Git submodule, appends the line `theme = 'ananke'"` to the `config.toml` file, and creates a new directory named `.github/workflows/` in the `blog` directory. The `.github/workflows/` directory can be used to store GitHub Actions. The GitHub Actions automates the building and deployment of your site.

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

Next, we create a new markdown file named `example.md` using [Hugo](https://gohugo.io/), and open it in Vim for editing. Although, you can use any editor you wish. Once completed, we change draft from `true` to `false` and add our markdown content.

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

## Obsidian

[Obsidian](https://obsidian.md/) is a note-taking tool that allows users to create and organize their notes in a network of interconnected documents. It uses a [Markdown-based](https://www.markdownguide.org/cheat-sheet/) text editor and allows for bidirectional linking, which enables users to quickly find and connect related information. Obsidian also has a graph view that visually displays the connections between notes, making it easier to explore and understand the relationships between ideas.

### Installation

To install Obsidian, follow the instruction provided on their website [here](https://obsidian.md/download). If you are using a Debian based Linux distribution, you can use the commands provided below; just change the URL to the latest one from the website.

```bash
wget https://github.com/obsidianmd/obsidian-releases/releases/download/v1.1.9/obsidian_1.1.9_amd64.deb
sudo apt install ./obsidian_1.1.9_amd64.deb
```

### Writing your Blog

To more easily write content for your blog, you can open the folder of the website you created with [Obsidian](https://obsidian.md/) as a vault.

![vault](images/81078ea2b7788fb358bcc136e04b8b6df4f50e2f8e7f0caf2ef43da859e47698.png)

Once completed, create a new note by clicking on the `New Note` button in the top left corner. Next, give your note a title by typing it at the top of the note. Finally, write your content using Markdown syntax (a simple markup language). A cheatsheet for writing markdown can be found [here](https://www.markdownguide.org/cheat-sheet/).

## Publishing your Work

Once completed, we can push our code to GitHub, which should begin the build process and serve your site to `<username>.github.io`.

```bash
git add .
git commit -m "First Commit"
git push
```

## Conclusion

In conclusion, building a portfolio website with [Hugo](https://gohugo.io/) and [Obsidian](https://obsidian.md/) is an excellent way to showcase your work to the world. With the flexibility of Hugo and the powerful note-taking capabilities of [Obsidian](https://obsidian.md/), you can easily create a personalized website that perfectly represents your skills and accomplishments.

Using these tools, you can easily create a portfolio website that is not only beautiful and functional, but also easy to maintain and update. A portfolio website built with [Hugo](https://gohugo.io/) and [Obsidian](https://obsidian.md/) can help you showcase your work to potential clients or employers, and take your career to the next level.

So, if you're looking for an easy and efficient way to build your own portfolio website, then [Hugo](https://gohugo.io/) and [Obsidian](https://obsidian.md/) are definitely worth considering. With a little bit of time and effort, you can create a stunning portfolio that truly represents who you are and what you do.

## References

- [Hugo Quickstart](https://gohugo.io/getting-started/quick-start/)
- [Obsidian Website](https://obsidian.md/)