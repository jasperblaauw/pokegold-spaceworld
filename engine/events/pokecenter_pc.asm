; PokemonCenterPC.Jumptable indices
	const_def
	const PCITEM_PLAYERS_PC
	const PCITEM_BILLS_PC
	const PCITEM_OAKS_PC
	const PCITEM_HALL_OF_FAME
	const PCITEM_TURN_OFF

PokemonCenterPC::
; Also used for player's PC.
;
; feature/completion: the demo gated the whole thing behind DEBUG_FIELD_F --
; normal play fell straight through to PC_Demo, the YOROIDORI news page, so the
; bedroom PC (and every Pokémon Center PC) did nothing. Removed that gate, and
; with it the _DEBUG "wasn't connected" branch, which tested the same flag and
; would now refuse in normal play. The demo's no-party refusal is gone too: the
; item storage this menu leads to is useful before you have a Pokémon.
	call PC_PlayBootSound

; Open the player's PC menu
	ld hl, .TurnOnText
	call MenuTextBoxBackup

.DisplayMenu:
	ld hl, .TopMenu
	call LoadMenuHeader
.loop
	xor a
	ld [wActiveBackpackPocket], a
	call OpenMenu
	jr c, .shutdown
	ld a, [wMenuSelection]
	ld hl, .Jumptable
	call CallJumptable
	jr nc, .loop

.shutdown
	call CloseWindow
	ret

.TurnOnText:
	text "Booted up the"
	line "computer!"

	para "Connected to the"
	line "network!"
	prompt

.TopMenu:
	db MENU_BACKUP_TILES
	menu_coords 0, 0, 14, 12
	dw .MenuData
	db 1 ; default item

.MenuData:
	db STATICMENU_CURSOR
	db 0
	dw .WhichPC
	dw PlaceMenuStrings
	dw .MenuStrings

.MenuStrings:
	db "<PLAYER>'s <PC>@"
	db "???'s <PC>@"
	db "OAK's <PC>@"
	db "HALL OF FAME@"
	db "LOG OFF@"

.Jumptable:
	dw PlayersPC
	dw BillsPC
	dw OaksPC
	dw OaksPC
	dw TurnOffPC

.WhichPC:
; PCITEM_BILLS_PC (the box system) is deliberately left out: it is still
; untranslated and boxes do not survive a save, so depositing a Pokémon there
; would lose it. Put it back once M1e lands.
	db 3
	db PCITEM_PLAYERS_PC
	db PCITEM_OAKS_PC
	db PCITEM_TURN_OFF
	db -1

PC_PlayBootSound:
	ld de, SFX_CHOOSE_PC_OPTION
	call PlaySFX
	ret

Unreferenced_NoPokemonText: ; the demo refused to boot the PC without a party
	text "Beep!"
	line "People without"
	cont "# can't use"
	cont "this!"
	text_end
	text_end

PC_Demo: ; unreferenced (see PokemonCenterPC)
	ld de, SFX_CHOOSE_PC_OPTION
	call PlaySFX
	ld hl, .SkarmoryText
	call PrintText
	call TextboxWaitPressAorB_BlinkCursor
	ret

.SkarmoryText:
	text "# JOURNAL"
	line "HOME PAGE"
	cont "<⋯⋯> <⋯⋯> <⋯⋯> <⋯⋯>"

	para "New # found!"
	line "Named YOROIDORI."
	cont "Its wings are as"
	cont "hard as steel."

	para "It will be classed"
	line "not only as a"
	cont "FLYING type but"
	cont "also as a new"
	cont "STEEL type."
	cont "Further research"
	cont "is awaited."
	cont "<⋯⋯>　<⋯⋯>　<⋯⋯>　<⋯⋯>　<⋯⋯>　<⋯⋯>"
	done

BillsPC:
	callfar _BillsPC
	and a
	ret

PlayersPC:
	call _PlayersPC
	and a
	ret

OaksPC:
	ld hl, .TooManyConnectionsText
	call MenuTextBoxBackup
	and a
	ret

.TooManyConnectionsText:
	text "The line is busy."
	line "Can't connect."
	prompt

TurnOffPC:
	ld hl, .ClosedPCText
	call MenuTextBoxBackup
	scf
	ret

.ClosedPCText:
	text "Closed the link to"
	line "the network."
	prompt

_PlayersPC:
	ld hl, .TurnOnText
	call MenuTextBoxBackup
.loop
	call UpdateTimePals
	ld hl, .MenuHeader
	call LoadMenuHeader
	call VerticalMenu
	push af
	call ExitMenu
	pop af
	jr c, .done
	ld a, [wMenuCursorY]
	dec a
	ld hl, .Jumptable
	call CallJumptable
	jr nc, .loop
	ld hl, .ShutDownText
	call MenuTextBoxBackup
.done
	ret

.MenuHeader:
	db MENU_BACKUP_TILES
	menu_coords 0, 0, 10, 10
	dw .MenuStrings
	db   1 ; default selection

.MenuStrings:
	db STATICMENU_CURSOR
	db 4
	db "WITHDRAW@"
	db "DEPOSIT@"
	db "TOSS@"
	db "LOG OFF@"

.Jumptable:
	dw PlayerWithdrawItemMenu
	dw PlayerDepositItemMenu
	dw PlayerTossItemMenu
	dw PlayerLogOffMenu

.TurnOnText:
	text "<PLAYER> connected"
	line "to their own <PC>."

	para "Accessed the item"
	line "storage system!"
	prompt

.ShutDownText:
	text "<PLAYER> closed"
	line "the link to their"
	cont "own <PC>."

	para ""
	done

PlayerWithdrawItemMenu:
	call LoadStandardMenuHeader
	call ClearTileMap
	call UpdateSprites
.loop
	call PCItemsJoypad
	jr c, .quit
	call .Submenu
	jr .loop
.quit
	call Call_ExitMenu
	and a
	ret

.Submenu:
	callfar _CheckTossableItem
	ld a, [wItemAttributeValue]
	and a
	jr z, .AskQuantity
	ld a, 1
	ld [wItemQuantity], a
	jr .Withdraw

.AskQuantity:
	ld hl, .HowManyToWithdrawText
	call MenuTextBox
	callfar SelectQuantityToToss
	call ExitMenu
	call ExitMenu
	jr c, .done

.Withdraw:
	ld hl, wNumPCItems
	ld a, [wItemIndex]
	call TossItem
	ld hl, wNumBagItems
	call ReceiveItem
	jr nc, .PackFull
	predef LoadItemData
	ld hl, .WithdrewItemsText
	call MenuTextBoxBackup
	ret

.PackFull:
	ld hl, .NoRoomWithdrawText
	call MenuTextBoxBackup
	ld hl, wNumPCItems
	call ReceiveItem
	ret

.done
	ret

.HowManyToWithdrawText:
	text "Withdraw how many?"
	done

.WithdrewItemsText:
	text_from_ram wStringBuffer2
	text " x@"
	deciram wItemQuantity, 1, 2
	text_start
	line "withdrawn."
	prompt

.NoRoomWithdrawText:
	text "There's no room to"
	line "withdraw it!"
	prompt

PlayerTossItemMenu:
	call LoadStandardMenuHeader
	call ClearTileMap
	call ClearSprites
	ld hl, wStateFlags
	res SPRITE_UPDATES_DISABLED_F, [hl]
	call UpdateSprites
.loop
	call PCItemsJoypad
	jr c, .quit
	ld de, wNumPCItems
	callfar TryTossItem
	jr .loop
.quit
	ld hl, wStateFlags
	set SPRITE_UPDATES_DISABLED_F, [hl]
	call Call_ExitMenu
	and a
	ret

PlayerLogOffMenu:
	scf
	ret

PlayerDepositItemMenu:
	call .CheckItemsInBag
	ret c
	call LoadStandardMenuHeader
	callfar GetPocket2Status
	callfar DrawBackpack
.loop
	callfar BackpackLoop
	jr c, .quit
	call .TryDepositItem
	jr .loop
.quit
	call ClearPalettes
	ld hl, wStateFlags
	set SPRITE_UPDATES_DISABLED_F, [hl]
	call Call_ExitMenu
	and a
	ret

.CheckItemsInBag:
	callfar CheckItemsQuantity
	ret nc

; no item to deposit
	ld hl, .NoItemsText
	call MenuTextBoxBackup
	scf
	ret

.NoItemsText:
	text "You don't have a"
	line "single item!"
	prompt

.TryDepositItem:
	callfar CheckItemMenu
	ld a, [wItemAttributeValue]
	ld hl, .Jumptable
	jp CallJumptable

.Jumptable:
	dw .Depositable
	dw .NotDepositable
	dw .BallNotDepositable
	dw .SwapPockets
	dw .Depositable
	dw .Depositable
	dw .Depositable

.NotDepositable:
	ld hl, .CantDepositText
	call MenuTextBoxBackup
	ret

.CantDepositText:
	text "<TM>s can't be"
	line "deposited!"
	prompt

.BallNotDepositable:
	ld hl, .CantDepositBallText
	call MenuTextBoxBackup
	ret

.CantDepositBallText:
	text "The BALL HOLDER"
	line "can't be stored!"
	prompt

.SwapPockets:
	callfar FlipPocket2Status
	xor a
	ld [wSelectedSwapPosition], a
	ret

.Depositable:
	call .DepositItem
	ret

.DepositItem:
	callfar _CheckTossableItem
	ld a, [wItemAttributeValue]
	and a
	jr z, .AskQuantity
	ld a, 1
	ld [wItemQuantity], a
	jr .ContinueDeposit

.AskQuantity:
	ld hl, .HowManyDepositText
	call MenuTextBox
	callfar SelectQuantityToToss
	push af
	call ExitMenu
	call ExitMenu
	pop af
	jr c, .DeclinedToDeposit

.ContinueDeposit:
	ld hl, wNumBagItems
	ld a, [wItemIndex]
	call TossItem
	ld hl, wNumPCItems
	call ReceiveItem
	jr nc, .NoRoomInPC
	predef LoadItemData
	ld hl, .DepositItemsText
	call MenuTextBoxBackup
	ret

.NoRoomInPC:
	ld hl, .NoRoomDepositText
	call MenuTextBoxBackup
	ld hl, wNumBagItems
	call ReceiveItem
	ret

.DeclinedToDeposit:
	and a
	ret

.HowManyDepositText:
	text "Deposit how many?"
	done

.DepositItemsText:
	text_from_ram wStringBuffer2
	text " x@"
	deciram wItemQuantity, 1, 2
	text_start
	line "deposited."
	prompt

.NoRoomDepositText:
	text "The <PC> is full."
	line "Can't deposit any"
	cont "more!"
	prompt

PCItemsJoypad:
	ld hl, .MenuHeader
	call CopyMenuHeader
	ld a, [wBackpackAndKeyItemsCursor]
	ld [wMenuCursorPosition], a
	ld a, [wBackpackAndKeyItemsScrollPosition]
	ld [wMenuScrollPosition], a
	call ScrollingMenu
	ld a, [wMenuScrollPosition]
	ld [wBackpackAndKeyItemsScrollPosition], a
	ld a, [wMenuCursorY]
	ld [wBackpackAndKeyItemsCursor], a
	ld a, [wMenuJoypad]
	cp PAD_B
	jr z, .b_button
	cp PAD_A
	jr z, .a_button
	cp PAD_SELECT
	jr z, .select
	jr .next
.select
	callfar SwitchItemsInBag
	jp .next
.next
	jp PCItemsJoypad
.a_button
	callfar ScrollingMenu_ClearLeftColumn
	call PlaceHollowCursor
	and a
	ret
.b_button
	scf
	ret

.MenuHeader:
	db MENU_BACKUP_TILES
	menu_coords 4, 1, 19, 10
	dw .MenuData
	db  1 ; default selection

.MenuData:
	db SCROLLINGMENU_ENABLE_SELECT | SCROLLINGMENU_ENABLE_FUNCTION3 | SCROLLINGMENU_ENABLE_RIGHT | SCROLLINGMENU_ENABLE_LEFT
	db 4, 8 ; rows, columns
	db SCROLLINGMENU_ITEMS_QUANTITY ; type
	dbw 0, wNumPCItems
	dba PlaceMenuItemName
	dba PlaceMenuItemQuantity
	dba UpdateItemDescription

; Leftover menu data for a Gen I-styled deposit menu (with the addition of the item's description)
.UnusedDepositMenuHeader:
	db MENU_BACKUP_TILES
	menu_coords 4, 1, 19, 10
	dw .UnusedDepositMenuData
	db  1 ; default selection

.UnusedDepositMenuData:
	db SCROLLINGMENU_ENABLE_SELECT | SCROLLINGMENU_ENABLE_FUNCTION3 | SCROLLINGMENU_ENABLE_RIGHT | SCROLLINGMENU_ENABLE_LEFT
	db 4, 8 ; rows, columns
	db SCROLLINGMENU_ITEMS_QUANTITY ; type
	dbw 0, wItems
	dba PlaceMenuItemName
	dba PlaceMenuItemQuantity
	dba UpdateItemDescription
