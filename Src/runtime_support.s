#ifndef RUNTIME_SUPPORT_S
#define RUNTIME_SUPPORT_S

.syntax unified
.cpu cortex-m4
.fpu fpv4-sp-d16
.thumb

.global _sbrk
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
.global environ

.section .bss.runtime_support, "aw", %nobits
.align 4
__sbrk_heap_end:
    .word 0

.section .data.runtime_support, "aw", %progbits
.align 4
__env:
    .word 0
environ:
    .word __env

.section .text.runtime_support, "ax", %progbits
.align 2

/* Purpose: Semihosting init hook for newlib; no-op in bare-metal baseline.
 * Inputs: none
 * Outputs: none
 * Clobbers: none
 * Preserves: all registers
 */
.type initialise_monitor_handles, %function
.thumb_func
initialise_monitor_handles:
    bx lr
.size initialise_monitor_handles, . - initialise_monitor_handles

/* Purpose: Return pseudo process id expected by libc.
 * Inputs: none
 * Outputs: r0 = process id
 * Clobbers: r0
 * Preserves: r1-r11, lr
 */
.type _getpid, %function
.thumb_func
_getpid:
    movs r0, #1
    bx lr
.size _getpid, . - _getpid

/* Purpose: Stub signal delivery API.
 * Inputs: r0 = pid, r1 = signal
 * Outputs: r0 = -1
 * Clobbers: r0
 * Preserves: r1-r11, lr
 */
.type _kill, %function
.thumb_func
_kill:
    mvn r0, #0
    bx lr
.size _kill, . - _kill

/* Purpose: Process termination hook for bare-metal environment.
 * Inputs: r0 = status
 * Outputs: none (infinite loop)
 * Clobbers: none
 * Preserves: all registers
 */
.type _exit, %function
.thumb_func
_exit:
_exit_loop:
    b _exit_loop
.size _exit, . - _exit

/* Purpose: Read stub for libc; no backend provided in this stage.
 * Inputs: r0 = file, r1 = ptr, r2 = len
 * Outputs: r0 = bytes read (0)
 * Clobbers: r0
 * Preserves: r1-r11, lr
 */
.type _read, %function
.thumb_func
_read:
    movs r0, #0
    bx lr
.size _read, . - _read

/* Purpose: Write stub for libc; reports success without transport backend.
 * Inputs: r0 = file, r1 = ptr, r2 = len
 * Outputs: r0 = len
 * Clobbers: r0
 * Preserves: r1-r11, lr
 */
.type _write, %function
.thumb_func
_write:
    mov r0, r2
    bx lr
.size _write, . - _write

/* Purpose: Close stub for libc.
 * Inputs: r0 = file
 * Outputs: r0 = -1
 * Clobbers: r0
 * Preserves: r1-r11, lr
 */
.type _close, %function
.thumb_func
_close:
    mvn r0, #0
    bx lr
.size _close, . - _close

/* Purpose: fstat stub for libc.
 * Inputs: r0 = file, r1 = stat*
 * Outputs: r0 = 0
 * Clobbers: r0
 * Preserves: r1-r11, lr
 */
.type _fstat, %function
.thumb_func
_fstat:
    movs r0, #0
    bx lr
.size _fstat, . - _fstat

/* Purpose: isatty stub for libc.
 * Inputs: r0 = file
 * Outputs: r0 = 1
 * Clobbers: r0
 * Preserves: r1-r11, lr
 */
.type _isatty, %function
.thumb_func
_isatty:
    movs r0, #1
    bx lr
.size _isatty, . - _isatty

/* Purpose: lseek stub for libc.
 * Inputs: r0 = file, r1 = ptr, r2 = dir
 * Outputs: r0 = 0
 * Clobbers: r0
 * Preserves: r1-r11, lr
 */
.type _lseek, %function
.thumb_func
_lseek:
    movs r0, #0
    bx lr
.size _lseek, . - _lseek

/* Purpose: open stub for libc.
 * Inputs: r0 = path, r1 = flags, r2 = mode
 * Outputs: r0 = -1
 * Clobbers: r0
 * Preserves: r1-r11, lr
 */
.type _open, %function
.thumb_func
_open:
    mvn r0, #0
    bx lr
.size _open, . - _open

/* Purpose: wait stub for libc.
 * Inputs: r0 = status
 * Outputs: r0 = -1
 * Clobbers: r0
 * Preserves: r1-r11, lr
 */
.type _wait, %function
.thumb_func
_wait:
    mvn r0, #0
    bx lr
.size _wait, . - _wait

/* Purpose: unlink stub for libc.
 * Inputs: r0 = path
 * Outputs: r0 = -1
 * Clobbers: r0
 * Preserves: r1-r11, lr
 */
.type _unlink, %function
.thumb_func
_unlink:
    mvn r0, #0
    bx lr
.size _unlink, . - _unlink

/* Purpose: times stub for libc.
 * Inputs: r0 = buffer
 * Outputs: r0 = -1
 * Clobbers: r0
 * Preserves: r1-r11, lr
 */
.type _times, %function
.thumb_func
_times:
    mvn r0, #0
    bx lr
.size _times, . - _times

/* Purpose: stat stub for libc.
 * Inputs: r0 = path, r1 = stat*
 * Outputs: r0 = 0
 * Clobbers: r0
 * Preserves: r1-r11, lr
 */
.type _stat, %function
.thumb_func
_stat:
    movs r0, #0
    bx lr
.size _stat, . - _stat

/* Purpose: link stub for libc.
 * Inputs: r0 = old, r1 = new
 * Outputs: r0 = -1
 * Clobbers: r0
 * Preserves: r1-r11, lr
 */
.type _link, %function
.thumb_func
_link:
    mvn r0, #0
    bx lr
.size _link, . - _link

/* Purpose: fork stub for libc.
 * Inputs: none
 * Outputs: r0 = -1
 * Clobbers: r0
 * Preserves: r1-r11, lr
 */
.type _fork, %function
.thumb_func
_fork:
    mvn r0, #0
    bx lr
.size _fork, . - _fork

/* Purpose: execve stub for libc.
 * Inputs: r0 = path, r1 = argv, r2 = envp
 * Outputs: r0 = -1
 * Clobbers: r0
 * Preserves: r1-r11, lr
 */
.type _execve, %function
.thumb_func
_execve:
    mvn r0, #0
    bx lr
.size _execve, . - _execve

/* Purpose: Heap extension hook used by malloc/newlib.
 * Inputs: r0 = increment (bytes)
 * Outputs: r0 = previous heap end on success, -1 on failure
 * Clobbers: r1-r3, r12
 * Preserves: r4-r11, lr
 */
.type _sbrk, %function
.thumb_func
_sbrk:
    ldr r1, =__sbrk_heap_end
    ldr r2, [r1]
    cmp r2, #0
    bne _sbrk_have_heap
    ldr r2, =_end
    str r2, [r1]

_sbrk_have_heap:
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

#endif /* RUNTIME_SUPPORT_S */
