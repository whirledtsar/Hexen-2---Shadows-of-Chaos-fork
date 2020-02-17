This is a modification of the Shadows Of Chaos mod by Bloodshot, which itself is based on Game Of Tomes by peeweeRotA. It adds new enemies, alternate fire modes, and increases the importance of stats. Melee weapons' power scales with strength, magical abilities scale with wisdom/intelligence, and thrown weapons (plus the crossbow) scale with dexterity.

============
Weapon modes
============
	Explanations of each weapon's various attack modes (standard means unchanged from vanilla Hexen 2)

		Paladin
	Gauntlets
Normal: standard
Altfire: Stronger but slower punch
Tomed: Stronger, pushes enemies back slightly
Tomed altfire: Stronger altfire, pushes enemies far

	Vorpal sword
Main: standard
Altfire: Lightning throw*
Tomed: Stronger + reflects incoming projectiles
Tomed altfire: Quietus (fires projectiles)

	Axe
Main: standard
Altfire: Melee attack
Tomed: standard
Tomed altfire: Stronger altfire

	Purifier
Main: standard
Altfire: Fire trail (moves along the ground and burns enemies)
Tomed: standard
Tomed altfire: Flamethrower
 
		Crusader
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
Altfire: Meteor grenade
Tomed: standard
Tomed altfire: same as tomed

	Sunstaff
Main: standard
Altfire: same as main
Tomed: standard
Tomed altfire: same as tomed

		Necromancer
	Sickle
Main: standard
Altfire: Uses health to resurrect corpses as friendly monster (what type depends on your level and monster's level)
Tomed: Lightning strike
Tomed altfire: Resurrection with increased monster tier

	Magic missile
Main: standard
Altfire: Short-ranged attack that drains health if your health is low
Tomed: standard
Tomed altfire: Stronger altfire that always drains health

	Bone shards
Main: standard
Altfire: Explosive shard ball*
Tomed: Wide spread of shards
Tomed altfire: Shard ball that becomes a turret on impact*

		Assassin
	Crossbow
Main: Arrow that can stick in enemies; arrows that stick do damage over time but won't kill
Altfire: Spread with 1 strong bolt and 2 weak bolts (spread decreases as dexterity increases)
Tomed: Flaming arrow that sticks in enemies and then explodes
Tomed altfire: Spread with 5 powered-up bolts

	Others
Altfire: Chain hook

*Unlocked at level 3

=======
Changes
=======

	Changes to the SoC mod
-Various balance tweaks & bugfixes
-Corpses fading out can be toggled by typing "impulse 46" in console
-Monster respawning can be toggled with "impulse 45". Corpse fading needs to be enabled for it to work
-Random monster variations can be toggled with "impulse 47". This will take effect on the next map
-All classes receive mana & health upon leveling up (only the amount added to their maximum pool)
-Glyph artifact has a small delay between firing (length depends on class)
-All melee attacks knock enemies back
-Most explosions have dynamic light effects
-Assassin's Set Staff doesn't drain mana continuously after charging; tomed mode costs 20 mana instead of 30
-Inventory maximum amounts reduced to encourage use over hoarding - you can only carry 5 Quartz Flasks, and 1 or 2 each of powerful artifacts such as the Mystic Urn
-Disc of repulsion puts some monsters into jump state so they can't attack in the air
-Afrits no longer phase through geometry
-Skull wizards won't teleport immediately after teleporting in
-Archer Lord health (and experience points given) approximately halved
-Mummies make a sound and light up when firing arrows

	Mapping features
-Monsters can use "waketarget" field; they will trigger that entity upon sighting the player (eg. waketarget a button to simulate them pressing it); uses "delay" field if non-zero
-All monsters can use the SPAWNIN flag (128) to only spawn in when triggered; use SPAWNQUIET (65536) to spawn without teleport fog/noise
-Monster spawner func's can spawn more types of monsters (see spawnflags for full list); use SPAWN_SUPER (8388608) to spawn monster's super variant if applicable
-all flame/torch lights can use the soundtype field to use alternate ambient sounds
-trigger_relay can have a random delay; minimum and maximum seconds determined by cnt & lifetime fields
 respectively

	New entities - see FGD for further documentation
-monster_maulotaur: maulotaur from Heretic; model by Razumen, code by Whirledtsar
-monster_maulotaur_lord: boss-strength maulotaur
-custom_sound_ambient: ambient sound maker that can use any sound file; code by Shanjaq
-custom_sound_maker: triggered sound maker that can use any sound file; code by Shanjaq
-trigger_reflect: brush entity that reflects missiles
-trigger_kill: brush entity that forces its target to die when triggered or touched
-light_newfire: large raging fire; use spawnflag 4 to scale size from bottom; ported from the Portals of Praevus expansion
