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
; English item names are far longer than the Japanese ones (up to 12 tiles), so
; the price column is pushed to the far right of the row: offset 12 from the
; row start (col 2) puts the ¥ + four digits at cols 14-18, leaving cols 2-13
; for the name. See .PrintAmount.
	db 4, 12 ; rows, price column offset
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
; The precomputed price is a 3-byte (6-digit) BCD, MSB first. Item prices never
; exceed 4 digits, so skip the high byte and print only the low two (4 digits):
; ¥ + 4 digits = 5 tiles, which sits flush at the right edge of the row (cols
; 14-18) so the full English item name has cols 2-13 to itself.
	inc hl
	push de
	ld d, h
	ld e, l
	pop hl
	ld [hl], '¥'
	inc hl
	ld c, 2 | PRINTNUM_LEADINGZEROS
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
	ld a, 1 ; start on the first item
.buy_loop
	call .BuyMenu
	jr nc, .buy_loop
	call ExitMenu
	pop af
	ldh [hMapAnims], a
	ret

.BuyMenu:
; IN/OUT: a = cursor row. CopyMenuHeader resets wMenuCursorPosition to the
; header's default every pass, which snapped the cursor back to the top row after
; each purchase (wMenuScrollPosition survives on its own). Carry the row across
; passes in a, on the stack while .BuySelected runs -- pop bc keeps its flags.
	push af
	call UpdateSprites
	ld hl, DebugMart_BuyMenuHeader
	call CopyMenuHeader
	pop af
	ld [wMenuCursorPosition], a
	call ScrollingMenu
	ld a, [wMenuCursorY]
	push af
	call .BuySelected
	pop bc
	ld a, b
	ret

.BuySelected:
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
; One short line: SelectQuantityToBuy's ×NN/price box sits over the right half
; of the second line and would cover anything printed there.
	text "How many?"
	done

.ConfirmPurchaseText:
	text_from_ram wStringBuffer2
	text " x@"
	deciram wItemQuantity, 1, 2
	text_start
	line "¥@"
	deciram hMoneyTemp, 3, 6
	text ". OK?"
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
