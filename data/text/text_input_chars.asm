TextEntryChars:
; English uppercase naming keyboard (5 rows x 17 tiles; columns 5 and 11 are
; blank spacers to match the cursor geometry). B deletes; START or the
; bottom-right key (charmap $F0 = NAMINGSCREEN_END) confirms.
	db "ABCDE FGHIJ KLMNO"
	db "PQRST UVWXY Z    "
	db "01234 56789      "
	db "-?!., /'(): ♂♀×  "
	db "                円"

TextEntryCharsLower:
; Lowercase page (SELECT toggles between this and TextEntryChars). Same digits,
; punctuation and END key as the uppercase page; only the letters differ.
	db "abcde fghij klmno"
	db "pqrst uvwxy z    "
	db "01234 56789      "
	db "-?!., /'(): ♂♀×  "
	db "                円"

TextEntryHiragana:
	db "あいうえお　かきくけこ　さしすせそ"
	db "たちつてと　なにぬねの　はひふへほ"
	db "まみむめも　やゆよわん　らりるれろ"
	db "ゃゅょっを　１２３４５　６７８９０"
	db "　ﾞﾟ　ー？！円"

TextEntryKatakana:
	db "アイウエオ　カキクケコ　サシスセソ"
	db "タチツテト　ナニヌネノ　ハヒフヘホ"
	db "マミムメモ　ヤユヨワン　ラリルレロ"
	db "ャュョッヲ　１２３４５　６７８９０"
	db "　ﾞﾟ　ー？！円"
