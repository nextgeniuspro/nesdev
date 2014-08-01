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

Delay .macro
  Del \1
  Del \1
  Del \1
  Del \1
  Del \1
  Del \1
  Del \1
  Del \1
  Del \1
  Del \1
  Del \1
  .endm

Del .macro
  LDX #HIGH(\1)
  LDY #LOW(\1)
Loop1\@:
  DEX
  CPX #$00
  BNE Loop1\@
Loop2\@:  
  DEY
  CPY #$00
  BNE Loop2\@
  .endm

; Store registers values to stack
PushCpuState .macro
  PHA
  TXA
  PHA
  TYA
  PHA
  .endm

; Restore values from stack to registers
PopCpuState .macro
  PLA
  TAY
  PLA
  TAX
  PLA
  .endm

; Copy one value from Param1 to Param2, register A saves to stack
; PARAM1 - source
; PARAM2 - destination
MemCpySafe .macro
  PHA
  LDA \1
  STA \2
  PLA
  .endm 

; Copy one value from Param1 to Param2, without safe register A value
; PARAM1 - source
; PARAM2 - destination
MemCpy .macro
  LDA \1
  STA \2
  .endm