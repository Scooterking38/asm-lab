# Lab 01 — Minimal main()

## Objective
Learning how data movement maps from c to asm

## Source
int main(void) { return 42; }

## Build
gcc -O0 -no-pie -g -o lab01_O0 lab01.c
gcc -O2 -no-pie -g -o lab01_O2 lab01.c

## Prediction
mov eax, 42
ret

## Disassembly
    ❯ objdump -d -M intel lab01_O0 | sed -n '/<main>:/,/^$/p' #O0
    0000000000401116 <main>:
    401116:       55                      push   rbp
    # save the frame pointer onto the stack
    401117:       48 89 e5                mov    rbp,rsp
    # move the stack pointer into the frame pointer (rbp = rsp)
    40111a:       b8 2a 00 00 00          mov    eax,0x2a
    # move 42 into the lower half of the accumulator
    40111f:       5d                      pop    rbp
    # grab the frame pointer back off the stack
    401120:       c3                      ret
    # send the accumulator's value to the caller

    ❯ objdump -d -M intel lab01_O2 | sed -n '/<main>:/,/^$/p' #O2
    0000000000401020 <main>:
    401020:       b8 2a 00 00 00          mov    eax,0x2a
    # move 42 into the lower half of the accumulator
    401025:       c3                      ret
    # send the accumulator's value to the caller
    401026:       66 2e 0f 1f 84 00 00    cs nop WORD PTR [rax+rax*1+0x0]
    # filler dummy memory operation so the next function starts at a 16 byte boundary
    40102d:       00 00 00 
    # still part of the same filler op, just wrapped to the next line by objdump

## Analysis
Using O0 does no optimisation as we can see here:
It messes with the stack and the frame pointer, despite there being no functions or calls in the program.

Using 02 has normal optimization:
It spots the pointless prologue,
However it still needs a filler at the end to reach the correct memory location for the next function.

## What surprised me
My prediction of mov eax, 42 / ret only matched the -O2 output. At -O0 there's a full prologue and epilogue I didn't predict. Also I read mov rbp,rsp backwards at first - it means rbp = rsp, not the other way round.

## Pattern to remember
- mov dst, src - destination is on the left in intel syntax
- push rbp; mov rbp,rsp = standard prologue
- pop rbp; ret = standard epilogue
- -O2 drops the prologue/epilogue for a function with no locals and no calls
- 66 2e 0f 1f 84 00 00 00 00 00 = padding nop, skip it
- if objdump wraps bytes onto the next line with a blank mnemonic, it's still the same instruction