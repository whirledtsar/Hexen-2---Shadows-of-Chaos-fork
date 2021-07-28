/*
	=Reiver=
	Code by Whirledtsar, model by Razumen
	
	Custom/edited functions used:
	ai_ws.hc:		void ChangePitch ()
	fx.hc:		void fx_light (vector org, float effect)
	weapons.hc:	void Knockback (entity victim, entity attacker, entity inflictor, float force, float zmod)
*/

$frame 000pose

$frame 001rise 002rise 003rise 004rise 005rise 006rise 007rise 008rise 009rise 010rise 011rise 012rise 013rise 014rise 015rise 016rise 017rise 018rise 019rise 020rise 021rise 022rise 023rise 024rise

$frame 025idle 026idle 027idle 028idle 029idle 030idle 031idle 032idle 033idle 034idle 035idle 036idle 037idle 038idle

$frame 039look 040look 041look 042look 043look 044look 045look 046look 047look 048look 049look 050look 051look 052look 053look

$frame 054fire 055fire 056fire 057fire 058fire 059fire 060fire 061fire 062fire 063fire 064fire 065fire 066fire 067fire 068fire 069fire 070fire

$frame 071meleel 072meleel 073meleel 074meleel 075meleel 076meleel 077meleel 078meleel 079meleel 080meleel 081meleel 082meleel 083meleel 084meleel 085meleel 086meleel 087meleel 088meleel

$frame 089meleer 090meleer 091meleer 092meleer 093meleer 094meleer 095meleer 096meleer 097meleer 098meleer 099meleer 100meleer 101meleer 102meleer 103meleer 

$frame 104painguard 105painguard 106painguard 107painguard 108painguard 109painguard 110painguard 111painguard 112painguard 113painguard 114painguard 115painguard 116painguard 117painguard 118painguard 119painguard

$frame 120leech 121leech 122leech 123leech 124leech 125leech 126leech

$frame 127stun 128stun 129stun 130stun 131stun 132stun 133stun 134stun 135stun 136stun 137stun

$frame 138death 139death 140death 141death 142death 143death 144death

float REIV_BURIED = 2;
float REIV_DORMANT = 16;
float SF_FLYABOVE = 262144;
float REIV_NOFX = 524288;

float REIV_HEIGHT = 500;
float REIV_RANGE = 60;
float REIV_SPEED = 6;
float REIV_CHARGE = 16;
vector REIV_MINS = '-18 -18 5';
vector REIV_MAXS = '18 18 30';

void() reiv_buried;
void() reiv_fx;
void() reiv_melee;
void() reiv_meleedrain;
void() reiv_mis;
void(entity attacker, float damg) reiv_pain;
void() reiv_blasted;
void() reiv_run;
void() reiv_stand;

void() precache_reiver
{
	precache_model("models/reiver.mdl");
	precache_model("models/lavaball.mdl");
	
	precache_sound("assassin/chntear.wav");
	precache_sound("imp/fireball.wav");
	precache_sound("misc/rubble.wav");
	precache_sound("reiv/blood.wav");
	precache_sound("reiv/die.wav");
	precache_sound("reiv/idle.wav");
	precache_sound("reiv/pain.wav");
	precache_sound("reiv/see.wav");
	precache_sound("weapons/drain.wav");
}

void reiv_check ()
{	//self.enemy = reiver, self = dummy entity
local entity amstuck, stuckent;
	amstuck = findradius(self.enemy.origin, 80);
	
	while (amstuck)
	{
		if (amstuck!=world && (amstuck.solid==SOLID_BBOX || amstuck.solid==SOLID_SLIDEBOX))
			stuckent = amstuck;
		amstuck = amstuck.chain;
	}
	if (!stuckent) {
		self.enemy.solid = SOLID_SLIDEBOX;
		self.think = SUB_Remove;
	}
	else {
		Knockback (stuckent, self.enemy, self.enemy, 5, 0.2);
		self.enemy.solid = SOLID_NOT;
		self.think = reiv_check;
	}
	thinktime self : HX_FRAME_TIME*0.5;
}

void reiv_risefx ()
{
	if (self.spawnflags & REIV_NOFX)
		return;
	
	string mdl;
	vector org;
	float r = random();
	if (r<0.75)
		mdl = "models/schunk1.mdl";
	else if (r<0.5)
		mdl = "models/schunk2.mdl";
	else
		mdl = "models/schunk3.mdl";
	org = self.origin;
	org_y += random(self.mins_y,self.maxs_y)*0.75;
	ThrowSingleChunk (mdl, org, random(3), 1,random(0.1,0.3));
	particle(org, randomv('-6 -6 2', '6 6 6'), rint(random(98,103)), 5);	//rint(random(85,88)
}

void reiv_rise () [++ $001rise .. $024rise]
{
	if (cycle_wrapped)
	{
		self.attack_finished = time+2;
		self.movetype = MOVETYPE_STEP;
		self.th_pain = reiv_pain;
		self.th_blasted = reiv_blasted;
		setsize (self, REIV_MINS, REIV_MAXS);
		self.hull = HULL_CROUCH;
		//self.solid = SOLID_SLIDEBOX;		//handled in reiv_check
		self.takedamage = DAMAGE_YES;
		self.th_run = reiv_run;
		self.think = reiv_run;
		thinktime self : 0;
	}
	
	else if (self.frame == $001rise) {
		setmodel (self, "models/reiver.mdl");
		self.solid = SOLID_PHASE;
		
		local entity new;
		new = spawn();
		setorigin(new, self.origin);
		new.enemy = self;
		new.think = reiv_check;
		thinktime new : 0;
	}
	else if (self.frame == $002rise && (!self.spawnflags & REIV_NOFX))
		sound (self, CHAN_BODY, "misc/rubble.wav", 1, 0.3);
	
	if (self.frame < $012rise)
		reiv_risefx();
	else
		reiv_fx();
}

void reiv_buried ()
{
	if (!self.spawnflags & REIV_DORMANT)
		ai_stand();
	else if (self.goalentity)	//activated by targeting
	{
		self.think = reiv_rise;
		self.think();
	}
	thinktime self : HX_FRAME_TIME;
}

void reiv_chargedrain () [++ $120leech .. $126leech]
{
	self.think = reiv_chargedrain;
	reiv_fx();
	
	if (self.reivAcceleration <= 6 + skill) {
		++self.reivAcceleration;
		ai_face();
		ChangePitch();
	}
	
	check_z_move(3);	//move along z axis too
	
	if (!walkmove(self.angles_y, REIV_CHARGE+self.reivAcceleration, TRUE))
	{
		if (trace_ent == self.enemy)
			self.think = reiv_meleedrain;
		else
			self.think = reiv_run;
		thinktime self : 0;
	}
	else if (time > self.reivChargeTime)
	{
		self.think = reiv_run;
		thinktime self : 0;
	}
}

void reiv_chargeprep () [++ $025idle .. $038idle]
{
	reiv_fx();
	ai_face();
	enemy_yaw = vectoyaw(self.goalentity.origin - self.origin);
	
	if (FacingIdeal()) {
		self.yaw_speed = 12;	//reset yaw speed
		self.reivChargeTime = time+1;	//stop charging at this time
		self.think = reiv_chargedrain;
		thinktime self : 0;
	}
	else
		thinktime self : HX_FRAME_TIME;
}

void reiv_die () [++ $138death .. $144death]
{
	if (self.artifact_active == 0)		//if not frozen or stoned
		self.movetype = MOVETYPE_NONE;	//dont fall to ground
	if (cycle_wrapped || (self.frame == $138death && self.health<-60) )
	{	//create bone gibs as well as blood gibs
		local entity bone;
		bone = spawn();
		bone.solid = SOLID_NOT;
		bone.thingtype = THINGTYPE_BONE;
		setmodel (bone, "models/null.spr");
		setorigin (bone, self.origin+'0 0 8');
		setsize (bone, self.mins*0.5, self.maxs*0.5);
		bone.think = chunk_death;
		thinktime bone : 0;
		
		setsize(self,self.mins*0.8,self.maxs*0.8);	//decrease size so chunk_death outputs more reasonably-sized gibs
		chunk_death();
		return;
	}
	else if (self.frame == $138death)
		sound (self, CHAN_VOICE, "reiv/die.wav", 1, ATTN_NORM);
	
	thinktime self : HX_FRAME_TIME*2;
}

void reiv_dodge () [++ $025idle .. $038idle]
{
float moving;
	
	self.think = reiv_dodge;
	thinktime self : HX_FRAME_TIME;
	
	moving = movestep (0, 0, (REIV_SPEED*0.5+self.reivAcceleration) * self.reivDodgeDir, FALSE);	//height is -1 if going down, 1 if going up
	++self.reivAcceleration;
	
	if (!moving || self.reivChargeTime<time) {
		self.reivDodgeTimer = time+1;	//dont dodge again until then
		self.think = reiv_run;
	}
}

float reiv_checkdodge ()
{
vector org;
float up, down;
	up = down = FALSE;
	makevectors(self.angles);
	org = self.origin;
	org_z = self.absmax_z;
	traceline(org, org + v_up*96, FALSE, self);
	if (trace_fraction==1)
		up = TRUE;
	
	org_z = self.origin_z;
	traceline(org, org - v_up*96, FALSE, self);
	if (trace_fraction==1)
		down = TRUE;
	
	if (up&&down) {	//if we can dodge both up or down, do the opposite of what we did last
		if (self.monster_stage && self.monster_stage==self.reivDodgeDir)
			self.reivDodgeDir*=(-1);
		else if (random()<0.5)
			self.reivDodgeDir=1;
		else
			self.reivDodgeDir=-1;
	}
	else if (up)
		self.reivDodgeDir=1;
	else if (down)
		self.reivDodgeDir=-1;
	else
		self.reivDodgeDir=0;
		
	if (up||down)
		return TRUE;
	
	return FALSE;
}

void reiv_checkdef ()
{
	if (self.reivDodgeTimer>time)
		return;
	if (random()<0.33)
		return;
	if (!EnemyIsValid(self.enemy))
		return;
	if ((range(self.enemy) == RANGE_MELEE) || (self.enemy.flags&FL_CLIENT && PlayerHasMelee(self.enemy)))
		return;
	if (!reiv_checkdodge())
		return;
	
	if ((self.enemy.last_attack < time+1 && self.enemy.last_attack > time-1) && lineofsight(self, self.enemy))
	{	//if enemy recently fired at us, then dodge
		self.reivChargeTime = time+0.5;	//stop dodging at this time
		self.monster_stage = self.reivDodgeDir;	//dodge in the opposite direction next time
		self.think = reiv_dodge;
		reiv_dodge();
	}
	else
		return;
}

void reiv_fx ()
{
	particle4(self.origin, 1, rint (256 + 16*8 + random(9)), PARTICLETYPE_FASTGRAV, rint(random(1,2)));
	if (random()<0.1 && time > self.reivFXTimer) {
		sound (self, CHAN_BODY, "reiv/blood.wav", 1, ATTN_IDLE);
		self.reivFXTimer = time + 2;
	}
}

void reiv_hit (float dir, float drain)
{
vector org1,org2;
float dist,damg;
	
	if (drain && self.reivDrainTimer > time)
		return;
	
	if (!self.enemy)
		return;
	
	if (dir==0)
		dir = random(-1,1);
	damg=random(8,14);
	
	makevectors(self.angles);
	org1=self.origin+v_forward*15+(self.proj_ofs*0.5);
	org2=(self.enemy.absmin+self.enemy.absmax)*0.5;
	dist=vlen(org2-org1);
	
	if (dist > REIV_RANGE)
		return;
	
	SUB_TraceRange(org1,org2,FALSE,self,30,15);
	
	if (trace_fraction == 0 || !trace_ent.takedamage)
		return;
	
	if (!trace_ent.flags & FL_MONSTER && !trace_ent.flags & FL_CLIENT)
		drain = FALSE;
	
	T_Damage(trace_ent,self,self,damg);
	if (drain)
	{
		sound (self, CHAN_BODY, "weapons/drain.wav", 1, ATTN_NORM);
		self.health += damg;
		if (self.health > self.max_health)
			self.health = self.max_health;	//dont give more than spawn health
		if (self.health >= self.max_health*0.6)
			self.reivSecondPhase = FALSE;
	}
	sound(self,CHAN_WEAPON,"assassin/chntear.wav",1,ATTN_NORM);
	SpawnPuff(trace_endpos,(v_right*100)*dir,10,trace_ent);
	if(trace_ent.thingtype==THINGTYPE_FLESH)
		MeatChunks (trace_endpos,(v_right*random(-200,200))*dir+'0 0 200', 3,trace_ent);
	
	self.reivDrainTimer = time+0.5;
}

void reiv_charge ()
{
	self.reivAcceleration+=0.5;
	ai_charge(REIV_SPEED+self.reivAcceleration);
}

void reiv_meleeL () [++ $071meleel .. $088meleel]
{
	reiv_fx();
	
	if (self.frame <= $077meleel)
		reiv_charge();
	
	if (self.frame == $077meleel)
		reiv_hit(-1, FALSE);
	
	else if (cycle_wrapped)
	{
		self.reivAcceleration = 0;
		self.lefty = FALSE;
		self.think = reiv_run;
		thinktime self : 0;
	}
}

void reiv_meleeR () [++ $089meleer .. $103meleer]
{
	reiv_fx();
	
	if (self.frame <= $095meleer)
		reiv_charge();
	
	if (self.frame == $095meleer)
		reiv_hit(1, FALSE);
	
	else if (cycle_wrapped)
	{
		self.reivAcceleration = 0;
		self.lefty = TRUE;
		self.think = reiv_run;
		thinktime self : 0;
	}
}

void reiv_meleedrain () [++ $120leech .. $126leech]
{
	reiv_fx();
	reiv_charge();
	
	if (self.frame >= $122leech && self.frame <= $124leech)
		reiv_hit(0, TRUE);
	
	if (cycle_wrapped)
	{
		self.reivAcceleration = 0;
		self.think = reiv_run;
		thinktime self : 0;
	}
}

void reiv_melee ()
{
	ai_face();
	
	if (self.health < self.max_health*0.6 || random()<0.1)
		self.think = reiv_meleedrain;
	
	else if (self.lefty)
		self.think = reiv_meleeL;
	else
		self.think = reiv_meleeR;
	
	thinktime self : 0;
}

void reiv_misthink ()
{
	//particle4(self.origin, 1, rint (256 + 16*6 + random(9)), PARTICLETYPE_FASTGRAV, random(1,4));
	particle4(self.origin,3,random(160,176),PARTICLETYPE_FASTGRAV,random(2,4));
	//particle(self.origin, '0 0 -30', 144, 2);
	thinktime self : HX_FRAME_TIME*0.5;
}

void reiv_misfire () [++ $054fire .. $070fire]
{
	reiv_fx();
	if (self.frame <= $064fire)
	{
		ai_face();
		ChangePitch();
	}
	
	if (self.frame == $064fire)
	{
		fx_light (self.origin+self.proj_ofs, EF_MUZZLEFLASH);
		sound (self, CHAN_WEAPON, "imp/fireball.wav", 1, ATTN_NORM);
		
		vector org1,org2,diff;
		entity newmis;
		makevectors(self.angles);
		org1 = self.origin+self.proj_ofs;
		org2 = self.enemy.origin+self.enemy.proj_ofs;
		//if only Create_Missile returned the entity spawned, then i could just use that and give it the think function i want, rather than copying it
		newmis = spawn ();
		newmis.owner = self;
		newmis.movetype = MOVETYPE_FLYMISSILE;
		newmis.solid = SOLID_BBOX;
		
		diff = normalize(org2 - org1);
		diff+=aim_adjust(self.enemy);

		newmis.velocity = diff*800;
		newmis.angles = vectoangles(newmis.velocity);
		newmis.avelocity = '0 600 600';
		
		newmis.scale = 0.666;
		setmodel (newmis,"models/lavaball.mdl");
		setsize (newmis, '-5 -5 -5', '5 5 5');
		setorigin (newmis, org1);
		
		newmis.dmg = random(16,22);
		newmis.touch = fireballTouch;
		newmis.think = reiv_misthink;
		thinktime newmis : HX_FRAME_TIME;
	}
	if (cycle_wrapped)
	{
		self.think = reiv_run;
		thinktime self : 0;
	}
}

void reiv_mis ()
{
	local float r = range(self.enemy);
	if (r == RANGE_MELEE)
		self.think = reiv_melee;
	else if (r <= RANGE_MID && self.reivSecondPhase && (!self.spawnflags & SF_FLYABOVE)) {
		if (self.reivVoiceTimer < time) {
			sound (self, CHAN_VOICE, "reiv/idle.wav", 1, ATTN_NORM);
			self.reivVoiceTimer = time+1.5;
		}
		self.yaw_speed = 16;	//turn faster in preparation
		self.think = reiv_chargeprep;	//make sure were facing the right way first
	}
	else
		self.think = reiv_misfire;
	
	thinktime self : 0;
}

void reiv_painguard () [++ $104painguard .. $119painguard]
{
	reiv_fx();
	if (self.frame == $110painguard || self.frame == $111painguard)
		reiv_hit(0, FALSE);
	
	if (cycle_wrapped)
	{
		self.pain_finished = time+1.5;
		self.think = reiv_run;
		reiv_checkdef();
		thinktime self : 0;
	}
}

void reiv_painstun () [++ $127stun .. $137stun]
{
	reiv_fx();
	if (self.frame < $130stun)
		ai_pain(3);
	
	if (cycle_wrapped)
	{
		self.pain_finished = time+1;
		reiv_checkdef();
		self.think = reiv_run;
		thinktime self : 0;
	}
}

void reiv_pain (entity attacker, float damg)
{
	if (self.health < self.max_health*0.6 && self.reivSecondPhase == FALSE) {
		self.pain_finished = time-1;
		MeatChunks (self.origin+randomv(self.mins*0.75, self.maxs*0.75),v_right*random(-200,200)+'0 0 200', 3, self);
		MeatChunks (self.origin+randomv(self.mins*0.75, self.maxs*0.75),v_right*random(-200,200)+'0 0 200', 3, self);
		self.reivSecondPhase = TRUE;	//enter phase 2
	}

float enemy_range;
	enemy_range = vlen(self.origin-self.enemy.origin);
	
	if (self.pain_finished > time || (random(self.max_health*0.75)>self.health) ) {
		if (attacker==self.enemy && random()<0.3 && enemy_range > REIV_RANGE*1.5) {
			if (reiv_checkdodge())
				reiv_dodge();
			else
				return;
		}
		return;
	}
	
	sound (self, CHAN_VOICE, "reiv/pain.wav", 1, ATTN_NORM);
	
	if (enemy_range < REIV_RANGE*1.5 || random()<0.1)
		self.think = reiv_painguard;
	else
		self.think = reiv_painstun;
	
	self.pain_finished = time+1;
	thinktime self : 0;
}

void reiv_blasted () [++ $127stun .. $137stun]
{
	if (self.blasted > 1) {
		ai_backfromenemy(self.blasted);
		self.blasted -= BLAST_DECEL;
	}
	
	if (self.frame == $137stun)
		self.think = reiv_run;
	else
		self.think = reiv_blasted;
	thinktime self : HX_FRAME_TIME;
}

void reiv_run () [++ $025idle .. $038idle]
{
	self.think = reiv_run;
	thinktime self : HX_FRAME_TIME;
	
	ChangePitch();
	reiv_fx();
	self.reivAcceleration = 0;	//accelerator for charging
	ai_run(REIV_SPEED);
	reiv_checkdef();
	
	if (self.spawnflags & SF_FLYABOVE && self.enemy.origin_z < self.origin_z) {
		//ai_face();
		float height;
		height = self.origin_z - self.enemy.origin_z;
		if (height>0 && height<REIV_HEIGHT) {
			movestep (0, 0, REIV_SPEED*2, FALSE);
		}
	}
	if (self.th_stand == reiv_buried)
		self.th_stand = reiv_stand;
}

void reiv_stand2 () [++ $039look .. $053look]
{
	ai_stand();
	reiv_fx();
	
	thinktime self : HX_FRAME_TIME*2;
	
	if (cycle_wrapped)
	{
		self.reivIdleTimer = time+3;
		self.think = reiv_stand;
		thinktime self : 0;
	}
	else if (self.frame == $039look)
		sound (self, CHAN_VOICE, "reiv/idle.wav", 1, ATTN_IDLE);
}

void reiv_stand () [++ $025idle .. $038idle]
{	
	ai_stand();
	reiv_fx();
	
	if (cycle_wrapped && random()<0.2 && self.reivIdleTimer < time)
		self.think = reiv_stand2;
}

void reiv_walk () [++ $025idle .. $038idle]
{
	ai_walk(REIV_SPEED*0.5);
}

/*monster_reiver (1 0.3 0) (-20 -20 0) (20 20 32) AMBUSH 
	
	Experience: 40
	Health: 120
*/
void monster_reiver ()
{
	if(deathmatch)
	{
		remove(self);
		return;
	}

	if(!self.flags2&FL_SUMMONED && !self.flags2&FL2_RESPAWN)
		precache_reiver();
	
	self.reivDrainTimer = time;			//timer for when to drain health again
	self.reivSecondPhase = FALSE;	//in ranged phase or melee drain phase
	self.reivIdleTimer = time+2;	//timer for look anim
	self.reivChargeTime = time;	//timer for when to stop charging & dodging
	if (!self.experience_value)
		self.experience_value = 80;
	self.init_exp_val = self.experience_value;
	self.flags (+) FL_FLY;
	self.reivVoiceTimer = time;		//timer for voice
	if (!self.health)
		self.health = 160;
	self.reivFXTimer = time+1;			//timer for blood sound
	self.max_health = self.health;	//save spawn health for later checks
	self.mass = 10.1;	//not 10!
	self.monsterclass = CLASS_GRUNT;
	self.movetype = MOVETYPE_STEP;
	self.proj_ofs = '0 0 24';
	self.sightsound = "reiv/see.wav";
	self.solid = SOLID_SLIDEBOX;
	self.reivDodgeTimer = time;	//timer for when we can dodge again
	self.thingtype = THINGTYPE_FLESH;
	self.turn_time = 6;		//change pitch at this speed
	self.view_ofs = '0 0 32';
	self.reivAcceleration = 0;	//accelerator for charge speed
	self.yaw_speed = 12;
	
	setmodel (self, "models/reiver.mdl");
	setsize (self, REIV_MINS, REIV_MAXS);
	self.hull = HULL_CROUCH;
	
	if (self.spawnflags & REIV_BURIED)
	{
		self.mdl = self.model;
		self.movetype = MOVETYPE_NOCLIP;
		self.solid = SOLID_NOT;
		self.takedamage = DAMAGE_NO;
		self.th_stand = reiv_buried;
		self.th_run = reiv_rise;
		self.th_pain = SUB_Null;
		setmodel (self, "models/null.spr");
		if (self.spawnflags&REIV_DORMANT && self.targetname == "") {
			//self.spawnflags(-)REIV_DORMANT;
			dprint ("Error: dormant Reiver has no targetname!\n");
		}
	}
	else
	{
		self.th_stand = reiv_stand;
		self.th_run = reiv_run;
		self.th_pain = reiv_pain;
		self.th_blasted = reiv_blasted;
	}
	
	self.th_walk = reiv_walk;
	self.th_melee = reiv_melee;
	self.th_missile = reiv_mis;
	self.th_die = reiv_die;
	self.th_init = monster_reiver;
	
	flymonster_start();
}

