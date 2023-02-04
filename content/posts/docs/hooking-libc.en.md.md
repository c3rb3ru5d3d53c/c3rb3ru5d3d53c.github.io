---
weight: 4
title: "Hooking C Runtime or libc"
description: "How to Hook the C Runtime (libc) in Linux using LD_PRELOAD"
date: "2023-02-04"
draft: false
author: "c3rb3ru5d3d53c"
images: []
tags: ["Hooking", "libc", "Linux"]
categories: ["Docs"]
lightgallery: true
---

## Introduction

A friend at work asked me if we can actively change `argc` when executing a target program without modifying the target program. I was not sure at the time what the solution would be. However, after some thought; I thought about `LD_PRELOAD` and using it to hook specific functions. I figured, well it probably won't allow the hooking of `libc`, but in reality it does. This is of course interesting behavior that can be leveraged for offensive and defensive security research practices. With all that context out of the way, let's get into it!

## Technique

`LD_PRELOAD` allows you to prioritize your own shared libraries in Linux; even ahead of `libc`.  In this case, we create the shared library by exporting a function with the name [`__libc_start_main`](https://refspecs.linuxfoundation.org/LSB_2.0.1/LSB-Core/LSB-Core/baselib---libc-start-main-.html), which is responsible for parsing `argc` for number of arguments, `argv` for the argument array and `envp` for the array of environment variables. Using this method, it is possible to execute code before the execution of the `main` function in the target binary. The code to hook `main` or [`__libc_start_main`](https://refspecs.linuxfoundation.org/LSB_2.0.1/LSB-Core/LSB-Core/baselib---libc-start-main-.html) is provided in *Figure 1*.

```c
// Compile: gcc hook.c -o hook.so -fPIC -shared
// Execute: LD_PRELOAD=./hook.so ./program

#define _GNU_SOURCE
#include <stdio.h>
#include <dlfcn.h>

static int (*main_orig)(int, char **, char **);

int main_hook(int argc, char **argv, char **envp){
    return main_orig(argc, argv, envp);
}

int __libc_start_main(
    int (*main)(int, char **, char **),
    int argc,
    char **argv,
    int (*init)(int, char **, char **),
    void (*fini)(void),
    void (*rtld_fini)(void),
    void *stack_end){
    main_orig = main;
    typeof(&__libc_start_main) orig = dlsym(RTLD_NEXT, "__libc_start_main");
    return orig(main_hook, argc, argv, init, fini, rtld_fini, stack_end);
}
```
*Figure 1: Hooking `main` function in `libc` `__libc_start_main`*

Next, compile the code with the following command:
```bash
gcc hook.c -o hook.so -fPIC -shared
```

Finally we can inspect the behavior of `argc`, `argv` and `envp` that are passed using your own progam (Figure 2).

```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

void print_argv(char **argv){
  int count = 0;
  while (1){
    if (argv[count] != NULL){
      printf("argv[%d] = %s\n", count, argv[count]);
    } else {
      break;
  }
    count++;
  }
}

int main(int argc, char **argv){
  printf("argc: %d\n", argc);
  print_argv(argv);
  return 0;
}
```
*Figure 2. Program to Inspect Hooked Values for `argc`, `argv` and `envp`*

## Demo

Alright, let me shut all the way up, `POC|GTFO` right?

![demo](images/eb2adb6ffc783c640e69a435017e55816dfbf3baa8c4fe66aa67476be57389eb.gif)

## Conclusion

This technique could also be used for analysing malware, where we can introspect APIs and dump their respective arguments during execution to a location of our choice.

From an offensive research perspective, this technique can be used to perform fuzzing of applications and how they interact with `libc`.

A feature of Linux that can be used for good and evil.

## References
- https://refspecs.linuxfoundation.org/LSB_2.0.1/LSB-Core/LSB-Core/baselib---libc-start-main-.html
- https://gist.github.com/apsun/1e144bf7639b22ff0097171fa0f8c6b1
