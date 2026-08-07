; name lengths
DEF NAME_LENGTH          EQU 11 ; English
DEF PLAYER_NAME_LENGTH   EQU 8 ; English: 7 usable + terminator (was 6, JP)
DEF NAME_LENGTH_JAPANESE EQU 6 ; original prototype width (5 usable + terminator)
DEF BOX_NAME_LENGTH      EQU 9
DEF MON_NAME_LENGTH      EQU 11 ; English: 10 usable + terminator (was 6, JP)
; PC box storage (wBox in WRAM, sBox in SRAM) deliberately stays at the original
; Japanese name width. Flat 8KB WRAM (no CGB WRAM banking here) has no room for a
; full 30-mon box at English widths, and box save/persistence is deferred anyway
; (M1e: Dummy_SaveBox is stubbed, boxes are unreachable in the current slice).
; When M1e implements boxes, widen these AND solve the WRAM/SRAM budget (ideally
; load one box at a time like retail) and the deposit/withdraw copy lengths.
DEF BOX_MON_NAME_LENGTH  EQU NAME_LENGTH_JAPANESE ; boxed-mon nickname width
DEF BOX_MON_OT_LENGTH    EQU NAME_LENGTH_JAPANESE ; boxed-mon OT-name width
DEF TYPE_NAME_LENGTH     EQU 5
DEF MOVE_NAME_LENGTH     EQU 13 ; English (was 8); 12 usable + terminator
DEF ITEM_NAME_LENGTH     EQU 13 ; English (was 11); also the generic GetName copy width
DEF TRAINER_CLASS_NAME_LENGTH EQU 13 ; English (was 11)

; GetName types (see home/names.asm)
	const_def 1
	const MON_NAME              ; 01
	const MOVE_NAME             ; 02
	const DUMMY_NAME            ; 03
	const ITEM_NAME             ; 04
	const PARTY_OT_NAME         ; 05
	const ENEMY_OT_NAME         ; 06
	const TRAINER_NAME          ; 07
	const MOVE_DESC_NAME_BROKEN ; 08

; see home/text.asm
DEF BORDER_WIDTH   EQU 2
DEF TEXTBOX_WIDTH  EQU SCREEN_WIDTH
DEF TEXTBOX_INNERW EQU TEXTBOX_WIDTH - BORDER_WIDTH
DEF TEXTBOX_HEIGHT EQU 6
DEF TEXTBOX_INNERH EQU TEXTBOX_HEIGHT - BORDER_WIDTH
DEF TEXTBOX_X      EQU 0
DEF TEXTBOX_INNERX EQU TEXTBOX_X + 1
DEF TEXTBOX_Y      EQU SCREEN_HEIGHT - TEXTBOX_HEIGHT
DEF TEXTBOX_INNERY EQU TEXTBOX_Y + 2

; PrintNumber, PrintBCDNumber bit flags (see home/print_num.asm and home/print_bcd.asm)
	const_def 6
	shift_const PRINTNUM_LEFTALIGN    ; 6
	shift_const PRINTNUM_LEADINGZEROS ; 7

; character sets (see constants/charmap.asm)
DEF FIRST_REGULAR_TEXT_CHAR EQU $60
DEF FIRST_HIRAGANA_DAKUTEN_CHAR EQU $20
