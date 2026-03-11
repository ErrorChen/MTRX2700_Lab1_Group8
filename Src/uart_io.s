#ifndef UART_IO_S
#define UART_IO_S

#include "platform_defs.s"

.syntax unified
.cpu cortex-m4
.fpu fpv4-sp-d16
.thumb

.global uartInit
.global uartWriteByte
.global uartReadByteNonBlocking

.section .text.uart_io, "ax", %progbits
.align 2

/* Purpose: UART layer initialisation entry point.
 * Inputs: none
 * Outputs: none
 * Clobbers: r0-r2
 * Preserves: r4-r11, lr
 * Notes/TODO:
 * - Architecture-stage baseline only.
 * - Currently enables USART1 peripheral clock only.
 * - Pin mux, baud, frame, and IRQ setup are deferred.
 */
.type uartInit, %function
.thumb_func
uartInit:
    ldr r0, =RCC_BASE
    ldr r1, [r0, #RCC_APB2ENR_OFFSET]
    ldr r2, =RCC_APB2ENR_USART1EN
    orrs r1, r1, r2
    str r1, [r0, #RCC_APB2ENR_OFFSET]
    bx lr
.size uartInit, . - uartInit

/* Purpose: UART transmit API boundary.
 * Inputs: r0 = byte to transmit (LSB)
 * Outputs: r0 = STATUS_OK / STATUS_UNSUPPORTED
 * Clobbers: r0
 * Preserves: r1-r11, lr
 * Notes/TODO: Full TX implementation is intentionally deferred.
 */
.type uartWriteByte, %function
.thumb_func
uartWriteByte:
    ldr r0, =STATUS_UNSUPPORTED
    bx lr
.size uartWriteByte, . - uartWriteByte

/* Purpose: UART non-blocking receive API boundary.
 * Inputs: none
 * Outputs: r0 = STATUS_OK / STATUS_UNSUPPORTED, r1 = received byte when STATUS_OK
 * Clobbers: r0-r1
 * Preserves: r2-r11, lr
 * Notes/TODO: Full RX implementation is intentionally deferred.
 */
.type uartReadByteNonBlocking, %function
.thumb_func
uartReadByteNonBlocking:
    ldr r0, =STATUS_UNSUPPORTED
    movs r1, #0
    bx lr
.size uartReadByteNonBlocking, . - uartReadByteNonBlocking

#endif /* UART_IO_S */
