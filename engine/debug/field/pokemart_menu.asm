FieldDebug_PokemartMenu:
	ld hl, DebugMart_WelcomeText
	call MenuTextBox
	call ExitMenu
	call .DoPokemartMenu
	ld a, FIELDDEBUG_RETURN_REOPEN
	ret

.DoPokemartMenu:
	call LoadStandardMenuHeader
	callfar PlaceMoneyTopRight
	ld hl, DebugMart_PokemartMenuText
	call PrintText
	ld hl, .MenuHeader
	call CopyMenuHeader
	call VerticalMenu
	push af
	call ExitMenu
	pop af
	jr c, .exit_menu
	ld a, [wMenuCursorY]
	dec a
	ld hl, .MenuJumptable
	call CallJumptable
	jr nc, .DoPokemartMenu
	ret

.exit_menu
	ld hl, DebugMart_GoodbyeText
	call MenuTextBoxBackup
	scf
	ret

.MenuHeader:
	db MENU_BACKUP_TILES
	menu_coords 0, 0, 10, 8
	dw .MenuData
	db 1 ; default

.MenuData:
	db STATICMENU_CURSOR
	db 3 ; items
	db "BUY@"
	db "SELL@"
	db "GOODBYE@"

.MenuJumptable:
	dw DebugMart_Buy
	dw DebugMart_Sell
	dw .exit_menu

DebugMart_BuyMenuHeader:
	db MENU_BACKUP_TILES
	menu_coords 1, 3, 19, 11
	dw .BuyMenuParams
	db 1 ; default

.BuyMenuParams:
	db STATICMENU_WRAP
	db 4, 8 ; rows, columns
	db SCROLLINGMENU_ITEMS_NORMAL
	dbw 0, wCurMartCount
	dba PlaceMenuItemName
	dba .PrintAmount
	dba UpdateItemDescription

.PrintAmount:
	ld a, [wScrollingMenuCursorPosition]
	ld c, a
	ld b, 0
	ld hl, wBattleMenuRows
	add hl, bc
	add hl, bc
	add hl, bc
	push de
	ld d, h
	ld e, l
	pop hl
; English writes the currency symbol before the figure; the six digits still
; end on the same column as before.
	ld [hl], '¥'
	inc hl
	ld c, 3 | PRINTNUM_LEADINGZEROS
	call PrintBCDNumber
	ret

DebugMart_WelcomeText:
	text "Welcome to the"
	line "FRIENDLY SHOP!"
	prompt

DebugMart_PokemartMenuText:
	text "What can I do"
	line "for you?"
	done

DebugMart_GoodbyeText:
	text "We hope to see"
	line "you again!"
	prompt

DebugMart_Buy:
	ld de, DebugMart_ItemList
	call RunMartBuyMenu
	and a
	ret

RunMartBuyMenu::
; feature/completion: pulled out of DebugMart_Buy so a real town mart
; (maps/OldCityMart.asm) can share the same scrolling-list/quantity/purchase
; UI instead of duplicating it -- ROM is at 100% capacity, and this was the
; only mart implementation to begin with. Also finishes the purchase itself,
; which this never did before (see .UnderDevelopmentText, now gone): the
; debug field mart could browse and pick a quantity but never actually buy.
; IN: de = pointer to a -1-terminated list of item IDs to sell.
; feature/completion: disable overworld tile animation while this full-screen menu
; is up, then restore it -- the same save/xor/restore every other full-screen menu
; does (trainer card, party, pokedex, ...). Standard hygiene for a menu opened over a
; live overworld. (The "BUY hangs the game" crash was NOT this or any VBlank/STAT
; race -- it was a cross-bank read of the caller's item list corrupting WRAM; see
; DebugMart_LoadItems below and OldCityMartItemList's bank note. Keeping this because
; it is correct regardless, not because it fixes the crash.)
	ldh a, [hMapAnims]
	push af
	xor a
	ldh [hMapAnims], a
	call DebugMart_LoadItems
	call LoadStandardMenuHeader
	call ClearTileMap
.buy_loop
	call .BuyMenu
	jr nc, .buy_loop
	call ExitMenu
	pop af
	ldh [hMapAnims], a
	ret

.BuyMenu:
	call UpdateSprites
	ld hl, DebugMart_BuyMenuHeader
	call CopyMenuHeader
	call ScrollingMenu
	ld a, [wMenuJoypad]
	cp PAD_B
	jr z, .cancel_buy
; Only A confirms a purchase. ScrollingMenu only ever returns A or B here (SELECT/
; START are filtered out unless their enable flags are set), so this is a guard --
; but the original `jr z, .buy_item` jumped to the very next line, buying on any key.
	cp PAD_A
	jr nz, .cancel_buy
.buy_item
	ld a, MAX_ITEM_STACK
	ld [wItemQuantityBuffer], a
	ld hl, .HowManyText
	call PrintText
	callfar SelectQuantityToBuy
	call ExitMenu
	jr c, .done
	predef LoadItemData
	ld hl, .ConfirmPurchaseText
	call PrintText
	call YesNoBox
	jr c, .done

; hMoneyTemp (3 bytes, MSB-first, set by SelectQuantityToBuy's live price *
; quantity) vs wMoney, same layout. CompareBytes (home/util.asm) walks both
; MSB-first and returns on the first differing byte; carry set there means
; wMoney's byte was smaller, i.e. not enough money.
	ld hl, hMoneyTemp
	ld de, wMoney
	ld c, 3
	call CompareBytes
	jr c, .not_enough_money

; Give the item before charging for it, so a full pocket costs nothing.
; Always pass wNumBagItems: _ReceiveItem (engine/items/inventory.asm) routes by the
; item's pocket attribute, so a POKé BALL dispatches to the ball pocket (ReceiveBall)
; on its own. The old code hand-routed balls to wNumBallItems, which made
; DoesHLEqualwNumBagItems fail -> the ball fell through to PutItemInPocket (regular-
; item format) and never landed in the ball pocket (money charged, ball vanished).
	ld hl, wNumBagItems
	call ReceiveItem
	jr nc, .pack_full

	ld hl, hMoneyTemp + 2
	ld de, wMoney + 2
	ld c, 3
	and a
.pay_loop
	ld a, [de]
	sbc a, [hl]
	ld [de], a
	dec de
	dec hl
	dec c
	jr nz, .pay_loop

	ld hl, .ThanksText
	call MenuTextBoxBackup
	jr .done

.not_enough_money
	ld hl, .NotEnoughMoneyText
	call MenuTextBoxBackup
	jr .done

.pack_full
	ld hl, .PackFullText
	call MenuTextBoxBackup

.done
	and a
	ret

.cancel_buy
	scf
	ret

.BuyPromptText: ; unreferenced?
	text "What would you"
	line "like to buy?"
	done

.HowManyText:
	text "How many would"
	line "you like?"
	done

.ConfirmPurchaseText:
	text_from_ram wStringBuffer2
	text " x@"
	deciram wItemQuantity, 1, 2
	text_start
	line "¥@"
	deciram hMoneyTemp, 3, 6
	text " Buy them?"
	done

.ThanksText:
	text "Thank you!"
	prompt

.NotEnoughMoneyText:
	text "You don't have"
	line "enough money!"
	prompt

.PackFullText:
	text "Your PACK is"
	line "full!"
	prompt

INCLUDE "data/debug/field_debug_pokemart_items.asm"

DebugMart_Sell:
	call DebugMart_ShowPlaceholderText
	and a
	ret

; unused
	callfar CheckItemsQuantity
	jp c, .no_items
	call LoadStandardMenuHeader
	xor a
	ld [wActiveBackpackPocket], a
.bag_loop
	callfar DrawBackpack
	callfar BackpackLoop
	jr c, .close_bag
	call .DoBagFunctions
	jr nc, .bag_loop
.close_bag
	call ClearBGPalettes
	call CloseWindow
	call UpdateTimePals
	and a
	ret

.DoBagFunctions:
	callfar CheckItemMenu
	ld a, [wItemAttributeValue]
	ld hl, .BagJumptable
	call CallJumptable
	ret

.BagJumptable:
	dw .CheckSellableItem
	dw .CannotSellItem
	dw .BallPocket
	dw .FlipPocket
	dw .CheckSellableItem
	dw .CheckSellableItem
	dw .CheckSellableItem

.FlipPocket:
	callfar FlipPocket2Status
	xor a
	ld [wSelectedSwapPosition], a
	ret

.CannotSellItem:
	ld hl, .CannotSellText
	call MenuTextBoxBackup
	and a
	ret

.CannotSellText:
	text "That can't be"
	line "used!"
	prompt

.BallPocket:
	callfar BallPocket
	jr nc, .CheckSellableItem
	and a
	ret

.CheckSellableItem:
	callfar _CheckTossableItem
	ld a, [wItemAttributeValue]
	and a
	jr nz, .not_sellable
	jp .ItemQuantityPrompt

.not_sellable
	ld hl, .ImportantItemText
	call MenuTextBoxBackup
	and a
	ret

.ImportantItemText:
	text "That item is vital"
	line "and can't be sold!"
	prompt

.no_items
	ld hl, .NoItemsText
	call MenuTextBoxBackup
	and a
	ret

.NoItemsText:
	text "You don't have a"
	next "single item!"
	prompt

.ItemQuantityPrompt:
	ld hl, .HowManyItemsText
	call PrintText
	callfar SelectQuantityToBuy
	jr c, .got_quantity
	jp .CannotSellItem

.got_quantity
	and a
	ret

.HowManyItemsText:
	text "How many will"
	line "you sell?"
	done

DebugMart_LoadItems:
	ld hl, wCurMartCount
.load_loop
	ld a, [de]
	inc de
	ld [hli], a
	cp -1
	jr nz, .load_loop
	ld hl, wBattleMenuRows
	ld de, wCurMartCount + 1
.load_loop2
	ld a, [de]
	inc de
	cp -1
	jr z, .done_load
	push de
	call .GetPrice
	pop de
	jr .load_loop2

.done_load
	ret

.GetPrice:
	push hl
	ld [wCurItem], a
	callfar GetItemPrice
	ld a, d
	ld [wBuySellItemPrice], a
	ld a, e
	ld [wBuySellItemPrice + 1], a
	ld hl, wStringBuffer1
	ld de, wBuySellItemPrice
	lb bc, PRINTNUM_LEADINGZEROS | 2, 6
	call PrintNumber
	pop hl
	ld de, wStringBuffer1
	ld c, 3
.print_price
	call .PrintPaddedDigits
	swap a
	ld b, a
	call .PrintPaddedDigits
	or b
	ld [hli], a
	dec c
	jr nz, .print_price
	ret

.PrintPaddedDigits:
	ld a, [de]
	inc de
	cp '　'
	jr nz, .to_digit
	ld a, '０'
.to_digit
	sub '０'
	ret

DebugMart_ShowPlaceholderText:
	ld hl, .PlaceholderText
	call MenuTextBox
	call ExitMenu
	ret

.PlaceholderText:
	text "Under development."
	next ""
	prompt
