#!/bin/bash

set -ex

gcc -Wall -Wextra -O2 -c -fPIC -o framebuffer.o main.c
gcc -shared -o framebuffer.so framebuffer.o
