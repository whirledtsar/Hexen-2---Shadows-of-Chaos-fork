/*
 * $Header: /cvsroot/uhexen2/gamecode/hc/h2/warhamer.hc,v 1.2 2007-02-07 16:24:56 sezero Exp $
 */

/*
==============================================================================

Q:\art\models\weapons\warhammer\final\warham.hc
MG
==============================================================================
*/

// For building the model
$cd Q:\art\models\weapons\warhammer\final
$origin 0 0 0
$base BASE skin
$skin skin
$flags 0

//
$frame Chop1        Chop2        Chop3        Chop4        Chop5        
$frame Chop6        Chop7        Chop8        Chop9        Chop10       
$frame Chop11       Chop12       

//
$frame Hack1        Hack2        Hack3        Hack4        Hack5        
$frame Hack6        Hack7        Hack8        Hack9        Hack10       

//
$frame LtoR1        LtoR2        LtoR3        LtoR4        LtoR5        
$frame LtoR6        LtoR7        LtoR8        LtoR9        LtoR10       
$frame LtoR11

//
$frame Return1      Return2      Return3	  Return4    

//
$frame RtoL1        RtoL2        RtoL3        RtoL4        RtoL5        
$frame RtoL6        RtoL7        RtoL8        RtoL9        RtoL10       
$frame RtoL11       RtoL12       RtoL13       

//
$frame Select1      Select2      Select3      Select4      Select5      
$frame Select6      Select7      Select8      Select9      

//
$frame Throw1       Throw2       Throw3       Throw4       Throw5       
$frame Throw6       Throw7       Throw8       Throw9       Throw10

//
$frame idle

float HAMMER_THROW_COST = 3;

string HAMMER_TEXMOD = "models/warhamer.mdl"

void(vector org) spawn_tfog;
void(float max_strikes, float damg)CastLightning;
void()warhammer_idle;
void()warhammer_select;

void ThrowHammerReturn (void)
{
	//sound(self.controller, CHAN_ITEM, "weapons/weappkup.wav",1, ATTN_NORM);
//	if(self.controller.weapon==IT_WEAPON1)
// Only play selection if they're still on weapon1
//Or, if using another weapon, play the select frames,
//then go back to what you were doing with the current weapon
	self.controller.weapon=IT_WEAPON1;
	self.controller.th_weapon=warhammer_select;
    sound(self, CHAN_VOICE, "misc/null.wav", 0.3, ATTN_NORM);
	remove(self);
}

void HammerZap (void)
{
vector zapangle, tospot, fromspot;
float numstrikes, strikelength;
	if(pointcontents(self.origin)==CONTENT_WATER)//FIXME:Include other water types
		strikelength=42;
	else
		strikelength=14;

	numstrikes=random(1,6);
	while(numstrikes>0)
	{
		zapangle=RandomVector('360 360 360');
		makevectors(zapangle);
		fromspot = self.origin + v_forward*16;
		tospot=self.origin + (v_forward*random(strikelength+32,32)); //Keep it to 30 si it won' have to draw more than one model
		do_lightning (self,self.level,STREAM_ATTACHED,1,fromspot,tospot,3);
		self.level+=1;
		numstrikes-=1;
		if(self.level>32)
			self.level=0;
	}
	self.effects=EF_MUZZLEFLASH;
}

void hammer_bounce ()
{
	if(other.thingtype!=THINGTYPE_FLESH)
		if(self.t_width<time)
		{
			self.t_width=time+0.3;
			if(random()<0.3)
				sound(self,CHAN_BODY,"weapons/met2stn.wav",0.5,ATTN_NORM);
			else if(random()<0.5)
				sound(self,CHAN_BODY,"weapons/vorpht2.wav",0.5,ATTN_NORM);
			else
				sound(self,CHAN_BODY,"paladin/axric1.wav",0.75,ATTN_NORM);
		}
}

void() ThrowHammerThink =
{
vector destiny;
float distance;
	makevectors(self.controller.v_angle);
	destiny=self.controller.origin+self.controller.proj_ofs+v_right*7+'0 0 -7';
	distance=vlen(self.origin-destiny);	

	if(self.lifetime<time||(distance<28&&self.counter<time))
	{
//		spawn_tfog(self.controller.origin);
		ThrowHammerReturn();
	}

	if(self.counter<=time)
		self.owner=self;
	if(distance>377)
		self.aflag= -1;
	
	if (self.aflag == -1)
	{
	local vector dir;
		dir = normalize(destiny - self.origin);
		if (self.watertype < -2)
			self.velocity = dir * self.speed*0.5;
	    else self.velocity = dir * self.speed;
			self.angles = vectoangles(self.velocity);
		if (self.flags & FL_ONGROUND)
	    {
			self.avelocity = '500 0 0';
	        self.flags(-)FL_ONGROUND;
		}
    }
	
	if(self.pain_finished<=time)
	{
		sound(self, CHAN_VOICE, "paladin/axblade.wav", 0.5, ATTN_NORM);
		self.pain_finished=time+0.3;
	}
	
	if(self.controller.health<=0||!self.controller.flags2&FL_ALIVE||self.controller.model=="models/sheep.mdl")
    {
        sound(self, CHAN_VOICE, "misc/null.wav", 0.3, ATTN_NORM);
		if(pointcontents(self.origin)==CONTENT_SOLID)
			remove(self);
		else
		{
			self.touch=hammer_bounce;
			self.avelocity=randomv('-400 -400 -400','400 400 400');
			self.movetype=MOVETYPE_BOUNCE;
			self.think=corpseblink;
			thinktime self : 3;
		}
		return;
    }
//	HammerZap();
	thinktime self : 0.1;
	self.think = ThrowHammerThink;
	
	if (self.origin==VEC_ORIGIN)	//ws: not sure what causes this bug, but heres a band-aid
		ThrowHammerReturn();
};

void HammerTouch ()
{
	float inertia;
	float tome;
	
	tome = self.owner.artifact_active&ART_TOMEOFPOWER;

	if (other == self.controller)
		if (self.aflag||self.counter<time)
			ThrowHammerReturn();
        else 
			return;
	else if (other.takedamage && self.velocity != VEC_ORIGIN && other != self.controller)
	{
      //if(self.velocity != VEC_ORIGIN && other != self.controller)
        if (self.aflag < 1)  
        {
			if (tome) //tome throws monster back and casts lightning
			{
	//          spawn_touchblood(40);
	//          SpawnChunk(self.origin, self.velocity);
				other.punchangle_x = -20;
				self.enemy = other;  
				CastLightning(3, self.dmg / 2);
				if(other.health&&other.solid!=SOLID_BSP&&other.movetype!=MOVETYPE_PUSH)
				{
					if (other.mass<=10)
						inertia=1;
					else 
						inertia = other.mass/10;
					other.velocity_x = other.velocity_x + self.velocity_x / inertia;
					other.velocity_y = other.velocity_y + self.velocity_y / inertia;
	//				other.velocity_z = other.velocity_z + 100/inertia;
					other.flags(-)FL_ONGROUND;
				}		
			}
			else	//just make a puff if not tome
			{
				Knockback (other, self.owner, self, 9, 0.75);	//light knockback
				SpawnPuff (self.origin, '0 0 0', 20,other);
			}
			T_Damage(other, self, self.controller, self.dmg);
			MetalHitSound(other.thingtype);
        }
	}
	else if(!MetalHitSound(other.thingtype))
		sound(self, CHAN_BODY, "weapons/hitwall.wav", 1, ATTN_NORM);
  
	if (self.aflag < 1)
	{
		self.aflag = -1;
		self.movetype=MOVETYPE_NOCLIP;
		self.solid=SOLID_PHASE;
	}
}

void ThrowHammer (float dexmod, float tome)
{
	local entity missile;
	sound(self, CHAN_WEAPON, "weapons/vorpswng.wav", 1, ATTN_NORM);
	missile = spawn();
	missile.owner = self;
	missile.controller = self;
	missile.classname = "mjolnir";
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;
	makevectors(self.v_angle);
	missile.velocity = normalize(v_forward);
	missile.angles = vectoangles(missile.velocity);
	missile.speed = 800;
	if (self.waterlevel > 2)
		missile.velocity = missile.velocity * missile.speed*0.5;
	else
		missile.velocity = missile.velocity * missile.speed;
	missile.touch = HammerTouch;
	thinktime missile : 0;
	missile.frags=TRUE;
	missile.counter = time + 0.3;
	missile.lifetime = time + 3;
	sound(missile, CHAN_VOICE, "paladin/axblade.wav", 1, ATTN_NORM);
	missile.think = ThrowHammerThink;
	setmodel(missile, "models/hamthrow.mdl");
	setsize(missile,'-1 -2 -4','1 2 4');
	setorigin(missile, self.origin+self.proj_ofs + v_forward * FL_SWIM);
	missile.avelocity = '-500 0 0';
	missile.aflag = 0;
	missile.level= 4;
	missile.drawflags=MLS_ABSLIGHT;//Powermode?  Translucent when returning?
	missile.abslight = 1;
	//missile.dmg=random(wismod, wismod * 1.5);
	missile.dmg=random(dexmod*2.25, dexmod * 2.75);		//dex is ~12 at level 3
	if (tome)
		missile.dmg *= 1.5;

	self.attack_finished=time + 1;
}

void warhammer_gone ()
{
	self.th_weapon=warhammer_gone;
	self.weaponmodel="";
	self.weaponframe=0;
}

void warhammer_throw (float tome)
{
	//float wismod;
	//wismod = self.wisdom;
	float dexmod;
	dexmod = self.dexterity;
	
	self.th_weapon=warhammer_throw;
	self.wfs = advanceweaponframe($Throw1,$Throw10);
	if (self.weaponframe == $Throw7)
	{
		sound (self, CHAN_WEAPON, "weapons/vorpswng.wav", 1, ATTN_NORM);
		ThrowHammer(dexmod, tome);
		
		if (self.bluemana >= HAMMER_THROW_COST && !self.artifact_active&ART_TOMEOFPOWER)
			self.bluemana -= HAMMER_THROW_COST;
	}
	else if (self.wfs==WF_LAST_FRAME)
		warhammer_gone();
}

void test_traceline ()
{
	vector	source;
	vector	dir;

	makevectors (self.v_angle);
	source = self.origin + self.proj_ofs;
	dir=normalize(v_forward);

	traceline (source, source + dir*64, TRUE, self);

//	if (trace_fraction <1.0)
//		spawntestmarker(trace_endpos);
}

void warhammer_fire (string hitdir, vector ofs, float tome)
{
	vector	source;
	vector	org;
	float	damg;
	float strmod;
	float force, zmod;
	
	strmod = self.strength;		//starts at ~13
	force = 10;
	zmod = 1;

	makevectors (self.v_angle);
	source = self.origin + self.proj_ofs;

//	tracearea (self.origin, self.origin + v_forward*64*self.scale, '-16 -16 -14','16 16 14',FALSE, world);
	traceline (source, source + v_forward*64*self.scale + ofs, FALSE, self.goalentity);
	if(!trace_ent||trace_ent==self.goalentity)
		traceline (source, source + v_forward*64*self.scale + ofs-v_up*32, FALSE, self.goalentity);
	if(!trace_ent||trace_ent==self.goalentity)
		traceline (source, source + v_forward*64*self.scale + ofs+v_up*16, FALSE, self.goalentity);

	if (trace_fraction <1.0)//&&trace_ent!=firsttarg)  
	{
		org = trace_endpos + (v_forward * 4);
	
		if (trace_ent.takedamage&&trace_ent!=self)
		{
			if(trace_ent.thingtype == THINGTYPE_FLESH)
			{
				self.weaponmodel = "models/warhamerblood.mdl";
				HAMMER_TEXMOD = "models/warhamerblood.mdl";
			}
			
			self.goalentity=trace_ent;
			SpawnPuff (org, '0 0 0', 20,trace_ent);
	
			damg = random(strmod, strmod * 1.5);
			if(!MetalHitSound(trace_ent.thingtype))
				sound (self, CHAN_WEAPON, "weapons/gauntht1.wav", 1, ATTN_NORM);

			if(hitdir=="top")
			{
				damg += (strmod * 0.5);
				zmod = -1;
				trace_ent.deathtype="hammercrush";
			}
			
			//increase damage for tome
			if (tome)
			{
				damg *= 2;
				force *= 1.5;
			}
			
			if (self.super_damage)
				damg += strmod;

			Knockback (trace_ent, self, self, force, zmod);
			T_Damage (trace_ent, self, self, damg);
			
		}
		else if(ofs=='0 0 0')
		{
			sound (self, CHAN_WEAPON, "weapons/hitwall.wav", 1, ATTN_NORM);
			org = trace_endpos - v_forward + v_right*10 - v_up*40;
			CreateSpark (org);
		}
	}
}

void warhammer_idle(void)
{
	self.th_weapon=warhammer_idle;
	self.weaponframe=$idle;
	
	self.weaponmodel = HAMMER_TEXMOD;
}

void warhammer_return (void)
{
	self.th_weapon=warhammer_return;
	self.wfs = advanceweaponframe($Return1,$Return4);
	if (self.wfs==WF_CYCLE_WRAPPED)
		warhammer_idle();
}

void warhammer_deselect (void)
{
	self.wfs = advanceweaponframe($Select9,$Select1);
	self.th_weapon=warhammer_deselect;
	if (self.wfs == WF_LAST_FRAME)
		W_SetCurrentAmmo();
}

void warhammer_select (void)
{
//  Check to see if have warhammer
//	if(!self.?) warhammer_gone();
	self.th_weapon=warhammer_select;
	self.wfs = advanceweaponframe($Select1,$Select9);
	self.weaponmodel = HAMMER_TEXMOD;
	if (self.wfs==WF_CYCLE_WRAPPED)
	{
		self.attack_finished = time - 1;
		warhammer_idle();
	}
}

void warhammer_c ()
{
	vector ofs;
	
	float tome;
	tome = self.artifact_active&ART_TOMEOFPOWER;
	
	makevectors(self.v_angle);
	self.th_weapon=warhammer_c;
	self.wfs = advanceweaponframe($LtoR1,$LtoR11);
	if (self.weaponframe == $LtoR4)
		self.weaponframe+=3;
	if (self.weaponframe == $LtoR7)
	{
		sound (self, CHAN_WEAPON, "weapons/vorpswng.wav", 1, ATTN_NORM);
		self.goalentity=self;
		ofs=normalize(v_right)*30;
		warhammer_fire ("right",ofs, tome);
		self.punchangle_y= -1;
	}
	else if (self.weaponframe == $LtoR8)
		warhammer_fire ("right",'0 0 0', tome);
	else if (self.weaponframe == $LtoR9)
	{
		ofs=normalize(v_right)*-30;
		warhammer_fire ("right",ofs, tome);
		self.punchangle_y= -2;
	}

	if (self.wfs==WF_CYCLE_WRAPPED)
		warhammer_return();
}

void warhammer_b ()
{
	vector ofs;
	float tome;
	tome = self.artifact_active&ART_TOMEOFPOWER;
	
	makevectors(self.v_angle);
	self.th_weapon=warhammer_b;
	self.wfs = advanceweaponframe($RtoL1,$RtoL11);
	if (self.weaponframe == $RtoL5)
	{
		sound (self, CHAN_WEAPON, "weapons/vorpswng.wav", 1, ATTN_NORM);
		self.goalentity=self;
		ofs=normalize(v_right)*-30;
		warhammer_fire ("left",ofs, tome);
		self.punchangle_y= 1;
	}
	else if (self.weaponframe == $RtoL6)
		warhammer_fire ("left",'0 0 0', tome);
	else if (self.weaponframe == $RtoL7)
	{
		ofs=normalize(v_right)*30;
		warhammer_fire ("left",ofs, tome);
		self.punchangle_y= 2;
	}
	if (self.wfs==WF_CYCLE_WRAPPED)
		warhammer_select();
}	

void warhammer_a ()
{
	float tome;
	tome = self.artifact_active&ART_TOMEOFPOWER;

	vector ofs;
	makevectors(self.v_angle);
	self.th_weapon=warhammer_a;
	self.wfs = advanceweaponframe($Chop1,$Chop12);
	if (self.weaponframe == $Chop7)
	{
		sound (self, CHAN_WEAPON, "weapons/vorpswng.wav", 1, ATTN_NORM);
		self.goalentity=self;
		ofs=normalize(v_up)*30;
		ofs+=normalize(v_right)*15;
		warhammer_fire ("top",ofs, tome);
	}
	else if (self.weaponframe == $Chop8)
		warhammer_fire ("top",'0 0 0', tome);
	else if (self.weaponframe == $Chop9)
	{
		ofs=normalize(v_up)*-30;
		warhammer_fire ("top",ofs, tome);
		self.velocity_z-= 260;
		self.punchangle_x= 5;
	}

	if (self.wfs==WF_CYCLE_WRAPPED)
		warhammer_return();
}

void Cru_Wham_Fire (float rightclick)
{
	if (self.artifact_active&ART_TOMEOFPOWER)
	{
		warhammer_throw(TRUE);
	}
	else if (rightclick && self.bluemana >= HAMMER_THROW_COST && self.level>=3)
	{
		warhammer_throw(FALSE);
	}
	
	else
	{
		self.attack_finished = time + .7;  // Attack every .7 seconds
		
		//Top attack if jumping
		if (!self.flags & FL_ONGROUND)
		{
			warhammer_a();
		}
		else
		{
			if (random() < 0.5)
				warhammer_b();
			else if (random () < 0.75)
				warhammer_c();
			else
				warhammer_a();
		}
	}
}

