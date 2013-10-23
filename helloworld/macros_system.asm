; Wait for vertical blanking
; NOPARAM
VBlankWait .macro
Vwait\@:
  LDA $2002
  BPL Vwait\@
  .endm
