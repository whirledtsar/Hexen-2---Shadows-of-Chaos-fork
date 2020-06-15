float RANDOM_SINGLETRIG		= 1;
float RANDOM_NOREPEAT		= 2;
float RANDOM_IGNOREMISSING	= 4;
float RANDOM_REMOVELOSER	= 16;

/*	trigger_reflect
Brush entity that reflects any missiles that hit it, with a slight random adjustment in angle. Can be used in conjunction with func_wall to block movement and un-reflectable attacks like lightning beams.
Don't killtarget this entity - just target it to remove it.
Speed: Modifier to missile's original speed. Less than 1 is recommended so the player has a better chance of dodging reflected missiles.
Spawnflags: Deactivated (8) to start deactivated and activate when used. Targetting it after this will remove it like normal.
Issues: Behaves oddly with thrown Warhammer; doesn't account for Tornado
*/

void reflect_touch ()
{
	if (self.inactive || !IsMissile(other) || (other.safe_time && other.safe_time>time))	//IsMissile is in ai.hc
		return;		//use safe_time to check if missile was already just reflected, or else it can get stuck in back & forth loop
	
	/*if (self.movedir != '0 0 0')
	{
		makevectors (other.angles);
		if (v_forward * self.movedir < 0)
			return;		// not facing the right way
	}*/
	if (other.classname=="tornato"||other.classname=="funnal"||other.classname=="chain_head")
		return;		//don't know how to handle these yet
	other.velocity *= (-self.speed);
	makevectors(other.velocity);
	other.velocity += (v_up*random(-60,60) + v_right*random(-60,60));
	other.angles = vectoangles(other.velocity);
	if(other.movedir) {
		other.movedir=other.angles;
		other.movedir=normalize(other.velocity);
	}
	if(other.o_angle)
		other.o_angle=other.angles;
	
	other.owner = other.controller = self.goalentity;
	if (other.owner && other.enemy)
		other.enemy = other.owner;
	else if (other.controller && other.enemy)
		other.enemy = other.controller;
	else if (other.enemy)
		other.enemy = world;
	other.safe_time = time+1;
	if (other.effects & EF_NODRAW && other.touch==bone_shard_touch)		//don't know why bone shards become invisible, but they do
		other.effects (-) EF_NODRAW;
	
	CreateBlueFlash(other.origin);
	if (self.pain_finished <= time)
	{
		setorigin (self.goalentity, other.origin);
		sound (self.goalentity, CHAN_AUTO, "raven/blast.wav", 1, ATTN_NORM);
		self.pain_finished = time+0.3;
	}
}

void reflect_remove ()
{
	remove(self.goalentity);
	remove(self);
}

void trigger_reflect ()
{
	InitTrigger();
	self.touch=reflect_touch;
	self.use=reflect_remove;
	
	if (!self.speed)
		self.speed = 1;
	else
		self.speed = fabs(self.speed);
	
	entity reflector;
	reflector = spawn();
	setorigin (reflector, ((self.mins + self.maxs) * 0.5));
	self.goalentity = reflector;	//ws: set missile owner as dummy entity, because setting it to world doesn't work out at all
	self.pain_finished = time;		//delay between making reflection noise
}

/*======================================================================
 Player ladder (originally from Rubicon2 codebase by JohnFitz)
 - This is a very simple system, jump to attach to the ladder brush
 - move up down via jumpping (hook in preplayer code)
 - Added multiple climbing sounds (works with player footsound state)
 - Modified to have on/off/toggle state via triggers
 - Downsides to system, there is no abilty to go down a ladder

/*======================================================================
/*QUAKED trigger_ladder (.5 .5 .5) x x x Deactivated
Invisible brush based ladder (jump key to climb)
-------- KEYS --------
targetname : trigger entity
angle    : direction player must be facing to climb ladder (required)
count  : time between climb sound (def = depends on sound type)
speed    : velocity speed to climb ladder (def=160)
sounds   : whether to use rope sound or not
-------- SPAWNFLAGS --------
Deactivated : Starts off and waits for trigger
-------- NOTES --------
Invisible brush based ladder (jump key to climb)
This entity cannot be damaged and is always touchable once activated

======================================================================*/

void trigger_ladder_touch (void)
{	
	if (self.inactive) return;
	if (!other.flags&FL_CLIENT)	return;
	if (!other.health) return;
	if (other.waterlevel > 1) return;
	if (other.flags&FL_WATERJUMP) return;
	if (other.flags2&FL_CHAINED) return;
	
	if (self.movedir != '0 0 0')
	{
		makevectors (other.angles);
		if (v_forward * self.movedir < 0)
			return;		// not facing the right way
	}
	
	other.onladder = TRUE;
	other.ladder = self;
}

void trigger_ladder ()
{
	if (!self.speed)
		self.speed = 160;
	if (self.soundtype) {		// Old Rope
		if(!self.count)
			self.count = 0.7;
		
		self.noise1 = "player/ladrope1.wav";
		self.noise2 = "player/ladrope2.wav";
		self.noise3 = "player/ladrope3.wav";
		self.noise4 = "player/ladrope4.wav";
		
		precache_sound(self.noise1);
		precache_sound(self.noise2);
		precache_sound(self.noise3);
		precache_sound(self.noise4);
	}
	self.touch = trigger_ladder_touch;
	
	InitTrigger();
}

/*	//idea: point entity that, when triggered, transfers its fields to its targets - used to change properties of moving objects
void trigger_changefields ()
{
	entity ent;
	float i, valid, movercnt;
	valid = FALSE;
	i = 0;
	movercnt = 9;
	string movers[9] =
		{"func_crusher", "func_door", "func_door_rotating", "func_door_secret", "func_newplat", "func_plat", "func_rotating", "func_train", "func_train_mp"};
	for (i = 0; i < movercnt; i++) {
		string name;
		name = movers[i];
		if (ent.classname==name)
			valid = TRUE;
	}
	if (!valid)
		return;
	
	if (self.level)
		ent.level = self.level;
	if (self.speed)
		ent.speed = self.speed;
	if (self.wait)
		ent.wait = self.wait;
	if (ent.classname == "func_door")
		if (self.angles_y)
			ent.angles_y = self.angles_y;
	if (ent.classname == "func_door_rotating")
		if (self.flags)
			ent.flags = self.flags;
	if (ent.classname == "func_rotating" || ent.classname == "func_train" || ent.classname == "func_train_mp")
		if (self.anglespeed)
			ent.anglespeed = self.anglespeed;
}

void trigger_fields_transfer ()
{
	self.touch = self.use = trigger_changefields;
}
*/

void hub_intermission_use(void)
{
	entity search;

	nextmap = self.map;
	nextstartspot = self.target;

	intermission_running = 1;

	if(!self.delay) self.delay = 2;
	intermission_exittime = time + self.delay;

	//Remove cross-level trigger server flags for next hub
	if(!self.spawnflags&2)
	{
		serverflags(-)(SFL_CROSS_TRIGGER_1|
					SFL_CROSS_TRIGGER_2|
					SFL_CROSS_TRIGGER_3|
					SFL_CROSS_TRIGGER_4|
					SFL_CROSS_TRIGGER_5|
					SFL_CROSS_TRIGGER_6|
					SFL_CROSS_TRIGGER_7|
					SFL_CROSS_TRIGGER_8);
	}

	if(!self.spawnflags&1)
	{	
		search=find(world,classname,"player");
		while(search)
		{//Take away all their goodies
			search.puzzle_inv1 = string_null;
			search.puzzle_inv2 = string_null;
			search.puzzle_inv3 = string_null;
			search.puzzle_inv4 = string_null;
			search.puzzle_inv5 = string_null;
			search.puzzle_inv6 = string_null;
			search.puzzle_inv7 = string_null;
			search.puzzle_inv8 = string_null;
			search=find(search,classname,"player");
		}
	}

	if(!self.level) self.level = 11;
	WriteByte (MSG_ALL, SVC_INTERMISSION);
	WriteByte (MSG_ALL, self.level);
	
	FreezeAllEntities();
}

/*QUAKED trigger_hub_intermission (.5 .5 .5) (-8 -8 -8) (8 8 8)
Inky's modified version (05/06/2020)
See usage at
http://earthday.free.fr/Inkys-Hexen-II-Mapping-Corner/mapping-tricks-intermission.html
*/
void trigger_hub_intermission(void)
{
	self.use = hub_intermission_use;
}

/*
	~trigger_random~
AKA teh penguin of d00m. When triggered, it uses an entity out of a numerical range of entities.
The first possible target is determined by its .flags, and the last by its .flags2.
Entities to be used are identified by their .targetid, rather than .targetname. Use integer values because decimals will be rounded.
If there are id's missing from its range, it will automatically recalculate so that its range is full of valid entities. Check spawnflag 4 if this isn't desired. Since the process re-assigns id's, it would break any entity used by a separate trigger_random's.
If you want entity with an id to behave like it's targetted (eg. a door not to spawn a trigger field), then give it a junk targetname such as "null".
It also uses its targets/killtargets when triggered (only once if spawnflag 1 is checked).
Will be deactivated after being used .count times if set.
This trigger reserves the targetname "trigger_random_target". If you give an entity that targetname, expect bad things.

count: maximum uses
flags: minimum target id
flags2: maximum target id
spawnflags: 1 (RANDOM_SINGLETRIG): Only use target/killtarget once
			2 (RANDOM_NOREPEAT) : Only use any random id once
			4 (RANDOM_IGNOREMISSING) : Don't reorganize range if an id in range has no matching entities
			16 (RANDOM_REMOVELOSER) : After triggering random entity, remove all other entities in trigger's range.
									Possible useage: spawning random monster or activating random trigger and removing the ones not chosen. Implies single-use.
*/

void trigger_random_reorder (float id)
{
entity found, first;
float valid;
	if (id>self.flags2 || id<self.flags)
		return;
	
	if (id<self.flags2)		//not last in range, so decrement greater id's
	{
		found = nextent(world);
		while (found)
		{
			if (found.targetid > id && found.targetid <= self.flags2)
			{
				if (!valid) {
					first = found;	//found first relevant entity in list
					valid = TRUE;
				}
				dprint("Trigger_random: Decremented id ");dprint(ftos(found.targetid));dprint("\n");
				found.targetid -= 1;
			}
			found=nextent(found);
		}
	}
	
	found = nextent(first);		//we know none of the entities before first are relevant, so start search there
	while (found)
	{
		if (found.targetid == id) {
			dprint("Trigger_random: reset id ");dprint(ftos(id));dprint("\n");
			found.targetid = 0;
		}
		found=nextent(found);
	}
	
	self.flags2 -= 1;				//lower random range for next use
	if (self.flags2<self.flags) {	//we've used everything in our range so remove
		remove(self);
		return;
	}
}

void trigger_random_use ()
{
entity found;
float r, valid;
	r = random(self.flags, self.flags2+1);
	if (r>self.flags2)
		r = self.flags2;
	else if (r<self.flags)
		r = self.flags;
	r = rint(r);
	
	found = nextent(world);					//search entire list of entities in world
	while (found)
	{
		if (found.targetid == r)
		{
			if (!valid)
				valid = TRUE;
			
			string otarg = self.target;
			string oname = found.targetname;
			found.targetname = "trigger_random_target";
			self.target = found.targetname;	//trigger temporarily targets the entity whose id matches our random selection
			SUB_UseTargets();				//use them
			self.target = otarg;			//done using them so reset our target and the matching id's targetname
			found.targetname = oname;
		}
		found=nextent(found);
	}
	
	if (!valid)		//we couldnt find a matching id, so retry
	{
		if (!self.spawnflags&RANDOM_IGNOREMISSING)
			trigger_random_reorder (r);
		trigger_random_use();
		return;
	}
	
	if (self.spawnflags&RANDOM_REMOVELOSER) {	//after using random id, remove all non-matching entities within our range
		found = nextent(world);	
		while (found)
		{
			if (found.targetid >= self.flags && found.targetid <= self.flags2 && found.targetid != r)
			{
				if (found!=world && !found.flags&FL_CLIENT)	{	//neither should have a targetid in the first place, but just in case...
					if (found.flags & FL_MONSTER)
						killed_monsters += 1;
					remove(found);
				}
				dprint(found.classname);
			}
			found=nextent(found);
		}
	}
	else if (self.spawnflags&RANDOM_NOREPEAT)
		trigger_random_reorder (r);		//we don't want to use an id again, so reorganize our range
	
	SUB_UseTargets();									//use our actual targets & killtargets
	if (self.spawnflags&RANDOM_SINGLETRIG)				//dont use non-random targets again
		self.target = self.killtarget = string_null;	//uninitiated string, not ""
	
	if (self.count)
		++self.counter;
	if (self.counter>=self.count) {
		remove(self);
		return;
	}
}

void trigger_random_check ()
{
entity found;
float valid, i;
	
	self.think = SUB_Null;
	thinktime self : -1;
	
	if (!self.flags || !self.flags2) {
		dprint("*\n*Error: trigger_random with missing min or max*\n");
		remove(self);
		return;
	}
	else {
		if (self.flags>self.flags2) {
			dprint("*\n*Error: trigger_random min greater than max*\n");
			self.flags = self.flags2;
		}
		if (self.flags2<self.flags) {
			dprint("*\n*Error: trigger_random max less than min*\n");
			self.flags2 = self.flags;
		}
	}
	
	for (i = self.flags; i <= self.flags2; i++)
	{	dprint("*\n*Trigger_random: checking id ");dprint(ftos(i));dprint("*\n");
		found = nextent(world);
		while (found)
		{
			if (found.targetid == i) {
				valid = TRUE;
				found = world;	//end this while loop
			}
			else
				found=nextent(found);
		}
		if (!valid && !self.spawnflags&RANDOM_IGNOREMISSING) {
			dprint("*\n*Trigger_random: found missing id ");dprint(ftos(i));dprint("*\n");
			trigger_random_reorder (i);		//found id without a match, so reorganize our range
		}
		valid = FALSE;
	}
	
	return;
}

void trigger_random ()
{
	self.think = trigger_random_check;
	thinktime self : 0.1;	//slight delay to make sure all entities are spawned before checking their id's
	self.use = trigger_random_use;
	
	if (self.spawnflags&RANDOM_REMOVELOSER)
		self.count=1;
}

//trigger_stop: backport from PoP

void trigger_stop_use ()
{
entity found;
	if(self.inactive)
		return;

	if(self.nextthink==-1)
		return;

	found=find(world,targetname,self.target);
	while(found)
	{
		found.velocity='0 0 0';
		found.avelocity='0 0 0';
		found.nextthink=-1;

		stopSound(found, 0);

		if (found.classname == "func_train" || found.classname == "func_door_rotating")
			sound (found, CHAN_VOICE, found.noise1, 1, ATTN_NORM);

		found=find(found,targetname,self.target);
	}

	if(self.wait==-1)
		self.nextthink=-1;
	else if(self.wait>0)
		thinktime self : self.wait;
	else
		thinktime self : 999999999999;
}

void trigger_stop_touch ()
{
	if(other.classname!="player" || self.inactive)
		return;

	trigger_stop_use();
}

/*QUAKED trigger_stop (.5 .5 .5) (-8 -8 -8) (8 8 8) notouch
Stops its target that is moving or rotating
This will trigger only once until triggered again unless you give it a wait.
*/
void trigger_stop(void)
{
	InitTrigger();
	self.use=trigger_stop_use;
	if(self.spawnflags&8)
		self.inactive=TRUE;
	if(!self.spawnflags&1)
		self.touch=trigger_stop_touch;
}
