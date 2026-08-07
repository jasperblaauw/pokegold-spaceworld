MACRO attr_blk
	db (SGB_ATTR_BLK << 3) + ((\1 * 6) / 16 + 1)
	db \1
ENDM

MACRO attr_blk_data
	db \1 ; which regions are affected
	db \2 + (\3 << 2) + (\4 << 4) ; palette for each region
	db \5, \6, \7, \8 ; x1, y1, x2, y2
ENDM

BlkPacket_Default:
	attr_blk 1
	attr_blk_data %011, 0,0,0, 00,00, 19,17
	ds 8

BlkPacket_GSIntroJigglypuffPikachu:
	attr_blk 1
	attr_blk_data %111, 1,1,0, 00,10, 19,13
	ds 8

BlkPacket_Battle:
	attr_blk 5
	attr_blk_data %111, 2,2,0, 00,12, 19,17
	attr_blk_data %011, 1,1,0, 01,00, 10,03
	attr_blk_data %011, 0,0,0, 10,08, 19,10
	attr_blk_data %011, 2,2,0, 00,04, 08,11
	attr_blk_data %011, 3,3,0, 11,00, 19,07

BlkPacket_StatsScreen:
	attr_blk 1
	attr_blk_data %111, 1,1,0, 00,01, 07,07
	ds 8

BlkPacket_MoveList:
	attr_blk 1
	attr_blk_data %111, 1,1,0, 11,01, 19,02
	ds 8

BlkPacket_Pokedex:
	attr_blk 1
	attr_blk_data %111, 1,1,0, 01,01, 08,08
	ds 8

BlkPacket_SlotMachine:
	attr_blk 5
	attr_blk_data %011, 1,1,0, 00,00, 19,11
	attr_blk_data %011, 2,2,0, 00,04, 19,09
	attr_blk_data %010, 3,3,0, 00,06, 19,07
	attr_blk_data %011, 0,0,0, 04,04, 15,09
	attr_blk_data %011, 0,0,0, 00,12, 19,17

BlkPacket_PartyMenu:
; feature/completion: the per-mon HP-color blocks below shifted down 1 row
; (y1/y2 +1) to match the English-layout row swap in party_menu.asm (the HP
; bar/text now sit 1 row lower than the JP layout). Also fixed their region
; mask %010 (line/border only, so the bar interior was never colored — SGB_
; ApplyPartyMenuHPPals only ever pokes the palette byte, not this mask) to
; %011, matching BlkPacket_Battle's identical pattern (palette values \2=\3=
; health color, \4=0, mask=%011) for the same kind of small filled HP-color
; rect.
	attr_blk 7
	attr_blk_data %111, 0,0,1, 00,00, 02,15 ; widened to row 15: icons are 2 tiles tall, so mon 5's (index*16+26 px) spans tile rows 13-15, past the old y2=12
	attr_blk_data %011, 0,0,0, 12,01, 18,02
	attr_blk_data %011, 0,0,0, 12,03, 18,04
	attr_blk_data %011, 0,0,0, 12,05, 18,06
	attr_blk_data %011, 0,0,0, 12,07, 18,08
	attr_blk_data %011, 0,0,0, 12,09, 18,10
	attr_blk_data %011, 0,0,0, 12,11, 18,12
	ds 4

BlkPacket_TrainerGear:
	attr_blk 1
	attr_blk_data %111, 0,0,1, 00,00, 19,02
	ds 8

BlkPacket_TitleScreen:
	attr_blk 1
	attr_blk_data %111, 0,0,1, 00,00, 19,05
	ds 8
