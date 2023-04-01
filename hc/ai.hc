/*
 * $Header: /cvsroot/uhexen2/gamecode/hc/portals/ai.hc,v 1.4 2007-02-07 16:59:29 sezero Exp $
 */
void(entity etemp, entity stemp, entity stemp, float dmg) T_Damage;
void() CheckMonsterBuff;
/*

.enemy
Will be world if not currently angry at anyone.

.pathcorner
The next path spot to walk toward.  If .enemy, ignore .pathcorner
When an enemy is killed, the monster will try to return to it's path.

.hunt_time
Set to time + something when the player is in sight, but movement straight for
him is blocked.  This causes the monster to use wall following code for
movement direction instead of sighting on the player.

.ideal_yaw
A yaw angle of the intended direction, which will be turned towards at up
to 45 deg / state.  If the enemy is in view and hunt_time is not active,
this will be the exact line towards the enemy.

.pausetime
A monster will leave it's stand state and head towards it's .pathcorner when
time > .pausetime.

walkmove(angle, speed) primitive is all or nothing
*/

void sdprint (string dmess, float includeEnemy)
{
	if(self.playercontrolled)
	{
		dprint(dmess);
		if (includeEnemy)
		{
			dprint(" enemy: ");
			dprint(self.enemy.classname);
		}
		dprint("\n");
	}
}
//float ArcherCheckAttack (void);
float MedusaCheckAttack (void);
void()SetNextWaypoint;
void()SpiderMeleeBegin;
void()spider_onwall_wait;
float(entity targ , entity from)infront_of_ent;
void(entity proj)mezzo_choose_roll;
void()multiplayer_health;
void()riderpath_init;
void(float move_speed)riderpath_move;
float(float move_speed)eidolon_riderpath_move;
void() eidolon_guarding;
void()hive_die;
float()eidolon_check_attack;
float(entity ent) EnemyIsValid;
float(entity ent) IsAlly;
void() minionfx;

//void()check_climb;

//
// globals
//
float	current_yaw;

//
// when a monster becomes angry at a player, that monster will be used
// as the sight target the next frame so that monsters near that one
// will wake up even if they wouldn't have noticed the player
//
float	sight_entity_time;
float(float v) anglemod =
{
	while (v >= 360)
		v = v - 360;
	while (v < 0)
		v = v + 360;
	return v;
};

//============================================================================

/*
=============
range

returns the range catagorization of an entity reletive to self
0	melee range, will become hostile even if back is turned
1	visibility and infront, or visibility and show hostile
2	infront and show hostile
3	only triggered by damage
=============
*/
float(entity targ) range =
{
vector	spot1, spot2;
float		r,melee;	

	if((self.solid==SOLID_BSP||self.solid==SOLID_TRIGGER)&&self.origin=='0 0 0')
		spot1=(self.absmax+self.absmin)*0.5;
	else
		spot1 = self.origin + self.view_ofs;

	if((targ.solid==SOLID_BSP||targ.solid==SOLID_TRIGGER)&&targ.origin=='0 0 0')
		spot2=(targ.absmax+targ.absmin)*0.5;
	else
		spot2 = targ.origin + targ.view_ofs;
	
	r = vlen (spot1 - spot2);

	if (self.classname=="monster_mummy")
		melee = 50;
	else if (self.classname=="monster_yakman"||self.netname=="golem")//longer reach
		melee = 150;
	else
		melee = 100;

	if (r < melee)
		return RANGE_MELEE;
	if (r < 500)
		return RANGE_NEAR;
	if (r < 1000)
		return RANGE_MID;
	return RANGE_FAR;
};

/*
=============
visible2ent

returns 1 if the entity is visible to self, even if not infront ()
=============
*/
void spawntestmarker(vector org, float life, float skincolor)
{
	newmis=spawn_temp();
	newmis.drawflags=MLS_ABSLIGHT;
	newmis.abslight=1;
	newmis.frame=1;
	newmis.skin=skincolor;
	setmodel(newmis,"models/test.mdl");
	setorigin(newmis,org);
	newmis.think=SUB_Remove;
	if(life==-1)
		self.nextthink=-1;
	else
		thinktime newmis : life;
}

float visible2ent (entity targ, entity forent)
{
vector	spot1, spot2;
entity oself;
	if((forent.solid==SOLID_BSP||forent.solid==SOLID_TRIGGER)&&forent.origin=='0 0 0')
		spot1=(forent.absmax+forent.absmin)*0.5;
	else
		spot1 = forent.origin + forent.view_ofs;
		
	if((targ.solid==SOLID_BSP||targ.solid==SOLID_TRIGGER)&&targ.origin=='0 0 0')
		spot2=(targ.absmax+targ.absmin)*0.5;
	else
		spot2 = targ.origin + targ.view_ofs;
	
	SUB_TraceThroughObstacles(spot1, spot2, TRUE, forent, targ);

/*
	if(forent.classname=="monster_skull_wizard"&&trace_fraction==1&&self.think==self.th_stand)
	{
		dprint("Skullwizard awakened by: ");
		dprint(targ.classname);
		dprint("\n");
		forent.nextthink=-1;
		forent.think=SUB_Null;
		forent.th_run=self.th_stand;
		forent.effects=EF_BRIGHTLIGHT;
		if(targ.classname!="player")
		{
			targ.nextthink=-1;
			targ.think=SUB_Null;
			targ.th_run=targ.th_stand;
			targ.effects=EF_BRIGHTLIGHT;
		}
	}
*/
	if (trace_fraction == 1)
	{
		if(forent.flags&FL_MONSTER)
		{
			oself=self;
			self=forent;
			if(visibility_good(targ,0.15 - skill/20))
			{
//				dprint("a monster, with good visible\n");
				self=oself;
				return TRUE;
			}
			self=oself;
		}
		else
		{
/*			spawntestmarker(spot1, -1, 0);
			dprintv("spot1%s\n", spot1);
			spawntestmarker(spot2, -1, 0);
			dprintv("spot2%s\n", spot2);
			dprint("not a monster, but visible\n");*/
			return TRUE;
		}
	}

	return FALSE;
}

/*
=============
infront_of_ent

returns 1 if the targ is in front (in sight) of from
=============
*/
float infront_of_ent (entity targ , entity from)
{
	vector	vec,spot1,spot2;
	float	accept,dot;

	if(from.classname=="player")
	    makevectors (from.v_angle);
	else if(from.classname=="monster_medusa")
		makevectors (from.angles+from.angle_ofs);
	else
	    makevectors (from.angles);

	if((from.solid==SOLID_BSP||from.solid==SOLID_TRIGGER)&&from.origin=='0 0 0')
		spot1=(from.absmax+from.absmin)*0.5;
	else
		spot1 = from.origin + from.view_ofs;

	spot2=(targ.absmax+targ.absmin)*0.5;

    vec = normalize (spot2 - spot1);
	dot = vec * v_forward;

    accept = 0.3;
	
    if ( dot > accept)
		return TRUE;
	return FALSE;
}

/*
=============
visible

returns 1 if the entity is visible to self, even if not infront ()
=============
*/
float visible (entity targ)
{
	return visible2ent(targ,self);
}

/*
=============
infront

returns 1 if the entity is in front (in sight) of self
=============
*/
float infront (entity targ)
{
	return infront_of_ent(targ,self);
}


//============================================================================

/*
===========
ChangeYaw

Turns towards self.ideal_yaw at self.yaw_speed
Sets the global variable current_yaw
Called every 0.1 sec by monsters
============
*/
/*

void ChangeYaw ()
{
float		ideal, move;

//current_yaw = self.ideal_yaw;
// mod down the current angle
	current_yaw = anglemod( self.angles_y );
	ideal = self.ideal_yaw;


	if (current_yaw == ideal)
		return;
	
	move = ideal - current_yaw;
	if (ideal > current_yaw)
	{
		if (move > 180)
			move = move - 360;
	}
	else
	{
		if (move < -180)
			move = move + 360;
	}
		
	if (move > 0)
	{
		if (move > self.yaw_speed)
			move = self.yaw_speed;
	}
	else
	{
		if (move < 0-self.yaw_speed )
			move = 0-self.yaw_speed;
	}

	current_yaw = anglemod (current_yaw + move);

	self.angles_y = current_yaw;
}

*/


//============================================================================

void() HuntTarget =
{
	sdprint("Hunting target... ", TRUE);
	self.goalentity = self.enemy;
	self.think = self.th_run;
//	self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
	self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
	thinktime self : 0.1;
//	SUB_AttackFinished (1);	// wait a while before first attack
};

void SightSound (void)
{
	if (self.classname == "monster_archer")
		sound (self, CHAN_VOICE, "archer/sight.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_archer_lord")
		sound (self, CHAN_VOICE, "archer/sight2.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_mummy")
		sound (self, CHAN_WEAPON, "mummy/sight.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_mummy_lord")
		sound (self, CHAN_WEAPON, "mummy/sight2.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_death_knight")
		sound (self, CHAN_WEAPON, "death_knight/ksight.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_disciple")
		sound (self, CHAN_WEAPON, "disciple/sight.wav", 1, ATTN_NORM);
	else if (self.sightsound)
		sound (self, CHAN_VOICE, self.sightsound, 1, ATTN_NORM);

}

void() FoundTarget =
{
	if (self.enemy.classname == "player")
	{	// let other monsters see this monster for a while
		sight_entity = self;
		sight_entity_time = time + 1;
	}
	
	self.show_hostile = time + 1;		// wake up other monsters

	SightSound ();

	HuntTarget ();
	SUB_UseWakeTargets ();	//ws: monsters use self.waketarget upon sighting player
};

/*
===========
FindTarget

Self is currently not attacking anything, so try to find a target

Returns TRUE if an enemy was sighted

When a player fires a missile, the point of impact becomes a fakeplayer so
that monsters that see the impact will respond as if they had seen the
player.

To avoid spending too much time, only a single client (or fakeclient) is
checked each frame.  This means multi player games will have slightly
slower noticing monsters.
============
*/
float(float dont_hunt) FindTarget =
{
entity	client;
float		r;

// if the first spawnflag bit is set, the monster will only wake up on
// really seeing the player, not another monster getting angry

// spawnflags & 3 is a big hack, because zombie crucified used the first
// spawn flag prior to the ambush flag, and I forgot about it, so the second
// spawn flag works as well
	sdprint("Summon monster finding any target", TRUE);
    if(!deathmatch&&(self.playercontrolled||self.classname=="cube_of_force"))
	{
		sdprint("Summon monster finding Monster target", TRUE);
		if (FindMonsterTarget())
		{
			HuntTarget();
			return TRUE;
		}
		//return FALSE;
	}
	
	if(self.classname=="monster_raven")
		return FALSE;
	
	sdprint("Summon monster finding Player target", TRUE);
	if (sight_entity_time >= time && sight_entity!=world && !(self.spawnflags & 1))
	{
		client = sight_entity;
		if (client.enemy == self.enemy) {
			if (self.wallspot==VEC_ORIGIN) {
				self.wallspot=(sight_entity.enemy.origin+sight_entity.enemy.absmax*0.5);
				SetNextWaypoint();
			}
			return TRUE;
		}
	}
	else
	{
		client = checkclient ();
		if (!client)
			return FALSE;	// current check entity isn't in PVS
	}

if (self.playercontrolled && (client==self.controller || client==self.owner))	//if minion, follow enemy (player controller) but dont alert monsters or play sight sound
	{
		if (range(client)<=RANGE_MELEE && visible(client))	//ws: if summoned minion and already close to player, dont move further
			return FALSE;
		HuntTarget();
		return TRUE;
	}
	
	if (client == self.enemy)
		return FALSE;
	
	if (client.flags & FL_NOTARGET)
		return FALSE;

	r = range (client);
	if (r == RANGE_FAR)
		return FALSE;

	if(!visibility_good(client,5))
	{
//		dprint("Monster has low visibility on ");
//		dprint(client.netname);
//		dprintf("(%s)\n",client.visibility);
		return FALSE;
	}

	if(self.think!=spider_onwall_wait)
		if (r == RANGE_NEAR)
		{
			if (client.show_hostile < time && !infront (client))
				return FALSE;
		}
		else if (r == RANGE_MID)
		{
			if (!infront (client))
				return FALSE;
		}
	
	if (!visible (client))
		return FALSE;

//
// got one
//
	self.enemy = client;

	if (self.enemy.classname != "player" && !self.playercontrolled)
	{//If this check fails, do not let this entity set self as
	 //sight_ent- avoids daisy-chaining of enemy sight
		self.enemy = self.enemy.enemy;
		if (self.enemy.classname != "player")
		{
			self.enemy = world;
			return FALSE;
		}
		//ws: when a monster alerts a monster to the players presence, transfer the former monster's waypoint spot to the alerted monster so they can path to them better
		if (client==sight_entity && time<sight_entity_time) {
			self.wallspot=(sight_entity.enemy.origin+sight_entity.enemy.absmax*0.5);
			SetNextWaypoint();
		}
		SightSound ();
		HuntTarget ();
		return TRUE;
	}

	if(!dont_hunt)
		FoundTarget ();
	return TRUE;
};

void()SpiderJumpBegin;
//=============================================================================
/*
void(float dist) ai_forward =
{
	walkmove (self.angles_y, dist, FALSE);
};
*/
void(float dist) ai_back =
{
	walkmove ( (self.angles_y+180), dist, FALSE);
};


/*
=============
ai_pain

stagger back a bit
=============
*/
void(float dist) ai_pain =
{
//	ai_back (dist);
float	away;
	
	away = vectoyaw (self.origin - self.enemy.origin)+90*random(0.5,-0.5);
	
	walkmove (away, dist,FALSE);
};

/*
=============
ai_painforward

stagger back a bit
=============
*/
/*
void(float dist) ai_painforward =
{
	walkmove (self.ideal_yaw, dist, FALSE);
};
*/

/*
=============
ai_walk

The monster is walking it's beat
=============
*/
//THE PIT!

float find_enemy_target ()
{
entity found;
	if(self.target=="")
		return FALSE;

	found=find(world, targetname, self.target);
	if(!found)
	{
		found=find(world, targetname, self.targetname);
		if(found)
			if(found.enemy.flags2&FL_ALIVE)
				found=found.enemy;
	}
	if(found==world||!found.flags2&FL_ALIVE)
	{
		if(!found.targetname)
			self.target="";
		return FALSE;
	}
	self.goalentity = self.pathentity = found;
	self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
	self.enemy=self.goalentity;
	self.th_run();
	return TRUE;
}

void(float dist) ai_walk =
{
	CheckMonsterBuff();
	MonsterCheckContents();
	self.flags2(-)FL2_MOVING;

	movedist = dist;

	// check for noticing a player
//THE PIT!
	if(world.model=="maps/monsters.bsp")
		if(find_enemy_target())
			return;

	sdprint("Summon monster contents are ok", FALSE);
	if (FindTarget (FALSE))
		return;
	if (movedist)
		self.flags2(+)FL2_MOVING;
	if(!movetogoal(dist))
	{
		if(trace_ent.solid==SOLID_BSP&&trace_fraction<1)
		{
			if(trace_plane_normal!='0 0 0')
				self.walldir='0 0 0' - trace_plane_normal;
		}
	}
};

/*
=============
ai_stand

The monster is staying in one place for a while, with slight angle turns
=============
*/
void ApplyMonsterBuff(entity monst, float canBeLeader);
void() ai_stand =
{
	sdprint("Summon monster standing", FALSE);
	minionfx();
	CheckMonsterBuff();
	
	MonsterCheckContents();
	
//THE PIT!
	if(world.model=="maps/monsters.bsp")
		if(find_enemy_target())
			return;

	if (FindTarget (FALSE))
		return;
	sdprint("Summon monster found target", TRUE);
	if (time > self.pausetime)
	{
		sdprint("Summon monster start walking", TRUE);
		self.th_walk ();
		return;
	}

// change angle slightly
};

/*
=============
ai_turn

don't move, but turn towards ideal_yaw
=============
*/
/*
void() ai_turn =
{
	if (FindTarget (FALSE))
		return;
	
	ChangeYaw ();
};
*/

//=============================================================================

/*
=============
ChooseTurn
=============
*/
/*
void(vector dest3) ChooseTurn =
{
	local vector	dir, newdir;
	
	dir = self.origin - dest3;

	newdir_x = trace_plane_normal_y;
	newdir_y = 0 - trace_plane_normal_x;
	newdir_z = 0;
	
	if (dir * newdir > 0)
	{
		dir_x = 0 - trace_plane_normal_y;
		dir_y = trace_plane_normal_x;
	}
	else
	{
		dir_x = trace_plane_normal_y;
		dir_y = 0 - trace_plane_normal_x;
	}

	dir_z = 0;
	self.ideal_yaw = vectoyaw(dir);	
};
*/

/*
============
FacingIdeal

Within angle to launch attack?
============
*/
float() FacingIdeal =
{
	local	float	delta;
	
	delta = anglemod(self.angles_y - self.ideal_yaw);
	if (delta > 45 && delta < 315)
		return FALSE;
	return TRUE;
};


//=============================================================================
void UseBlast (void);
void LeaderRepulse (void)
{
	entity findmissile;
	float useblast;
	
	useblast = FALSE;
	
	//find a player blast within a certain range
	findmissile = findradius(self.origin, BLAST_RADIUS);
	while(findmissile)
	{
		if (findmissile.movetype == MOVETYPE_FLYMISSILE && findmissile.owner.classname == "player")
		{
			useblast = TRUE;
		}
		
		findmissile = findmissile.chain;
	}
	
	if (useblast)
	{
		UseBlast();
	}
}

float()pent_check_attack;
float() CheckAnyAttack =
{
	if (!enemy_vis)
		return FALSE;
	
	//leaders can deflect attacks
	if (self.bufftype & BUFFTYPE_LEADER)
		LeaderRepulse();

	if(self.classname=="monster_eidolon")
		if(self.goalentity==self.controller)
			return FALSE;
		else
			return eidolon_check_attack();

	if(self.classname=="monster_pentacles")
		return pent_check_attack();

	if(self.classname=="monster_medusa")
	{
//		dprint("medusa checking\n");
		return MedusaCheckAttack();
	}
	
	if (IsAlly(self.enemy))
		return FALSE;

	return CheckAttack ();
};


/*
=============
ai_attack_face

Turn in place until within an angle to launch an attack
=============
*/
void() ai_attack_face =
{
	self.ideal_yaw = enemy_yaw;
	ChangeYaw ();
	if (FacingIdeal())  // Ready to go get em
	{
		if (self.attack_state == AS_MISSILE)
			self.th_missile ();
		else if (self.attack_state == AS_MELEE)
			self.th_melee ();
		self.attack_state = AS_STRAIGHT;
	}
};


/*
=============
ai_run_slide

Strafe sideways, but stay at aproximately the same range
=============
*/
void ai_run_slide ()
{
float	ofs;
	
	self.ideal_yaw = enemy_yaw;
	ChangeYaw ();
	if (self.lefty)
		ofs = 90;
	else
		ofs = -90;
	
	if (walkmove (self.ideal_yaw + ofs, movedist, FALSE))
		return;
		
	self.lefty = 1 - self.lefty;
	
	walkmove (self.ideal_yaw - ofs, movedist, FALSE);
}


/*
=============
ai_run

The monster has an enemy it is trying to kill
=============
*/

void(float dist) ai_run =
{
	sdprint("Doing AI run... ", FALSE);
	minionfx();
	CheckMonsterBuff();
	MonsterCheckContents();
	self.flags2(-)FL2_MOVING;
	
	movedist = dist;
// see if the enemy is dead
	//if (!self.enemy.flags2&FL_ALIVE||(self.enemy.artifact_active&ARTFLAG_STONED&&self.classname!="monster_medusa"))
	if (!EnemyIsValid(self.enemy))
	{	sdprint("summoned monster target dead ", TRUE);
//THE PIT!
	if(world.model=="maps/monsters.bsp")
		if(find_enemy_target())
			return;

		self.enemy = world;
	// FIXME: look all around for other targets
		if (self.oldenemy.health > 0)
		{
			self.enemy = self.oldenemy;
			HuntTarget ();
		}
		else if(coop)
		{
			if(!FindTarget(TRUE))	//Look for other enemies in the area
			{
				if (self.pathentity)
					self.th_walk ();
				else
					self.th_stand ();
				return;
			}
		}
		else
		{
			if (self.pathentity)
				self.th_walk ();
			else
				self.th_stand ();
			return;
		}
	}
	if (self.playercontrolled && self.controller.enemy!=world && self.controller.enemy!=self.enemy)	//summoned monster check if player has acquired enemy
		FindMonsterTarget();

	self.show_hostile = time + 1;		// wake up other monsters

// check knowledge of enemy
	enemy_vis = visible(self.enemy);
	if (enemy_vis)
	{
		sdprint("Target alive and visible... ", TRUE);
		self.search_time = time + 5;
		if(self.mintel)
		{
			sdprint("Summoned monster is smart enough to see it ", TRUE);
			self.goalentity=self.enemy;
		    self.wallspot=(self.enemy.absmin+self.enemy.absmax)*0.5;
		}
	}
	else
	{
		sdprint("Can't see target ", TRUE);
		if(coop)
		{
			if(!FindTarget(TRUE))
				if(self.model=="models/spider.mdl")
				{
					if(random()<0.5)
						SetNextWaypoint();
				}
				else 
					SetNextWaypoint();
		}
		if(self.mintel)
			sdprint("Smart enough to find target ", TRUE);
			if(self.model=="models/spider.mdl")
			{
				if(random()<0.5)
					SetNextWaypoint();
			}
			else 
				SetNextWaypoint();
	}

	if(random()<0.5&&(!self.flags&FL_SWIM)&&(!self.flags&FL_FLY)&&(self.spawnflags&JUMP))
		CheckJump();
	if (self.playercontrolled)		//ws: if summoned minion and already close to player, dont move further
		if (self.enemy==self.controller && enemy_vis && range(self.enemy)==RANGE_MELEE) {
			self.think=self.th_stand;
			self.th_stand();
		}

// look for other coop players
	if (coop && self.search_time < time)
	{
		if (FindTarget (FALSE))
			return;
	}

	enemy_infront = infront(self.enemy);
	enemy_range = range(self.enemy);
	if(self.classname!="monster_eidolon")
		enemy_yaw = vectoyaw(self.goalentity.origin - self.origin);
	
	if ((self.attack_state == AS_MISSILE) || (self.attack_state == AS_MELEE))  // turning to attack
	{
		sdprint("Turning to attack ", TRUE);
		if(self.classname!="monster_eidolon")
			ai_attack_face ();
		return;
	}

	if (CheckAnyAttack ())
	{
		sdprint("Is allowed to attack ", TRUE);
		return;					// beginning an attack
	}
	if (self.attack_state == AS_SLIDING)
	{
		ai_run_slide ();
		return;
	}
		
// head straight in
//	if(self.netname=="spider")
//		check_climb();

//ws: new AI for SoC flying enemies, attempts to fly a certain distance above enemy intead of automatically adjusting to their height
	if (self.spawnflags&SF_FLYABOVE && (!self.enemy.flags&FL_FLY) && self.zmovetime < time) {
		//dont try to fly above other flying enemies because they would rise to the skybox lol
		if (!enemy_vis && self.flags&FL_NOZ) {
			if (self.search_time < time+2)		//path normally to try to find enemy if we havent found them after a couple seconds
				self.flags(-)FL_NOZ;
		}
		
		traceline(self.origin, self.origin+('0 0 1'*self.maxs_z)+'0 0 32', FALSE, self);
		//debug entity new; new = spawn(); setmodel(new, "models/h_imp.mdl"); setorigin(new, trace_endpos); new.think = SUB_Remove; thinktime new : 0.1;
		if (trace_fraction < 1 || pointcontents(trace_endpos)<=CONTENT_SOLID) {
			//dprint("ai_run: Flymonster won't hug ceiling\n");
			self.flags(-)FL_NOZ;		//dont hug ceiling
			self.zmovetime = time+3;	//move around to try to path to higher ceiling room
		}
		else if (enemy_vis && (self.enemy.flags&FL_ONGROUND||self.enemy.groundentity)) {
			//try to fly above but dont follow jumping players exactly because it looks silly
			self.flags(+)FL_NOZ;
			
			float diff;
			diff = self.absmin_z - self.enemy.absmin_z;
			
			if (diff < self.hoverz)
				movestep(0, 0, 5, FALSE);
			else if (diff > self.hoverz + 16) {
				traceline(self.origin, self.origin-('0 0 1'*8), FALSE, self);
				if (trace_fraction<1 || pointcontents(trace_endpos)<=CONTENT_SOLID) {
					//dprint("ai_run: Flymonster won't hug floor\n");
					self.flags(-)FL_NOZ;		//also dont hug floor of wall if already above player
					self.zmovetime = time+1;
				}
				else
					movestep(0, 0, -5, FALSE);
			}
		}
	}
	
	if (movedist)
		self.flags2(+)FL2_MOVING;
	if(self.classname=="monster_eidolon")
	{
		if(!self.path_current)
			riderpath_init();
		if(!eidolon_riderpath_move(dist))
		{
			if(self.think==self.th_run)
				eidolon_guarding();
		}
		else if(self.think==eidolon_guarding)
			self.th_run();
	}
	else if(!movetogoal(dist))
	{
		if(trace_ent.solid==SOLID_BSP&&trace_fraction<1)
		{
		vector movdir;
/*			dprint("RUNNING\n");
			dprintv("Pent hit wall - normal = %s\n",trace_plane_normal);
			dprintv("Origin = %s\n",self.origin);
			dprintv("End_pos = %s\n",trace_endpos);*/
			movdir=normalize(trace_endpos - self.origin);
//			dprintv("Move dir = %s\n",movdir);
			if(trace_plane_normal=='0 0 0')
			{
				traceline(self.origin,self.origin+movdir*64,TRUE,self);
//				dprintv("New normal = %s\n",trace_plane_normal);
			}
			if(trace_plane_normal!='0 0 0')
			{
				self.walldir='0 0 0' - trace_plane_normal;
//				dprintv("New walldir = %s\n",self.walldir);
			}
/*			else
			{
				dprintf("Trace fraction	= %s\n", trace_fraction);
				if(trace_startsolid)
					dprint("Trace started in wall\n");
				else if(trace_allsolid)
					dprint("Trace completely in wall\n");
				else if(trace_ent.solid==SOLID_BSP)
					dprint("Wall in my way\n");
				else
				{
					dprint(trace_ent.classname);
					dprint(" in my way\n");
				}
			}
*/		}
	}
};

