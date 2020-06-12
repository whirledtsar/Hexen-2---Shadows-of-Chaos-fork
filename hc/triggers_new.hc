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

