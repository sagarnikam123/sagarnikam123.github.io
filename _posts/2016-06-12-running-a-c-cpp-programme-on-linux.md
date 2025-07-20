---
date: 2016-06-12
layout: post
title: "Running a C/C++ programme on Linux"
description: "compiling & running c/cpp programmes"
category: [c,cpp]
tags: [compile,run]
---

##### install GNU C/C++ compiler

```
sudo apt-get update
sudo apt-get install build-essential manpages-dev
```

##### verify installation

```
whereis gcc
which gcc
gcc --version
```
```
whereis g++
which g++
g++ --version
```

#### compiling C program

+ **helloWorld.c**


```
#include<stdio.h>

int main(void)
{
 printf("Hello World !.\n");
 printf("This is 'C'. \n");
 return 0;
}
```

+ **compiling C program**

```
cc helloWorld.c -o helloWorld
```
or `make helloWorld` or `gcc helloWorld.c -o helloWorld`

+ **running a C program**

```
./helloWorld
```

-----

#### compile & running cpp program on Linux

+ **helloWorld.cpp**

```
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

```
g++ -o helloWorld helloWorld.cpp
```
or
```
make helloWorld
```

* **run**

```
./helloWorld
```

----

#### generating symbolic information for gdb and warning messages

```
cc -g -Wall helloWorld.c -o helloWorld
```

```
g++ -g -Wall helloWorld.c -o helloWorld
```

----

#### optimized code

```
cc -O helloWorld.c -o helloWorld
```
```
g++ -O helloWorld.c -o helloWorld
```

----

#### compiling a C program that uses math functions/Xlib graphics functions

> link the library using `-l` option

```
cc myth1.c -o executable -lm
```

----

#### compile a program with multiple source files
```
cc light.c sky.c fireworks.c -o executable
```

```
g++ ac.c bc.c file3.c -o my-program-name
```

----
