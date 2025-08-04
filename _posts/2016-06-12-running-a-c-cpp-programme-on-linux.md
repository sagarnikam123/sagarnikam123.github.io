---
layout: post
title: "Running a C/C++ programme on Linux"
description: "compiling & running c/cpp programmes"
date: 2016-06-12 12.00.00 +0530
categories: [c,cpp]
tags: [compile,run]
---

##### install GNU C/C++ compiler

```shell
sudo apt-get update
sudo apt-get install build-essential manpages-dev
```

##### verify installation

```shell
whereis gcc
which gcc
gcc --version
```

```shell
whereis g++
which g++
g++ --version
```

#### compiling C program

+ **helloWorld.c**

```cpp
#include<stdio.h>

int main(void)
{
 printf("Hello World !.\n");
 printf("This is 'C'. \n");
 return 0;
}
```

+ **compiling C program**

```shell
cc helloWorld.c -o helloWorld
```
or `make helloWorld` or `gcc helloWorld.c -o helloWorld`

+ **running a C program**

```shell
./helloWorld
```

#### compile & running cpp program on Linux

+ **helloWorld.cpp**

```cpp
#include <iostream>
using namespace std;
int main ()
{
  cout << "Hello World! ";
  cout << "\n";
  cout << "I'm a C++ program";
  cout << "\n";
  return 0;
}
```

+ **compile**

```shell
g++ -o helloWorld helloWorld.cpp
```
or
```shell
make helloWorld
```

* **run**

```shell
./helloWorld
```

#### generating symbolic information for gdb and warning messages

```shell
cc -g -Wall helloWorld.c -o helloWorld
```

```shell
g++ -g -Wall helloWorld.c -o helloWorld
```

#### optimized code

```shell
cc -O helloWorld.c -o helloWorld
```

```shell
g++ -O helloWorld.c -o helloWorld
```

#### compiling a C program that uses math functions/Xlib graphics functions

> link the library using `-l` option

```shell
cc myth1.c -o executable -lm
```

#### compile a program with multiple source files

```shell
cc light.c sky.c fireworks.c -o executable
```

```shell
g++ ac.c bc.c file3.c -o my-program-name
```
