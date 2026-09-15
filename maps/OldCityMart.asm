	map_attributes OldCityMart, OLD_CITY_MART

OldCityMart_MapEvents::
	dw $4000 ; unknown

	def_warp_events
	warp_event  4,  7, OLD_CITY, 8, 51
	warp_event  5,  7, OLD_CITY, 8, 51

	def_bg_events
	bg_event  0,  7, 1

	def_object_events
	object_event  1,  3, SPRITE_CLERK, SPRITEMOVEFN_TURN_RIGHT, 0, 0, -1, -1, 0, 0, 0, 0, 0, 0
	object_event 10,  5, SPRITE_YOUNGSTER, SPRITEMOVEFN_RANDOM_WALK_X, 2, 0, -1, -1, 0, 0, 0, 0, 0, 0
	object_event  4,  1, SPRITE_COOLTRAINER_M, SPRITEMOVEFN_TURN_UP, 0, 0, -1, -1, 0, 0, 0, 0, 0, 0

OldCityMart_Blocks::
INCBIN "maps/Mart.blk"

	map_generic_scriptloader
	map_generic_script_pointers
	map_generic_script

	map_generic_npc_ids

OldCityMartSignPointers:
	dw OldCityMartSignText

OldCityMartSignText:
	ld hl, OldCityMartTextString1
	call OpenTextbox
	ret

OldCityMartTextString1:
	text "OLD CITY MART"
	line "Buy what you need"
	cont "before you go!"
	done

OldCityMart_TextPointers::
	dw OldCityMartNPCText1
	dw OldCityMartNPCText2
	dw OldCityMartNPCText3

; feature/completion: the first real, working mart -- shares RunMartBuyMenu
; (engine/debug/field/pokemart_menu.asm) with the debug field mart rather
; than duplicating the scrolling-list/quantity/purchase UI. Structure mirrors
; FieldDebug_PokemartMenu/.DoPokemartMenu: a welcome box that fully closes
; (prompt), then a separate menu-drawing routine -- not one continuous
; start_asm-nested text stream, since `prompt` ends the box and returns to
; the caller rather than falling through to more text data.
OldCityMartNPCText1:
	ld hl, OldCityMartTextString2
	call OpenTextbox
	call OldCityMartMenu
	ret

OldCityMartTextString2:
	text "Welcome to the"
	line "POKéMON MART!"
	prompt

OldCityMartMenu:
	call LoadStandardMenuHeader
; The welcome box was an overworld textbox; closing it (TextboxCleanup ->
; ReloadObjectGFX -> LoadWalkingSpritesGFX) reloaded the walking-sprite frames
; over the text font in vFont, so drawing the menu now would render the prompt
; and the BUY list as sprite garbage. Re-upload the font first. The font extras
; and box-frame tiles live in vChars2 and survive, so only the main font needs
; restoring; RunMartBuyMenu inherits it and never clobbers it.
	call LoadFont
	callfar PlaceMoneyTopRight
	ld hl, OldCityMartTextString3
	call PrintText
	ld hl, .MenuHeader
	call CopyMenuHeader
	call VerticalMenu
	push af
	call ExitMenu
	pop af
	jr c, .goodbye
	ld a, [wMenuCursorY]
	cp 1
	jr nz, .goodbye
; OldCityMartItemList lives in bank $3f (data/debug/field_debug_pokemart_items.asm),
; NOT here in the maps bank ($25): DebugMart_LoadItems reads it with `ld a,[de]` after
; callfar has mapped bank $3f, so the list must be resident in $3f at read time. Loading
; its address here with `ld de` is bank-agnostic and fine.
	ld de, OldCityMartItemList
	callfar RunMartBuyMenu
	jp OldCityMartMenu

.goodbye
	ld hl, OldCityMartTextString4
	call MenuTextBoxBackup
; RunMartBuyMenu ran ClearTileMap + a full-screen menu and LoadFont reloaded the
; text font over the walking-sprite frames in vFont. MenuTextBoxBackup only closes
; the window (restores backed-up tiles); it neither reanchors the map nor reloads
; the object GFX, so returning straight to the overworld left the NPC/player sprites
; drawn from clobbered VRAM (garbage tiles) and stale menu tiles on the map -- the
; glitch cleared only once the start menu forced a full ReanchorMap. CloseText is the
; canonical "done with textboxes, return to overworld" call (== the closetext script
; command): TextboxCleanup reanchors the map + UpdateSprites + ReloadObjectGFX, then
; ClearWindowData/InitToolgearBuffer. The debug field mart never needed this because
; its caller (the field debug menu) reloads the overworld on exit.
	call CloseText
	ret

.MenuHeader:
	db MENU_BACKUP_TILES
	menu_coords 0, 0, 10, 5
	dw .MenuData
	db 1 ; default

.MenuData:
	db STATICMENU_CURSOR
	db 2 ; items
	db "BUY@"
	db "CANCEL@"

OldCityMartTextString3:
	text "What can I do"
	line "for you?"
	done

OldCityMartTextString4:
	text "We hope to see"
	line "you again!"
	prompt

OldCityMartNPCText2:
	ld hl, OldCityMartTextString5
	call OpenTextbox
	ret

OldCityMartTextString5:
	text "This MART sells"
	line "all sorts of"
	cont "handy stuff!"
	done

OldCityMartNPCText3:
	ld hl, OldCityMartTextString6
	call OpenTextbox
	ret

OldCityMartTextString6:
	text "I always stock up"
	line "on POKé BALLS"
	cont "before a trip."
	done
