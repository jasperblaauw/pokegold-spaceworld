#!/usr/bin/env python3
# Generates numeric-keyed MOVE_DESC and ITEM_DESC and writes them into
# translations.py (replacing the empty placeholders). Faithful English
# renderings of the prototype's Japanese move/item descriptions.
import sys, re, os
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import gen_site as G  # noqa

# ------------------------------------------------------------------ MOVES
# Ordered 1..251 (list index 0 == key "1"). Faithful to the JP source; beta
# moves get a plain gloss. Terse Gen-2 register.
MOVE_EN = [
 "Pounds the foe with forelegs or tail.",                                   # 1 Pound
 "Chops with a hand. High critical-hit ratio.",                             # 2 Karate Chop
 "Slaps the foe 2-5 times in a row.",                                       # 3 DoubleSlap
 "Pummels the foe 2-5 times in a row.",                                     # 4 Comet Punch
 "A punch thrown with tremendous power.",                                   # 5 Mega Punch
 "Throws coins at the foe. Money is picked up after battle.",               # 6 Pay Day
 "A fiery punch. May burn the foe.",                                        # 7 Fire Punch
 "An icy punch. May freeze the foe.",                                       # 8 Ice Punch
 "An electric punch. May paralyze the foe.",                                # 9 ThunderPunch
 "Scratches the foe with sharp claws.",                                     # 10 Scratch
 "Grips the foe with large pincers.",                                       # 11 ViceGrip
 "A pincer attack that faints the foe if it hits.",                         # 12 Guillotine
 "Whips up a whirlwind on turn 1, attacks on turn 2.",                      # 13 Razor Wind
 "A fighting dance that sharply raises ATTACK.",                            # 14 Swords Dance
 "Cuts the foe with claws or a scythe.",                                    # 15 Cut
 "Whips up a strong wind with wings to strike the foe.",                    # 16 Gust
 "Spreads wings wide and body-slams the foe.",                              # 17 Wing Attack
 "Blows the foe away. Ends a wild battle.",                                 # 18 Whirlwind
 "Flies up on turn 1, attacks on turn 2.",                                  # 19 Fly
 "Binds and squeezes the foe for 2-5 turns.",                              # 20 Bind
 "Slams the foe with a long tail or vine.",                                 # 21 Slam
 "Whips the foe with slender, whip-like vines.",                            # 22 Vine Whip
 "Stomps with a big foot. May cause flinching.",                            # 23 Stomp
 "Kicks the foe twice with two legs.",                                      # 24 Double Kick
 "A kick thrown with tremendous power.",                                    # 25 Mega Kick
 "A jump kick. The user is hurt if it misses.",                             # 26 Jump Kick
 "Spins the body quickly and kicks.",                                       # 27 Rolling Kick
 "Throws sand in the foe's face to lower accuracy.",                        # 28 Sand Attack
 "A headfirst charge. May cause flinching.",                                # 29 Headbutt
 "Jabs the foe with a pointed horn.",                                       # 30 Horn Attack
 "Jabs the foe 2-5 times with a horn.",                                     # 31 Fury Attack
 "Spins a horn like a drill. Faints the foe if it hits.",                   # 32 Horn Drill
 "Charges the foe with the whole body.",                                    # 33 Tackle
 "Falls onto the foe bodily. May paralyze.",                                # 34 Body Slam
 "Wraps and squeezes the foe for 2-5 turns.",                              # 35 Wrap
 "A reckless charge. The user also takes damage.",                          # 36 Take Down
 "Rampages 2-3 turns, then becomes confused.",                             # 37 Thrash
 "A life-risking charge. The user also takes damage.",                      # 38 Double-Edge
 "Wags the tail to lower the foe's DEFENSE.",                               # 39 Tail Whip
 "Attacks with a poison stinger. May poison.",                             # 40 Poison Sting
 "Stabs the foe twice with twin stingers.",                                # 41 Twineedle
 "Fires sharp spikes at the foe 2-5 times.",                               # 42 Pin Missile
 "Glares to frighten and lower the foe's DEFENSE.",                        # 43 Leer
 "Bites with sharp teeth. May cause flinching.",                           # 44 Bite
 "A cute cry that lowers the foe's ATTACK.",                               # 45 Growl
 "Roars to drive the foe away. Ends a wild battle.",                       # 46 Roar
 "A soothing song that lulls the foe into deep sleep.",                    # 47 Sing
 "Emits sound waves that may confuse the foe.",                            # 48 Supersonic
 "A shockwave that always deals 20 damage.",                              # 49 SonicBoom
 "Uses psychic power to disable one of the foe's moves.",                 # 50 Disable
 "Melts the foe with acid. May lower DEFENSE.",                            # 51 Acid
 "A small flame attack. May burn the foe.",                                # 52 Ember
 "A powerful flame attack. May burn the foe.",                             # 53 Flamethrower
 "Cloaks the body in white mist, preventing stat drops.",                 # 54 Mist
 "Blasts water at the foe.",                                               # 55 Water Gun
 "Blasts water with tremendous force.",                                    # 56 Hydro Pump
 "Crashes a huge wave down on the foe.",                                   # 57 Surf
 "Fires an icy beam. May freeze the foe.",                                 # 58 Ice Beam
 "Whips snow up in a fierce wind. May freeze the foe.",                    # 59 Blizzard
 "Fires a strange beam. May confuse the foe.",                             # 60 Psybeam
 "Blasts water hard. May lower the foe's SPEED.",                          # 61 BubbleBeam
 "Fires a rainbow beam. May lower ATTACK.",                                # 62 Aurora Beam
 "Big damage, but the user can't move next turn.",                         # 63 Hyper Beam
 "Jabs the foe with a long beak.",                                         # 64 Peck
 "Spins the body around a beak and charges.",                              # 65 Drill Peck
 "Slams self and foe into the ground. The user is hurt too.",             # 66 Submission
 "Trips the foe with timing. May cause flinching.",                       # 67 Low Kick
 "Returns a physical blow at double the damage.",                          # 68 Counter
 "Throws using gravity. Deals damage equal to LEVEL.",                    # 69 Seismic Toss
 "Builds up great power and attacks.",                                     # 70 Strength
 "Drains half the damage dealt to restore HP.",                           # 71 Absorb
 "Drains half the damage dealt to restore HP.",                           # 72 Mega Drain
 "Plants a seed that saps the foe's HP each turn.",                        # 73 Leech Seed
 "Grows all at once to raise SPECIAL.",                                    # 74 Growth
 "Cuts with leaves. High critical-hit ratio.",                            # 75 Razor Leaf
 "Gathers light on turn 1, attacks on turn 2.",                           # 76 SolarBeam
 "Scatters a powder that poisons the foe.",                               # 77 PoisonPowder
 "Scatters a numbing powder that paralyzes.",                             # 78 Stun Spore
 "Scatters a sleep-inducing powder.",                                     # 79 Sleep Powder
 "Rampages 2-3 turns, then becomes confused.",                            # 80 Petal Dance
 "Binds the foe in silk to lower SPEED.",                                 # 81 String Shot
 "A shockwave that always deals 40 damage.",                              # 82 Dragon Rage
 "Traps the foe in flames for 2-5 turns.",                                # 83 Fire Spin
 "An electric jolt. May paralyze the foe.",                               # 84 ThunderShock
 "A strong electric jolt. May paralyze the foe.",                         # 85 Thunderbolt
 "A weak jolt that paralyzes the foe.",                                   # 86 Thunder Wave
 "Drops a lightning bolt. May paralyze.",                                 # 87 Thunder
 "Hurls small rocks at the foe.",                                         # 88 Rock Throw
 "Shakes the ground. Big damage, but airborne foes escape.",             # 89 Earthquake
 "Opens a fissure. Faints the foe if it hits.",                           # 90 Fissure
 "Burrows on turn 1, attacks on turn 2.",                                # 91 Dig
 "Badly poisons the foe, damage rising each turn.",                       # 92 Toxic
 "A psychic attack. May confuse the foe.",                                # 93 Confusion
 "A strong psychic attack. May lower SP.DEF.",                            # 94 Psychic
 "Hypnotizes the foe into deep sleep.",                                   # 95 Hypnosis
 "A yoga pose that draws out power to raise ATTACK.",                     # 96 Meditate
 "Relaxes the body to sharply raise SPEED.",                              # 97 Agility
 "Moves at great speed to always strike first.",                          # 98 Quick Attack
 "ATTACK rises each time the user is hit.",                               # 99 Rage
 "Uses psychic power to flee from battle.",                               # 100 Teleport
 "Shows an eerie illusion. Deals damage equal to LEVEL.",                # 101 Night Shade
 "Copies a foe's move for use during the battle.",                        # 102 Mimic
 "An awful sound that harshly lowers the foe's DEFENSE.",                 # 103 Screech
 "Creates illusory copies to lower the foe's accuracy.",                  # 104 Double Team
 "Restores half of max HP.",                                              # 105 Recover
 "Tenses the body to raise DEFENSE.",                                     # 106 Harden
 "Shrinks the body to lower the foe's accuracy.",                         # 107 Minimize
 "Uses smoke or ink to lower the foe's accuracy.",                        # 108 Smokescreen
 "An eerie light that confuses the foe.",                                 # 109 Confuse Ray
 "Withdraws into a hard shell to raise DEFENSE.",                         # 110 Withdraw
 "Curls up to hide weak points and raise DEFENSE.",                       # 111 Defense Curl
 "Creates a wall that sharply raises DEFENSE.",                           # 112 Barrier
 "A wall of light that weakens special attacks.",                         # 113 Light Screen
 "Black mist that resets all stat changes.",                             # 114 Haze
 "A wall of light that weakens physical attacks.",                        # 115 Reflect
 "Focuses power to raise the critical-hit ratio.",                        # 116 Focus Energy
 "Endures attacks 2-3 turns, then strikes back double.",                 # 117 Bide
 "Waggles a finger to use a random move.",                                # 118 Metronome
 "Copies the foe's move to strike back.",                                 # 119 Mirror Move
 "Deals big damage, but faints the user.",                               # 120 Selfdestruct
 "Hurls a large egg at the foe.",                                        # 121 Egg Bomb
 "Licks with a long tongue. May paralyze.",                              # 122 Lick
 "Sprays exhaust gas. May poison the foe.",                              # 123 Smog
 "Hurls sludge. May poison the foe.",                                    # 124 Sludge
 "Clubs the foe with a bone. May cause flinching.",                      # 125 Bone Club
 "A blast in the shape of the kanji 'dai'. May burn.",                   # 126 Fire Blast
 "Charges as if climbing a waterfall.",                                  # 127 Waterfall
 "Clamps the foe in a shell for 2-5 turns.",                             # 128 Clamp
 "Fires countless unavoidable star-shaped rays.",                        # 129 Swift
 "Pulls in the head on turn 1, attacks on turn 2.",                      # 130 Skull Bash
 "Fires sharp spikes 2-5 times.",                                        # 131 Spike Cannon
 "Squeezes the foe for 2-5 turns.",                                      # 132 Constrict
 "Forgets for a moment to sharply raise SP.DEF.",                        # 133 Amnesia
 "Distracts the foe with a spoon to lower accuracy.",                    # 134 Kinesis
 "Restores half of max HP.",                                             # 135 Softboiled
 "A jumping knee kick. The user is hurt if it misses.",                  # 136 Hi Jump Kick
 "Intimidates with a belly pattern to paralyze.",                        # 137 Glare
 "Drains half the damage dealt to restore HP.",                          # 138 Dream Eater
 "Sprays poison gas that poisons the foe.",                              # 139 Poison Gas
 "Hurls round objects 2-5 times.",                                       # 140 Barrage
 "Drains half the damage dealt to restore HP.",                          # 141 Leech Life
 "Demands a kiss with a scary face. Puts the foe to sleep.",             # 142 Lovely Kiss
 "Seeks a weak point on turn 1, attacks on turn 2.",                     # 143 Sky Attack
 "Transforms cells to match the foe's appearance.",                      # 144 Transform
 "Sprays bubbles. May lower the foe's SPEED.",                           # 145 Bubble
 "A rhythmic one-two punch. May confuse the foe.",                       # 146 Dizzy Punch
 "Scatters spores that put the foe to sleep.",                           # 147 Spore
 "A bright light that lowers the foe's accuracy.",                       # 148 Flash
 "Deals random damage of 1 to LEVEL x1.5.",                              # 149 Psywave
 "Just bounces. Nothing happens...",                                     # 150 Splash
 "Liquefies the body to sharply raise DEFENSE.",                        # 151 Acid Armor
 "Hammers with a pincer. High critical-hit ratio.",                      # 152 Crabhammer
 "Deals big damage, but faints the user.",                               # 153 Explosion
 "Scratches with sharp claws 2-5 times.",                                # 154 Fury Swipes
 "Throws a bone that hits going and coming - twice.",                    # 155 Bonemerang
 "Sleeps 2 turns to fully restore HP and cure status.",                  # 156 Rest
 "Hurls large rocks. May cause flinching.",                              # 157 Rock Slide
 "Bites with sharp fangs. May cause flinching.",                         # 158 Hyper Fang
 "Reduces polygon count to become angular, raising ATTACK.",             # 159 Sharpen
 "Applies a texture to match the foe's type.",                           # 160 Conversion
 "Fires three beams combined into one.",                                 # 161 Tri Attack
 "Bites hard to halve the foe's HP.",                                    # 162 Super Fang
 "Slashes with claws or a scythe. High critical-hit ratio.",             # 163 Slash
 "Uses 1/4 of max HP to make a decoy.",                                  # 164 Substitute
 "Used when out of PP. The user also takes damage.",                     # 165 Struggle
 "Sketches a foe's move to learn it permanently.",                       # 166 Sketch
 "Kicks 3 times, growing stronger each hit.",                            # 167 Triple Kick
 "Steals the foe's held item during the attack.",                        # 168 Thief
 "Ensnares the foe in sticky silk so it can't flee.",                    # 169 Spider Web
 "Senses the foe's movements to ensure the next hit.",                   # 170 Mind Reader
 "Saps 1/8 of the sleeping foe's HP each turn.",                         # 171 Nightmare
 "Charges cloaked in flames. May burn the foe.",                         # 172 Flame Wheel
 "Usable only while asleep. Attacks with a loud snore.",                 # 173 Snore
 "Hurts the user to damage the foe each turn. (beta)",                   # 174 Nail Down
 "Deals more damage the lower the user's HP.",                           # 175 Flail
 "Applies a texture to the foe, randomizing its type.",                  # 176 Conversion2
 "Attacks with money; stronger the richer the trainer. (beta)",          # 177 Coin Hurl
 "Clings spores to harshly lower the foe's DEFENSE.",                    # 178 Cotton Spore
 "Deals more damage the lower the user's HP.",                           # 179 Reversal
 "Resents the last move used, cutting its PP.",                          # 180 Spite
 "Rides snow on the wind. May freeze the foe.",                          # 181 Powder Snow
 "Blocks the foe's attack next turn.",                                   # 182 Protect
 "An incredibly fast punch that always strikes first.",                  # 183 Mach Punch
 "A scary face that harshly lowers the foe's DEFENSE.",                  # 184 Scary Face
 "Approaches unaware and lands an unavoidable hit.",                     # 185 Faint Attack
 "Demands a kiss with a cute face. Confuses the foe.",                   # 186 Sweet Kiss
 "Beats the belly to intimidate and sharply raise ATTACK.",             # 187 Belly Drum
 "Hurls sludge. May poison the foe.",                                    # 188 Sludge Bomb
 "Throws mud in the foe's face to lower accuracy.",                      # 189 Mud Slap
 "Fires a blob of ink to lower the foe's accuracy.",                     # 190 Octazooka
 "Sets a trap that hurts a foe switching in.",                           # 191 Spikes
 "Hard to land, but big damage. Always paralyzes on a hit.",             # 192 Zap Cannon
 "Lets NORMAL moves hit GHOST-type foes.",                               # 193 Foresight
 "If the user faints after this, the foe faints too.",                   # 194 Destiny Bond
 "Any Pokemon that hears it faints in 3 turns.",                         # 195 Perish Song
 "While synchronized, the foe takes the same damage.",                   # 196 Synchronize
 "Reads the foe's movements to ensure the next hit.",                    # 197 Detect
 "Strikes 2-5 times with a handheld bone. (beta)",                       # 198 Bone Lock
 "Takes aim to ensure the next attack hits.",                            # 199 Lock On
 "Rampages 2-3 turns, then becomes confused.",                           # 200 Outrage
 "Whips up a sandstorm that damages each turn.",                         # 201 Sandstorm
 "Drains half the damage dealt to restore HP.",                          # 202 Giga Drain
 "Survives the next attack with at least 1 HP.",                         # 203 Endure
 "Charms the foe to harshly lower ATTACK.",                              # 204 Charm
 "Attacks 5 turns, growing stronger each hit.",                          # 205 Rollout
 "Attacks holding back, always leaving 1 HP.",                           # 206 False Swipe
 "Enrages and confuses the foe, but sharply raises its ATTACK.",         # 207 Swagger
 "Restores half of max HP.",                                             # 208 Milk Drink
 "Charges cloaked in electricity. May paralyze.",                        # 209 Spark
 "Slashes with claws or a scythe twice.",                                # 210 Fury Cutter
 "Spreads wings wide and body-slams the foe.",                           # 211 Steel Wing
 "Staring at the foe somehow keeps it from fleeing. (beta)",             # 212 Stalker
 "Makes an opposite-gender foe unable to attack.",                       # 213 Attract
 "Usable only while asleep. Uses a random move.",                        # 214 Sleep Talk
 "A soothing bell tone that cures all status. (beta)",                   # 215 Bell Chime
 "Attacks a caring trainer's foe with full power.",                      # 216 Return
 "Gives the foe a bomb - but sometimes heals it instead.",               # 217 Present
 "Vents frustration on the foe with full power.",                        # 218 Frustration
 "A mysterious power that prevents status problems.",                    # 219 Safeguard
 "Adds both HP totals and splits them evenly.",                          # 220 Pain Split
 "A mystical flame. May cause flinching.",                               # 221 Sacred Fire
 "Shakes the ground. Damage varies randomly.",                          # 222 Magnitude
 "Hard to land, but big damage. Always confuses on a hit.",              # 223 DynamicPunch
 "A tremendous sound that distracts and lowers SP.ATK.",                 # 224 Megahorn
 "Exhales a powerful breath to attack.",                                 # 225 DragonBreath
 "Switches out while passing on added effects.",                         # 226 Baton Pass
 "Forces the foe to repeat its last move 2-5 times.",                    # 227 Encore
 "Deals big damage to a foe that is switching out.",                     # 228 Pursuit
 "Spins the body fast to attack.",                                       # 229 Rapid Spin
 "Throws bait to distract and lower the foe's evasion. (beta)",          # 230 Tempt
 "Strikes with a hard tail. May lower DEFENSE.",                         # 231 Iron Tail
 "Strikes with a hard head. May cause flinching.",                       # 232 Rock Head
 "Attacks without being hit, but takes big damage on a miss.",           # 233 Vital Throw
 "Restores HP. The amount varies with the time of day.",                 # 234 Morning Sun
 "Restores HP. The amount varies with the time of day.",                 # 235 Synthesis
 "Restores HP. The amount varies with the time of day.",                 # 236 Moonlight
 "Damage varies with the Pokemon using it.",                             # 237 Hidden Power
 "Crosses pincers to attack. High critical-hit ratio. (beta)",           # 238 Cross Cutter
 "Whips up a fierce wind to attack.",                                    # 239 Twister
 "Boosts WATER-type moves for 5 turns.",                                 # 240 Rain Dance
 "Boosts FIRE-type moves for 5 turns.",                                  # 241 Sunny Day
 "(placeholder - 'description in progress')",                            # 242 blank
 "(placeholder - 'description in progress')",                            # 243 blank
 "(placeholder - 'description in progress')",                            # 244 blank
 "Grabs and hurls the foe for big damage. (beta)",                       # 245 Uproot
 "Body-slams the foe on the wind. High critical-hit ratio. (beta)",      # 246 Wind Ride
 "(placeholder - 'description in progress')",                            # 247 Water Sport
 "Strikes with thick arms. May raise ATTACK. (beta)",                    # 248 Strong Arm
 "Lights up the area to raise move accuracy. (beta)",                    # 249 Bright Moss
 "Traps the foe in a vortex for 2-5 turns.",                             # 250 Whirlpool
 "Just bounces. Nothing happens...",                                     # 251 Bounce
]
assert len(MOVE_EN) == 251, len(MOVE_EN)
MOVE_DESC = {str(i+1): s for i, s in enumerate(MOVE_EN)}

# ------------------------------------------------------------------ ITEMS
# Type-name map for the many "equip to boost/weaken X-type moves" hold items.
TYPE = {"くさ":"Grass","ひこう":"Flying","でんき":"Electric","いわ":"Rock",
        "ノーマル":"Normal","どく":"Poison","ドラゴン":"Dragon","むし":"Bug",
        "エスパー":"Psychic","みず":"Water","かくとう":"Fighting","ほのお":"Fire",
        "ゴースト":"Ghost","じめん":"Ground","こおり":"Ice","はがね":"Steel","メタル":"Steel"}
STATUS = {"どく":"poison","やけど":"burns","こおり":"freezing","ねむり":"sleep",
          "マヒ":"paralysis","こんらん":"confusion"}

def item_en(jp):
    """Pattern-translate a normalised JP item description; None if unmatched."""
    s = jp.replace(" / ", " ").replace("　"," ").strip()
    z2a = lambda d: d.translate(str.maketrans("０１２３４５６７８９", "0123456789"))
    m = re.fullmatch(r"たいりょくを(\d+) かいふくする", s)
    if m: return "Restores %s HP." % z2a(m.group(1))
    if s == "たいりょくを ぜんかいふくする": return "Fully restores HP."
    if s == "ポケモンを つかまえることが できる": return "Used to catch wild Pokemon."
    if s == "とくていの ポケモンを しんかさせる": return "Evolves certain Pokemon."
    if s == "ポケモンが つれる": return "Used to fish for Pokemon."
    # status cure
    m = re.fullmatch(r"(\S+) じょうたいから かいふくする", s)
    if m and m.group(1) in STATUS:
        return "Cures %s." % STATUS[m.group(1)]
    # equip: boost X-type move power
    m = re.fullmatch(r"そうびすると (\S+?)タイプの わざのいりょくが あがる", s)
    if m and m.group(1) in TYPE:
        return "Held item: boosts the power of %s-type moves." % TYPE[m.group(1)]
    # equip: weaken X-type move damage taken
    m = re.fullmatch(r"そうびすると (\S+?)タイプの わざのいりょくを よわめられる", s)
    if m and m.group(1) in TYPE:
        return "Held item: weakens damage taken from %s-type moves." % TYPE[m.group(1)]
    # equip: prevent status
    m = re.fullmatch(r"そうびすると (\S+) じょうたいに ならない", s)
    if m and m.group(1) in STATUS:
        st = {"poison":"poisoned","burns":"burned","freezing":"frozen","sleep":"put to sleep",
              "paralysis":"paralyzed","confusion":"confused"}[STATUS[m.group(1)]]
        return "Held item: prevents the holder from being %s." % st
    # TMs / HMs (digits are full-width in source; fold to ASCII)
    z2a = lambda d: d.translate(str.maketrans("０１２３４５６７８９", "0123456789"))
    m = re.fullmatch(r"わざマシン(\d+)", s)
    if m: return "TM%s - a Technical Machine." % z2a(m.group(1))
    m = re.fullmatch(r"ひでんマシン(\d+)", s)
    if m: return "HM%s - a Hidden Machine." % z2a(m.group(1))
    return None

# Manual overrides / non-formulaic items, keyed by the numeric key (col 2 of dump).
ITEM_OVR = {
 "6":  "Lets you view the Town Map.",
 "7":  "Lets you move at double speed. Can't be used indoors.",
 "14": "Fully restores HP and cures all status.",
 "19": "Escapes instantly from a dungeon.",
 "20": "Keeps weak Pokemon away for 100 steps.",
 "21": "Fully restores a Pokemon's PP.",
 "26": "Raises a Pokemon's maximum HP.",
 "27": "Raises a Pokemon's ATTACK base points.",
 "28": "Raises a Pokemon's DEFENSE base points.",
 "29": "Raises a Pokemon's SPEED base points.",
 "31": "Raises a Pokemon's SPECIAL base points.",
 "32": "Raises a Pokemon's level by one.",
 "33": "Raises accuracy for the current battle only.",
 "36": "A ball of gold. Sells for a high price.",
 "37": "Guarantees escape from a wild Pokemon.",
 "38": "Cures all status problems.",
 "39": "Revives a fainted Pokemon with half HP.",
 "40": "Revives a fainted Pokemon with full HP.",
 "41": "Raises SP.DEF for the current battle only.",
 "42": "Keeps weak Pokemon away for 200 steps.",
 "43": "Keeps weak Pokemon away for 250 steps.",
 "44": "Raises the critical-hit rate for the current battle only.",
 "49": "Raises ATTACK for the current battle only.",
 "51": "Raises DEFENSE for the current battle only.",
 "52": "Raises SPEED for the current battle only.",
 "53": "Raises SP.ATK for the current battle only.",
 "54": "Holds up to 9999 coins.",
 "55": "Sounds when a hidden item is nearby on screen.",
 "56": "Wakes a sleeping Pokemon.",
 "57": "Shares EXP with Pokemon that didn't battle.",
 "62": "Raises a move's maximum PP.",
 "63": "Restores 10 PP to one of a Pokemon's moves.",
 "64": "Fully restores one of a Pokemon's moves' PP.",
 "65": "Restores 10 PP to all of a Pokemon's moves.",
 "66": "Held item: weakens damage taken from Grass-type moves.",  # Mystic Petal
 "67": "Held item: weakens damage taken from Flying-type moves.", # White Feather
 "68": "Held item: damages the foe before battle begins.",         # Confuse Claw
 "69": "Held item: raises SP.DEF by 10.",                          # Wisdom Orb
 "70": "Held item: raises DEFENSE by 10.",                         # Steel Shell
 "71": "Held item: raises all stats by 5.",                        # Up Grade
 "72": "Held item: may dodge the foe's attack.",                   # Strange Thread
 "74": "Held item: may let the holder move first.",               # Quick Needle
 "79": "Held item: prevents the holder from being poisoned.",      # Snakeskin
 "82": "Held item: the foe may flinch.",                           # Kings Rock
 "83": "Held item: nullifies all type effectiveness.",             # Strange Power
 "84": "Held item: revives from fainting after battle.",           # Life Tag
 "86": "A fine mushroom. Sells for a high price.",                 # Cordyceps
 "89": "Held item: lets Dig be used outside battle.",              # Digging Claw
 "91": "Held item: doubles prize money.",                          # Amulet Coin
 "93": "Held item: strikes back with 1/4 damage.",                # Counter Cuff
 "94": "Held item: makes wild encounters rarer.",                 # Talisman Tag
 "103": "A very tasty tail. Sells for a high price.",             # Slowpoke Tail
 "106": "Held item: switch out without using a turn.",           # Flee Feather
 "110": "A lovely pearl. Sells for a high price.",               # Big Pearl
 "113": "Held item: makes wild encounters more common.",         # Spell Tag
 "116": "Held item: prevents the holder from sleeping.",         # Stimulus Orb
 "117": "Held item: prevents confusion.",                        # Calm Berry
 "119": "Held item: may endure a hit without fainting.",         # Focus Orb
 "121": "Held item: may dodge the foe's attack.",               # Detect Orb
 "122": "Held item: raises the catch rate for Pokemon.",        # Long Tongue
 "123": "Lets you enter the lottery.",                          # Lotto Ticket
 "124": "Held item: stops the holder from evolving.",           # Everstone
 "125": "Held item: raises ATTACK by 10.",                      # Sharp Horn
 "126": "Held item: doubles EXP gained.",                       # Lucky Egg
 "127": "Held item: raises the catch rate for Pokemon.",        # Long Vine
 "128": "Held item: restores 1 HP with each step.",             # Moms Love
 "129": "Held item: lets you flee any wild Pokemon.",           # Smokescreen (item)
 "131": "Lets you move at double speed. Can be used indoors.",   # Skateboard
 "132": "A red gem. Sells for a high price.",                    # Crimson Jewel
 "133": "Held item: halves special-attack damage taken.",       # Invisible Wall
 "134": "Held item: raises the critical-hit rate.",             # Sharp Scythe
 "139": "Held item: raises ATTACK by 10.",                      # Twin Horns
 "143": "Held item: halves physical-attack damage taken.",      # Metal Coat
 "146": "Held item: restores 30 HP each turn.",                 # Leftovers
 "147": "Held item: raises SP.DEF by 10.",                      # Ice Wing
 "148": "Held item: raises SPEED by 10.",                       # Thunder Wing
 "149": "Held item: raises SP.ATK by 10.",                      # Fire Wing
 "152": "Held item: raises all stats by 10.",                   # Berserk Gene
 "153": "Evolves certain Pokemon.",                             # Heart Stone
 "156": "Revives all fainted Pokemon with 1 HP.",              # Sacred Ash
 "157": "A holder for storing TMs.",                            # TM Holder
 "158": "A special item.",                                      # Mail
 "159": "A special item.",                                      # Ball Holder
 "160": "A holder for storing ordinary items.",                # Bag
 "161": "A holder for storing important items.",               # Important Bag
 "162": "Evolves certain Pokemon.",                            # Poison Stone
}

def build_items():
    t = G.read("data/items/descriptions.asm")
    order = re.findall(r'dw ([A-Za-z0-9_]+)Description', t)
    blocks = re.split(r'\n(?=[A-Za-z0-9_]+Description:)', t)
    bd = {}
    for b in blocks:
        m = re.match(r'([A-Za-z0-9_]+)Description:', b)
        if m: bd[m.group(1)] = re.findall(r'(?:db|next|line|para|cont)\s+"([^"]+)"', b)
    out = {}
    unmatched = []
    for i, lab in enumerate(order):
        fl = bd.get(lab, [])
        joined = "".join(x.replace("@","") for x in fl).strip()
        if not any(G.has_jp(x) for x in fl) or set(joined) <= set("？?　 /"):
            continue
        key = str(i+1)
        disp = " / ".join(G.jp_clean(x) for x in fl if G.jp_clean(x))
        if key in ITEM_OVR:
            out[key] = ITEM_OVR[key]; continue
        en = item_en(disp)
        if en: out[key] = en
        else: unmatched.append((key, disp))
    return out, unmatched

ITEM_DESC, UNMATCHED = build_items()

def emit(path=None):
    """Write the numeric-keyed dicts to desc_generated.py (next to this file)."""
    import json
    path = path or os.path.join(HERE, "desc_generated.py")
    with open(path, "w", encoding="utf-8") as f:
        f.write("# Auto-generated by build_descs.py — numeric-keyed move/item descriptions.\n")
        f.write("# Regenerate: python3 build_descs.py  (writes this file). Do not hand-edit.\n")
        f.write("MOVE_DESC = " + json.dumps(MOVE_DESC, ensure_ascii=False))
        f.write("\n\nITEM_DESC = " + json.dumps(ITEM_DESC, ensure_ascii=False) + "\n")
    return path

if __name__ == "__main__":
    print("MOVE_DESC:", len(MOVE_DESC))
    print("ITEM_DESC:", len(ITEM_DESC))
    print("UNMATCHED items:", len(UNMATCHED))
    for k, d in UNMATCHED:
        print("  ", k, d)
    print("wrote", emit())
