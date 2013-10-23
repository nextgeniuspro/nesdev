; Load 32 bytes (background and spite, 1st background) of palette from address
; PARAM1 - high byte of palette address
; PARAM2 - low byte of palette address
; Example: Loadpalette HIGH(palette), LOW(palette)
Loadpalette .macro
  BIT $2002             
  LDA #$3F              ; set PPU working address 3F00 - palette 
  STA $2006             
  LDA #$00
  STA $2006             
  LDX #$00              ; reset counter
Loadpaletteloop\@:
  LDA (\1 << 8 | \2), x        ; load data from address (high byte PARAM1 and low byte PARAM2 + the value in x)
  STA $2007             
  INX                   
  CPX #$20              ; Compare X to 32, looping if not equal
  BNE Loadpaletteloop\@
  .endm



; Shorthand, just put 1 tile from param 1 to video memory
; PARAM1 - Tile number in Name Table
; Example of using: Drawtile #$24
Drawtile .macro
  LDA \1
  STA $2007
  .endm



; Clear background
; NOPARAM
Clearscreen .macro
  LDA $2002
  LDA #$20
  STA $2006 
  LDA #$00
  STA $2006
  LDA #$24
  LDY #$00
Clearscreenrowloop\@:
  LDX #$00
Clearscreencolloop\@:
  STA $2007
  INX
  CPX #$20
  BNE Clearscreencolloop\@
  INY
  CPY #$1D
  BNE Clearscreenrowloop\@
  LDA #$00
  STA $2006
  STA $2006
  .endm