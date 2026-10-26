# Lab 02 — Function calls and the ABI

## Objective
Learning how functions interact and where args go

## Source
```c
int add(int a, int b) { return a + b; }
int main(void) { int x = add(3, 4); return x; }
```

## Build
```bash
gcc -O0 -no-pie -g -o lab02_O0 lab02.c
gcc -O2 -no-pie -g -o lab02_O2 lab02.c
```

## Prediction
- 3 goes in edi, 4 goes in esi
- main calls add, result comes back in eax
- add does the addition and returns

## Disassembly

```
❯ objdump -d -M intel lab02_O0
0000000000401116 <add>:
401116:       55                      push   rbp
401117:       48 89 e5                mov    rbp,rsp
# prologue
40111a:       89 7d fc                mov    DWORD PTR [rbp-0x4],edi
40111d:       89 75 f8                mov    DWORD PTR [rbp-0x8],esi
# move args to stack
401120:       8b 55 fc                mov    edx,DWORD PTR [rbp-0x4]
401123:       8b 45 f8                mov    eax,DWORD PTR [rbp-0x8]
401126:       01 d0                   add    eax,edx
# load from stack and add
401128:       5d                      pop    rbp
401129:       c3                      ret
# epilogue and return
000000000040112a <main>:
40112a:       55                      push   rbp
40112b:       48 89 e5                mov    rbp,rsp
# prologue
40112e:       48 83 ec 10             sub    rsp,0x10
# make space for local x
401132:       be 04 00 00 00          mov    esi,0x4
# arg 2 = 4
401137:       bf 03 00 00 00          mov    edi,0x3
# arg 1 = 3
40113c:       e8 d5 ff ff ff          call   401116 <add>
# jump to add
401141:       89 45 fc                mov    DWORD PTR [rbp-0x4],eax
401144:       8b 45 fc                mov    eax,DWORD PTR [rbp-0x4]
# store return value then load it back
401147:       c9                      leave
401148:       c3                      ret
# epilogue and return

❯ objdump -d -M intel lab02_O2 | sed -n '/<main>:/,/^$/p'
0000000000401020 <main>:
401020:       b8 07 00 00 00          mov    eax,0x7
# 7 precalculated
401025:       c3                      ret
# return
401026:       66 2e 0f 1f 84 00 00    cs nop WORD PTR [rax+rax*1+0x0]
40102d:       00 00 00
# padding nop
```

## Analysis
At -O0 there's a lot of pointless stack shuffling. Args go into edi/esi, then add copies them to the stack, then loads them back to add them.

At -O2 add disappears entirely. The compiler worked out 3+4=7 at compile time and just puts 7 in eax.

## What surprised me
- add is completely gone at -O2. The whole function got folded into the constant 7.
- esi gets set before edi (arg 2 before arg 1). Order doesn't matter but I expected edi first.

## Pattern to remember
- SysV arg order: edi, esi, edx, ecx, r8, r9
- call pushes return address then jumps; ret pops it and jumps back
- leave = mov rsp,rbp; pop rbp
- at -O2, functions with constant args can be precalculated and disappear