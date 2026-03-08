.syntax unified
.cpu cortex-m4
.fpu fpv4-sp-d16
.thumb

#include "definitions.s"

.global main
.global SystemInit
.global ledWritePattern
.global softwareDelay
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

.section .bss
.align 4
__sbrk_heap_end:
    .word 0

.section .data
.align 4
__env:
    .word 0
environ:
    .word __env

.section .text
.align 2

/* Purpose: Startup clock hook (called by Reset_Handler).
 * Inputs: none
 * Outputs: none
 * Clobbers: none
 * Preserves: all registers
 * Test: place a breakpoint after BL SystemInit in startup and continue.
 */
.type SystemInit, %function
.thumb_func
SystemInit:
    bx lr
.size SystemInit, . - SystemInit

/* Purpose: Write LED pattern to PE8..PE15 via ODR high byte.
 * Inputs: r0 = 8-bit LED pattern
 * Outputs: none
 * Clobbers: r1
 * Preserves: r2-r11, lr
 * Test: inspect GPIOE->ODR[15:8] while stepping this function.
 */
.type ledWritePattern, %function
.thumb_func
ledWritePattern:
    ldr r1, =GPIOE_BASE
    strb r0, [r1, #LED_ODR_HIGH_BYTE_OFFSET]
    bx lr
.size ledWritePattern, . - ledWritePattern

/* Purpose: Software busy-wait delay.
 * Inputs: r0 = loop count
 * Outputs: none
 * Clobbers: r0
 * Preserves: r1-r11, lr
 * Test: adjust DELAY_LOOP_COUNT to tune blink period.
 */
.type softwareDelay, %function
.thumb_func
softwareDelay:
    cmp r0, #0
    beq softwareDelay_done
softwareDelay_loop:
    subs r0, r0, #1
    bne softwareDelay_loop
softwareDelay_done:
    bx lr
.size softwareDelay, . - softwareDelay

/* Purpose: Program entry point. Blink LEDs with 0x55/0xAA pattern.
 * Inputs: none
 * Outputs: does not return
 * Clobbers: r0-r4
 * Preserves: not applicable (infinite loop)
 * Test: 8 LEDs alternate visible patterns.
 */
.type main, %function
.thumb_func
main:
    bl enablePeripheralClocks
    bl initialiseDiscoveryBoard

    ldr r4, =PATTERN_INIT
main_loop:
    mov r0, r4
    bl ledWritePattern
    eors r4, r4, #0xFF
    ldr r0, =DELAY_LOOP_COUNT
    bl softwareDelay
    b main_loop
.size main, . - main

/* ---------- Minimal newlib syscall stubs ---------- */

.type initialise_monitor_handles, %function
.thumb_func
initialise_monitor_handles:
    bx lr
.size initialise_monitor_handles, . - initialise_monitor_handles

.type _getpid, %function
.thumb_func
_getpid:
    movs r0, #1
    bx lr
.size _getpid, . - _getpid

.type _kill, %function
.thumb_func
_kill:
    mvn r0, #0
    bx lr
.size _kill, . - _kill

.type _exit, %function
.thumb_func
_exit:
_exit_loop:
    b _exit_loop
.size _exit, . - _exit

.type _read, %function
.thumb_func
_read:
    movs r0, #0
    bx lr
.size _read, . - _read

.type _write, %function
.thumb_func
_write:
    /* Return len to report successful write without backend I/O. */
    mov r0, r2
    bx lr
.size _write, . - _write

.type _close, %function
.thumb_func
_close:
    mvn r0, #0
    bx lr
.size _close, . - _close

.type _fstat, %function
.thumb_func
_fstat:
    movs r0, #0
    bx lr
.size _fstat, . - _fstat

.type _isatty, %function
.thumb_func
_isatty:
    movs r0, #1
    bx lr
.size _isatty, . - _isatty

.type _lseek, %function
.thumb_func
_lseek:
    movs r0, #0
    bx lr
.size _lseek, . - _lseek

.type _open, %function
.thumb_func
_open:
    mvn r0, #0
    bx lr
.size _open, . - _open

.type _wait, %function
.thumb_func
_wait:
    mvn r0, #0
    bx lr
.size _wait, . - _wait

.type _unlink, %function
.thumb_func
_unlink:
    mvn r0, #0
    bx lr
.size _unlink, . - _unlink

.type _times, %function
.thumb_func
_times:
    mvn r0, #0
    bx lr
.size _times, . - _times

.type _stat, %function
.thumb_func
_stat:
    movs r0, #0
    bx lr
.size _stat, . - _stat

.type _link, %function
.thumb_func
_link:
    mvn r0, #0
    bx lr
.size _link, . - _link

.type _fork, %function
.thumb_func
_fork:
    mvn r0, #0
    bx lr
.size _fork, . - _fork

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
 * Test: ensure no undefined reference to _sbrk at link time.
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
