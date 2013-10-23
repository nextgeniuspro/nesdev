  .inesprg 1   ; 1x 16KB PRG code
  .ineschr 1   ; zero CHR bank
  .inesmir 0   ; mirroring type 0
  .inesmap 0   ; memory mapper NROM

  .include "macros_video.asm"
  .include "macros_system.asm"

;;;;;;;;;;;;;;;

    
  .bank 0
  .org $C000 

; Draw text Hello World, param1 and param2 specify the position
; PARAM1 - high byte of base address in VRAM
; PARAM2 - low byte of base address in VRAM
; Example of using: DrawHello #$26, #$02
DrawHello .macro
  LDA \1
  STA $2006
  LDA \2
  STA $2006

  Drawtile #$11           ; H
  Drawtile #$0E           ; E
  Drawtile #$15           ; L
  Drawtile #$15           ; L
  Drawtile #$18           ; 0
  Drawtile #$24           ;  
  Drawtile #$20           ; W
  Drawtile #$18           ; O
  Drawtile #$1B           ; R
  Drawtile #$15           ; L
  Drawtile #$0D           ; D  

  LDA #$00
  STA $2006
  STA $2006
  .endm

RESET:
  SEI          ; disable IRQs
  CLD          ; disable decimal mode
  LDX #$40
  STX $4017    ; disable APU frame IRQ
  LDX #$FF
  TXS          ; Set up stack
  INX          ; now X = 0
  STX $2000    ; disable NMI
  STX $2001    ; disable rendering
  STX $4010    ; disable DMC IRQs

  VBlankWait

  Clearscreen
  Loadpalette HIGH(palette), LOW(palette)
  DrawHello #$25, #$8A


  LDA #%10010000   ; enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
  STA $2000
  LDA #%00011110   ; enable sprites, enable background, no clipping on left side
  STA $2001

Forever:
  JMP Forever ;jump back to Forever, infinite loop

NMI:
  RTI

;;;;;;;;;;;;;;  
 
  .bank 1
  .org $FFFA     ;first of the three vectors starts here NMI, RESET and IRQ
  .dw NMI        
  .dw RESET      
  .dw 0

  .org $E000
palette:
  .db $0F,$21,$19,$11,  $22,$36,$17,$0F,  $22,$30,$21,$0F,  $22,$27,$17,$0F   ;;background palette
  .db $0F,$21,$19,$11,  $22,$36,$17,$0F,  $22,$30,$21,$0F,  $22,$27,$17,$0F   ;;sprite palette

  .bank 2
  .org $0000
  .incbin "mario.chr"   ;includes 8KB graphics file from SMB1
