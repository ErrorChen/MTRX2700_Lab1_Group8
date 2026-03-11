.syntax unified
.cpu cortex-m4
.fpu fpv4-sp-d16
.thumb

#include "definitions.s"

/* Compile-time top-level selection: valid values 1..5. */
.equ ACTIVE_EXERCISE,                    5
.equ ERROR_LOOP_DELAY_CYCLES,            400000

.global main
.global SystemInit

.global ledWritePattern
.global softwareDelayCycles
.global ledErrorLoop

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

.extern enablePeripheralClocks
.extern initialiseDiscoveryBoard
.extern timInit1MHz

.section .text.entry, "ax", %progbits
.align 2

/* Purpose: CMSIS startup hook called by Reset_Handler before data init.
 * Inputs: none
 * Outputs: none
 * Clobbers: none
 * Preserves: all
 * Test: Reset target and confirm execution reaches main.
 */
.type SystemInit, %function
.thumb_func
SystemInit:
    bx lr
.size SystemInit, . - SystemInit

/* Purpose: Program entry point and compile-time exercise dispatcher.
 * Inputs: none
 * Outputs: none (never returns)
 * Clobbers: r0-r3, lr
 * Preserves: r4-r11
 * Test: Set ACTIVE_EXERCISE (1..5) and confirm selected entry runs.
 */
.type main, %function
.thumb_func
main:
    bl enablePeripheralClocks
    bl initialiseDiscoveryBoard
    bl timInit1MHz

.if ACTIVE_EXERCISE == 1
    bl exercise1Entry
.elseif ACTIVE_EXERCISE == 2
    bl exercise2Entry
.elseif ACTIVE_EXERCISE == 3
    bl exercise3Entry
.elseif ACTIVE_EXERCISE == 4
    bl exercise4Entry
.elseif ACTIVE_EXERCISE == 5
    bl exercise5Entry
.else
    bl ledErrorLoop
.endif

main_fallthrough_trap:
    b main_fallthrough_trap
.size main, . - main

/* Purpose: Write an 8-bit LED pattern to PE8..PE15.
 * Inputs: r0 = LED bitmask
 * Outputs: none
 * Clobbers: r1
 * Preserves: r2-r11, lr
 * Test: Call with 0x55 and verify alternating LEDs.
 */
.type ledWritePattern, %function
.thumb_func
ledWritePattern:
    ldr r1, =GPIOE_BASE
    strb r0, [r1, #LED_ODR_HIGH_BYTE_OFFSET]
    bx lr
.size ledWritePattern, . - ledWritePattern

/* Purpose: Busy-loop software delay for coarse timing.
 * Inputs: r0 = loop iterations
 * Outputs: none
 * Clobbers: r0
 * Preserves: r1-r11, lr
 * Test: Toggle an LED around calls and inspect timing on scope.
 */
.type softwareDelayCycles, %function
.thumb_func
softwareDelayCycles:
    cmp r0, #0
    beq softwareDelayCycles_done
softwareDelayCycles_loop:
    subs r0, r0, #1
    bne softwareDelayCycles_loop
softwareDelayCycles_done:
    bx lr
.size softwareDelayCycles, . - softwareDelayCycles

/* Purpose: Visible error indicator for invalid top-level selector.
 * Inputs: none
 * Outputs: none (infinite loop)
 * Clobbers: r0, lr
 * Preserves: r1-r11
 * Test: Set ACTIVE_EXERCISE to invalid value and check flashing pattern.
 */
.type ledErrorLoop, %function
.thumb_func
ledErrorLoop:
ledErrorLoop_loop:
    movs r0, #LED_ERROR_PATTERN_A
    bl ledWritePattern
    ldr r0, =ERROR_LOOP_DELAY_CYCLES
    bl softwareDelayCycles

    movs r0, #LED_ERROR_PATTERN_B
    bl ledWritePattern
    ldr r0, =ERROR_LOOP_DELAY_CYCLES
    bl softwareDelayCycles
    b ledErrorLoop_loop
.size ledErrorLoop, . - ledErrorLoop

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
 * Preserves: all
 * Test: Link with nano specs and ensure no unresolved symbol.
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
 * Preserves: r1-r11, lr
 * Test: Any libc call needing getpid should receive non-zero value.
 */
.type _getpid, %function
.thumb_func
_getpid:
    movs r0, #1
    bx lr
.size _getpid, . - _getpid

/* Purpose: Stub signal delivery backend for bare metal.
 * Inputs: r0 = pid, r1 = signal
 * Outputs: r0 = -1
 * Clobbers: r0
 * Preserves: r1-r11, lr
 * Test: Link-time syscall references resolve correctly.
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
 * Preserves: all
 * Test: Trigger _exit and confirm CPU halts in loop.
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
 * Preserves: r1-r11, lr
 * Test: Read requests return EOF.
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
 * Preserves: r1-r11, lr
 * Test: printf-style calls report bytes accepted.
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
 * Preserves: r1-r11, lr
 * Test: close() on host descriptors fails deterministically.
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
 * Preserves: r1-r11, lr
 * Test: libc checks for tty/device do not hard-fail.
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
 * Preserves: r1-r11, lr
 * Test: stdout/stderr treated as terminal-compatible.
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
 * Preserves: r1-r11, lr
 * Test: lseek calls return zero offset.
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
 * Preserves: r1-r11, lr
 * Test: open() fails cleanly in bare-metal context.
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
 * Preserves: r1-r11, lr
 * Test: wait() returns unsupported.
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
 * Preserves: r1-r11, lr
 * Test: unlink() returns unsupported.
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
 * Preserves: r1-r11, lr
 * Test: times() returns unsupported.
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
 * Preserves: r1-r11, lr
 * Test: stat() returns generic success for minimal libc expectations.
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
 * Preserves: r1-r11, lr
 * Test: link() returns unsupported.
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
 * Preserves: r1-r11, lr
 * Test: fork() returns unsupported.
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
 * Preserves: r1-r11, lr
 * Test: execve() returns unsupported.
 */
.type _execve, %function
.thumb_func
_execve:
    mvn r0, #0
    bx lr
.size _execve, . - _execve

/* Purpose: Heap extension hook for newlib malloc family.
 * Inputs: r0 = increment in bytes
 * Outputs: r0 = previous heap end, or -1 on failure
 * Clobbers: r1-r3, r12
 * Preserves: r4-r11, lr
 * Test: Small malloc allocations advance heap; overflow returns -1.
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

#include "exercise1.s"
#include "exercise2.s"
#include "exercise3.s"
#include "exercise4.s"
#include "exercise5.s"
