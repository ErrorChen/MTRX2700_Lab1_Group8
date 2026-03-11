.syntax unified
.cpu cortex-m4
.fpu fpv4-sp-d16
.thumb

/* Compatibility wrapper.
 *
 * Constants were moved to Src/platform_defs.s as part of modular refactor.
 * This file remains to preserve existing generated build-file expectations.
 */

#include "platform_defs.s"
