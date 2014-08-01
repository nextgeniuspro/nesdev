  .inesprg 1   ; 1x 16KB PRG code
  .ineschr 1   ; 1x CHR bank
  .inesmir 0   ; mirroring type 0
  .inesmap 0   ; memory mapper NROM

  .include "macros_video.asm"
  .include "macros_system.asm"


;;;;;;;;;;;;;;;
; Constants

kVideoPage1 = $2000
kVideoPage2 = $2400
kVideoPage3 = $2800
kVideoPage4 = $2C00

kEmptyCell = $24


;;;;;;;;;;;;;;;

  .rsset $0000     ; set pointers in zero page
TMP        .rs 1
    

;;;;;;;;;;;;;;;

  .bank 0
  .org $C000 

; Draws text Hello World, param1 and param2 specify the position
; PARAM1 - PPU Name Table Address ($2000, $2400, $2800, $2C00)
; PARAM2 - X position
; PARAM3 - Y position
; Example: DrawHello $20, #5, #7
DrawHello .macro
  MoveTo \1, \2, \3

  DrawTile #$11           ; H
  DrawTile #$0E           ; E
  DrawTile #$15           ; L
  DrawTile #$15           ; L
  DrawTile #$18           ; 0
  DrawTile #kEmptyCell     ;  
  DrawTile #$20           ; W
  DrawTile #$18           ; O
  DrawTile #$1B           ; R
  DrawTile #$15           ; L
  DrawTile #$0D           ; D  

  LDA #$00
  STA $2006
  STA $2006
  .endm

RESET:
  SEI          ; disable IRQs

  PPUInit
  ClearScreen #kVideoPage1, #kEmptyCell
  LoadPalette pPalette 

MainLoop:
  VBlankWait
  ; Draw scene here
  DrawHello #kVideoPage1, #10, #7
  JMP MainLoop

NMI:
  RTI

;;;;;;;;;;;;;;  
 
  .bank 1
  .org $FFFA     ;first of the three vectors starts here NMI, RESET and IRQ
  .dw NMI        
  .dw RESET      
  .dw 0

  .org $E000
pPalette:
  .db $0F,$21,$19,$11,  $22,$36,$17,$0F,  $22,$30,$21,$0F,  $22,$27,$17,$0F   ;background palette
  .db $0F,$21,$19,$11,  $22,$36,$17,$0F,  $22,$30,$21,$0F,  $22,$27,$17,$0F   ;sprite palette

  .bank 2
  .org $8000
  .incbin "mario.chr"   ;includes 8KB graphics file from SMB1
