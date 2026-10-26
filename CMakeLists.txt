cmake_minimum_required(VERSION 3.20)
project(RawAssembly ASM_NASM)

# Change this line to tell the compiler driver to bypass standard startup files
set(CMAKE_ASM_NASM_LINK_FLAGS "-no-pie -nostdlib")

add_executable(RawAssembly
        lab01-return/lab01.c)
