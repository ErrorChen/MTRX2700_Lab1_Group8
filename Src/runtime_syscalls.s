#include "platform_defs.inc"

.global initialise_monitor_handles
.global _getpid
.global _kill
.global _exit
.global _read
.global _write
.global _close
.global _fstat
.global _isatty
.global _lseek
.global _open
.global _wait
.global _unlink
.global _times
.global _stat
.global _link
.global _fork
.global _execve
.global _sbrk
.global environ

.section .bss.syscalls, "aw", %nobits
.align 4
__sbrk_heap_end:
    .word 0

.section .data.syscalls, "aw", %progbits
.align 4
__env:
    .word 0
environ:
    .word __env

.section .text.syscalls, "ax", %progbits
.align 2

/* Purpose: newlib semihosting setup hook (unused in this project).
 * Inputs: none
 * Outputs: none
 * Clobbers: none
 * Preserved registers: all
 * Side effects: none
 * Test idea: Link with nano specs and ensure symbol resolves.
 */
.type initialise_monitor_handles, %function
.thumb_func
initialise_monitor_handles:
    bx lr
.size initialise_monitor_handles, . - initialise_monitor_handles

/* Purpose: Return pseudo process ID expected by newlib.
 * Inputs: none
 * Outputs: r0 = 1
 * Clobbers: r0
 * Preserved registers: r1-r11, lr
 * Side effects: none
 * Test idea: getpid() should return non-zero value.
 */
.type _getpid, %function
.thumb_func
_getpid:
    movs r0, #1
    bx lr
.size _getpid, . - _getpid

/* Purpose: Stub signal delivery backend for bare-metal environment.
 * Inputs: r0 = pid, r1 = signal
 * Outputs: r0 = -1
 * Clobbers: r0
 * Preserved registers: r1-r11, lr
 * Side effects: none
 * Test idea: kill() should deterministically report unsupported.
 */
.type _kill, %function
.thumb_func
_kill:
    mvn r0, #0
    bx lr
.size _kill, . - _kill

/* Purpose: Bare-metal process exit trap.
 * Inputs: r0 = status
 * Outputs: none (infinite loop)
 * Clobbers: none
 * Preserved registers: all
 * Side effects: CPU remains in tight loop.
 * Test idea: Trigger _exit and verify execution halts in loop.
 */
.type _exit, %function
.thumb_func
_exit:
_exit_loop:
    b _exit_loop
.size _exit, . - _exit

/* Purpose: Read syscall stub.
 * Inputs: r0 = fd, r1 = buf, r2 = len
 * Outputs: r0 = 0
 * Clobbers: r0
 * Preserved registers: r1-r11, lr
 * Side effects: none
 * Test idea: read() should return EOF behavior.
 */
.type _read, %function
.thumb_func
_read:
    movs r0, #0
    bx lr
.size _read, . - _read

/* Purpose: Write syscall stub.
 * Inputs: r0 = fd, r1 = buf, r2 = len
 * Outputs: r0 = len
 * Clobbers: r0
 * Preserved registers: r1-r11, lr
 * Side effects: none
 * Test idea: printf path should report bytes accepted.
 */
.type _write, %function
.thumb_func
_write:
    mov r0, r2
    bx lr
.size _write, . - _write

/* Purpose: Close syscall stub.
 * Inputs: r0 = fd
 * Outputs: r0 = -1
 * Clobbers: r0
 * Preserved registers: r1-r11, lr
 * Side effects: none
 * Test idea: close() should return unsupported.
 */
.type _close, %function
.thumb_func
_close:
    mvn r0, #0
    bx lr
.size _close, . - _close

/* Purpose: fstat syscall stub.
 * Inputs: r0 = fd, r1 = stat*
 * Outputs: r0 = 0
 * Clobbers: r0
 * Preserved registers: r1-r11, lr
 * Side effects: none
 * Test idea: libc fstat probes should not hard-fail.
 */
.type _fstat, %function
.thumb_func
_fstat:
    movs r0, #0
    bx lr
.size _fstat, . - _fstat

/* Purpose: isatty syscall stub.
 * Inputs: r0 = fd
 * Outputs: r0 = 1
 * Clobbers: r0
 * Preserved registers: r1-r11, lr
 * Side effects: none
 * Test idea: stdout/stderr treated as terminal-compatible.
 */
.type _isatty, %function
.thumb_func
_isatty:
    movs r0, #1
    bx lr
.size _isatty, . - _isatty

/* Purpose: lseek syscall stub.
 * Inputs: r0 = fd, r1 = ptr, r2 = dir
 * Outputs: r0 = 0
 * Clobbers: r0
 * Preserved registers: r1-r11, lr
 * Side effects: none
 * Test idea: lseek() should return zero offset.
 */
.type _lseek, %function
.thumb_func
_lseek:
    movs r0, #0
    bx lr
.size _lseek, . - _lseek

/* Purpose: open syscall stub.
 * Inputs: r0 = path, r1 = flags, r2 = mode
 * Outputs: r0 = -1
 * Clobbers: r0
 * Preserved registers: r1-r11, lr
 * Side effects: none
 * Test idea: open() should report unsupported.
 */
.type _open, %function
.thumb_func
_open:
    mvn r0, #0
    bx lr
.size _open, . - _open

/* Purpose: wait syscall stub.
 * Inputs: r0 = status
 * Outputs: r0 = -1
 * Clobbers: r0
 * Preserved registers: r1-r11, lr
 * Side effects: none
 * Test idea: wait() should report unsupported.
 */
.type _wait, %function
.thumb_func
_wait:
    mvn r0, #0
    bx lr
.size _wait, . - _wait

/* Purpose: unlink syscall stub.
 * Inputs: r0 = path
 * Outputs: r0 = -1
 * Clobbers: r0
 * Preserved registers: r1-r11, lr
 * Side effects: none
 * Test idea: unlink() should report unsupported.
 */
.type _unlink, %function
.thumb_func
_unlink:
    mvn r0, #0
    bx lr
.size _unlink, . - _unlink

/* Purpose: times syscall stub.
 * Inputs: r0 = tms*
 * Outputs: r0 = -1
 * Clobbers: r0
 * Preserved registers: r1-r11, lr
 * Side effects: none
 * Test idea: times() should report unsupported.
 */
.type _times, %function
.thumb_func
_times:
    mvn r0, #0
    bx lr
.size _times, . - _times

/* Purpose: stat syscall stub.
 * Inputs: r0 = path, r1 = stat*
 * Outputs: r0 = 0
 * Clobbers: r0
 * Preserved registers: r1-r11, lr
 * Side effects: none
 * Test idea: stat() probes should return generic success.
 */
.type _stat, %function
.thumb_func
_stat:
    movs r0, #0
    bx lr
.size _stat, . - _stat

/* Purpose: link syscall stub.
 * Inputs: r0 = old path, r1 = new path
 * Outputs: r0 = -1
 * Clobbers: r0
 * Preserved registers: r1-r11, lr
 * Side effects: none
 * Test idea: link() should report unsupported.
 */
.type _link, %function
.thumb_func
_link:
    mvn r0, #0
    bx lr
.size _link, . - _link

/* Purpose: fork syscall stub.
 * Inputs: none
 * Outputs: r0 = -1
 * Clobbers: r0
 * Preserved registers: r1-r11, lr
 * Side effects: none
 * Test idea: fork() should report unsupported.
 */
.type _fork, %function
.thumb_func
_fork:
    mvn r0, #0
    bx lr
.size _fork, . - _fork

/* Purpose: execve syscall stub.
 * Inputs: r0 = path, r1 = argv, r2 = envp
 * Outputs: r0 = -1
 * Clobbers: r0
 * Preserved registers: r1-r11, lr
 * Side effects: none
 * Test idea: execve() should report unsupported.
 */
.type _execve, %function
.thumb_func
_execve:
    mvn r0, #0
    bx lr
.size _execve, . - _execve

/* Purpose: Heap extension hook for newlib allocators.
 * Inputs: r0 = increment in bytes
 * Outputs: r0 = previous heap end or -1 on failure
 * Clobbers: r1-r3, r12
 * Preserved registers: r4-r11, lr
 * Side effects: Advances __sbrk_heap_end pointer when space permits.
 * Test idea: Small malloc should advance heap; overflow should return -1.
 */
.type _sbrk, %function
.thumb_func
_sbrk:
    ldr r1, =__sbrk_heap_end
    ldr r2, [r1]
    cmp r2, #0
    bne _sbrk_haveHeap

    ldr r2, =_end
    str r2, [r1]

_sbrk_haveHeap:
    ldr r3, =_estack
    ldr r12, =_Min_Stack_Size
    subs r3, r3, r12

    adds r12, r2, r0
    cmp r12, r3
    bhi _sbrk_fail

    str r12, [r1]
    mov r0, r2
    bx lr

_sbrk_fail:
    mvn r0, #0
    bx lr
.size _sbrk, . - _sbrk
