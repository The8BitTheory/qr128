;masks
; this generates the xor masks for qr-codes
; and writes them to memory

; bit 7: 1=untouched, 0=already touched
; bit 6: 0=content-data module, 1=alignment or timing
; bit 5: unused
; bit 4,3,2: mask pattern data
; bit 1: 0=visible module, 1=mask module
; bit 0: 1=dark, 0=light module

; %1.....0. MEANS, THE MODULE SPOT IS UNTOUCHED. CAN BE USED FOR WRITING data
; %0.....0. MEANS, THE MODULE SPOT IS ALREADY WRITTEN. DON'T write data here
; %.1....0. MEANS, IF WRITTEN: THE MODULE SPOT IS A CONTENT-DATA SPOT (mask is applied here)
; %.0....0. MEANS, IF WRITTEN: THE MODULE SPOT IS A FINDER OR ALIGNMENT OR TIMING SPOT (no mask here)
; %..000x1. bit x set means module is set for mask pattern 111
; %..00x01. bit x set means module is set for mask pattern 101
; %..0x001. bit x set means module is set for mask pattern 100
; %..x0001. bit x set means module is set for mask pattern 001
; %......01 MEANS THIS IS A DARK MODULE.
; %......00 MEANS THIS IS A LIGHT MODULE.


*= $1300


