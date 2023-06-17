class input

const CONTROLLER_1 $4016
const CONTROLLER_2 $4017
const BTN_A			%10000000
const BTN_B			%01000000
const BTN_SELECT	%00100000
const BTN_START		%00010000
const BTN_U			%00001000
const BTN_D			%00000100
const BTN_L			%00000010
const BTN_R			%00000001

; 3 for multiplayer
;	0 - working vars
;	1 - player 1
;	2 - player 2
; current one gets copied into 0 when updating that monkey
var [3] buttonsDown ; ABsSUDLR
var [3] buttonsPressed

; get controller input from player 1 and store it in buttonsDown
	; modifies:
	;	x
Read:
	; from http://wiki.nesdev.com/w/index.php/Controller_reading:
	; "Writing 1 to $4016 causes the register to fill its parallel inputs from the buttons currently held."
	; "Writing 0 to $4016 returns it to serial mode, waiting to be read out one bit at a time."
	lda #$01
	sta CONTROLLER_1
	lsr a ; clever byte-saving trick from nesdev.org
	sta CONTROLLER_1
	
	ldx #8
	.loop:
		lda CONTROLLER_1
		lsr a
		rol buttonsDown+1
		lda CONTROLLER_2
		lsr a
		rol buttonsDown+2
		dex
		bne .loop
	.end: rts