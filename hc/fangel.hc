/*
 * $Header: /cvsroot/uhexen2/gamecode/hc/portals/fangel.hc,v 1.2 2007-02-07 16:59:32 sezero Exp $
 */

/*
==============================================================================

Q:\art\models\monsters\Fangel\final\fangel.hc

==============================================================================
*/

// For building the model
$cd Q:\art\models\monsters\Fangel\final
$origin 0 0 0
$base BASE skin
$skin skin
$flags 0


//
$frame fblock1      fblock2      fblock3      fblock4      fblock5      
$frame fblock6      fblock7      fblock8      fblock9      fblock10     
$frame fblock11     fblock12     fblock13     fblock14     fblock15     
$frame fblock16     fblock17     fblock18     fblock19     fblock20     
$frame fblock21     

//
$frame fdeth1       fdeth2       fdeth3       fdeth4       fdeth5       
$frame fdeth6       fdeth7       fdeth8       fdeth9       fdeth10      
$frame fdeth11      fdeth12      fdeth13      fdeth14      fdeth15      
$frame fdeth16      fdeth17      fdeth18      fdeth19      fdeth20      
$frame fdeth21      fdeth22      fdeth23      fdeth24      fdeth25      
$frame fdeth26      fdeth27      fdeth28      fdeth29      fdeth30      
$frame fdeth31      fdeth32      fdeth33      fdeth34      fdeth35      
$frame fdeth36      fdeth37      fdeth38      fdeth39      fdeth40      

//
$frame ffly1        ffly2        ffly3        ffly4        ffly5        
$frame ffly6        ffly7        ffly8        ffly9        ffly10       
$frame ffly11       ffly12       ffly13       ffly14       ffly15       
$frame ffly16       ffly17       ffly18       ffly19       ffly20       
$frame ffly21       ffly22       ffly23       ffly24       ffly25       
$frame ffly26       ffly27       ffly28       ffly29       ffly30       

//
$frame fhand1       fhand2       fhand3       fhand4       fhand5       
$frame fhand6       fhand7       fhand8       fhand9       fhand10      
$frame fhand11      fhand12      fhand13      fhand14      fhand15      
$frame fhand16      fhand17      fhand18      fhand19      fhand20      
$frame fhand21      fhand22      

//
$frame fmove1       fmove2       fmove3       fmove4       fmove5       
$frame fmove6       fmove7       fmove8       fmove9       fmove10      
$frame fmove11      fmove12      fmove13      fmove14      fmove15      
$frame fmove16      fmove17      fmove18      fmove19      fmove20      

//
$frame fpain1       fpain2       fpain3       fpain4       fpain5       
$frame fpain6       fpain7       fpain8       fpain9       fpain10      
$frame fpain11      fpain12      

//
$frame ftranA1      ftranA2      ftranA3      ftranA4      ftranA5      
$frame ftranA6      ftranA7      ftranA8      ftranA9      ftranA10     
$frame ftranA11     ftranA12     ftranA13     ftranA14     ftranA15     
$frame ftranA16     ftranA17     ftranA18     ftranA19     ftranA20     

//
$frame ftranB1      ftranB2      ftranB3      ftranB4      ftranB5      
$frame ftranB6      ftranB7      ftranB8      ftranB9      ftranB10     
$frame ftranB11     ftranB12     ftranB13     ftranB14     ftranB15     
$frame ftranB16     ftranB17     ftranB18     ftranB19     ftranB20     

//
$frame fwing1       fwing2       fwing3       fwing4       fwing5       
$frame fwing6       fwing7       fwing8       fwing9       fwing10      
$frame fwing11      fwing12      fwing13      fwing14      fwing15      
$frame fwing16      fwing17      fwing18      fwing19      fwing20      
$frame fwing21      fwing22      fwing23      fwing24      fwing25      
$frame fwing26      fwing27      fwing28      fwing29      fwing30      


// Function protos
void() fangel_blockframes;
void fangel_handframes (void);
void fangel_wingframes (void);
void fangel_flyframes (void);
void fangel_painframes (void);

// Constants
float fangel_attack_speed = 11;
float fangel_move_speed = 6;

float () fangel_check_incoming =
{
entity item;
vector vec, realVec;
float dot;

	if(range(self.enemy)<=RANGE_MELEE)
		return FALSE;
	
	if (self.think == fangel_painframes)
		return FALSE;
	else if ( (self.think==fangel_wingframes || self.think==fangel_handframes) && random() < (1-skill*0.1))
		return FALSE;	//ws: not likely to block if in attack state

	if(fov(self,self.enemy,30)&&self.enemy.last_attack+0.75>time)
	{
		if ( !(PlayerHasMelee(self.enemy) && range(self.enemy)>RANGE_NEAR) )
		{	//if enemy is punching air or fighting something else in melee, dont block
			self.th_save = self.think;
			if (self.think == fangel_painframes)
				self.th_save = fangel_flyframes;
			self.fangel_Count = 0;
			fangel_blockframes();
			return TRUE;
		}
	}

	if(random()>0.4 + skill/10 + self.skin/10)
		return FALSE;

	item = findradius(self.origin, 256);
	while (item)
	{
		/*if (item.owner.classname == "player" && (item.movetype == MOVETYPE_FLYMISSILE ||
			item.movetype == MOVETYPE_BOUNCEMISSILE || item.movetype==MOVETYPE_BOUNCE))*/
		if (IsMissile(item) && IsEnemyOwned(item))
		{
			vec = normalize(self.origin - item.origin + self.view_ofs);
			realVec = normalize(item.velocity);
			dot= vec*realVec;
			if (dot >= 0.4) 
			{
				self.th_save = self.think;
				if (self.think == fangel_painframes)
					self.th_save = fangel_flyframes;
				self.fangel_Count = 0;
				fangel_blockframes();
				return TRUE;
			}
		}
		item = item.chain;
	}
	
	return FALSE;
};

// Monster Stages
float FANGEL_STAGE_WAIT     = 0;
float FANGEL_STAGE_FLY      = 1;
float FANGEL_STAGE_FLOAT    = 2;
float FANGEL_STAGE_SIDESTEP = 3;
//float FANGEL_STAGE_STRAIGHT = 3;
//float FANGEL_STAGE_REVERSE  = 4;
//float FANGEL_STAGE_ATTACK   = 10;

void() fangel_check_wing =
{
float retval;

	if(!self.enemy)
		return;

	enemy_infront = visible(self.enemy);

	// If we are flying, don't attack as often
	if (self.monster_stage == FANGEL_STAGE_FLY && random() < 0.5) 
		enemy_infront = 0;

	if (enemy_infront)
	{	//ws: increased attack chance, because she isnt always checking this, so make it count when she does
		self.th_save = self.think;
		enemy_range = range (self.enemy);
		if (random() < 0.5)
		   retval = CheckMonsterAttack(MA_FAR_MELEE,1.25);
		else
		   retval = CheckMonsterAttack(MA_MISSILE,1.25);
	}
	else retval = MA_NOATTACK;

	if (retval != MA_SUCCESSFUL)
		fangel_check_incoming();
	else
		self.yaw_speed = fangel_attack_speed;
};

void fangel_find_spot (void)
{
float crj, radius,dist;
vector vec;

	crj=0;
	while(crj < 50)
	{
		radius = random(100,200);

		vec = randomv('0 0 0', '360 360 0');

		vec = normalize(vec);
		vec = self.enemy.origin + vec*radius;

		vec_z = vec_z + random(20, 40) + self.enemy.view_ofs_z;

		tracearea (self.origin,vec,self.mins,self.maxs,FALSE,self);
		if (trace_fraction == 1)
		{
			self.monster_last_seen = vec;

			dist = self.origin_z - self.monster_last_seen_z;

			if (dist < -20)
				self.z_movement = random(0,2);
			else if (dist > 20 )
				self.z_movement = random(-2,0);
			else
				self.z_movement = random(-2,2);   // Give her a little up and down movement

			self.z_duration = time + HX_FRAME_TIME * random(15,25);

			return;
		}
		crj += 1;
	}

	self.monster_stage = FANGEL_STAGE_FLOAT;
	self.monster_duration = random(20,30);
}

void() fangel_init =
{  // Set the fallen angel ready
//	dprint(self.enemy.classname);
//	dprint("- Found enemy\n");
	self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
	//self.th_stand = fangel_flyframes;
	//self.think=self.th_stand;
	self.think = self.th_run;
	thinktime self : random(.1,.6);
	self.count = 0;
	self.monster_stage = FANGEL_STAGE_FLY;
	self.monster_duration = 0;
	self.goalentity = self.enemy;

	self.monster_awake = TRUE;

	if (self.skin)
		self.drawflags (+) MLS_POWERMODE;

	fangel_find_spot();
};


void fangel_wait (void)
{
	self.frame = $fhand1;
	thinktime self : 0.15;
	LocateTarget();
	if(EnemyIsValid(self.enemy)) // We found a target
		fangel_init();
	else if(random(100)<5&&self.t_width<time)
	{
		self.t_width=time+7;
		if(self.skin)
			sound(self,CHAN_AUTO,"fangel/ambi2.wav",random(0.75,1),ATTN_NORM);
		else
			sound(self,CHAN_AUTO,"fangel/ambi1.wav",random(0.75,1),ATTN_NORM);
	}
}

void fangel_sidestep (void) 
{
float retval;
float dist;
float chance;

	self.monster_duration -= 1;

	dist = random(1,4);  // Movement distance this turn

	retval = walkmove(self.angles_y + 90, dist, FALSE);

	if (!retval)
	{
		self.monster_stage = FANGEL_STAGE_FLY;
		fangel_find_spot();
		self.think = fangel_flyframes;
		self.nextthink = time;
		return;
	}

	dist = self.origin_z - self.monster_last_seen_z;

	if (dist < -20)
	{
		self.z_movement = random(0,2);
		self.z_duration = time + HX_FRAME_TIME * random(15,25);
	}
	else if (dist > 20)
	{
		self.z_movement = random(-2,0);
		self.z_duration = time + HX_FRAME_TIME * random(15,25);
	}

	if (self.monster_duration <= 0)
	{
		chance = random();
		if (chance < .33)
		{
			self.monster_stage = FANGEL_STAGE_FLOAT;
			self.monster_duration = random(10,30);
		}
		else if (chance < .66)
			self.think = fangel_handframes;  // Come back fighting
		else
			self.think = fangel_wingframes;  // Come back fighting
	}
}

void fangel_fly (float thrust) 
{
float retval;
float dist;
float Length;

	Length = vhlen(self.origin - self.monster_last_seen);
	self.ideal_yaw = vectoyaw(self.monster_last_seen - self.origin);
	ChangeYaw();

	dist = (2.0 + thrust * 4);  // Movement distance this turn

	if (Length < 20)
	{
		if (random() < 0.1)
			fangel_find_spot();
		else
		{
			self.monster_stage = FANGEL_STAGE_FLOAT;
			self.monster_duration = random(10,30);
		}
		return;
	}

	retval = walkmove(self.angles_y, dist, FALSE);

	if (!retval)
	{
		fangel_find_spot();
		return;
	}

	dist = self.origin_z - self.monster_last_seen_z;

	if (dist < -20)
	{
		self.z_movement = random(2,4);
		self.z_duration = time + HX_FRAME_TIME * random(15,25);
	}
	else if (dist > 20)
	{
		self.z_movement = random(-2,-4);
		self.z_duration = time + HX_FRAME_TIME * random(15,25);
	}

	if (self.z_duration > time)
		movestep(0,0,self.z_movement, FALSE);
}

void () fangel_float =
{
	self.monster_duration = self.monster_duration - 1;
	ai_face();

	enemy_range = range (self.enemy);	// Attack if they are too near
	if ((enemy_range <= RANGE_MELEE) && (random() < .9))
		self.monster_duration = 0;
	else if ((enemy_range <= RANGE_NEAR) && (random() < .25))
		self.monster_duration = 0;

	if (self.monster_duration <= 0)
	{
		self.monster_stage = FANGEL_STAGE_FLY;
		fangel_find_spot();
	}
};


void fangel_move (float thrust)
{
	check_z_move(thrust/2);
//	movestep(0,0,thrust/2, FALSE);

	if (self.monster_stage == FANGEL_STAGE_WAIT)
	{
//		dprint("Waiting\n");
		fangel_wait();
		return;
	}
	else if (self.monster_stage == FANGEL_STAGE_FLY)
	{
		fangel_fly(thrust);
		return;
	}
	else if (self.monster_stage == FANGEL_STAGE_SIDESTEP)
	{
		fangel_sidestep();
		return;
	}
	else if (self.monster_stage == FANGEL_STAGE_FLOAT)
	{
		fangel_float();
		return;
	}
}

void () fangel_prepare_attack = 
{
	ai_face();
};

void () fangel_hand_fire =
{
	fangel_prepare_attack();

	sound (self, CHAN_WEAPON, "fangel/hand.wav", 1, ATTN_NORM);

	do_faSpell('10 -4 8',FALSE);	//straight ahead
	do_faSpell('10 -4 8',TRUE);		//lead shot
};

void () fangel_wing_fire =
{
	fangel_prepare_attack();

	sound (self, CHAN_WEAPON, "fangel/wing.wav", 1, ATTN_NORM);

	makevectors (self.angles);

	do_faBlade('8 6 4',360, v_right*2);
	do_faBlade('-8 6 4',360, v_right*(-2));
};


float fangel_fly_offsets[20] =
{
	0,
	0.1,
	0.2,
	0.3,
	0.4,
	0.5,
	0.6,
	0.7,
	0.8,
	0.9,
	1,
	0.9,
	0.8,
	0.7,
	0.6,
	0.5,
	0.4,
	0.3,
	0.2,
	0.1
};

// Frame Code

void() fangel_blockframes =
{
float RetVal;
float chance;
	self.think = fangel_blockframes;
	thinktime self : HX_FRAME_TIME;

	if(self.velocity!='0 0 0')
		self.velocity=self.velocity*0.7;

	// Turn to face the attacker
	ai_face();

	check_z_move(3);
//	movestep(0,0,-1, FALSE);   // Float down while deflecting shots

	if (self.fangel_Count)
	{
		self.fangel_Count -= 1;
		RetVal = 3;
	}
	else if(fov(self,self.enemy,30)&&self.enemy.last_attack+0.75>time&&self.frame == $fblock13)
		self.fangel_Count+=1;
	else
		RetVal = AdvanceFrame($fblock1,$fblock21);

	if (self.frame==$fblock21)		//	Only deflect after this frame
	{
		if(self.movechain)
			remove(self.movechain);
		self.movechain=world;
	}

	if (RetVal == AF_END)
	{
		self.takedamage = DAMAGE_YES;
		chance = random();

		if (chance < .1)
			self.think = self.th_save;
		else if (chance < .60)
			self.think = fangel_handframes;  // Come back fighting
		else
			self.think = fangel_wingframes;  // Come back fighting
	}
	else if (RetVal == AF_NORMAL)
	{
		if (self.frame == $fblock13) 
			self.fangel_Count = 30;		//40
	}

	if (self.frame == $fblock9)
	{
		self.takedamage = DAMAGE_NO;
		spawn_reflect();
		stopSound(self,CHAN_WEAPON);//cut off wings sound
	}
};

void() fangel_deathframes =
{
//entity skull;

	if(self.health<=-40)
	{
		ThrowGib ("models/blood.mdl", self.health);
		ThrowGib ("models/blood.mdl", self.health);
		stopSound(self,CHAN_WEAPON);//cut off wings sound
		chunk_death();
		return;
	}

	self.think = fangel_deathframes;
	thinktime self : HX_FRAME_TIME;

	traceline (self.origin, self.origin - '0 0 250',FALSE,self);
	particle2(trace_endpos,'-30 -30 50','30 30 100',384,PARTICLETYPE_SPELL,80);

	if (self.frame == 26)
		self.drop_time = time + .25;

	if ((self.frame == 27) && (!self.flags & FL_ONGROUND))
	{
		self.frame = 26;
		self.velocity_z = -20;
		if (self.drop_time < time)	// Dropping too long so let her die.
			self.frame = 27;
	}

/*Should she spew a head if not chunked?
	if (self.frame == $fdeth40)
	{
		skull= spawn();
		CreateEntityNew(skull,ENT_FANGEL_HEAD,"models/h_fangel.mdl",chunk_death);

		skull.flags(-)FL_ONGROUND;

		skull.avelocity_x = random(30);
		skull.avelocity_y = random(30);
		skull.avelocity_z = random(80);
		thinktime skull : random(4,10);
		skull.think = MakeSolidCorpse;
		setorigin(skull,self.origin);
	}
*/

	if (AdvanceFrame($fdeth1,$fdeth40) == AF_BEGINNING)
		remove(self);

	if (self.frame == $fdeth1)
		self.movetype = MOVETYPE_STEP;

	if (self.frame == $fdeth10)
	{
		if (self.classname == "monster_fallen_angel")
			sound (self, CHAN_WEAPON, "fangel/death.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_WEAPON, "fangel/death2.wav", 1, ATTN_NORM);
	}
};


void fangel_flyforward (void)
{
	AdvanceFrame($fmove1,$fmove20);
	self.frame += 1;

	fangel_move(3*fangel_fly_offsets[self.frame - $fmove1]);

	if (self.frame == $fmove2)
		sound (self, CHAN_WEAPON, "fangel/fly.wav", 1, ATTN_NORM);

	if ((self.frame >= $fmove6 && self.frame <= $fmove8) ||
	    (self.frame >= $fmove16 && self.frame <= $fmove18))
	{
		self.fangel_SaveFrame = self.frame;
		fangel_check_wing();
	}
}

void fangel_flyother (void)
{
	AdvanceFrame($ffly1,$ffly30);
	fangel_move(3*fangel_fly_offsets[rint((self.frame - $ffly1)*.65)]);

	if (self.frame == $ffly1) 
		sound (self, CHAN_WEAPON, "fangel/fly.wav", 1, ATTN_NORM);

	if ((self.frame >= $ffly11 && self.frame <= $ffly13) ||
	    (self.frame >= $ffly26 && self.frame <= $ffly28))
	{
		self.fangel_SaveFrame = self.frame;
		fangel_check_wing();
	}
}

void() fangel_flyframes =
{
	if (!EnemyIsValid(self.enemy)) {
		stopSound(self,CHAN_WEAPON);//cut off wings sound
		self.think = self.th_stand;
	}
	else
		self.think = fangel_flyframes;
	thinktime self : HX_FRAME_TIME;
	if (visible(self.enemy))
		self.wallspot = (self.enemy.absmin+self.enemy.absmax)*0.5;
	else
		SetNextWaypoint();

	fangel_check_incoming();

	if(self.velocity!='0 0 0')
		self.velocity=self.velocity*0.7;

	if (self.monster_stage == FANGEL_STAGE_FLY)
		fangel_flyforward();
	else
		fangel_flyother();
};

void fangel_handframes (void)
{
	self.think = fangel_handframes;
	thinktime self : HX_FRAME_TIME;

	fangel_check_incoming();

	if (AdvanceFrame($fhand1,$fhand22) == AF_END)
	{
		fangel_prepare_attack();

		if (random() < .25)
		{
			self.monster_stage = FANGEL_STAGE_SIDESTEP;
			self.monster_duration = random(20,40);
			fangel_find_spot();
			self.think = fangel_flyframes;
		}
		else
		{
			self.think = self.th_save; 
		}

		self.frame = self.fangel_SaveFrame;
		self.yaw_speed = fangel_move_speed;
	}
	else
	{
		if (self.frame == $fhand12) fangel_hand_fire();
		else fangel_prepare_attack();
	}
}

void() fangel_painframes =
{
	float chance;

	self.think = fangel_painframes;
	thinktime self : HX_FRAME_TIME;
	if (AdvanceFrame($fpain1,$fpain12) == AF_END)
	{
		fangel_check_incoming();

		chance = random();
		if (chance < .33)
			self.think = self.th_save;
		else if (chance < .66)
			self.think = fangel_handframes;  // Come back fighting
		else
			self.think = fangel_wingframes;  // Come back fighting

		self.frame = self.fangel_SaveFrame;
	}
};

void() fangel_prepare_beam =
{	//ws: hitting the player instantly for the attack's duration felt cheap. so instead, find the player's position beforehand and aim beam there.
	if (!self.enemy) {
		self.finaldest = v_forward*512;
		return;
	}
	
	enemy_vis = visible(self.enemy);
	if (!enemy_vis) {
		self.finaldest = self.wallspot;		//if we cant see enemy, aim at last spot we saw them in
	}
	if (enemy_vis && !self.shoot_cnt) {		//if not yet firing, remember direction player is heading
		self.finaldest = (self.enemy.absmin+self.enemy.absmax)*0.5;
		self.movedir = self.enemy.velocity;
		if (!self.enemy.flags&FL_ONGROUND)
			self.movedir_z = 0;		//ignore jumping
	}
	if (!self.shoot_cnt)
		return;
	
	//while firing, aim beam in the direction player was heading before firing
	if (self.movedir == VEC_ORIGIN)	//player wasnt moving, no need to aim
		return;
	//self.finaldest += self.movedir*(20+((skill>2)*8));
	self.finaldest += normalize(self.movedir)*(vlen(self.movedir)*0.04);
	self.ideal_yaw = vectoyaw(self.finaldest - self.origin);
	self.yaw_speed = 18;
	ChangeYaw();			//turn towards angle of beam
	self.yaw_speed = fangel_move_speed;
};

void() fangel_wingframes =
{
	self.think = fangel_wingframes;
	thinktime self : HX_FRAME_TIME;

	if (AdvanceFrame($fwing1,$fwing30) == AF_END)
	{
		fangel_prepare_attack();
		self.finaldest = self.movedir = VEC_ORIGIN;		//reset beam aim

		if (random() < .25)
		{
			self.monster_stage = FANGEL_STAGE_SIDESTEP;
			self.monster_duration = random(20,40);
			fangel_find_spot();
			self.think = fangel_flyframes;
		}
		else
			self.think = self.th_save; 

		self.frame = self.fangel_SaveFrame;
		self.yaw_speed = fangel_move_speed;
	}
	else
	{
		if (self.classname == "monster_fallen_angel")
		{
			if (self.frame == $fwing21) 
			{
				if (self.shoot_cnt < 3)
				{
					if (self.shoot_time < time)
					{
						fangel_wing_fire();
						self.shoot_cnt += 1;
						self.shoot_time = time + HX_FRAME_TIME * 3;
					}
					self.frame = $fwing20;
				}
				else
					self.shoot_cnt =0;
			}
			else
				fangel_prepare_attack();
		}
		else
		{
			fangel_prepare_beam();
			if (self.frame == $fwing20)
				sound(self, CHAN_ITEM, "golem/gbfire.wav", 1, ATTN_NORM);
			if (self.frame == $fwing21) 
			{
				if (self.shoot_cnt < 30)
				{
				vector org1,org2;
					makevectors(self.angles);
					org1 = self.origin-'0 0 5'+v_forward*10;
					org2 = self.finaldest;
					self.effects(+)EF_MUZZLEFLASH;
					WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
					WriteByte (MSG_BROADCAST, TE_STREAM_COLORBEAM);	//beam type
					WriteEntity (MSG_BROADCAST, self);				//owner
					WriteByte (MSG_BROADCAST, 0);					//tag + flags
					WriteByte (MSG_BROADCAST, 1);					//time
					WriteByte (MSG_BROADCAST, rint(random(0,4)));			//color

					WriteCoord (MSG_BROADCAST, org1_x);
					WriteCoord (MSG_BROADCAST, org1_y);
					WriteCoord (MSG_BROADCAST, org1_z);

					WriteCoord (MSG_BROADCAST, org2_x);
					WriteCoord (MSG_BROADCAST, org2_y);
					WriteCoord (MSG_BROADCAST, org2_z);

					LightningDamage (self.origin, org2, self, 3,"sunbeam");

					//self.frame -= 1;
					self.shoot_cnt += 1;
					self.frame = $fwing20;
				}
				else
					self.shoot_cnt =0;
			}
			else
				fangel_prepare_attack();
		}
	}
};

void(entity attacker, float damage) fangel_pain =
{	//ws: decreased damage requirement
	if (random(self.health*0.1) > damage || self.pain_finished>time)
		return;		// didn't flinch
	
	/*
	if (self.frame >= $ffly11 && self.frame <= $ffly28)
	{
		if (self.classname == "monster_fallen_angel")
			sound (self, CHAN_WEAPON, "fangel/pain.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_WEAPON, "fangel/pain2.wav", 1, ATTN_NORM);

		self.fangel_SaveFrame = self.frame;
		// didn't want to use self.think just in case we just began to attack
		self.th_save = fangel_flyframes;
		fangel_painframes();
	}*/
	if (self.think == fangel_flyframes)
	{
		self.finaldest = self.movedir = VEC_ORIGIN;		//reset beam aim
		if (self.classname == "monster_fallen_angel")
			sound (self, CHAN_WEAPON, "fangel/pain.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_WEAPON, "fangel/pain2.wav", 1, ATTN_NORM);
		self.pain_finished=time + 1 + self.skin;
		ThrowGib ("models/blood.mdl", self.health);
		if (self.health < 50)
			self.drawflags (-) DRF_TRANSLUCENT|MLS_POWERMODE;

		self.fangel_SaveFrame = self.frame;
		// didn't want to use self.think just in case we just began to attack
		self.th_save = fangel_flyframes;
		fangel_painframes();
	}
};


void() init_fangel =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	
	self.init_org = self.origin;

	self.monster_stage = FANGEL_STAGE_WAIT;

	if (!self.flags2&FL_SUMMONED && !self.flags2&FL2_RESPAWN)
	{
		precache_model4 ("models/fangel.mdl");//converted for MP
		precache_model2 ("models/faspell.mdl");
		precache_model2 ("models/fablade.mdl");
		precache_model4 ("models/h_fangel.mdl");

		precache_sound2("fangel/fly.wav");
		precache_sound2("fangel/deflect.wav");
		precache_sound2("fangel/hand.wav");
		precache_sound2("fangel/wing.wav");
		precache_sound("mezzo/reflect.wav");	//SoC: bouncing missiles
		precache_sound("golem/gbfire.wav");	//SoC: beam attack
	}

	if (self.classname == "monster_fallen_angel")
	{
		if(!self.health)
			self.health = 250;
		if(!self.experience_value)
			self.experience_value = 150;
	}
	else
	{
		if(!self.health)
			self.health = 500;
		if(!self.experience_value)
			self.experience_value = 400;
	}
	CreateEntityNew(self,ENT_FANGEL,"models/fangel.mdl",fangel_deathframes);

	self.hull = HULL_SCORPION;//HULL_BIG;
	if (self.classname == "monster_fallen_angel")
		self.skin = 0;
	else
		self.skin = 1;

	if(!self.max_health)
		self.max_health=self.health;

	self.th_stand = fangel_wait;	//fangel_flyframes;
	self.th_walk = fangel_flyframes;
	self.th_run = fangel_flyframes;
	self.th_pain = fangel_pain;
	self.th_die = fangel_deathframes;
	self.th_missile = fangel_handframes;
	self.th_melee = fangel_wingframes;
	self.headmodel="models/h_fangel.mdl";
	
	self.ideal_yaw = self.angles * '0 1 0';
	self.yaw_speed = fangel_move_speed;
	self.view_ofs = '0 0 -5';
	self.mintel = 3;

	if (self.classname == "monster_fallen_angel_lord")
		self.drawflags (+) DRF_TRANSLUCENT;

	self.init_exp_val = self.experience_value;
	self.frame=$fhand1;
	
	flymonster_start();
};


/*QUAKED monster_fallen_angel (1 0.3 0) (-14 -14 -41) (14 14 23) AMBUSH STUCK JUMP x DORMANT
New item for QuakeEd

-------------------------FIELDS-------------------------
--------------------------------------------------------

*/
void() monster_fallen_angel =
{
	self.th_init=monster_fallen_angel;
	if (!self.flags2&FL_SUMMONED && !self.flags2&FL2_RESPAWN)
	{
		precache_sound2("fangel/death.wav");
		precache_sound2("fangel/pain.wav");
		precache_sound2("fangel/ambi1.wav");
	}

	init_fangel();
};

/*QUAKED monster_fallen_angel_lord (1 0.3 0) (-14 -14 -41) (14 14 23) AMBUSH STUCK JUMP x DORMANT
New item for QuakeEd

-------------------------FIELDS-------------------------
--------------------------------------------------------

*/
void() monster_fallen_angel_lord =
{
	self.th_init=monster_fallen_angel_lord;
	if (!self.flags2&FL_SUMMONED && !self.flags2&FL2_RESPAWN)
	{
		precache_sound2("fangel/death2.wav");
		precache_sound2("fangel/pain2.wav");
		precache_sound2("fangel/ambi2.wav");
	}

	init_fangel();
};

