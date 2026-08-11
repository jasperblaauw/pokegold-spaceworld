DebugMart_ItemList:
; First byte is the item count (see RunMartBuyMenu / OldCityMartItemList). This
; list happened to work before only because ITEM_BICYCLE = 7 = its item count.
	db 8 ; number of items
	db ITEM_BICYCLE
	db ITEM_MOON_STONE
	db ITEM_ANTIDOTE
	db ITEM_BURN_HEAL
	db ITEM_MAX_POTION
	db ITEM_HYPER_POTION
	db ITEM_SUPER_POTION
	db ITEM_POTION
	db -1

; feature/completion: the Old City mart's list MUST live in this bank ($3f, with
; RunMartBuyMenu/DebugMart_LoadItems), not in maps/OldCityMart.asm's bank ($25).
; DebugMart_LoadItems reads the list with `ld a,[de]` while bank $3f is mapped
; (callfar switched to it). A list at a $25 address is read out of bank $3f at the
; same offset -> garbage item count/terminator -> the load loop overruns wCurMartCount
; and corrupts WRAM until it hits a stray $ff (crash). The debug list above only ever
; worked because it was already here. Keep every mart's list in this bank, or pass the
; list's bank and read it far. maps/OldCityMart.asm just references this label.
OldCityMartItemList::
; First byte is the item count; see RunMartBuyMenu / DebugMart_LoadItems.
	db 8 ; number of items
	db ITEM_POKE_BALL
	db ITEM_POTION
	db ITEM_ANTIDOTE
	db ITEM_PARLYZ_HEAL
	db ITEM_AWAKENING
	db ITEM_BURN_HEAL
	db ITEM_ESCAPE_ROPE
	db ITEM_REPEL
	db -1
