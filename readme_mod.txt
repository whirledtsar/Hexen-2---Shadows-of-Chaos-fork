This is a modification of the Shadows Of Chaos mod by Bloodshot, which itself is based on Game Of Tomes by peeweeRotA. It adds alternate fire modes, increases the importance of stats, and adds new enemies & features for mappers. Melee weapons' power scales with strength, magic damage scales with wisdom, secondary magic effects scale with intelligence, and thrown weapons (plus the crossbow) scale with dexterity. There are various features that can be toggled on/off - use console command "impulse 50".
Don't delete the autoexec.cfg file (unless you know what you're doing) - it's necessary to bind keys for altfire and stats menu.

============
Weapon modes
============
	Explanations of each weapon's various attack modes (standard means unchanged from vanilla Hexen 2)

		=Paladin=
	Gauntlets
Normal: standard
Altfire: Stronger but slower punch
Tomed: Stronger, pushes enemies back
Tomed altfire: Stronger altfire, pushes enemies even further

	Vorpal sword
Main: standard
Altfire: Lightning throw*
Tomed: Stronger + reflects incoming projectiles
Tomed altfire: Quietus (fires projectiles)

	Axe
Main: standard
Altfire: Melee attack (consumes no mana normally, but can be held to charge for a much stronger swing that uses mana)
Tomed: standard
Tomed altfire: Stronger altfire

	Purifier
Main: standard
Altfire: Flamethrower
Tomed: standard
Tomed altfire: Flame trail
 
		=Crusader=
	War hammer
Main: standard
Altfire: Throwing hammer boomerang*
Tomed: standard
Tomed altfire: same as tomed

	Ice mace
Main: standard
Altfire: Freeze wave (burst-fire with cooldown)
Tomed: standard
Tomed altfire: same as tomed

	Meteor staff
Main: standard
Altfire: same
Tomed: standard
Tomed altfire: same as tomed

	Sunstaff
Main: standard
Altfire: same
Tomed: standard
Tomed altfire: Sun ball that casts rays

		=Necromancer=
	Sickle
Main: standard
Altfire: Uses health to resurrect corpses as friendly monster (what type depends on your level and monster's level). If there is no corpse nearby, it will teleport existing out of sight/faraway minions to your location.
Tomed: Lightning strike
Tomed altfire: Resurrection with increased monster tier

	Magic missile
Main: standard
Altfire: Star wall that blocks projectiles in your field of view and disappears after a few seconds
Tomed: standard
Tomed altfire: Spinning star that passes through multiple enemies

	Bone shards
Main: standard
Altfire: Explosive shard ball*
Tomed: Wide spread of shards
Tomed altfire: Shard ball that becomes a turret on impact*

		=Assassin=
	Crossbow
Main: Arrow that can stick in enemies; arrows that stick do damage over time but won't kill
Altfire: Spread with 1 strong bolt and 2 weak bolts (spread decreases as dexterity increases)
Tomed: Flaming arrow that sticks in enemies and then explodes
Tomed altfire: Spread with 5 powered-up bolts

	Others
Altfire: Chain hook

*Unlocked at level 3

		=Demoness=
	Blood Rain
Main: standard
Altfire: Charge up to fire 3 shot spread
Tomed: standard
Tomed altfire: same as tomed

	Acid Orb
Main: standard
Altfire: Lingering poison scratch
Tomed: standard
Tomed altfire: same as tomed

	Flame Orb
Main: standard
Altfire: Flame circle
Tomed: standard
Tomed altfire: same as tomed

=================
Attribute effects
=================

		=General=
Dexterity: effectiveness of armor
Intelligence: Cube Of Force lifetime, mana capacity increase when levelling up
Wisdom: Cube Of Force damage

		=Paladin=
Strength: Gauntlets damage, Vorpal Sword damage
Intelligence: None
Wisdom: Vorpal Sword altfire missile damage, Vorpal Sword tomed missile damage
Dexterity: Warhammer damage

		=Crusader=
Strength: Warhammer damage
Intelligence: Ice Mace altfire spread, Ice Mace blizzard lifetime, Meteor Staff tornado lifetime
Wisdom: Blizzard damage
Dexterity: Warhammer thrown damage

		=Necromancer=
Strength: Sickle damage
Intelligence: Sickle lightning strike amount, Bone altfire shard amount, Bone turret firerate, Magic Missile homing rate
Wisdom: Magic Missile damage, Bone altfire damage
Dexterity: None

		=Assassin=
Strength: Katar damage
Intelligence: None
Wisdom: Set Staff scarab damage
Dexterity: Katar backstab chance, Crossbow spread

		=Demoness=
Strength: None
Intelligence: Acid Orb poison time, Flame Orb burning chance, Flame Orb flame circle radius
Wisdom: Blood Rain damage, Flame Orb damage, Tempest Staff damage
Dexterity: None

=======
Changes
=======

	Changes
-Various balance tweaks & bugfixes
-Stats affect gameplay more, and you can choose which ones to level up
-Corpses fading out, monsters respawning, & random monster variations are disabled by default but can be toggled in the console. Type "impulse 50" to see your current settings and how to toggle them.
-All classes receive mana & health upon leveling up (only the amount added to their capacity)
-Inventory maximum amounts reduced to encourage use over hoarding - you can only carry 5 Quartz Flasks, and 2 each of powerful artifacts such as the Mystic Urn
-Glyph artifact has a small delay between firing (length depends on class)
-Disc Of Repulsion works on flying and swimming enemies
-Disc of repulsion puts some monsters into jump state so they can't attack in the air
-All melee attacks knock enemies back
-Most explosions have dynamic light effects
-Assassin's Set Staff doesn't drain mana continuously after charging
-Necromancer's minions can follow player between maps if theyre close enough to exit
-Bishop attack works more like their Hexen 1 counterpart
-Archer Lord health (and experience points given) reduced by 1/3rd
-Mummies make a sound and light up when firing arrows
-Skull Wizard Lord can resurrect nearby corpses
-Fallen Angels rebalanced across the board
-Hydras can attack player if theyre out of water but close by

	Mapping features
-Instead of trigger messages using an index in strings.txt, messages (except for plaques) can use a plain string instead
-Switchable shadow support (with ericw light compiler)
-All monsters can use the SPAWNIN flag (128) to only spawn in when triggered; use SPAWNQUIET (65536) to spawn without teleport fog/noise
-Monsters can use "waketarget" field; they will trigger that entity upon sighting the player (eg. waketarget a button to simulate them pressing it); uses "delay" field if non-zero
-Path corners can also use "waketarget"; this target will be used when a monster or train reaches the path corner
-Monsters will wait at a path corner if it has a wait value
-Monster spawner func's can spawn more types of monsters (see spawnflags for full list); use SPAWN_SUPER spawnflag to use strong variant if applicable
-Torches & flames can use alternate sounds & volumes, determined by soundtype field
-Torches can emit ambient sounds (in vanilla they don't - use spawnflag 4 to enable) and the sounds will be toggled if the torch is triggered or shootable
-Relays can have a random delay; minimum and maximum seconds determined by cnt & lifetime fields
 respectively
-Change level triggers can reset player inventory (use spawnflag 16)
-If a trigger_hurt has a target, it will act like a relay and hurt its target when triggered
-If a texture's name starts with *slime, it will behave like swamp sludge (slowed movement and unique effects)
-Raven entity works (randomly wanders and cycles through animations)

	New entities - see FGD for further documentation
-monster_maulotaur/monster_maulotaur_lord: maulotaur from Heretic
-monster_reiver: reiver from Hexen; model by Razumen, code by whirledtsar
-monster_roman/monster_roman_lord: Roman-style monster that behaves like the Mummy enemy
-monster_undying: reanimated corpse; model by Bloodshot, code by Bloodshot & whirledtsar
-monster_medusa_red: weaker variant of the Medusa with lower health and less aggressive missiles
-misc_model: decorative entity that can use any model; can be breakable, solid with custom bounding box, and triggered on/off/killed depending on spawnflags
-custom_sound_ambient: ambient sound maker that can use any sound file
-custom_sound_maker: triggered sound maker that can use any sound file
-light_chan: hanging chandelier
-light_newfire: large raging fire; ported from the Portals of Praevus expansion
-misc_mist: stationary animated fog clouds
-misc_mistgen: rolling fog
-misc_portal: portal sprite from Hexen 1
-misc_portal_big: blue circular portal sprite
-misc_starwall: magic particle effect
-misc_waterfall: waterfall model; can start off, be triggered off/on, make noise, be scaled, use alternate skins, and be translucent
-obj_hang_corpse: hanging skeleton or corpse
-obj_skeleton_body: skeleton decoration
-obj_treecluster: cluster of dead trees
-trigger_ladder: brush entity that can be climbed with jump and descended with crouch
-trigger_reflect: brush entity that reflects missiles
-trigger_random: point entity that triggers a random entity from a range of targets
-trigger_reverse: point entity that reverses the direction of targetted door or rotating entities
-func_shadow: invisible, non-solid brush that casts a shadow
-misc_shadowcontroller: point entity that controls switchable shadows for brush entities (automatic and not necessary for doors, plats, & breakables)
-fx_leaves: brush entity that spawns leaves with gravity; inspired by Hexen 1

==================
Additional credits
==================
	Incomplete list; most models can be assumed credit to Bloodshot
Afrit code: Bloodshot, modified by whirledtsar
Afrit sounds: Hexen 1
Bishop sounds: Hexen 1
Bishop code: Bloodshot, modified by whirledtsar
Blood pool step sounds: Heretic 2
Chandelier model: Heretic 2
Cube Of Force disappear sound: Mageslayer
Death Knight code: Bloodshot
Disciple code: Bloodshot
Disciple sounds: Heretic
Fog sprites: Hexen 1
Legionnaire code: whirledtsar
Legionnaire model: Rogue Software (Dissolution Of Eternity)
Maulotaur code: whirledtsar
Maulotaur model: Razumen
Necromancer star wall sound: Mageslayer
Portal sprite: Hexen 1
Reiver code: whirledtsar
Reiver model: Razumen
Sludge enter sound: Hexen 1
Tree (swaying) model: Hexen 2 beta
Tree snowy skin: whirledtsar
Undying code: Bloodshot, modified by whirledtsar
Waterfall models: Preach, modified by Bloodshot and whirledtsar
Waterfall skins: Heretic 2, recolored by whirledtsar
Wendigo code: Bloodshot
Wendigo model: Bloodshot, based on Shambler model by Skiffy
custom_sound_maker/custom_sound_ambient code: Shanjaq
misc_model code: Joshua Skelton, modified by Inky and whirledtsar
