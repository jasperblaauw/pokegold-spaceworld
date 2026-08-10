; entry format:
;	db category
;	db height (meters * 10)
;	dw weight (kilograms * 10)
;	db entry text

PokedexEntryPointers1::
	dw BulbasaurDexEntry
	dw IvysaurDexEntry
	dw VenusaurDexEntry
	dw CharmanderDexEntry
	dw CharmeleonDexEntry
	dw CharizardDexEntry
	dw SquirtleDexEntry
	dw WartortleDexEntry
	dw BlastoiseDexEntry
	dw CaterpieDexEntry
	dw MetapodDexEntry
	dw ButterfreeDexEntry
	dw WeedleDexEntry
	dw KakunaDexEntry
	dw BeedrillDexEntry
	dw PidgeyDexEntry
	dw PidgeottoDexEntry
	dw PidgeotDexEntry
	dw RattataDexEntry
	dw RaticateDexEntry
	dw SpearowDexEntry
	dw FearowDexEntry
	dw EkansDexEntry
	dw ArbokDexEntry
	dw PikachuDexEntry
	dw RaichuDexEntry
	dw SandshrewDexEntry
	dw SandslashDexEntry
	dw NidoranFDexEntry
	dw NidorinaDexEntry
	dw NidoqueenDexEntry
	dw NidoranMDexEntry
	dw NidorinoDexEntry
	dw NidokingDexEntry
	dw ClefairyDexEntry
	dw ClefableDexEntry
	dw VulpixDexEntry
	dw NinetalesDexEntry
	dw JigglypuffDexEntry
	dw WigglytuffDexEntry
	dw ZubatDexEntry
	dw GolbatDexEntry
	dw OddishDexEntry
	dw GloomDexEntry
	dw VileplumeDexEntry
	dw ParasDexEntry
	dw ParasectDexEntry
	dw VenonatDexEntry
	dw VenomothDexEntry
	dw DiglettDexEntry
	dw DugtrioDexEntry
	dw MeowthDexEntry
	dw PersianDexEntry
	dw PsyduckDexEntry
	dw GolduckDexEntry
	dw MankeyDexEntry
	dw PrimeapeDexEntry
	dw GrowlitheDexEntry
	dw ArcanineDexEntry
	dw PoliwagDexEntry
	dw PoliwhirlDexEntry
	dw PoliwrathDexEntry
	dw AbraDexEntry
	dw KadabraDexEntry
	dw AlakazamDexEntry
	dw MachopDexEntry
	dw MachokeDexEntry
	dw MachampDexEntry
	dw BellsproutDexEntry
	dw WeepinbellDexEntry
	dw VictreebelDexEntry
	dw TentacoolDexEntry
	dw TentacruelDexEntry
	dw GeodudeDexEntry
	dw GravelerDexEntry
	dw GolemDexEntry
	dw PonytaDexEntry
	dw RapidashDexEntry
	dw SlowpokeDexEntry
	dw SlowbroDexEntry
	dw MagnemiteDexEntry
	dw MagnetonDexEntry
	dw FarfetchdDexEntry
	dw DoduoDexEntry
	dw DodrioDexEntry
	dw SeelDexEntry
	dw DewgongDexEntry
	dw GrimerDexEntry
	dw MukDexEntry
	dw ShellderDexEntry
	dw CloysterDexEntry
	dw GastlyDexEntry
	dw HaunterDexEntry
	dw GengarDexEntry
	dw OnixDexEntry
	dw DrowzeeDexEntry
	dw HypnoDexEntry
	dw KrabbyDexEntry
	dw KinglerDexEntry

BulbasaurDexEntry:
	db "SEED@"
	db 7
	dw 69
	db "The day it is@"
	db "born, a seed is@"
	db "set on its back;@"
	db "the two grow up@"
	db "together.@"
	db "@"

IvysaurDexEntry:
	db "SEED@"
	db 10
	dw 130
	db "A flower bud grows@"
	db "on its back. As it@"
	db "absorbs nutrients,@"
	db "the bud gradually@"
	db "develops.@"
	db "@"

VenusaurDexEntry:
	db "SEED@"
	db 20
	dw 1000
	db "To feed its huge@"
	db "flower, it moves@"
	db "toward sunny spots@"
	db "as if drawn to@"
	db "them.@"
	db "@"

CharmanderDexEntry:
	db "LIZARD@"
	db 6
	dw 85
	db "It loves hot@"
	db "things. The flame@"
	db "on its tail burns@"
	db "hotter when@"
	db "excited.@"
	db "@"

CharmeleonDexEntry:
	db "FLAME@"
	db 11
	dw 190
	db "Whipping its@"
	db "blazing tail, it@"
	db "raises the heat@"
	db "nearby to torment@"
	db "its foe.@"
	db "@"

CharizardDexEntry:
	db "FLAME@"
	db 17
	dw 905
	db "It breathes flames@"
	db "hot enough to melt@"
	db "rock and has@"
	db "started forest@"
	db "fires.@"
	db "@"

SquirtleDexEntry:
	db "TINYTURTL@"
	db 5
	dw 90
	db "After birth its@"
	db "back swells into a@"
	db "hard shell. It@"
	db "shoots foam from@"
	db "its mouth.@"
	db "@"

WartortleDexEntry:
	db "TURTLE@"
	db 10
	dw 225
	db "It hides@"
	db "underwater to@"
	db "stalk prey,@"
	db "steering with its@"
	db "ears when@"
	db "swimming.@"
	db "@"

BlastoiseDexEntry:
	db "SHELLFISH@"
	db 16
	dw 855
	db "So heavy and@"
	db "hard-shelled that@"
	db "most foes it@"
	db "body-slams are@"
	db "knocked out.@"
	db "@"

CaterpieDexEntry:
	db "WORM@"
	db 3
	dw 29
	db "Clad in green@"
	db "skin, it molts as@"
	db "it grows, then@"
	db "spins silk into a@"
	db "cocoon.@"
	db "@"

MetapodDexEntry:
	db "COCOON@"
	db 7
	dw 99
	db "Wrapped in a thin@"
	db "shell whose@"
	db "insides are soft;@"
	db "it cannot take a@"
	db "hard hit.@"
	db "@"

ButterfreeDexEntry:
	db "BUTTERFLY@"
	db 11
	dw 320
	db "Its wings are@"
	db "protected by@"
	db "water-repellent@"
	db "scales, so it can@"
	db "fly even on rainy@"
	db "days.@"
	db "@"

WeedleDexEntry:
	db "HAIRY BUG@"
	db 3
	dw 32
	db "Common in forests,@"
	db "it eats leaves.@"
	db "Its sharp head@"
	db "stinger poisons@"
	db "whatever it@"
	db "stings.@"
	db "@"

KakunaDexEntry:
	db "COCOON@"
	db 6
	dw 100
	db "It is transforming@"
	db "inside its shell@"
	db "to build its adult@"
	db "body. It can@"
	db "barely move.@"
	db "@"

BeedrillDexEntry:
	db "POISONBEE@"
	db 10
	dw 295
	db "Often in swarms,@"
	db "it flies at@"
	db "ferocious speed@"
	db "and stings with@"
	db "its rear barb.@"
	db "@"

PidgeyDexEntry:
	db "TINY BIRD@"
	db 3
	dw 18
	db "Widely spread@"
	db "through woods and@"
	db "forests. On@"
	db "landing, it flaps@"
	db "to kick up sand.@"
	db "@"

PidgeottoDexEntry:
	db "BIRD@"
	db 11
	dw 300
	db "Its claws are well@"
	db "developed. It@"
	db "carries prey up to@"
	db "100 km to its@"
	db "nest.@"
	db "@"

PidgeotDexEntry:
	db "BIRD@"
	db 15
	dw 395
	db "It spreads its@"
	db "fine wings to@"
	db "daunt foes and@"
	db "flies at Mach 2.@"
	db "@"

RattataDexEntry:
	db "MOUSE@"
	db 3
	dw 35
	db "It gnaws on@"
	db "anything. Small@"
	db "and quick, it@"
	db "turns up almost@"
	db "anywhere.@"
	db "@"

RaticateDexEntry:
	db "MOUSE@"
	db 7
	dw 185
	db "Its hind feet have@"
	db "three toes with@"
	db "small webbing, and@"
	db "it swims across@"
	db "rivers.@"
	db "@"

SpearowDexEntry:
	db "TINY BIRD@"
	db 3
	dw 20
	db "It eats bugs in@"
	db "the grass. With@"
	db "short wings, it@"
	db "flaps them busily.@"
	db "@"

FearowDexEntry:
	db "BEAK@"
	db 12
	dw 380
	db "With large wings@"
	db "it stays aloft in@"
	db "open sky, fine@"
	db "without ever@"
	db "landing.@"
	db "@"

EkansDexEntry:
	db "SNAKE@"
	db 20
	dw 69
	db "It hides in grassy@"
	db "fields. A young@"
	db "Ekans has no@"
	db "poison, so being@"
	db "bitten is@"
	db "harmless.@"
	db "@"

ArbokDexEntry:
	db "COBRA@"
	db 35
	dw 650
	db "Its belly pattern@"
	db "looks like a scary@"
	db "face; weak foes@"
	db "flee at the sight.@"
	db "@"

PikachuDexEntry:
	db "MOUSE@"
	db 4
	dw 60
	db "It has small@"
	db "electric sacs on@"
	db "both cheeks and@"
	db "discharges them@"
	db "when in a pinch.@"
	db "@"

RaichuDexEntry:
	db "MOUSE@"
	db 8
	dw 300
	db "Its shocks reach@"
	db "100,000 volts.@"
	db "Touch its tail and@"
	db "even an elephant@"
	db "faints.@"
	db "@"

SandshrewDexEntry:
	db "MOUSE@"
	db 6
	dw 120
	db "It digs a deep@"
	db "burrow to hide in@"
	db "dry places, coming@"
	db "out only to hunt@"
	db "prey.@"
	db "@"

SandslashDexEntry:
	db "MOUSE@"
	db 10
	dw 295
	db "Curled up, it is@"
	db "like a spiky ball.@"
	db "It rolls along to@"
	db "ram foes or to@"
	db "escape.@"
	db "@"

NidoranFDexEntry:
	db "POISONPIN@"
	db 4
	dw 70
	db "Small, but its@"
	db "poison barb is@"
	db "potent, take care.@"
	db "Its horn is small.@"
	db "@"

NidorinaDexEntry:
	db "POISONPIN@"
	db 8
	dw 200
	db "Being female, its@"
	db "horn grows slowly.@"
	db "It prefers close@"
	db "combat, scratching@"
	db "and biting.@"
	db "@"

NidoqueenDexEntry:
	db "DRILL@"
	db 13
	dw 600
	db "Its hard scales@"
	db "protect its whole@"
	db "body; it swings@"
	db "its tail to knock@"
	db "foes back.@"
	db "@"

NidoranMDexEntry:
	db "POISONPIN@"
	db 5
	dw 90
	db "It lifts its long@"
	db "ears to sense@"
	db "danger. Bigger@"
	db "spikes mean@"
	db "stronger poison.@"
	db "@"

NidorinoDexEntry:
	db "POISONPIN@"
	db 9
	dw 195
	db "Quick to fight,@"
	db "its head horn@"
	db "injects intense@"
	db "poison when it@"
	db "stabs.@"
	db "@"

NidokingDexEntry:
	db "DRILL@"
	db 14
	dw 620
	db "Its skin is@"
	db "diamond-hard and@"
	db "its long horn@"
	db "poisonous. Beware@"
	db "that horn.@"
	db "@"

ClefairyDexEntry:
	db "FAIRY@"
	db 6
	dw 75
	db "Adorable and@"
	db "mysterious, with@"
	db "many fans, but@"
	db "rare and hard to@"
	db "find.@"
	db "@"

ClefableDexEntry:
	db "FAIRY@"
	db 13
	dw 400
	db "Its hearing is so@"
	db "keen it can@"
	db "distinguish a pin@"
	db "dropped a@"
	db "kilometer away.@"
	db "@"

VulpixDexEntry:
	db "FOX@"
	db 6
	dw 99
	db "Though young, its@"
	db "six tails are@"
	db "beautiful. As it@"
	db "grows, its tails@"
	db "increase in@"
	db "number.@"
	db "@"

NinetalesDexEntry:
	db "FOX@"
	db 11
	dw 199
	db "With golden fur@"
	db "and nine long@"
	db "tails, it is said@"
	db "to live a thousand@"
	db "years.@"
	db "@"

JigglypuffDexEntry:
	db "BALLOON@"
	db 5
	dw 55
	db "When its round@"
	db "eyes waver, it@"
	db "sings a strange,@"
	db "pleasant song that@"
	db "makes you drowsy.@"
	db "@"

WigglytuffDexEntry:
	db "BALLOON@"
	db 10
	dw 120
	db "Its fine fur is@"
	db "supple to the@"
	db "touch; made into a@"
	db "pelt, it sells@"
	db "well.@"
	db "@"

ZubatDexEntry:
	db "BAT@"
	db 8
	dw 75
	db "It swarms in dark@"
	db "places, using@"
	db "ultrasonic waves@"
	db "to find its@"
	db "target.@"
	db "@"

GolbatDexEntry:
	db "BAT@"
	db 16
	dw 550
	db "It bites with@"
	db "sharp fangs and@"
	db "sucks up 300 cc of@"
	db "blood in a single@"
	db "go.@"
	db "@"

OddishDexEntry:
	db "WEED@"
	db 5
	dw 54
	db "By day it buries@"
	db "its face and@"
	db "barely moves; by@"
	db "night it walks,@"
	db "sowing seeds.@"
	db "@"

GloomDexEntry:
	db "WEED@"
	db 8
	dw 86
	db "The foul stench@"
	db "from its pistil@"
	db "carries 2 km and@"
	db "makes others@"
	db "faint.@"
	db "@"

VileplumeDexEntry:
	db "FLOWER@"
	db 12
	dw 186
	db "From the world's@"
	db "largest petals it@"
	db "scatters@"
	db "allergy-inducing@"
	db "pollen like a@"
	db "demon.@"
	db "@"

ParasDexEntry:
	db "MUSHROOM@"
	db 3
	dw 54
	db "The mushrooms on@"
	db "the bug's back are@"
	db "a cordyceps, and@"
	db "they grow larger@"
	db "over time.@"
	db "@"

ParasectDexEntry:
	db "MUSHROOM@"
	db 10
	dw 295
	db "It scatters poison@"
	db "spores; in China@"
	db "those spores are@"
	db "used as medicine.@"
	db "@"

VenonatDexEntry:
	db "INSECT@"
	db 10
	dw 300
	db "It nests in big@"
	db "trees and eats@"
	db "other bugs; at@"
	db "night it nears@"
	db "lights.@"
	db "@"

VenomothDexEntry:
	db "PSN MOTH@"
	db 15
	dw 125
	db "Scales cover its@"
	db "wings; each light@"
	db "flutter scatters@"
	db "highly poisonous@"
	db "powder.@"
	db "@"

DiglettDexEntry:
	db "MOLE@"
	db 2
	dw 8
	db "It burrows a meter@"
	db "down, gnawing tree@"
	db "roots, and rarely@"
	db "shows its face.@"
	db "@"

DugtrioDexEntry:
	db "MOLE@"
	db 7
	dw 333
	db "It tunnels through@"
	db "the earth to@"
	db "attack the unwary@"
	db "from an unexpected@"
	db "direction.@"
	db "@"

MeowthDexEntry:
	db "GHOSTCAT@"
	db 4
	dw 42
	db "It loves shiny@"
	db "things and often@"
	db "picks up money@"
	db "that has fallen@"
	db "here and there.@"
	db "@"

PersianDexEntry:
	db "SIAM CAT@"
	db 10
	dw 320
	db "Fierce-tempered.@"
	db "If it lifts its@"
	db "tail straight up,@"
	db "it will pounce and@"
	db "bite.@"
	db "@"

PsyduckDexEntry:
	db "DUCK@"
	db 8
	dw 196
	db "Always plagued by@"
	db "a headache; when@"
	db "it worsens it uses@"
	db "strange powers.@"
	db "@"

GolduckDexEntry:
	db "DUCK@"
	db 17
	dw 766
	db "Its webbed palms@"
	db "make it a strong@"
	db "swimmer, and its@"
	db "elegant form is@"
	db "seen at lakes.@"
	db "@"

MankeyDexEntry:
	db "PIGMONKEY@"
	db 5
	dw 280
	db "Nimble and@"
	db "violent. Once it@"
	db "gets angry and@"
	db "starts rampaging,@"
	db "it cannot be@"
	db "controlled.@"
	db "@"

PrimeapeDexEntry:
	db "PIGMONKEY@"
	db 10
	dw 320
	db "For no reason it@"
	db "flies into a rage@"
	db "and chases you no@"
	db "matter how far you@"
	db "run.@"
	db "@"

GrowlitheDexEntry:
	db "PUPPY@"
	db 7
	dw 190
	db "Friendly, but it@"
	db "has a wide@"
	db "territory, and if@"
	db "you approach@"
	db "carelessly it will@"
	db "attack.@"
	db "@"

ArcanineDexEntry:
	db "LEGENDARY@"
	db 19
	dw 1550
	db "A beautiful@"
	db "Pokémon admired@"
	db "since ancient@"
	db "times; it runs as@"
	db "if flying.@"
	db "@"

PoliwagDexEntry:
	db "TADPOLE@"
	db 6
	dw 124
	db "Its thin black@"
	db "skin shows its@"
	db "insides, seen as a@"
	db "spiral on its@"
	db "belly.@"
	db "@"

PoliwhirlDexEntry:
	db "TADPOLE@"
	db 10
	dw 200
	db "It can live on@"
	db "land or in water;@"
	db "on land it is@"
	db "always sweating to@"
	db "keep its body@"
	db "slimy.@"
	db "@"

PoliwrathDexEntry:
	db "TADPOLE@"
	db 13
	dw 540
	db "Skilled at the@"
	db "crawl and@"
	db "butterfly, it@"
	db "steadily overtakes@"
	db "even Olympic@"
	db "swimmers.@"
	db "@"

AbraDexEntry:
	db "PSI@"
	db 9
	dw 195
	db "It sleeps 18 hours@"
	db "a day, using@"
	db "various psychic@"
	db "powers even while@"
	db "asleep.@"
	db "@"

KadabraDexEntry:
	db "PSI@"
	db 13
	dw 565
	db "It emits alpha@"
	db "waves so strong@"
	db "that anyone near@"
	db "it gets a@"
	db "headache.@"
	db "@"

AlakazamDexEntry:
	db "PSI@"
	db 15
	dw 480
	db "Its brain@"
	db "calculates faster@"
	db "than a@"
	db "supercomputer; its@"
	db "IQ is roughly@"
	db "5,000.@"
	db "@"

MachopDexEntry:
	db "STRENGTH@"
	db 8
	dw 195
	db "Its whole body is@"
	db "muscle. Though@"
	db "childlike, it can@"
	db "throw a hundred@"
	db "adults.@"
	db "@"

MachokeDexEntry:
	db "STRENGTH@"
	db 15
	dw 705
	db "A tough body that@"
	db "never tires; it@"
	db "helps with jobs@"
	db "like hauling very@"
	db "heavy loads.@"
	db "@"

MachampDexEntry:
	db "STRENGTH@"
	db 16
	dw 1300
	db "Its four developed@"
	db "arms can throw@"
	db "1,000 punches in@"
	db "two seconds.@"
	db "@"

BellsproutDexEntry:
	db "FLOWER@"
	db 7
	dw 40
	db "From its@"
	db "human-faced bud,@"
	db "it is whispered to@"
	db "be a kind of the@"
	db "legendary@"
	db "mandrake.@"
	db "@"

WeepinbellDexEntry:
	db "FLYTRAP@"
	db 10
	dw 64
	db "Its leaves become@"
	db "cutters that slice@"
	db "foes; its mouth@"
	db "spews a dissolving@"
	db "fluid.@"
	db "@"

VictreebelDexEntry:
	db "FLYTRAP@"
	db 17
	dw 155
	db "A ferocious plant@"
	db "Pokémon common in@"
	db "the tropics, it@"
	db "dissolves anything@"
	db "with its acid.@"
	db "@"

TentacoolDexEntry:
	db "JELLYFISH@"
	db 9
	dw 455
	db "From its@"
	db "crystal-like eyes@"
	db "it fires a beam of@"
	db "mysterious light.@"
	db "@"

TentacruelDexEntry:
	db "JELLYFISH@"
	db 16
	dw 550
	db "Its 80 tentacles@"
	db "move freely. Being@"
	db "stung causes@"
	db "poisoning and a@"
	db "sharp pain.@"
	db "@"

GeodudeDexEntry:
	db "ROCK@"
	db 4
	dw 20
	db "It lives in@"
	db "mountains and@"
	db "fields. Looking@"
	db "like a rock,@"
	db "people trip over@"
	db "it.@"
	db "@"

GravelerDexEntry:
	db "ROCK@"
	db 10
	dw 1050
	db "Rolling down steep@"
	db "mountain slopes,@"
	db "it crushes@"
	db "anything in its@"
	db "way.@"
	db "@"

GolemDexEntry:
	db "MEGATON@"
	db 14
	dw 3000
	db "Its body is@"
	db "rock-hard. Even@"
	db "blowing it up with@"
	db "dynamite does no@"
	db "damage.@"
	db "@"

PonytaDexEntry:
	db "FIREHORSE@"
	db 10
	dw 300
	db "Light-bodied with@"
	db "immense leg power,@"
	db "it can clear even@"
	db "Tokyo Tower in a@"
	db "single jump.@"
	db "@"

RapidashDexEntry:
	db "FIREHORSE@"
	db 17
	dw 950
	db "Top speed 240@"
	db "km/h. Ablaze, it@"
	db "races at the same@"
	db "speed as the@"
	db "bullet train.@"
	db "@"

SlowpokeDexEntry:
	db "DOPEY@"
	db 12
	dw 360
	db "Slow and dopey, so@"
	db "slow it feels pain@"
	db "only five seconds@"
	db "after being@"
	db "struck.@"
	db "@"

SlowbroDexEntry:
	db "HERMIT@"
	db 16
	dw 785
	db "When a Slowpoke@"
	db "went to sea for@"
	db "food, a Shellder@"
	db "bit its tail and@"
	db "it became Slowbro.@"
	db "@"

MagnemiteDexEntry:
	db "MAGNET@"
	db 3
	dw 60
	db "It moves while@"
	db "floating,@"
	db "radiating@"
	db "electromagnetic@"
	db "waves from the@"
	db "units on either@"
	db "side.@"
	db "@"

MagnetonDexEntry:
	db "MAGNET@"
	db 10
	dw 600
	db "Several Magnemite@"
	db "link together,@"
	db "radiating powerful@"
	db "magnetic lines and@"
	db "high voltage.@"
	db "@"

FarfetchdDexEntry:
	db "WILD DUCK@"
	db 8
	dw 150
	db "It always walks@"
	db "around carrying a@"
	db "single plant stalk@"
	db "to build its nest.@"
	db "@"

DoduoDexEntry:
	db "TWIN BIRD@"
	db 14
	dw 392
	db "Poor at flying but@"
	db "fast on foot, it@"
	db "dashes across the@"
	db "land leaving giant@"
	db "footprints.@"
	db "@"

DodrioDexEntry:
	db "TRI-BIRD@"
	db 18
	dw 852
	db "Its three heads@"
	db "manage clever@"
	db "strategies; even@"
	db "asleep, one head@"
	db "is said to stay@"
	db "awake.@"
	db "@"

SeelDexEntry:
	db "SEA LION@"
	db 11
	dw 900
	db "Its thick, tough@"
	db "skin is covered in@"
	db "aqua fur; it can@"
	db "stay active even@"
	db "at -40C.@"
	db "@"

DewgongDexEntry:
	db "SEA LION@"
	db 17
	dw 1200
	db "Clad in white fur,@"
	db "it loves the cold,@"
	db "growing livelier@"
	db "as it gets colder.@"
	db "@"

GrimerDexEntry:
	db "SLUDGE@"
	db 9
	dw 300
	db "Sludge hit by moon@"
	db "X-rays became@"
	db "Grimer. It feeds@"
	db "on the filthiest@"
	db "things.@"
	db "@"

MukDexEntry:
	db "SLUDGE@"
	db 12
	dw 300
	db "Normally it blends@"
	db "into the ground@"
	db "unseen. Touch its@"
	db "body and you are@"
	db "poisoned.@"
	db "@"

ShellderDexEntry:
	db "BIVALVE@"
	db 3
	dw 40
	db "It is covered by a@"
	db "shell harder than@"
	db "diamond, though@"
	db "its insides are@"
	db "very soft.@"
	db "@"

CloysterDexEntry:
	db "BIVALVE@"
	db 15
	dw 1325
	db "Its shell is so@"
	db "hard not even a@"
	db "napalm bomb can@"
	db "break it; it opens@"
	db "only to attack.@"
	db "@"

GastlyDexEntry:
	db "GAS@"
	db 13
	dw 1
	db "A thin gas@"
	db "life-form. Wrapped@"
	db "in its gas, even@"
	db "an elephant faints@"
	db "in seconds.@"
	db "@"

HaunterDexEntry:
	db "GAS@"
	db 16
	dw 1
	db "If in the dark you@"
	db "feel watched@"
	db "though no one is@"
	db "there, a Haunter@"
	db "is there.@"
	db "@"

GengarDexEntry:
	db "SHADOW@"
	db 15
	dw 405
	db "It is said that on@"
	db "a lonely mountain@"
	db "it appears from@"
	db "the dark to take@"
	db "your life.@"
	db "@"

OnixDexEntry:
	db "ROCKSNAKE@"
	db 88
	dw 2100
	db "As it grows, the@"
	db "rock in its body@"
	db "changes until it@"
	db "becomes like a@"
	db "black diamond.@"
	db "@"

DrowzeeDexEntry:
	db "HYPNOSIS@"
	db 10
	dw 324
	db "A descendant of@"
	db "the legendary@"
	db "Tapir said to eat@"
	db "dreams; it is@"
	db "skilled at@"
	db "hypnosis.@"
	db "@"

HypnoDexEntry:
	db "HYPNOSIS@"
	db 16
	dw 756
	db "It holds a@"
	db "pendulum. One@"
	db "child was@"
	db "hypnotized by it@"
	db "and spirited away.@"
	db "@"

KrabbyDexEntry:
	db "RIVERCRAB@"
	db 4
	dw 65
	db "Its pincers are@"
	db "powerful weapons,@"
	db "and also balance@"
	db "its body as it@"
	db "walks sideways.@"
	db "@"

KinglerDexEntry:
	db "PINCER@"
	db 13
	dw 600
	db "Its pincers hide@"
	db "10,000-horsepower@"
	db "strength, but are@"
	db "so big it cannot@"
	db "move them well.@"
	db "@"

PokedexEntryPointers2::
	dw VoltorbDexEntry
	dw ElectrodeDexEntry
	dw ExeggcuteDexEntry
	dw ExeggutorDexEntry
	dw CuboneDexEntry
	dw MarowakDexEntry
	dw HitmonleeDexEntry
	dw HitmonchanDexEntry
	dw LickitungDexEntry
	dw KoffingDexEntry
	dw WeezingDexEntry
	dw RhyhornDexEntry
	dw RhydonDexEntry
	dw ChanseyDexEntry
	dw TangelaDexEntry
	dw KangaskhanDexEntry
	dw HorseaDexEntry
	dw SeadraDexEntry
	dw GoldeenDexEntry
	dw SeakingDexEntry
	dw StaryuDexEntry
	dw StarmieDexEntry
	dw MrMimeDexEntry
	dw ScytherDexEntry
	dw JynxDexEntry
	dw ElectabuzzDexEntry
	dw MagmarDexEntry
	dw PinsirDexEntry
	dw TaurosDexEntry
	dw MagikarpDexEntry
	dw GyaradosDexEntry
	dw LaprasDexEntry
	dw DittoDexEntry
	dw EeveeDexEntry
	dw VaporeonDexEntry
	dw JolteonDexEntry
	dw FlareonDexEntry
	dw PorygonDexEntry
	dw OmanyteDexEntry
	dw OmastarDexEntry
	dw KabutoDexEntry
	dw KabutopsDexEntry
	dw AerodactylDexEntry
	dw SnorlaxDexEntry
	dw ArticunoDexEntry
	dw ZapdosDexEntry
	dw MoltresDexEntry
	dw DratiniDexEntry
	dw DragonairDexEntry
	dw DragoniteDexEntry
	dw MewtwoDexEntry
	dw MewDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry ; should be ElebabyDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry
	dw NewcomerDexEntry

VoltorbDexEntry:
	db "BALL@"
	db 5
	dw 104
	db "Seen at power@"
	db "plants. Mistaken@"
	db "for a Poké Ball,@"
	db "it zaps those who@"
	db "touch it.@"
	db "@"

ElectrodeDexEntry:
	db "BALL@"
	db 12
	dw 666
	db "It stores enormous@"
	db "electron energy@"
	db "and explodes at@"
	db "the slightest@"
	db "stimulus.@"
	db "@"

ExeggcuteDexEntry:
	db "EGG@"
	db 4
	dw 25
	db "It looks like@"
	db "eggs, but was@"
	db "found to be a@"
	db "plant-seed-like@"
	db "life-form.@"
	db "@"

ExeggutorDexEntry:
	db "COCONUT@"
	db 20
	dw 1200
	db "A walking tropical@"
	db "rainforest; each@"
	db "of its fruits has@"
	db "a will of its own.@"
	db "@"

CuboneDexEntry:
	db "LONELY@"
	db 4
	dw 65
	db "It wears its dead@"
	db "mother's bone on@"
	db "its head and cries@"
	db "loudly when@"
	db "lonely.@"
	db "@"

MarowakDexEntry:
	db "BONEKEEP@"
	db 10
	dw 450
	db "Small and once@"
	db "weak, it turned@"
	db "ferocious after it@"
	db "began using bones.@"
	db "@"

HitmonleeDexEntry:
	db "KICKING@"
	db 15
	dw 498
	db "Its legs stretch@"
	db "and contract@"
	db "freely; even a@"
	db "distant foe is@"
	db "easily kicked.@"
	db "@"

HitmonchanDexEntry:
	db "PUNCHING@"
	db 14
	dw 502
	db "The spirit of a@"
	db "pro boxer@"
	db "possesses it; its@"
	db "punches are faster@"
	db "than the bullet@"
	db "train.@"
	db "@"

LickitungDexEntry:
	db "LICKING@"
	db 12
	dw 655
	db "Its tongue@"
	db "stretches twice@"
	db "its length,@"
	db "working like a@"
	db "hand to eat and@"
	db "attack.@"
	db "@"

KoffingDexEntry:
	db "POISONGAS@"
	db 6
	dw 10
	db "Its balloon body@"
	db "is packed with@"
	db "poison gas; it@"
	db "reeks from nearby.@"
	db "@"

WeezingDexEntry:
	db "POISONGAS@"
	db 12
	dw 95
	db "Very rarely, by@"
	db "mutation, twin@"
	db "small Koffing come@"
	db "out still linked@"
	db "together.@"
	db "@"

RhyhornDexEntry:
	db "SPIKES@"
	db 10
	dw 1150
	db "Dim but very@"
	db "strong, its body@"
	db "slam can smash@"
	db "even a skyscraper@"
	db "to pieces.@"
	db "@"

RhydonDexEntry:
	db "DRILL@"
	db 19
	dw 1200
	db "Armor-like skin@"
	db "guards its body;@"
	db "it can survive@"
	db "inside 2,000C@"
	db "magma.@"
	db "@"

ChanseyDexEntry:
	db "EGG@"
	db 11
	dw 346
	db "Its population is@"
	db "small, and it is@"
	db "said to bring@"
	db "happiness to@"
	db "whoever catches@"
	db "one.@"
	db "@"

TangelaDexEntry:
	db "VINE@"
	db 10
	dw 350
	db "Blue vines tangle@"
	db "together, hiding@"
	db "its true form; it@"
	db "coils around@"
	db "whatever comes@"
	db "near.@"
	db "@"

KangaskhanDexEntry:
	db "PARENT@"
	db 22
	dw 800
	db "The child rarely@"
	db "leaves its@"
	db "mother's belly@"
	db "pouch until about@"
	db "three years old.@"
	db "@"

HorseaDexEntry:
	db "DRAGON@"
	db 4
	dw 80
	db "It balances with@"
	db "its spring-coiled@"
	db "tail, and attacks@"
	db "by spitting ink.@"
	db "@"

SeadraDexEntry:
	db "DRAGON@"
	db 12
	dw 250
	db "By moving its fins@"
	db "and tail quickly,@"
	db "it can even swim@"
	db "backward while@"
	db "facing forward.@"
	db "@"

GoldeenDexEntry:
	db "GOLDFISH@"
	db 6
	dw 150
	db "Its fins are@"
	db "muscle-like,@"
	db "letting it swim@"
	db "through water at 5@"
	db "knots.@"
	db "@"

SeakingDexEntry:
	db "GOLDFISH@"
	db 13
	dw 390
	db "Its drill-sharp@"
	db "horn bores through@"
	db "rock faces to make@"
	db "its nest.@"
	db "@"

StaryuDexEntry:
	db "STARSHAPE@"
	db 8
	dw 345
	db "It appears in@"
	db "numbers on the@"
	db "seashore, and at@"
	db "night its core@"
	db "blinks red.@"
	db "@"

StarmieDexEntry:
	db "MYSTERY@"
	db 11
	dw 800
	db "Because of its@"
	db "geometric body,@"
	db "locals suspect it@"
	db "may be an alien@"
	db "life-form.@"
	db "@"

MrMimeDexEntry:
	db "BARRIER@"
	db 13
	dw 545
	db "Good at making@"
	db "people believe,@"
	db "the wall it makes@"
	db "by pantomime is@"
	db "said to truly@"
	db "appear.@"
	db "@"

ScytherDexEntry:
	db "MANTIS@"
	db 15
	dw 560
	db "It finishes prey@"
	db "with sharp@"
	db "scythes; very@"
	db "rarely it flies@"
	db "with its wings.@"
	db "@"

JynxDexEntry:
	db "HUMANOID@"
	db 14
	dw 406
	db "It walks swinging@"
	db "its hips. Drop@"
	db "your guard and you@"
	db "are drawn into@"
	db "dancing.@"
	db "@"

ElectabuzzDexEntry:
	db "ELECTRIC@"
	db 11
	dw 300
	db "Strong electricity@"
	db "is its favorite@"
	db "food, so it often@"
	db "appears at large@"
	db "power plants.@"
	db "@"

MagmarDexEntry:
	db "SPITFIRE@"
	db 13
	dw 445
	db "Found near@"
	db "craters; it@"
	db "breathes fire, its@"
	db "body reaching@"
	db "1,200C.@"
	db "@"

PinsirDexEntry:
	db "STAGBUG@"
	db 15
	dw 550
	db "Once gripped@"
	db "between its long@"
	db "horns, prey is@"
	db "said to be torn@"
	db "clean apart.@"
	db "@"

TaurosDexEntry:
	db "WILD BULL@"
	db 14
	dw 884
	db "Fixing on prey, it@"
	db "charges straight@"
	db "in, whipping@"
	db "itself with its@"
	db "tail.@"
	db "@"

MagikarpDexEntry:
	db "FISH@"
	db 9
	dw 100
	db "Almost no strength@"
	db "or speed, the@"
	db "weakest, most@"
	db "pathetic Pokémon@"
	db "in the world.@"
	db "@"

GyaradosDexEntry:
	db "ATROCIOUS@"
	db 65
	dw 2350
	db "Extremely violent;@"
	db "the hyper beam@"
	db "from its mouth@"
	db "burns everything@"
	db "to ash.@"
	db "@"

LaprasDexEntry:
	db "TRANSPORT@"
	db 25
	dw 2200
	db "Once overhunted,@"
	db "it nears@"
	db "extinction. It@"
	db "ferries people as@"
	db "it swims.@"
	db "@"

DittoDexEntry:
	db "TRANSFORM@"
	db 3
	dw 40
	db "It copies a foe's@"
	db "cell structure@"
	db "instantly and@"
	db "transforms to@"
	db "match it.@"
	db "@"

EeveeDexEntry:
	db "EVOLUTION@"
	db 3
	dw 65
	db "It has irregular@"
	db "genes; radiation@"
	db "from stones causes@"
	db "its body to mutate@"
	db "suddenly.@"
	db "@"

VaporeonDexEntry:
	db "BUBBLEJET@"
	db 10
	dw 290
	db "It lives near@"
	db "water; fins on its@"
	db "tail lead some to@"
	db "call it a mermaid.@"
	db "@"

JolteonDexEntry:
	db "LIGHTNING@"
	db 8
	dw 245
	db "It breathes in@"
	db "negative ions from@"
	db "the air and can@"
	db "spit out about@"
	db "10,000 volts.@"
	db "@"

FlareonDexEntry:
	db "FLAME@"
	db 9
	dw 250
	db "Storing flame in@"
	db "its body, its heat@"
	db "tops 1,000C,@"
	db "making it very@"
	db "dangerous.@"
	db "@"

PorygonDexEntry:
	db "VIRTUAL@"
	db 8
	dw 365
	db "Using the finest@"
	db "science, humans at@"
	db "last created an@"
	db "artificial@"
	db "Pokémon.@"
	db "@"

OmanyteDexEntry:
	db "SPIRAL@"
	db 4
	dw 75
	db "An ancient Pokémon@"
	db "revived from a@"
	db "fossil; it swims@"
	db "by waving its@"
	db "tentacles.@"
	db "@"

OmastarDexEntry:
	db "SPIRAL@"
	db 10
	dw 350
	db "With sharp fangs@"
	db "and tentacles,@"
	db "once it bites it@"
	db "sucks out the body@"
	db "fluids.@"
	db "@"

KabutoDexEntry:
	db "SHELLFISH@"
	db 5
	dw 115
	db "Regenerated from@"
	db "an ancient fossil;@"
	db "it shields itself@"
	db "with its hard@"
	db "shell.@"
	db "@"

KabutopsDexEntry:
	db "SHELLFISH@"
	db 13
	dw 405
	db "It swims freely@"
	db "and catches prey@"
	db "with its sharp@"
	db "scythes, sucking@"
	db "out the body@"
	db "fluids.@"
	db "@"

AerodactylDexEntry:
	db "FOSSIL@"
	db 18
	dw 590
	db "Revived from a@"
	db "dinosaur's genes@"
	db "preserved in@"
	db "amber; it flies@"
	db "while crying@"
	db "shrilly.@"
	db "@"

SnorlaxDexEntry:
	db "DOZING@"
	db 21
	dw 4600
	db "Unless it eats 400@"
	db "kg a day it is@"
	db "unhappy, then@"
	db "sleeps once it is@"
	db "done.@"
	db "@"

ArticunoDexEntry:
	db "FREEZE@"
	db 17
	dw 554
	db "A legendary ice@"
	db "bird, said to@"
	db "appear before@"
	db "those freezing on@"
	db "a snowy peak.@"
	db "@"

ZapdosDexEntry:
	db "ELECTRIC@"
	db 16
	dw 526
	db "A legendary bird@"
	db "that appears@"
	db "hurling giant@"
	db "lightning bolts@"
	db "from the clouds.@"
	db "@"

MoltresDexEntry:
	db "FLAME@"
	db 20
	dw 600
	db "The fabled@"
	db "firebird; each@"
	db "flap sets its@"
	db "wings blazing@"
	db "brightly,@"
	db "beautiful.@"
	db "@"

DratiniDexEntry:
	db "DRAGON@"
	db 18
	dw 33
	db "Long called a@"
	db "phantom Pokémon,@"
	db "it was found that@"
	db "a few do live@"
	db "underwater.@"
	db "@"

DragonairDexEntry:
	db "DRAGON@"
	db 40
	dw 165
	db "Wingless yet able@"
	db "to fly, it bends@"
	db "its body supplely@"
	db "as it goes, very@"
	db "beautiful.@"
	db "@"

DragoniteDexEntry:
	db "DRAGON@"
	db 22
	dw 2100
	db "Rarely seen, this@"
	db "sea deity truly@"
	db "exists; its wits@"
	db "seem to rival a@"
	db "human's.@"
	db "@"

MewtwoDexEntry:
	db "GENETIC@"
	db 20
	dw 1220
	db "Endlessly@"
	db "rewriting its@"
	db "genes for research@"
	db "turned it into a@"
	db "ferocious Pokémon.@"
	db "@"

MewDexEntry:
	db "NEW KIND@"
	db 4
	dw 40
	db "Even now called a@"
	db "phantom Pokémon;@"
	db "almost no one@"
	db "nationwide has@"
	db "seen its form.@"
	db "@"

NewcomerDexEntry:
	db "???@"
	db 0
	dw 0
	db "A Pokémon that has@"
	db "only just been@"
	db "discovered.@"
	db "Currently under@"
	db "investigation.@"
	db "@"
