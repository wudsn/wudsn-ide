
.include "globals.inc"

.segment "VECTORS"
.addr reset ; NMI: should never occur
.addr reset ; RESET
.addr reset ; IRQ: will only occur with brk
