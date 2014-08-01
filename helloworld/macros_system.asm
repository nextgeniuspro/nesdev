PPUInit .macro
  LDA #%10010000   ; enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
  STA $2000
  LDA #%00011110   ; enable sprites, enable background, no clipping on left side
  STA $2001
  .endm

; Wait for vertical blanking
VBlankWait .macro	
VWait\@:
  BIT $2002
  BPL VWait\@
  .endm

