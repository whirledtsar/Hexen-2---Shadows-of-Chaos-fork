This is a modification of the Shadows Of Chaos mod by Bloodshot, which itself is based on Game Of Tomes by peeweeRotA. It adds alternate fire modes, increases the importance of stats, and adds new enemies & features for mappers. Melee weapons' power scales with strength, magic damage scales with intelligence, secondary magic effects scale with wisdom, and thrown weapons (plus the crossbow) scale with dexterity. There are various features that can be toggled on/off - use console command "impulse 50".
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
Altfire: Uses health to resurrect corpses as friendly monster (what type depends on your level and monster's level)
Tomed: Lightning strike
Tomed altfire: Resurrection with increased monster tier

	Magic missile
Main: standard
Altfire: Short-range attack that drains health if your health is low
Tomed: standard
Tomed altfire: Stronger altfire that always drains health

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

		=All=
Intelligence: Cube Of Force lifetime
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

	Changes to the SoC mod
-Various balance tweaks & bugfixes
-Corpses fading out, monsters respawning, & random monster variations are disabled by default but can be toggled in the console. Type "impulse 50" to see your current settings and how to toggle them.
-All classes receive mana & health upon leveling up (only the amount added to their maximum pool)
-Glyph artifact has a small delay between firing (length depends on class)
-All melee attacks knock enemies back
-Most explosions have dynamic light effects
-Assassin's Set Staff doesn't drain mana continuously after charging
-Inventory maximum amounts reduced to encourage use over hoarding - you can only carry 5 Quartz Flasks, and 2 each of powerful artifacts such as the Mystic Urn
-Disc of repulsion puts some monsters into jump state so they can't attack in the air
-Afrits & Disciples no longer phase through geometry
-Archer Lord health (and experience points given) reduced by 1/3rd
-Mummies make a sound and light up when firing arrows
-Skull Wizard Lord can resurrect nearby corpses
-Fallen Angels rebalanced across the board

	Mapping features
-Instead of trigger messages using an index in strings.txt, messages (except for plaques) can use a plain string instead
-All monsters can use the SPAWNIN flag (128) to only spawn in when triggered; use SPAWNQUIET (65536) to spawn without teleport fog/noise
-Monsters can use "waketarget" field; they will trigger that entity upon sighting the player (eg. waketarget a button to simulate them pressing it); uses "delay" field if non-zero
-Path corners can also use "waketarget"; this target will be used when a monster or train reaches the path corner
-Monsters will wait at a path corner if it has a wait value
-Monster spawner func's can spawn more types of monsters (see spawnflags for full list); use SPAWN_SUPER (8388608) to spawn monster's super variant if applicable
-Torches & flames can use alternate sounds & volumes, determined by soundtype field
-Torches can emit ambient sounds (in vanilla they don't - use spawnflag 4 to enable) and the sounds will be toggled if the torch is triggered or shootable
-Relays can have a random delay; minimum and maximum seconds determined by cnt & lifetime fields
 respectively
-Change level triggers can reset player inventory (use spawnflag 16)
-If a trigger_hurt has a target, it will act like a relay and hurt its target when triggered
-If a texture's name starts with *slime, it will behave like swamp sludge (slowed movement and unique effects)

	New entities - see FGD for further documentation
-monster_maulotaur/monster_maulotaur_lord: maulotaur from Heretic; model by Razumen, code by Whirledtsar
-monster_reiver: reiver from Hexen; model by Razumen, code by Whirledtsar
-monster_roman/monster_roman_lord: Roman-style monster that behaves like the Mummy enemy
-monster_undying: reanimated corpse; model by Bloodshot, code by Bloodshot & Whirledtsar
-medusa_red: weaker variant of the Medusa with lower health and less aggressive missiles
-custom_model: non-interactive entity that can use any model; code by Joshua Skelton & Inky
-custom_sound_ambient: ambient sound maker that can use any sound file; code by Shanjaq
-custom_sound_maker: triggered sound maker that can use any sound file; code by Shanjaq
-light_chan: hanging chandelier
-light_newfire: large raging fire; ported from the Portals of Praevus expansion
-misc_mist: stationary animated fog clouds
-misc_mistgen: rolling fog
-misc_portal: portal sprite from Hexen 1
-misc_portal_big: blue circular portal sprite
-misc_starwall: magic particle effect
-misc_waterfall: waterfall model; can start off, be triggered off/on, make noise, be scaled, and be translucent
-obj_hang_corpse: hanging skeleton or corpse
-obj_skeleton_body: skeleton decoration
-obj_treecluster: cluster of dead trees
-trigger_ladder: brush entity that can be climbed with jump and descended with crouch
-trigger_reflect: brush entity that reflects missiles
-trigger_random: point entity that triggers a random entity from a range of targets.
-trigger_reverse: point entity that reverses the direction of targetted door or rotating entities
-fx_leaves: brush entity that spawns leaves with gravity; inspired by Hexen 1

==================
Additional credits
==================
	Incomplete list; most models can be assumed credit to Bloodshot
Bishop sounds: Hexen 1
Chandelier model: Heretic 2
Disciple sounds: Heretic
Fog sprites: Hexen 1
Legionnaire model: Rogue Software (Dissolution Of Eternity)
Maulotaur model: Razumen
Portal sprite: Hexen 1
Reiver model: Razumen
Tree (swaying) model: Hexen 2 beta
Tree snowy skin: whirledtsar
Waterfall models: originally by Preach, modified by Bloodshot & whirledtsar
Wendigo model: Bloodshot, based on Shambler model by Skiffy
