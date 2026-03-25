#include "platform_defs.inc"

.global uart4Init
.global uart5Init
.global uartSendBuffer
.global uartReadByteBlocking
.global uartReceiveFramedMessage
.global uartSendAckMessage
.global uartSendNakMessage
.global computeUartBrrFromClock
.global waitForAckOrNakWithTimeout

.extern initialiseUartGpioPins
.extern buildFramedMessage
.extern verifyFrameChecksum

.section .rodata.uart_io, "a", %progbits
.align 4
uartAckPayload:
    .asciz "ACK"
uartNakPayload:
    .asciz "NAK"

.section .bss.uart_io, "aw", %nobits
.align 4
uartControlFrameBuffer:
    .space MAX_FRAME_BYTES
uartAckWaitFrameBuffer:
    .space MAX_FRAME_BYTES

.section .text.uart_io, "ax", %progbits
.align 2

/* Purpose: Initialise UART4 for polling-mode 8N1 communication.
 * Inputs: none
 * Outputs: none
 * Clobbers: r0-r3, lr
 * Preserved registers: r4-r11
 * Side effects: Configures GPIO AF pins, BRR, and UART4 CR1 bits.
 * Test idea: Send bytes on PC10 and verify waveform with logic analyzer.
 */
.type uart4Init, %function
.thumb_func
uart4Init:
    push {lr}
    bl initialiseUartGpioPins

    ldr r0, =RCC_BASE
    ldr r1, [r0, #RCC_APB1ENR_OFFSET]
    ldr r2, =(RCC_APB1ENR_UART4EN | RCC_APB1ENR_UART5EN)
    orrs r1, r1, r2
    str r1, [r0, #RCC_APB1ENR_OFFSET]

    ldr r0, =UART4_BASE
    ldr r1, =APB1_CLOCK_HZ
    ldr r2, =DEFAULT_BAUD_RATE
    bl computeUartBrrFromClock
    str r3, [r0, #USART_BRR_OFFSET]

    ldr r1, =(USART_CR1_UE | USART_CR1_TE | USART_CR1_RE)
    str r1, [r0, #USART_CR1_OFFSET]
    pop {pc}
.size uart4Init, . - uart4Init

/* Purpose: Initialise UART5 for polling-mode 8N1 communication.
 * Inputs: none
 * Outputs: none
 * Clobbers: r0-r3, lr
 * Preserved registers: r4-r11
 * Side effects: Configures GPIO AF pins, BRR, and UART5 CR1 bits.
 * Test idea: Wire PC12/PD2 and verify bidirectional bytes with UART4.
 */
.type uart5Init, %function
.thumb_func
uart5Init:
    push {lr}
    bl initialiseUartGpioPins

    ldr r0, =RCC_BASE
    ldr r1, [r0, #RCC_APB1ENR_OFFSET]
    ldr r2, =(RCC_APB1ENR_UART4EN | RCC_APB1ENR_UART5EN)
    orrs r1, r1, r2
    str r1, [r0, #RCC_APB1ENR_OFFSET]

    ldr r0, =UART5_BASE
    ldr r1, =APB1_CLOCK_HZ
    ldr r2, =DEFAULT_BAUD_RATE
    bl computeUartBrrFromClock
    str r3, [r0, #USART_BRR_OFFSET]

    ldr r1, =(USART_CR1_UE | USART_CR1_TE | USART_CR1_RE)
    str r1, [r0, #USART_CR1_OFFSET]
    pop {pc}
.size uart5Init, . - uart5Init

/* Purpose: Send a fixed-length byte buffer over selected UART.
 * Inputs: r0 = UART base, r1 = buffer pointer, r2 = length
 * Outputs: none
 * Clobbers: r1-r4
 * Preserved registers: r0, r5-r11, lr
 * Side effects: Blocks until bytes are written and TX complete.
 * Test idea: Send known frame and verify exact byte order on TX line.
 */
.type uartSendBuffer, %function
.thumb_func
uartSendBuffer:
    push {r4, lr}
    mov r4, r2

uartSendBuffer_loop:
    cmp r4, #0
    beq uartSendBuffer_waitTc

uartSendBuffer_waitTxe:
    ldr r3, [r0, #USART_ISR_OFFSET]
    tst r3, #USART_ISR_TXE
    beq uartSendBuffer_waitTxe

    ldrb r3, [r1]
    strb r3, [r0, #USART_TDR_OFFSET]
    adds r1, r1, #1
    subs r4, r4, #1
    b uartSendBuffer_loop

uartSendBuffer_waitTc:
    ldr r3, [r0, #USART_ISR_OFFSET]
    tst r3, #USART_ISR_TC
    beq uartSendBuffer_waitTc

    pop {r4, pc}
.size uartSendBuffer, . - uartSendBuffer

/* Purpose: Receive one byte from selected UART using blocking polling.
 * Inputs: r0 = UART base
 * Outputs: r1 = received byte
 * Clobbers: r2
 * Preserved registers: r0, r3-r11, lr
 * Side effects: Busy-waits until RXNE is set.
 * Test idea: Stream characters and verify each call returns next byte.
 */
.type uartReadByteBlocking, %function
.thumb_func
uartReadByteBlocking:
uartReadByteBlocking_wait:
    ldr r2, [r0, #USART_ISR_OFFSET]
    tst r2, #USART_ISR_RXNE
    beq uartReadByteBlocking_wait

    ldrb r1, [r0, #USART_RDR_OFFSET]
    bx lr
.size uartReadByteBlocking, . - uartReadByteBlocking

/* Purpose: Receive, validate, and decode a framed UART message.
 * Inputs: r0 = UART base, r1 = frame scratch buffer, r2 = payload destination
 * Outputs: r3 = UART_STATUS_*, r2 = payload length when status is OK else 0
 * Clobbers: r0-r3, r4-r8, lr
 * Preserved registers: r9-r11
 * Side effects: Writes received frame and decoded payload buffers.
 * Test idea: Inject valid and malformed frames and check status codes.
 */
.type uartReceiveFramedMessage, %function
.thumb_func
uartReceiveFramedMessage:
    push {r4-r8, lr}
    mov r4, r0
    mov r5, r1
    mov r6, r2

uartReceiveFramedMessage_waitStx:
    mov r0, r4
    bl uartReadByteBlocking
    cmp r1, #STX
    bne uartReceiveFramedMessage_waitStx
    strb r1, [r5]

    mov r0, r4
    bl uartReadByteBlocking
    uxtb r7, r1
    strb r1, [r5, #1]

    cmp r7, #FRAME_MIN_LENGTH
    blo uartReceiveFramedMessage_lengthError
    cmp r7, #MAX_FRAME_BYTES
    bhi uartReceiveFramedMessage_lengthError

    subs r8, r7, #2
    adds r2, r5, #2

uartReceiveFramedMessage_readRest:
    cmp r8, #0
    beq uartReceiveFramedMessage_readDone

    mov r0, r4
    bl uartReadByteBlocking
    strb r1, [r2]
    adds r2, r2, #1
    subs r8, r8, #1
    b uartReceiveFramedMessage_readRest

uartReceiveFramedMessage_readDone:
    subs r2, r7, #FRAME_TRAILER_LENGTH
    adds r2, r5, r2
    ldrb r0, [r2]
    cmp r0, #ETX
    bne uartReceiveFramedMessage_etxError

    mov r1, r5
    mov r2, r7
    bl verifyFrameChecksum
    cmp r3, #1
    bne uartReceiveFramedMessage_checksumError

    subs r8, r7, #FRAME_MIN_LENGTH
    cmp r8, #MAX_PAYLOAD_BYTES
    bhi uartReceiveFramedMessage_payloadError

    adds r1, r5, #2
    mov r2, r6
    mov r0, r8

uartReceiveFramedMessage_copyPayload:
    cmp r0, #0
    beq uartReceiveFramedMessage_copyDone
    ldrb r12, [r1]
    cmp r12, #ASCII_NUL
    beq uartReceiveFramedMessage_payloadError
    strb r12, [r2]
    adds r1, r1, #1
    adds r2, r2, #1
    subs r0, r0, #1
    b uartReceiveFramedMessage_copyPayload

uartReceiveFramedMessage_copyDone:
    movs r12, #ASCII_NUL
    strb r12, [r2]
    mov r2, r8
    movs r3, #UART_STATUS_OK
    b uartReceiveFramedMessage_done

uartReceiveFramedMessage_lengthError:
    movs r3, #UART_STATUS_LENGTH_ERROR
    movs r2, #0
    b uartReceiveFramedMessage_done

uartReceiveFramedMessage_etxError:
    movs r3, #UART_STATUS_ETX_ERROR
    movs r2, #0
    b uartReceiveFramedMessage_done

uartReceiveFramedMessage_checksumError:
    movs r3, #UART_STATUS_CHECKSUM_ERROR
    movs r2, #0
    b uartReceiveFramedMessage_done

uartReceiveFramedMessage_payloadError:
    movs r3, #UART_STATUS_PAYLOAD_ERROR
    movs r2, #0

uartReceiveFramedMessage_done:
    pop {r4-r8, pc}
.size uartReceiveFramedMessage, . - uartReceiveFramedMessage

/* Purpose: Send framed ACK payload on selected UART peripheral.
 * Inputs: r0 = UART base
 * Outputs: none
 * Clobbers: r0-r2, r4, lr
 * Preserved registers: r5-r11
 * Side effects: Transmits ACK control frame.
 * Test idea: Verify outgoing payload equals "ACK" with valid active checksum.
 */
.type uartSendAckMessage, %function
.thumb_func
uartSendAckMessage:
    push {r4, lr}
    mov r4, r0

    ldr r0, =uartAckPayload
    ldr r1, =uartControlFrameBuffer
    bl buildFramedMessage

    mov r0, r4
    ldr r1, =uartControlFrameBuffer
    bl uartSendBuffer
    pop {r4, pc}
.size uartSendAckMessage, . - uartSendAckMessage

/* Purpose: Send framed NAK payload on selected UART peripheral.
 * Inputs: r0 = UART base
 * Outputs: none
 * Clobbers: r0-r2, r4, lr
 * Preserved registers: r5-r11
 * Side effects: Transmits NAK control frame.
 * Test idea: Verify outgoing payload equals "NAK" with valid active checksum.
 */
.type uartSendNakMessage, %function
.thumb_func
uartSendNakMessage:
    push {r4, lr}
    mov r4, r0

    ldr r0, =uartNakPayload
    ldr r1, =uartControlFrameBuffer
    bl buildFramedMessage

    mov r0, r4
    ldr r1, =uartControlFrameBuffer
    bl uartSendBuffer
    pop {r4, pc}
.size uartSendNakMessage, . - uartSendNakMessage

/* Purpose: Compute USART BRR from peripheral clock and target baud rate.
 * Inputs: r1 = peripheral clock (Hz), r2 = baud rate
 * Outputs: r3 = BRR divisor value
 * Clobbers: r0-r1
 * Preserved registers: r2, r4-r11, lr
 * Side effects: none
 * Test idea: For 8 MHz and 115200 baud, compare result with manual rounding.
 */
.type computeUartBrrFromClock, %function
.thumb_func
computeUartBrrFromClock:
    cmp r2, #0
    beq computeUartBrrFromClock_zero

    lsrs r0, r2, #1
    adds r1, r1, r0
    udiv r3, r1, r2
    bx lr

computeUartBrrFromClock_zero:
    movs r3, #0
    bx lr
.size computeUartBrrFromClock, . - computeUartBrrFromClock

/* Purpose: Wait for framed ACK/NAK response with microsecond timeout.
 * Inputs: r0 = UART base
 * Outputs: r0 = ACK_WAIT_ACK / ACK_WAIT_NAK / ACK_WAIT_TIMEOUT
 * Clobbers: r1-r3, r4-r8, lr
 * Preserved registers: r9-r11
 * Side effects: Consumes UART RX bytes and reads TIM2 counter.
 * Test idea: Send ACK, send NAK, and no response to verify all return codes.
 */
.type waitForAckOrNakWithTimeout, %function
.thumb_func
waitForAckOrNakWithTimeout:
    push {r4-r8, lr}
    mov r4, r0

    ldr r0, =TIM2_BASE
    ldr r5, [r0, #TIM_CNT_OFFSET]
    ldr r6, =uartAckWaitFrameBuffer

waitForAckOrNakWithTimeout_waitStx:
    ldr r1, [r4, #USART_ISR_OFFSET]
    tst r1, #USART_ISR_RXNE
    bne waitForAckOrNakWithTimeout_haveStxByte

    ldr r0, =TIM2_BASE
    ldr r1, [r0, #TIM_CNT_OFFSET]
    subs r1, r1, r5
    ldr r2, =EX5_ACK_TIMEOUT_US
    cmp r1, r2
    blo waitForAckOrNakWithTimeout_waitStx

    movs r0, #ACK_WAIT_TIMEOUT
    b waitForAckOrNakWithTimeout_done

waitForAckOrNakWithTimeout_haveStxByte:
    ldrb r1, [r4, #USART_RDR_OFFSET]
    cmp r1, #STX
    bne waitForAckOrNakWithTimeout_waitStx
    strb r1, [r6]

waitForAckOrNakWithTimeout_waitLen:
    ldr r1, [r4, #USART_ISR_OFFSET]
    tst r1, #USART_ISR_RXNE
    bne waitForAckOrNakWithTimeout_haveLen

    ldr r0, =TIM2_BASE
    ldr r1, [r0, #TIM_CNT_OFFSET]
    subs r1, r1, r5
    ldr r2, =EX5_ACK_TIMEOUT_US
    cmp r1, r2
    blo waitForAckOrNakWithTimeout_waitLen

    movs r0, #ACK_WAIT_TIMEOUT
    b waitForAckOrNakWithTimeout_done

waitForAckOrNakWithTimeout_haveLen:
    ldrb r1, [r4, #USART_RDR_OFFSET]
    uxtb r7, r1
    strb r1, [r6, #1]

    cmp r7, #FRAME_MIN_LENGTH
    blo waitForAckOrNakWithTimeout_nak
    cmp r7, #MAX_FRAME_BYTES
    bhi waitForAckOrNakWithTimeout_nak

    subs r8, r7, #2
    adds r2, r6, #2

waitForAckOrNakWithTimeout_readRest:
    cmp r8, #0
    beq waitForAckOrNakWithTimeout_validate

waitForAckOrNakWithTimeout_waitNext:
    ldr r1, [r4, #USART_ISR_OFFSET]
    tst r1, #USART_ISR_RXNE
    bne waitForAckOrNakWithTimeout_haveNext

    ldr r0, =TIM2_BASE
    ldr r1, [r0, #TIM_CNT_OFFSET]
    subs r1, r1, r5
    ldr r3, =EX5_ACK_TIMEOUT_US
    cmp r1, r3
    blo waitForAckOrNakWithTimeout_waitNext

    movs r0, #ACK_WAIT_TIMEOUT
    b waitForAckOrNakWithTimeout_done

waitForAckOrNakWithTimeout_haveNext:
    ldrb r1, [r4, #USART_RDR_OFFSET]
    strb r1, [r2]
    adds r2, r2, #1
    subs r8, r8, #1
    b waitForAckOrNakWithTimeout_readRest

waitForAckOrNakWithTimeout_validate:
    subs r2, r7, #FRAME_TRAILER_LENGTH
    adds r2, r6, r2
    ldrb r1, [r2]
    cmp r1, #ETX
    bne waitForAckOrNakWithTimeout_nak

    mov r1, r6
    mov r2, r7
    bl verifyFrameChecksum
    cmp r3, #1
    bne waitForAckOrNakWithTimeout_nak

    subs r8, r7, #FRAME_MIN_LENGTH
    cmp r8, #ACK_NAK_PAYLOAD_LENGTH
    bne waitForAckOrNakWithTimeout_nak

    adds r2, r6, #2
    ldrb r1, [r2]
    cmp r1, #0x41          /* A */
    bne waitForAckOrNakWithTimeout_checkNak
    ldrb r1, [r2, #1]
    cmp r1, #0x43          /* C */
    bne waitForAckOrNakWithTimeout_nak
    ldrb r1, [r2, #2]
    cmp r1, #0x4B          /* K */
    bne waitForAckOrNakWithTimeout_nak
    movs r0, #ACK_WAIT_ACK
    b waitForAckOrNakWithTimeout_done

waitForAckOrNakWithTimeout_checkNak:
    ldrb r1, [r2]
    cmp r1, #0x4E          /* N */
    bne waitForAckOrNakWithTimeout_nak
    ldrb r1, [r2, #1]
    cmp r1, #0x41          /* A */
    bne waitForAckOrNakWithTimeout_nak
    ldrb r1, [r2, #2]
    cmp r1, #0x4B          /* K */
    bne waitForAckOrNakWithTimeout_nak
    movs r0, #ACK_WAIT_NAK
    b waitForAckOrNakWithTimeout_done

waitForAckOrNakWithTimeout_nak:
    movs r0, #ACK_WAIT_NAK

waitForAckOrNakWithTimeout_done:
    pop {r4-r8, pc}
.size waitForAckOrNakWithTimeout, . - waitForAckOrNakWithTimeout
