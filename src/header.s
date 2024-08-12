.include "header.inc"

.segment "HEADER"
.byte "NES", $1A ; iNES Header
.byte 2 ; Number of 16KB PRG sections
.byte 1 ; Number of 8KB CHR sections
.byte "00" ; Mapper information
.byte "00000000" ; iNES 2.0 information
