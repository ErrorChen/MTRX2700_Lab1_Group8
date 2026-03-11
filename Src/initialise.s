.syntax unified
.cpu cortex-m4
.fpu fpv4-sp-d16
.thumb

/* Compatibility wrapper.
 *
 * Initialisation logic was moved to Src/board_init.s as part of modular
 * architecture cleanup. This file is intentionally non-owning and kept only
 * so legacy generated build inputs remain valid.
 */

.section .text.initialise_wrapper, "ax", %progbits
.align 2
