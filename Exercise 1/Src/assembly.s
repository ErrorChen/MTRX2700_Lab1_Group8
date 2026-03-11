.syntax unified
.thumb

.global main
.thumb_func

.type main, %function

.data
MyString: .asciz "hello"
MsgBufferC: .space 64
MsgBufferD: .space 64

.text

main:
    LDR   R1, =MyString
    BL    str_len

    LDR   R1, =MyString
    MOVS  R2, #1
    BL    str_case

    LDR   R0, =MyString
    LDR   R1, =MsgBufferC
    BL    build_msg_c

    LDR   R0, =MyString
    LDR   R1, =MsgBufferD
    BL    build_msg_d

    LDR   R1, =MsgBufferD
    BL    verify_bcc

stop:
    B     stop

str_len:
    MOV   R0, R1
    MOVS  R2, #0

len_loop:
    LDRB  R3, [R0], #1
    CMP   R3, #0
    BEQ   len_done
    ADDS  R2, R2, #1
    B     len_loop

len_done:
    BX    LR

str_case:
    MOV   R0, R1
    MOV   R4, R2

case_loop:
    LDRB  R3, [R0]
    CMP   R3, #0
    BEQ   case_done
    CMP   R4, #0
    BEQ   make_lower

make_upper:
    CMP   R3, #'a'
    BLT   store_char
    CMP   R3, #'z'
    BGT   store_char
    SUBS  R3, R3, #0x20
    B     store_char

make_lower:
    CMP   R3, #'A'
    BLT   store_char
    CMP   R3, #'Z'
    BGT   store_char
    ADDS  R3, R3, #0x20

store_char:
    STRB  R3, [R0]
    ADDS  R0, R0, #1
    B     case_loop

case_done:
    BX    LR

build_msg_c:
    PUSH  {R4-R6, LR}
    MOV   R4, R0
    MOV   R5, R1
    MOV   R1, R4
    BL    str_len
    MOV   R6, R2
    ADDS  R2, R6, #3
    MOVS  R3, #0x02
    STRB  R3, [R5], #1
    UXTB  R3, R2
    STRB  R3, [R5], #1

copy_c:
    CMP   R6, #0
    BEQ   etx_c
    LDRB  R3, [R4], #1
    STRB  R3, [R5], #1
    SUBS  R6, R6, #1
    B     copy_c

etx_c:
    MOVS  R3, #0x03
    STRB  R3, [R5]
    POP   {R4-R6, PC}

bcc_xor:
    MOV   R0, R1
    MOVS  R3, #0
    MOV   R4, R2

bcc_loop:
    CMP   R4, #0
    BEQ   bcc_done
    LDRB  R2, [R0], #1
    EORS  R3, R3, R2
    SUBS  R4, R4, #1
    B     bcc_loop

bcc_done:
    UXTB  R3, R3
    BX    LR

build_msg_d:
    PUSH  {R4-R7, LR}
    MOV   R4, R0
    MOV   R5, R1
    MOV   R7, R1
    MOV   R1, R4
    BL    str_len
    MOV   R6, R2
    ADDS  R2, R6, #4
    MOVS  R0, #0x02
    STRB  R0, [R5], #1
    UXTB  R0, R2
    STRB  R0, [R5], #1

copy_d:
    CMP   R6, #0
    BEQ   etx_d
    LDRB  R0, [R4], #1
    STRB  R0, [R5], #1
    SUBS  R6, R6, #1
    B     copy_d

etx_d:
    MOVS  R0, #0x03
    STRB  R0, [R5], #1
    SUBS  R6, R2, #1
    MOV   R1, R7
    MOV   R2, R6
    BL    bcc_xor
    STRB  R3, [R5]
    ADDS  R2, R6, #1
    POP   {R4-R7, PC}

verify_bcc:
    PUSH  {R4, LR}
    BL    bcc_xor
    CMP   R3, #0
    BEQ   checksum_ok
    MOVS  R3, #0
    POP   {R4, PC}

checksum_ok:
    MOVS  R3, #1
    POP   {R4, PC}
