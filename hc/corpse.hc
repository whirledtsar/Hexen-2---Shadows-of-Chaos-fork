/*
 * $Header: /cvsroot/uhexen2/gamecode/hc/portals/corpse.hc,v 1.2 2007-02-07 16:59:30 sezero Exp $
 */

void wandering_monster_respawn()
{
	vector newangle,spot1,spot2;
	float loop_cnt;
	
	//check if anything is in the path of spawning
	dprint("Respawning monster checking area\n");
	trace_fraction = 0;
	loop_cnt =0;
	spot1 = self.origin;
	while (trace_fraction < 1)
	{
		newangle = self.angles;
		makevectors (newangle);
		//check in front
		spot2 = spot1 + (v_forward * 30);
		traceline (spot1, spot2, FALSE, self);
		//check behind
		if (trace_fraction == 1) 	{
			spot2 = spot1 - (v_forward * 30);
			traceline (spot1, spot2, FALSE, self);
		}
		//check up (origin is on floor)
		if (trace_fraction == 1) {
			spot2 = spot1 + (v_up * 60);
			traceline (spot1, spot2, FALSE, self);
		}
		//just in case
		if (trace_fraction == 1) {
			setorigin(self, self.origin+'0 0 10');
			droptofloor();
			if (!walkmove(0,0, FALSE))
				trace_fraction = 0;
		}
		
		loop_cnt +=1;

		if (loop_cnt > 10)   // No endless loops
		{
			self.nextthink = time + 2;
			dprint("Respawning monster inhibited\n");
			return;
		}
	}
	
	//spot is clear, use spot
	dprint("Respawning monster ready to spawn\n");
	setorigin(self, self.origin+'0 0 10');	//avoid spawning inhibited by floor
	
	self.think = self.th_init;
	self.nextthink = time + HX_FRAME_TIME;
	
	CreateRedCloud (spot1 + '0 0 40','0 0 0',HX_FRAME_TIME);
}

void MarkForRespawn (void)
{
	entity newmis;
	
	if (CheckCfgParm(PARM_RESPAWN) && self.classname != "player" && self.th_init && self.th_init != SUB_Null && !self.preventrespawn && !self.playercontrolled && self.monsterclass < CLASS_BOSS) //do not respawn players or summoned monsters
	{
		dprint ("Classname: ");
		dprint (self.classname);
		dprint (" Controller: ");
		dprint (self.controller.classname);
			dprint (" Owner: ");
		dprint (self.owner.classname);
		dprint ("\n");
		dprintv("Marked for respawn: %s\n",self.origin);
		
		newmis = spawn ();
		setorigin(newmis, self.origin);
		
		newmis.flags2 (+) FL_SUMMONED;
		newmis.lifetime = time + 900;
		newmis.classname = self.classname;
		newmis.th_init = self.th_init;
		
		float chance;
		chance = random();
		if (chance<0.4)
			newmis.greenmana = 15;
		else if (chance<0.8)
			newmis.bluemana = 15;
		
		newmis.think = wandering_monster_respawn;
		thinktime newmis : self.respawntime + (self.monsterclass*60);
		
		//mark for respawn buff chance
		newmis.killerlevel = self.killerlevel;
	}
}

void corpseblink (void)
{
	self.think = corpseblink;
	thinktime self : 0.1;
	self.scale -= 0.10;

	if (self.scale < 0.10) {
		/*if (CheckCfgParm(PARM_RESPAWN)) {
			setmodel(self, "models/null.spr");
			self.effects (+) EF_NODRAW;
			self.respawntime = 0;	//respawn immediately upon our next think
			self.think = corpseblink;
			thinktime self : random(WANDERING_MONSTER_TIME_MIN, WANDERING_MONSTER_TIME_MAX);
		}
		else*/
			remove(self);
	}
}

void init_corpseblink (void)
{
	CreateYRFlash(self.origin);
	self.aflag = TRUE;
	self.drawflags (+) DRF_TRANSLUCENT | SCALE_TYPE_ZONLY | SCALE_ORIGIN_BOTTOM;

	corpseblink();
}

void() Spurt =
{
float bloodleak;

	makevectors(self.angles);
    bloodleak=rint(random(3,8));
    SpawnPuff (self.origin+v_forward*24+'0 0 -22', '0 0 -5'+ v_forward*random(20,40), bloodleak,self);
    sound (self, CHAN_AUTO, "misc/decomp.wav", 0.3, ATTN_NORM);
    if (self.lifetime < time||self.watertype==CONTENT_LAVA)
	    T_Damage(self,world,world,self.health);
	else
	{
	    self.think=Spurt;
		thinktime self : random(0.5,6.5);
	}
};

void () CorpseThink =
{
	self.think = CorpseThink;
	thinktime self : 3;

	if (self.watertype==CONTENT_LAVA)	// Corpse fell in lava
		T_Damage(self,self,self,self.health);
	else if (CheckCfgParm(PARM_FADE) && self.lifetime < time)			// Time is up, begone with you
		init_corpseblink();
};

void CorpsePain (entity attacker, float damage) =
{
	if (self.pain_finished > time)
		return;
	if (self.model == "models/spider.mdl")
		return;
	
	string mdl;
	float r = random();
	
	if (r<0.33)
		mdl = "models/flesh1.mdl";
	else if (r<0.66)
		mdl = "models/flesh2.mdl";
	else
		mdl = "models/flesh3.mdl";
	
	ThrowGib(mdl, self.health);
	ThrowGib("models/blood.mdl", self.health);
	self.pain_finished = time+0.5;
}

/*
 * This uses entity.netname to hold the head file (for CorpseDie())
 * hack so that we don't have to set anything outside this function.
 */
void()MakeSolidCorpse =
{
vector newmaxs;
// Make a gibbable corpse, change the size so we can jump on it

//Won't be necc to pass headmdl once everything has it's .headmodel
//value set in spawn
	self.netname="corpse";
	SUB_ResetTarget();
	self.th_pain = CorpsePain;	//SoC
	self.th_die = chunk_death;
	if (self.skin==GLOBAL_SKIN_ASH)
		self.th_die = shatter;
	//self.touch = obj_push; //Pushable corpses has the side effect of getting the player stuck when ironically it was meant to prevent that
	self.health = random(10,25);
	if (self.mass >= 30 && self.mass <= 100)
		self.health += (self.mass*0.5);	//ws: increase health for big corpses (yakmen, maulotaurs)
	self.takedamage = DAMAGE_YES;
	self.solid = SOLID_PHASE;
	self.experience_value = self.init_exp_val = 0;
	self.movetype = MOVETYPE_NONE;
	if(self.classname!="monster_hydra")
		self.movetype = MOVETYPE_STEP;//Don't get in the way	
	if(!self.mass)
		self.mass=1;

//To fix "player stuck" probem
	newmaxs=self.maxs;
	if(newmaxs_z>5)
		newmaxs_z=5;
	if (self.netname == "maulotaur")
		newmaxs_z+=5;
	/*if (self.classname=="monster_death_knight")
		//setsize (self, '-13 -28 -14', '10 3 -9'); //resize the dk berserker because i fucked up his origin and im too lazy to fix it. Also wtf are you doing using HexenC? It's 2017 nerd, go use UE4
	else*/
	setsize (self, self.mins,newmaxs);
	if(self.flags&FL_ONGROUND)
		self.velocity='0 0 0';
	self.flags(-)FL_MONSTER;
	if (!self.preventrespawn) {
		self.controller = self;
		self.respawntime = random(WANDERING_MONSTER_TIME_MAX, WANDERING_MONSTER_TIME_MAX);
		MarkForRespawn();
	}
	
	pitch_roll_for_slope('0 0 0',self);

    if ((self.decap)  && (self.classname == "player"))
    {	
		if (deathmatch||teamplay)
			self.lifetime = time + random(20,40); // decompose after 40 seconds
		else 
			self.lifetime = time + random(10,20); // decompose after 20 seconds

        self.owner=self;
        self.think=Spurt;
        thinktime self : random(1,4);
    }
    else 
	{
		if (CheckCfgParm(PARM_RESPAWN) && !CheckCfgParm(PARM_FADE))
			self.lifetime = time + random(WANDERING_MONSTER_TIME_MIN, WANDERING_MONSTER_TIME_MAX);
		else
			self.lifetime = time + random(20,30);
		self.aflag = FALSE;
		self.think=CorpseThink;
		thinktime self : 0;
	}
};

