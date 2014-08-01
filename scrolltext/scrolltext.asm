  .inesprg 1   ; 1x 16KB PRG code
  .ineschr 1   ; 1x CHR bank
  .inesmir 0   ; mirroring type 0
  .inesmap 0   ; memory mapper NROM

  .include "macros_video.asm"
  .include "macros_system.asm"

;;;;;;;;;;;;;;;

  .rsset $0000     ; set pointers in zero page
TMP        .rs 1
positionX  .rs 1   ; pointer variables are declared in RAM
positionY  .rs 1   ; low byte first, high byte after
direction  .rs 1
    
  .bank 0
  .org $C000 

; Draws text Hello World, param1 and param2 specify the position
; PARAM1 - PPU Name Table Address ($2000, $2400, $2800, $2C00)
; PARAM2 - X position
; PARAM3 - Y position
; Example: DrawHello $20, #5, #7
DrawHello .macro
  MoveTo \1, \2, \3

  DrawTile kEmptyCell     ;  
  DrawTile #$11           ; H
  DrawTile #$0E           ; E
  DrawTile #$15           ; L
  DrawTile #$15           ; L
  DrawTile #$18           ; 0
  DrawTile kEmptyCell     ;  
  DrawTile #$20           ; W
  DrawTile #$18           ; O
  DrawTile #$1B           ; R
  DrawTile #$15           ; L
  DrawTile #$0D           ; D  
  DrawTile kEmptyCell     ;  

  LDA #$00
  STA $2006
  STA $2006
  .endm

InitializeConstants .macro
  MemCpy kStartTextPositionX, positionX 
  MemCpy kStartTextPositionY, positionY
  MemCpy kStartTextDirectionX, direction
  .endm

ScrollTextPosition .macro
  LDA direction
  CMP kRightTextDirectionX
  BEQ ShiftRight\@
ShiftLeft\@:
  DEC positionX
  LDA positionX
  CMP kLeftTextPositionX
  BPL Exit\@              ; if less or equal than kLeftTextPositionX
  BEQ Exit\@
  LDA kRightTextDirectionX
  STA direction
  JMP Exit\@
ShiftRight\@:
  INC positionX
  LDA positionX
  CMP kRightTextPositionX
  BMI Exit\@              ; if more or equal than kRightTextPositionX
  BEQ Exit\@
  LDA kLeftTextDirectionX
  STA direction
Exit\@:
  .endm

RESET:
  SEI          ; disable IRQs
  CLD          ; disable decimal mode
  
  PPUInit
  ClearScreen kVideoPage1, kEmptyCell
  LoadPalette kPalette 

  InitializeConstants

MainLoop:
  Delay #$FFFF
  Delay #$FFFF
  Delay #$FFFF
  Delay #$FFFF
  ScrollTextPosition

  VBlankWait
  ; Draw scene here
  DrawHello kVideoPage1, positionX, positionY
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
kPalette:
  .db $0F,$21,$19,$11,  $22,$36,$17,$0F,  $22,$30,$21,$0F,  $22,$27,$17,$0F   ;;background palette
  .db $0F,$21,$19,$11,  $22,$36,$17,$0F,  $22,$30,$21,$0F,  $22,$27,$17,$0F   ;;sprite palette

kVideoPage1:
  .db $20
kVideoPage2:
  .db $24
kVideoPage3:
  .db $28
kVideoPage4:
  .db $2C

;; Constants
kStartTextPositionX:
  .db 7
kLeftTextPositionX:
  .db 0
kRightTextPositionX:
  .db 19
kStartTextPositionY:
  .db 7

kStartTextDirectionX:
  .db 0
kLeftTextDirectionX:
  .db 0
kRightTextDirectionX:
  .db 1

kEmptyCell:
  .db $24

  .bank 2
  .org $8000
  .incbin "mario.chr"   ;includes 8KB graphics file from SMB1
