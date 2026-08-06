# -*- coding: utf-8 -*-
# English translations for the Space World '97 prototype text.
# Keyed by stable ids (Pokémon name / JP category / block "map:label"), NOT by raw
# Japanese, so the generator's lookups are robust. Fill dicts progressively;
# anything absent renders as a visible "pending" marker.

# ---- Pokédex species categories (JP -> EN) --------------------------------
DEX_CAT = {
 "たね":"Seed","とかげ":"Lizard","かえん":"Flame","かめのこ":"Tiny Turtle","かめ":"Turtle",
 "こうら":"Shellfish","いもむし":"Worm","さなぎ":"Cocoon","ちょうちょ":"Butterfly","けむし":"Hairy Bug",
 "どくばち":"Poison Bee","ことり":"Tiny Bird","とり":"Bird","ねずみ":"Mouse","くちばし":"Beak",
 "へび":"Snake","コブラ":"Cobra","どくばり":"Poison Pin","ドリル":"Drill","ようせい":"Fairy",
 "きつね":"Fox","ふうせん":"Balloon","こうもり":"Bat","ざっそう":"Weed","フラワー":"Flower",
 "きのこ":"Mushroom","こんちゅう":"Insect","どくが":"Poison Moth","もぐら":"Mole","ばけねこ":"Monster Cat",
 "シャムネコ":"Siamese Cat","あひる":"Duck","ぶたざる":"Pig Monkey","こいぬ":"Puppy","でんせつ":"Legendary",
 "おたま":"Tadpole","ねんりき":"Psi","かいりき":"Superpower","ハエとり":"Flycatcher","くらげ":"Jellyfish",
 "がんせき":"Rock","メガトン":"Megaton","ひのうま":"Fire Horse","まぬけ":"Dopey","やどかり":"Hermit Crab",
 "じしゃく":"Magnet","かるがも":"Wild Duck","ふたごどり":"Twin Bird","みつごどり":"Triple Bird","あしか":"Sea Lion",
 "ヘドロ":"Sludge","２まいがい":"Bivalve","ガスじょう":"Gas","シャドー":"Shadow","いわへび":"Rock Snake",
 "さいみん":"Hypnosis","さわがに":"River Crab","はさみ":"Pincer","ボール":"Ball","たまご":"Egg",
 "やしのみ":"Coconut","こどく":"Lonely","ほねずき":"Bonekeeper","キック":"Kicking","パンチ":"Punching",
 "なめまわし":"Licking","どくガス":"Poison Gas","とげとげ":"Spikes","ツルじょう":"Vine","おやこ":"Parent",
 "ドラゴン":"Dragon","きんぎょ":"Goldfish","ほしがた":"Star Shape","なぞの":"Mysterious","バリアー":"Barrier",
 "かまきり":"Mantis","ひとがた":"Humanshape","でんげき":"Electric","ひふき":"Spitfire","くわがた":"Stag Beetle",
 "あばれうし":"Wild Bull","さかな":"Fish","きょうあく":"Atrocious","のりもの":"Transport","へんしん":"Transform",
 "しんか":"Evolution","あわはき":"Bubble Jet","かみなり":"Lightning","ほのお":"Flame","バーチャル":"Virtual",
 "うずまき":"Spiral","かせき":"Fossil","いねむり":"Dozing","れいとう":"Freeze","いでんし":"Genetic",
 "しんしゅ":"New Species","？？？":"???",
}

DEX_PLACEHOLDER = "A Pokémon that has only just been discovered. Currently under investigation."

# ---- Pokédex flavor text, keyed by Pokémon name (dex 1-151) ----------------
DEX_FLAVOR = {
"Bulbasaur":"From the day it is born, a seed is planted on its back, and it grows together with the Pokémon.",
"Ivysaur":"A flower bud grows on its back. As it absorbs nutrients, the bud gradually develops.",
"Venusaur":"To sustain its huge flower, when it finds a sunny spot it moves toward it as if drawn there.",
"Charmander":"It has a nature that loves hot things. The flame on its tail grows hotter when it is excited.",
"Charmeleon":"When it whips its blazing tail around, it raises the temperature nearby to torment its foe.",
"Charizard":"It breathes flames hot enough to melt boulders, and has been known to start forest fires.",
"Squirtle":"After it is born, its back swells and forms a hard shell. It shoots powerful foam from its mouth.",
"Wartortle":"It often hides underwater to stalk prey. When swimming fast it moves its ears to keep balance.",
"Blastoise":"So heavy, with such a hard shell, that most Pokémon it body-slams are knocked unconscious.",
"Caterpie":"It is covered in green skin. As it molts and grows, it spins silk and turns into a cocoon.",
"Metapod":"It is wrapped in a thin shell, but the inside is very soft and cannot withstand a strong attack.",
"Butterfree":"Its wings are protected by water-repellent scales, so it can fly even on rainy days.",
"Weedle":"Common in forests, it eats leaves. Its sharp head stinger poisons whatever it stings.",
"Kakuna":"It is transforming inside its shell to build its adult body. It can barely move.",
"Beedrill":"Sometimes appearing in swarms, it flies at ferocious speed and stings with the barb on its rear.",
"Pidgey":"Widely spread through woods and forests. On landing, it flaps to kick up sand.",
"Pidgeotto":"Its foot claws are well developed. It grabs prey and carries it up to 100 km to its nest.",
"Pidgeot":"It spreads its beautiful wings to intimidate foes, and flies through the sky at Mach 2.",
"Rattata":"It attacks by gnawing on anything. Small and quick, it turns up in all sorts of places.",
"Raticate":"Its hind feet have three toes with small webbing, and it swims across rivers.",
"Spearow":"It eats bugs in the grass. Because its wings are short, it is always busily flapping them.",
"Fearow":"With its large wings it can keep flying in the open sky, fine without landing even once.",
"Ekans":"It hides in grassy fields. A young Ekans has no poison, so being bitten is harmless.",
"Arbok":"The pattern on its belly looks like a fearsome face; weak foes flee at the mere sight of it.",
"Pikachu":"It has small electric sacs on both cheeks and discharges them when in a pinch.",
"Raichu":"Its electric shocks reach 100,000 volts. Touch its tail and even an Indian elephant would faint.",
"Sandshrew":"It digs a deep burrow to hide in dry places, coming out only to hunt prey.",
"Sandslash":"Curled up, it is like a spiky ball. It rolls along to ram foes or to escape.",
"Nidoran-F":"Even small, the power of its poison barb is intense—take care. The female's horn is smaller.",
"Nidorina":"Being female, its horn grows slowly. It prefers close combat, scratching and biting.",
"Nidoqueen":"Needle-like scales grow densely over its back; when excited, the needles stand on end.",
"Nidoran-M":"It raises its long ears to sense danger. The larger its spikes, the stronger its poison.",
"Nidorino":"Quick to anger and fight, its head horn is built to inject intense poison when it stabs.",
"Nidoking":"Its skin is hard as diamond and its long horn is its trademark. The horn is poisonous—beware.",
"Clefairy":"Mysterious and adorable, it has many fans, but its habitats are few, so it is hard to find.",
"Clefable":"Its hearing is so keen it can distinguish a pin dropped a kilometer away.",
"Vulpix":"Though young, its six tails are beautiful. As it grows, its tails increase in number.",
"Ninetales":"It has golden gleaming fur and nine long tails, and is said to live for a thousand years.",
"Jigglypuff":"When its round eyes waver, it sings a strange, pleasant song that makes you drowsy.",
"Wigglytuff":"Its fine fur is supple and pleasant to touch. Made into a pelt, it is said to sell well.",
"Zubat":"It appears in swarms in dark places, emitting ultrasonic waves to approach its target.",
"Golbat":"It bites with sharp fangs and sucks up 300 cc of blood in a single go.",
"Oddish":"By day it buries its face in the ground and barely moves; at night it walks about sowing seeds.",
"Gloom":"The incredibly foul stench from its pistil reaches 2 km away and makes creatures faint.",
"Vileplume":"From the world's largest petals it scatters allergy-inducing pollen like a demon.",
"Paras":"The mushrooms on the bug's back are a cordyceps, and they grow larger over time.",
"Parasect":"It scatters poison spores from its cap—yet in China those spores are used in herbal medicine.",
"Venonat":"It nests inside large trees and seems to eat other bugs. At night it comes near lights.",
"Venomoth":"Scales cover its wings; each light flutter scatters highly poisonous powder.",
"Diglett":"It burrows about a meter down, living on tree roots it gnaws, and rarely pokes its face up.",
"Dugtrio":"It tunnels through the earth to attack the unwary from an unexpected direction.",
"Meowth":"It loves shiny things and often picks up money that has fallen here and there.",
"Persian":"Fierce-tempered. Beware if it raises its tail straight up—a sign it will pounce and bite.",
"Psyduck":"Always troubled by a headache; when the headache grows severe it starts using strange powers.",
"Golduck":"Its webbed palms make it a strong swimmer, and its elegant form is seen at lakes.",
"Mankey":"Nimble and violent. Once it gets angry and starts rampaging, it cannot be controlled.",
"Primeape":"For some reason it flies into a rage and will chase you anywhere, no matter how far you flee.",
"Growlithe":"Friendly, but it has a wide territory, and if you approach carelessly it will attack.",
"Arcanine":"A beautiful Pokémon that has captivated people since ancient times; it runs lightly, as if flying.",
"Poliwag":"Its smooth black skin is thin. Its insides show through, appearing as a spiral on its belly.",
"Poliwhirl":"It can live on land or in water; on land it is always sweating to keep its body slimy.",
"Poliwrath":"Skilled at the crawl and butterfly, it steadily overtakes even Olympic swimmers.",
"Abra":"It sleeps 18 hours a day, using various psychic powers even while asleep.",
"Kadabra":"A special alpha wave emanates from it; just being near gives you a headache.",
"Alakazam":"Its brain calculates faster than a supercomputer; its IQ is roughly 5,000.",
"Machop":"Its whole body is muscle. Though childlike, it can throw a hundred adults.",
"Machoke":"A tough body that never tires; it helps with jobs like hauling very heavy loads.",
"Machamp":"Its four developed arms can throw 1,000 punches in two seconds.",
"Bellsprout":"From its human-faced bud, it is whispered to be a kind of the legendary mandrake.",
"Weepinbell":"Its leaves become cutters that slice foes, and its mouth spews a liquid that dissolves anything.",
"Victreebel":"A ferocious plant Pokémon common in the tropics, it dissolves anything with its acid.",
"Tentacool":"From its crystal-like eyes it fires a beam of mysterious light.",
"Tentacruel":"Its 80 tentacles move freely. Being stung causes poisoning and a sharp pain.",
"Geodude":"It lives in grasslands and mountains. Resembling a rock, people step on or trip over it unaware.",
"Graveler":"Rolling down steep mountain slopes, it crushes anything in its way.",
"Golem":"Its body is rock-hard. Even blowing it up with dynamite does no damage.",
"Ponyta":"Light-bodied with immense leg power, it can clear even Tokyo Tower in a single jump.",
"Rapidash":"Top speed 240 km/h. Ablaze, it races at the same speed as the bullet train.",
"Slowpoke":"Slow and dopey—so slow it feels pain only five seconds after being struck.",
"Slowbro":"When a Slowpoke went to sea for food, a Shellder bit its tail and it became Slowbro.",
"Magnemite":"It moves while floating, radiating electromagnetic waves from the units on either side.",
"Magneton":"Several Magnemite link together, radiating powerful magnetic lines and high voltage.",
"Farfetch'd":"It always walks around carrying a single plant stalk to build its nest.",
"Doduo":"Poor at flying but fast on foot, it dashes across the land leaving giant footprints.",
"Dodrio":"Its three heads manage clever strategies; even asleep, one head is said to stay awake.",
"Seel":"Its thick, tough skin is covered in aqua fur; it can stay active even at -40°C.",
"Dewgong":"Covered in pure white fur, it is strong against cold—the colder it is, the livelier it gets.",
"Grimer":"Sludge struck by X-rays from the moon changed into Grimer. Filthy things are its favorite food.",
"Muk":"Normally it blends into the ground unseen. Touch its body and you are poisoned.",
"Shellder":"It is covered by a shell harder than diamond, though its insides are very soft.",
"Cloyster":"Its shell is so hard not even a napalm bomb can break it; it opens only to attack.",
"Gastly":"A thin, gaseous life-form. Enveloped in its gas, even an Indian elephant collapses in two seconds.",
"Haunter":"If in the dark you feel watched though no one is there, a Haunter is there.",
"Gengar":"It is said that when you are stranded on a mountain, it appears from the dark to take your life.",
"Onix":"As it grows, the rock in its body changes until it becomes like a black diamond.",
"Drowzee":"A descendant of the legendary Tapir said to eat dreams; it is skilled at hypnosis.",
"Hypno":"It carries a pendulum-like object. There was an incident of it hypnotizing and spiriting away a child.",
"Krabby":"Its pincers are powerful weapons, and also balance its body as it walks sideways.",
"Kingler":"Its pincers hide 10,000-horsepower strength, but are so big it cannot move them well.",
"Voltorb":"It turns up at power plants. Many mistake it for a Poké Ball, touch it, and get zapped.",
"Electrode":"It stores enormous electron energy and explodes at the slightest stimulus.",
"Exeggcute":"It looks like eggs, but was found to be a plant-seed-like life-form.",
"Exeggutor":"A walking tropical rainforest; each of its fruits has a will of its own.",
"Cubone":"It wears the bone of its dead mother on its head, and when lonely is said to cry loudly.",
"Marowak":"Small and once weak, it turned ferocious after it began using bones.",
"Hitmonlee":"Its legs stretch and contract freely; even a distant foe is easily kicked.",
"Hitmonchan":"The spirit of a pro boxer possesses it; its punches are faster than the bullet train.",
"Lickitung":"Its tongue stretches twice its body length, moving like a hand to take food, attack, and more.",
"Koffing":"Its thin, balloon-like body is packed with poison gas; it stinks just from coming near.",
"Weezing":"Very rarely, by mutation, twin small Koffing come out still linked together.",
"Rhyhorn":"Dim but very strong, its body slam can smash even a skyscraper to pieces.",
"Rhydon":"Its whole body is protected by armor-like skin; it can survive even inside 2,000°C magma.",
"Chansey":"Its population is small, and it is said to bring happiness to whoever catches one.",
"Tangela":"Blue vines tangle together, hiding its true form; it coils around whatever comes near.",
"Kangaskhan":"The child rarely leaves the pouch on its mother's belly, leaving its parent in about three years.",
"Horsea":"It balances with its spring-coiled tail, and attacks by spitting ink.",
"Seadra":"By moving its fins and tail quickly, it can even swim backward while facing forward.",
"Goldeen":"Its dorsal and pectoral fins are muscle-like, and it swims through the water at 5 knots.",
"Seaking":"Its drill-sharp horn bores through rock faces to make its nest.",
"Staryu":"It appears in numbers on the seashore, and at night its core blinks red.",
"Starmie":"Because of its geometric body, locals suspect it may be an alien life-form.",
"Mr.Mime":"Good at making people believe, the wall it makes by pantomime is said to truly appear.",
"Scyther":"It slices prey with its sharp scythes to finish it; very rarely it flies using its wings.",
"Jynx":"It walks as if swinging its hips. Let your guard down and you are drawn, unwilling, into dancing.",
"Electabuzz":"Strong electricity is its favorite food, so it often appears at large power plants.",
"Magmar":"Found near volcanic craters; it breathes fire, and its body temperature reaches 1,200°C.",
"Pinsir":"Once caught between its two long horns, it is said it will not let go until you are torn apart.",
"Tauros":"Setting its sights on prey, it charges straight in, whipping its own body with its tail.",
"Magikarp":"Almost no strength or speed—the weakest, most pathetic Pokémon in the world.",
"Gyarados":"Extremely violent; the hyper beam from its mouth burns everything to ash.",
"Lapras":"Caught in great numbers in the past, it is near extinction. It carries people as it swims.",
"Ditto":"It can copy an opponent's cell structure in an instant and transform to look just like it.",
"Eevee":"It has irregular genes; radiation from stones causes its body to mutate suddenly.",
"Vaporeon":"It lives near water, but fish-like fins remain on its tail—some mistake it for a mermaid.",
"Jolteon":"It breathes in negative ions from the air and can spit out about 10,000 volts.",
"Flareon":"When it stores flame in its body its temperature tops 1,000°C, making it extremely dangerous.",
"Porygon":"Gathering the finest scientific power, they at last succeeded in creating an artificial Pokémon.",
"Omanyte":"An extinct Pokémon, but rarely a fossil is found from which it can be revived.",
"Omastar":"With sharp fangs and tentacles, once it bites prey it is over—it sucks out the body fluids.",
"Kabuto":"A Pokémon regenerated from an ancient creature's fossil; it guards itself with its hard shell.",
"Kabutops":"It swims freely and catches prey with its sharp scythes, sucking out the body fluids.",
"Aerodactyl":"Revived from a dinosaur's genes preserved in amber; it flies while crying shrilly.",
"Snorlax":"It is not satisfied unless it eats 400 kg of food a day, and falls asleep once it is done.",
"Articuno":"The legendary freeze Pokémon, said to appear before those freezing to death on a snowy mountain.",
"Zapdos":"A legendary bird Pokémon that appears while hurling giant lightning bolts from above the clouds.",
"Moltres":"Known since old as the firebird legend; each flap sets its wings blazing brightly—beautiful.",
"Dratini":"Long called a phantom Pokémon, it was found that a few do live underwater.",
"Dragonair":"Wingless yet able to fly, it bends its body supplely as it goes—very beautiful.",
"Dragonite":"Few have seen it, but this incarnation of the sea truly exists; its intellect seems to rival a human's.",
"Mewtwo":"Endlessly rewriting its genes for research turned it into a ferocious Pokémon.",
"Mew":"Even now called a phantom Pokémon; almost no one nationwide has seen its form.",
}

# ---- Move & item descriptions (auto-generated by build_descs.py) -----------
from desc_generated import MOVE_DESC, ITEM_DESC

# ---- Engine / battle / menu / system text ----------------------------------
from system_data import SYSTEM

# ---- Map dialogue, keyed by "MapStem:Label" (with #n for repeated labels) ---
DIALOGUE = {
"OldCityPokecenter2F:OldCityPokecenter2FTextString3":
 "Heave-ho!",
"OldCityPokecenter2F:OldCityPokecenter2FTextString4":
 "The thing behind me is a Time Machine.",
"OldCityPokecenterBattle:OldCityPokecenterBattleTextString1":
 "Just a moment, please!",
"OldCityPokecenterTrade:OldCityPokecenterTradeTextString1":
 "Just a moment, please!",
"PlayerHouse1F:PlayerHouse1FTextString1":
 "Mom: Oh? Professor Oak asked YOU to make a Pokédex for him? That's wonderful! It's not as if I dislike Pokémon either, so give it your best!",
"PlayerHouse2F:PlayerHouse2FTextString1":
 "Ken: Oh! That watch gleaming on your wrist... <PLAYER>, you finally bought a Trainer Gear too! Isn't that something! But fresh out of the box, all it tells you is the time, right? Later I'll set it up so you can see a map too! You're off to play anyway, aren't you? Too bad, though: Mom's out shopping, so there's no way you're getting any allowance today!",
"PlayerHouse2F:PlayerHouse2FTextString2":
 "That's right, there was mail waiting on your PC. If you're heading out, at least read your mail first.",
"PlayerHouse2F:PlayerHouse2FTextString3":
 "It's a doll my relatives in Kanto gave me as a Christmas present.",
"PlayerHouse2F:PlayerHouse2FTextString4":
 "I'm playing my Nintendo 64! ...... ...... Right then! Guess it's about time I headed outside to play!",
"PlayerHouse2F:PlayerHouse2FTextString5":
 "<PLAYER> turned on the PC! Huh? It looks like there's mail addressed to <PLAYER>. Read it?",
"PlayerHouse2F:PlayerHouse2FTextString6":
 "Forgive me for writing to you so suddenly. The truth is, there is something I simply must give you. Could you accept it? Pokémon researcher, Oak",
"PlayerHouse2F:PlayerHouse2FTextString7":
 "I'll read it later......",
"PlayerHouse2F:PlayerHouse2FTextString8":
 "New release: the Trainer Gear! The cutting-edge watch made for Pokémon Trainers. Of course it tells the time, but add a cartridge and it shows your location too! It makes phone calls! And to top it off, you can listen to the radio! To order... .............. it's on Silph's homepage.",
"PlayerHouse2F:PlayerHouse2FTextString9":
 "<PLAYER> switched on the radio! J-O-P-M. This is Pokémon Radio, bringing you the Pokémon News. ...... The world-renowned researcher Professor Oak has vanished from Kanto. Some believe he moved on in search of a new place to do research, but there is also a chance he was caught up in some incident, and those close to him are very worried. ...... That concludes the Pokémon News. ............ And now, please enjoy the music.",
"QuietHills:QuietHillsTrainer6EncounterString":
 "Hey, hey, look at this! This has GOT to be a new species of Pokémon!",
"QuietHills:QuietHillsTrainer6EncounterString#2":
 "I still don't know this Pokémon's traits, so it can't be helped.",
"QuietHills:QuietHillsTrainer6WonString":
 "Rumor has it that not just new Pokémon, but new types have been found too.",
"QuietHills:QuietHillsTrainer5EncounterString":
 "Lovely weather, isn't it~ How are you doing?",
"QuietHills:QuietHillsTrainer5EncounterString#2":
 "What was that for, meow~ ...what am I even saying?",
"QuietHills:QuietHillsTrainer5WonString":
 "Why did it turn out like this? I was only taking a walk...",
"QuietHills:QuietHillsTrainer4EncounterString":
 "Practicing my fire-breathing out here!",
"QuietHills:QuietHillsTrainer4EncounterString#2":
 "Ow-ow-ow, I blew it!",
"QuietHills:QuietHillsTrainer4WonString":
 "It gets dark once night falls, so kids, hurry on home! Me? I'm fine, I breathe fire.",
"QuietHills:QuietHillsTrainer3EncounterString":
 "When it comes to Bug Pokémon, I know more than anyone.",
"QuietHills:QuietHillsTrainer3EncounterString#2":
 "Para-para~",
"QuietHills:QuietHillsTrainer3WonString":
 "You're making a Pokédex? Let me see it a sec. Ohh, so you can search for Pokémon by type.",
"QuietHills:QuietHillsTrainer2EncounterString":
 "Just so you know, I study harder than you, so I'm definitely stronger than you!",
"QuietHills:QuietHillsTrainer2EncounterString#2":
 "W-why...?",
"QuietHills:QuietHillsTrainer2WonString":
 "That's strange... I study Pokémon properly every single day, and yet I lost...",
"QuietHills:QuietHillsTrainer6EncounterString#3":
 "Ta-daa! A never-before-seen Pokémon, a huge discovery!",
"QuietHills:QuietHillsTrainer6EncounterString#4":
 "I should have caught some other Pokémon too...",
"QuietHills:QuietHillsTrainer6WonString#2":
 "I've never seen your Pokémon either. Say, want to trade?",
"QuietHills:QuietHillsTrainer5EncounterString#3":
 "Hey, hey, let's have a Pokémon battle, come on~",
"QuietHills:QuietHillsTrainer5EncounterString#4":
 "Nooo~",
"QuietHills:QuietHillsTrainer5WonString#2":
 "It gets dark when night falls, right? Even walking, I can't see my surroundings well, and it's scary.",
"QuietHills:QuietHillsTrainer4EncounterString#3":
 "You! I won't get mad, so tell me where there's a pond!",
"QuietHills:QuietHillsTrainer4EncounterString#4":
 "If there's no water nearby...",
"QuietHills:QuietHillsTrainer4WonString#2":
 "Why is a grown man in a place like this?",
"QuietHills:QuietHillsTrainer3EncounterString#3":
 "Just started out with Pokémon? In that case I won't lose!",
"QuietHills:QuietHillsTrainer3EncounterString#4":
 "Whoa, what the heck?",
"QuietHills:QuietHillsTrainer3WonString#2":
 "Man, that's seriously frustrating.",
"QuietHills:QuietHillsTrainer2EncounterString#3":
 "This place is wide open, perfect for training. Training for what? Pokémon training, of course!",
"QuietHills:QuietHillsTrainer2EncounterString#4":
 "A-am I short on practice...?",
"QuietHills:QuietHillsTrainer2WonString#2":
 "Alright, time to run!",
"QuietHills:QuietHillsText1String":
 "The Pokémon on this hill are weak! That's why lots of Trainers train here. Everyone loves battling, so it's a good place to test your skill.",
"QuietHills:QuietHillsSignpost2String":
 "Quiet Hill. To Silent Hill, this way.",
"QuietHills:QuietHillsSignpost1String":
 "Quiet Hill. To Old City, this way.",
"RivalHouse:RivalHouseTextString1":
 "Huh? It looks like there's mail addressed to <RIVAL>. Read it?",
"RivalHouse:RivalHouseTextString2":
 "Forgive me for writing to you so suddenly. The truth is, there is something I simply must give you. Could you accept it? Pokémon researcher, Oak",
"RivalHouse:RivalHouseTextString3":
 "You shouldn't read other people's mail......",
"RivalHouse:RivalHouseTextString4":
 "The other day I spotted a Pidgey of an unusual color.",
"RivalHouse:RivalHouseTextString5":
 "Ken: Wh-wh-what, if it isn't <PLAYER>! I'm, uh, just here to help with some school homework! Huh? A map? Oh right, I did promise that. Got it, lend me your Trainer Gear. I'll slot the map cartridge in... and there, now you can see the map!",
"RivalHouse:RivalHouseTextString6":
 "If you're heading to Old City, you should meet a guy named Masaki. He's a friend of mine and a huge Pokémon maniac! He's sure to lend you a hand.",
"RivalHouse:RivalHouseTextString7":
 "Ken: <PLAYER>, I hear Professor Oak picked you to make a Pokédex? That's amazing, good luck!",
"Route2Gate1F:Route2Gate1FText1String":
 "Go through this gate and you'll reach Old City right away.",
"Route2Gate1F:Route2Gate1FText2String":
 "Old City has that famous Five-Story Pagoda. Have you ever been?",
"Route2Gate2F:Route2Gate2FTextString1":
 "Do you know Mr. Gantetsu? If you can get on his good side, you're quite the Trainer.",
"Route2Gate2F:Route2Gate2FTextString2":
 "Did you come sightseeing? Then that's a shame. Old City's Five-Story Pagoda isn't a place just anyone can enter.",
"Route2Gate2F:Route2Gate2FTextString3":
 "<PLAYER> peered through the telescope! Mmm! A tall, tall tower is visible!",
"Route2Gate2F:Route2Gate2FTextString4":
 "<PLAYER> peered through the telescope! Hmm? A long, long river is visible.",
"SilentHillLabBack:SilentHillLabBackTextString1":
 "Oak: See, there are three Pokémon over there! Ho ho! I'll give one to each of you. ...Now, choose!",
"SilentHillLabBack:SilentHillLabBackTextString2":
 "Oak: Now now, don't rush, <RIVAL>! You take your favorite too!",
"SilentHillLabBack:SilentHillLabBackTextString3":
 "Oak: Now then, <PLAYER>, which Pokémon will you have?",
"SilentHillLabBack:SilentHillLabBackTextString4":
 "Oak: Oho! The Fire Pokémon",
"SilentHillLabBack:SilentHillLabBackTextString4#2":
 "is the one for you, then?",
"SilentHillLabBack:SilentHillLabBackTextString5":
 "Oak: Hmm, the Water Pokémon",
"SilentHillLabBack:SilentHillLabBackTextString5#2":
 "is what you'll decide on, then?",
"SilentHillLabBack:SilentHillLabBackTextString6":
 "Oak: Ooh! The Grass Pokémon",
"SilentHillLabBack:SilentHillLabBackTextString6#2":
 "is the one you'd like, then?",
"SilentHillLabBack:SilentHillLabBackTextString7":
 "So, which will it be?",
"SilentHillLabBack:SilentHillLabBackTextString8":
 "Oak: This Pokémon is really full of energy! From Professor Oak, <PLAYER>",
"SilentHillLabBack:SilentHillLabBackTextString8#2":
 "received it!",
"SilentHillLabBack:SilentHillLabBackTextString9":
 "Oak: That's right! Even when wild Pokémon appear, if you have yours fight them, you'll be able to reach the next town!",
"SilentHillLabBack:SilentHillLabBackTextString10":
 "<RIVAL>: Ah! Me too! Gramps, give me one too!",
"SilentHillLabBack:SilentHillLabBackTextString11":
 "<RIVAL>: Fine, <PLAYER>! You choose first! I'm a generous guy, after all.",
"SilentHillLabBack:SilentHillLabBackTextString12":
 "<RIVAL>: Then I'll take this one!",
"SilentHillLabBack:SilentHillLabBackTextString13":
 "From Oak, <RIVAL>",
"SilentHillLabBack:SilentHillLabBackTextString13#2":
 "received it!",
"SilentHillLabBack:SilentHillLabBackTextString14":
 "<RIVAL>: <PLAYER>'s Pokémon is nice! But mine's pretty good too, right?",
"SilentHillLabBack:SilentHillLabBackTextString15":
 "Oak: Hey! Don't be greedy!",
"SilentHillLabFront:SilentHillLabFrontTextString1":
 "Looking at the PC, there was mail! ...... Professor Oak! The world is in an uproar over your going missing! By the way, that certain Pokémon you asked me to find: far from finding it, I can't even grasp a single clue. Maybe that thing really is a fictitious Pokémon after all...... From your assistant",
"SilentHillLabFront:SilentHillLabFrontTextString2A":
 "Push the START button! Press it and a menu opens up, ya know.",
"SilentHillLabFront:SilentHillLabFrontTextString2B":
 "To save, write a Pokémon Report. Best to do it often, ya know.",
"SilentHillLabFront:SilentHillLabFrontTextString3":
 "It's locked.",
"SilentHillLabFront:SilentHillLabFrontTextString4":
 "Oak: Good work!",
"SilentHillLabFront:SilentHillLabFrontTextString5":
 "Oak: That's right! I'm Oak! Sorry for being an old geezer! You two, I'm the one who called you here! Won't you hear me out for a bit?",
"SilentHillLabFront:SilentHillLabFrontTextString6A":
 "Oak: One year ago, in Kanto, I handed a Pokédex and Pokémon to boys like you for the sake of Pokémon research. And they did a truly fine job, succeeding in finding 150 kinds of Pokémon! But............ and yet...... the world is vast. Since then, new Pokémon have been turning up one after another all across the country! So I moved my research base from Kanto here, to Silent Hill. Change the place, and you can meet new Pokémon too. ........ I'll keep pushing my research forward, but as you can see I'm a worn-out old man. I have grandchildren and assistants, but even so, there simply aren't enough hands! <PLAYER>! <RIVAL>! Won't you lend your strength to Pokémon research?",
"SilentHillLabFront:SilentHillLabFrontTextString6B":
 "Oak: I see...... So I had no eye for people after all...... No! My eye for people can't be wrong! Right? You'll hear me out, won't you?",
"SilentHillLabFront:SilentHillLabFrontTextString7":
 "Oak: You two! Come with me a moment!",
"SilentHillLabFront:SilentHillLabFrontTextString8":
 "Oak: <PLAYER>! <RIVAL>! I entrust this Pokédex to you!",
"SilentHillLabFront:SilentHillLabFrontTextString9":
 "<PLAYER> received the Pokédex from Oak!",
"SilentHillLabFront:SilentHillLabFrontTextString10":
 "Oak: To make a complete Pokédex recording every Pokémon in this world, that was my dream! But new species keep turning up one after another! The time left to me is short! So I want you two to fulfill my dream in my place! Now, you two, set off at once! This is a great task that will go down in Pokémon history!",
"SilentHillLabFront:SilentHillLabFrontTextString11A":
 "Oak: Pokémon all over the world are waiting for <PLAYER>!",
"SilentHillLabFront:SilentHillLabFrontTextString11B":
 "Oak: Oh! <PLAYER>, how's it going? The Pokémon I gave you...? Oho! It seems quite attached to you now. You may have a talent for being a Pokémon Trainer. Keep dropping by to see me now and then, I'm curious about the pages of your Pokédex.",
"SilentHillLabFront:SilentHillLabFrontTextString12":
 "Oak: Welcome! How's your Pokédex coming along? Let's see...... shall I take a little look?",
"SilentHillLabFront:SilentHillLabFrontTextString13":
 "Oak: ...... Ahem! Well done, <PLAYER>! Come with me a moment! <RIVAL>, sorry, but wait there! <RIVAL>: Aww! What a cheapskate! Oak: <RIVAL>, weren't you just after a legendary Pokémon? <RIVAL>: *gulp*!",
"SilentHillLabFront:SilentHillLabFrontTextString14":
 "<RIVAL>: What, if it isn't <PLAYER>! I came because this place seemed suspicious too, but it looks like nobody's here......",
"SilentHillLabFront:SilentHillLabFrontTextString15":
 "<RIVAL>: Alright! Gramps! Leave it to me!",
"SilentHillLabFront:SilentHillLabFrontTextString16":
 "<RIVAL>: The Pokémon I picked looks stronger! You wanted this one, didn't you?",
"SilentHillLabFront:SilentHillLabFrontTextString17":
 "<RIVAL>: <PLAYER>! Since we got Pokémon from the old man...... let's have them battle a bit!",
"SilentHillLabFront:SilentHillLabFrontTextString18":
 "<RIVAL>: Dammit! Next time I definitely won't lose!",
"SilentHillLabFront:SilentHillLabFrontTextString19":
 "<RIVAL>: Alright! Let's battle other Pokémon and get stronger and stronger! Well then, bye-bye!",
"SilentHillLabFront:SilentHillLabFrontTextString20":
 "Gramps! I brought them along!",
"SilentHillLabFront:SilentHillLabFrontTextString21":
 "I once aimed to reach the very top as a Pokémon Trainer. Back then I was full of myself, until someone knocked me down a peg. You remind me a little of that guy. Thanks to him, I turned over a new leaf and began helping with the old man's research. ............ Now! This is the Pokédex! When you find a Pokémon, its data is written in automatically and the pages keep growing, a very high-tech Pokédex!",
"SilentHillLabFront:SilentHillLabFrontTextString22":
 "I did it long ago too, and it's quite a challenge...... Good luck!",
"SilentHillLabFront:SilentHillLabFrontTextString23":
 "Nanami: That young boy who brought you here earlier...... he's my little brother. Which means, yes! I'm Oak's granddaughter too! Grandpa is a fine Pokémon researcher, and I'm so happy I can help out! Oh, if he found out I said that, Grandpa would get carried away, so keep it a secret! ...... Grandpa seems to have completely forgotten, so I'll give you this instead! It's the latest-model Pokémon Backpack. <PLAYER> received the Pokémon Backpack! Nanami: This backpack has a Ball Holder that stores Poké Balls together, and a TM Holder that stores TMs together. I'll throw in 6 Poké Balls and one TM as a bonus, an empty holder is lonely after all! Say, <PLAYER>, your mom will worry, so before you leave town, go show her your face. ...... I'm praying for your success.",
"SilentHillLabFront:SilentHillLabFrontTextString24":
 "...... I'm praying for your success.",
"SilentHillLabFront:SilentHillLabFrontTextString25":
 "I'm the Professor's assistant. Of course, I hold the Professor in deep respect. I have a feeling you and I will meet again somewhere.",
"SilentHillLabFront:SilentHillLabFrontTextString26":
 "I'm the Professor's assistant. Of course, I hold the Professor in deep respect. I have a feeling you and I will meet again somewhere.",
"SilentHillLabFront:SilentHillLabFrontTextString27":
 "What's this? An electronic organizer, maybe?",
"SilentHillLabFront:SilentHillLabFrontTextString28":
 "<RIVAL>: So that Oak who sent the mail is this old geezer...... oh, sorry, this old man? It's my first time seeing the real thing!",
"SilentHillLabFront:SilentHillLabFrontTextString29":
 "<RIVAL>: <PLAYER>! Somehow this is starting to get fun!",
"SilentHillLabFront:SilentHillLabFrontTextString30":
 "I'm the Professor's assistant. I have a feeling you and I will meet again somewhere.",
"SilentHillLabFront:SilentHillLabFrontTextString31":
 "I'm the Professor's assistant. I have a feeling you and I will meet again somewhere.",
"SilentHillPokecenter:SilentHillPokecenterTextString1":
 "Currently under adjustment.",
"SilentHillPokecenter:SilentHillPokecenterTextString2":
 "I'm very sorry, but we're under repair right now, so we can't heal your Pokémon. Please take plenty of care when you leave town.",
"SilentHillPokecenter:SilentHillPokecenterTextString3":
 "That PC over there can be used free of charge anytime, as long as you're a Trainer. Handy, huh!",
"SilentHillPokecenter:SilentHillPokecenterTextString4":
 "That machine they're preparing now is supposedly amazing. They say it can even trade Pokémon across time! Is that really true?",
"SilentHillPokecenter:SilentHillPokecenterTextString5":
 "This is Houndoom. A type of Pokémon there's never been before.",
"SilentHillPokecenter:SilentHillPokecenterTextString6":
 "Houndoom: Grrrrr!",
"UnusedGen1Colosseum:UnusedGen1ColosseumText1":
 "!",
"UnusedGen1TradeCenter:UnusedGen1TradeCenterText1":
 "!",
}
