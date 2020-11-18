/*
==============================================================================

Q:\art\models\weapons\spllbook\spllbook.hc

==============================================================================
*/

// For building the model
$cd Q:\art\models\weapons\spllbook
$origin 0 0 0
$base BASE skin
$skin skin
$flags 0

//
$frame normal02     normal03     normal04     normal05     normal06     
$frame normal07     normal08     normal09     normal10     normal11     
$frame normal12     normal13

//
$frame idlean12     idlean13     idlean14     idlean15     idlean16     
$frame idlean17     idlean18     idlean19     idlean20     idlean21     
$frame idlean22     idlean23     idlean24     idlean25     idlean26     
$frame idlean27     idlean28     idlean29     idlean30     idlean31     
$frame idlean32     idlean33     idlean34     idlean35     

//
$frame idlebn36     idlebn37     idlebn38     idlebn39     idlebn40     
$frame idlebn41     idlebn42     idlebn43     idlebn44     idlebn45     
$frame idlebn46     idlebn47     idlebn48     idlebn49     idlebn50     
$frame idlebn51     idlebn52     idlebn53     idlebn54     idlebn55     
$frame idlebn56     idlebn57     idlebn58     idlebn59     


//
$frame select80     select81     select82     select83     select84     
$frame select85     select86     select87     select88     select89     
$frame select90     select91     select92     select93     select94     
$frame select95     select96     select97     select98     select99     


float BLRAIN_CHARGE = 8;

void bloodmissile_impact_effect()
{
	starteffect(CE_BLDRN_EXPL, self.origin-self.movedir*6,'0 0 0', HX_FRAME_TIME);
/*	particle3(self.origin,'2 2 2',rint(random(168,172)),PARTICLETYPE_DARKEN,5);
	particle3(self.origin,'4 4 4',rint(random(170,175)),PARTICLETYPE_DARKEN,5);
	particle3(self.origin,'8 8 8',rint(random(138,143)),PARTICLETYPE_DARKEN,10);
	particle3(self.origin,'16 16 16',rint(random(135,141)),PARTICLETYPE_DARKEN,5);
	particle3(self.origin,'32 32 32',rint(random(132,139)),PARTICLETYPE_DARKEN,5);*/
}

void BloodMissileTouch (void)
{
	if(pointcontents(self.origin)==CONTENT_SKY)
	{
//		if(self.movechain)
//			remove(self.movechain);
		remove(self);
		return;
	}

	if(other.classname==self.classname&&other.owner==self.owner)
		return;

	self.movedir=normalize(self.velocity);

	if(!other.takedamage)
	{
		if(self.frags)
		{
			//starteffect(CE_MEZZO_REFLECT,self.origin-self.movedir*8,0.05);
			//counter for number of bounces

			sound (self, CHAN_WEAPON, "succubus/brnbounce.wav", 1, ATTN_NORM);
			if(self.dmg>=2)
				self.dmg-=1;
			starteffect(CE_BRN_BOUNCE,self.origin - self.movedir*8 - '0 0 6','0 0 0',HX_FRAME_TIME);//CreateRedFlash(self.origin);
			thinktime self : 0;
			return;
		}
		else
		{
			sound (self, CHAN_WEAPON, "succubus/brnwall.wav", 1, ATTN_NORM);
			bloodmissile_impact_effect();
			remove(self);
			return;
		}
	}

	spawn_touchpuff(self.dmg,other);
	T_Damage(other,self,self.owner,self.dmg);
	bloodmissile_impact_effect();
	sound(self,CHAN_AUTO,"succubus/brnhit.wav",1,ATTN_NORM);
	//	starteffect(CE_MEZZO_REFLECT,self.origin-self.movedir*8,0.05);
//	if(self.movechain)
//		remove(self.movechain);
	remove(self);
}

/*
void TorpedoTrail (void)
{
	particle4(self.origin,7,random(148,159),PARTICLETYPE_GRAV,random(10,20));
}
*/


void BloodMissileFade ()
{
	self.angles=vectoangles(self.velocity);
	if(self.scale>0.3)
	{
		if(self.frame<4)
		{
			self.frame+=1;
			thinktime self : HX_FRAME_TIME;//powered up have longer range
		}
		else
		{
			self.scale-=0.15;
			self.abslight-=0.15;
			thinktime self : HX_FRAME_TIME + self.frags/10;//powered up have longer range
		}
		if(self.dmg>=1.75)
			self.dmg-=0.75;
	}
	else
		remove(self);
}

void FireBloodMissile (float offset)
{
float f_dist;
	makevectors(self.v_angle);

	self.effects(+)EF_MUZZLEFLASH;
	newmis=spawn();
	newmis.classname="blood missile";
	newmis.owner=self;
	newmis.drawflags(+)SCALE_ORIGIN_CENTER|MLS_FIREFLICKER;
	newmis.scale=1.3;
	newmis.abslight=1;
	newmis.dmg=random(15,22);
	f_dist=8;
	if(self.artifact_active&ART_TOMEOFPOWER)
	{
		if(!offset)
		{
			newmis.scale=2;
			newmis.avelocity_z=1000;
			newmis.dmg=random(20,30);
			f_dist=16;
			newmis.solid=SOLID_PHASE;
		}
		else 
			f_dist=offset*2 + 2;
		newmis.movetype=MOVETYPE_BOUNCEMISSILE;
		newmis.frags=TRUE;
	}
	else
	{
		newmis.frags=FALSE;
		newmis.movetype=MOVETYPE_FLYMISSILE;
	}

	newmis.solid=SOLID_BBOX;
	newmis.touch=BloodMissileTouch;

	newmis.speed=800;
	newmis.velocity=normalize(v_forward)*newmis.speed;// + spread;
	newmis.movedir=normalize(newmis.velocity);
	newmis.angles=vectoangles(newmis.velocity);

	setmodel(newmis,"models/sucwp1p.mdl");
	setsize(newmis,'0 0 0','0 0 0');

	//setorigin(newmis,self.origin+self.proj_ofs+v_forward*f_dist-v_right*12 + v_right*(offset*3) - '0 0 6');
	setorigin(newmis,self.origin+self.proj_ofs+v_forward*f_dist + v_right*(offset*3) + '0 0 5');	//ws: centered projectile to match crosshair
	sound(newmis,CHAN_AUTO,"succubus/brnfire.wav",1,ATTN_NORM);

	newmis.think=BloodMissileFade;
	thinktime newmis : 0.05;
}

void  blrn_power(float offset)
{
	if(self.attack_finished>time)
		return;

	FireBloodMissile(offset);
	if(offset==3)
		self.attack_finished=time+0.7;
	else if(offset==-3)
		self.punchangle_x=3;
}

void  blrn_normal()
{
	if(self.attack_finished>time)
		return;

	FireBloodMissile(0);
	self.attack_finished=time+0.4;
}

/*======================
ACTION
select
deselect
ready loop
relax loop
fire once
fire loop
ready to relax(after short delay)
relax to ready(Fire delay?  or automatic if see someone?)
=======================*/


void()bloodrain_ready;
void Suc_Blrn_Fire (float rightclick);

void bloodrain_fire (float rightclick)
{
	if(self.button0&&self.weaponframe==$normal07 &&!self.artifact_active&ART_TOMEOFPOWER)
		self.weaponframe=$normal07;
	else
		self.wfs = advanceweaponframe($normal02,$normal13);
	if(self.weaponframe<=$normal07)
		self.weaponframe+=1;
	self.th_weapon=bloodrain_fire;
	self.last_attack=time;
	if(self.wfs==WF_CYCLE_WRAPPED)
		bloodrain_ready();
	if(self.artifact_active&ART_TOMEOFPOWER)
	{
		if(self.weaponframe>=$normal07 && self.weaponframe<=$normal09)
			blrn_power((self.weaponframe - $normal08) *3);
	}
	else if(self.weaponframe==$normal07)
		if (rightclick)
			succ_scratch();
		else
			blrn_normal();
}

void bloodrain_charge ()
{
	self.th_weapon=bloodrain_charge;
	self.last_attack=time;
	
	if (self.weaponframe < $normal05) {
		if (self.search_time < time) {
			advanceweaponframe($normal02,$normal13);
			self.search_time = time+HX_FRAME_TIME*2;	//animate at half-speed
		}
	}
	else if (self.weaponframe == $normal05) {
		if (!self.button1 && self.weaponframe_cnt>=BLRAIN_CHARGE) {		//end loop if fire button released
			//advanceweaponframe($normal02,$normal13);
			++self.weaponframe;
			self.search_time = time + HX_FRAME_TIME*8;
		}
		else {
			self.weaponframe = $normal05;
			self.weaponframe_cnt += 1;
		}
	}
	
	if (self.weaponframe>$normal05) {
		if(self.weaponframe==$normal07) {
			if (self.search_time < time)
				advanceweaponframe($normal02,$normal13);
			if (self.altfiring < 3) {
				FireBloodMissile(random(-2,2));
				++self.altfiring;
			}
		}
		else
			advanceweaponframe($normal02,$normal13);
	}
	
	if (self.weaponframe>=$normal04 && self.weaponframe<=$normal06) {
		makevectors(self.v_angle);
		vector org = self.origin+self.proj_ofs+v_forward*15-v_right*12+'0 0 8';
		if (random()<0.5)
			particle3(org,'0.5 0.5 0.5',144,PARTICLETYPE_REDFIRE,1);
		//particle(org, '0 0 1', 384, 1);	//why does every fucking color i choose make grey particles? what the fuck? why have a color field if it doesnt fucking work?
	}
	
	if(self.weaponframe==$normal13) {
		self.altfiring = 0;
		self.search_time = 0;
		self.weaponframe_cnt = 0;
		self.attack_finished = time+0.3;
		bloodrain_ready();
	}
}

void Suc_Blrn_Fire (float rightclick) =
{
	if (rightclick && !self.artifact_active&ART_TOMEOFPOWER)
		bloodrain_charge();
	else
		bloodrain_fire();

	thinktime self : 0;
};

void bloodrain_jellyfingers ()
{
	self.wfs = advanceweaponframe($idlebn36,$idlebn59);
	self.th_weapon=bloodrain_jellyfingers;
	if(self.wfs==WF_CYCLE_WRAPPED)
		bloodrain_ready();
}

void bloodrain_ready (void)
{
	self.wfs = advanceweaponframe($idlean12,$idlean35);
	if(random()<0.1&&self.weaponframe==$idlean35)
		self.th_weapon=bloodrain_jellyfingers;
	else
		self.th_weapon=bloodrain_ready;
}


void bloodrain_select (void)
{
	self.wfs = advanceweaponframe($select80,$select99);
	self.weaponmodel = "models/sucwp1.mdl";
	self.th_weapon=bloodrain_select;
	if(self.wfs==WF_CYCLE_WRAPPED)
	{
		self.attack_finished = time - 1;
		bloodrain_ready();
	}
}

void bloodrain_deselect (void)
{
	self.wfs = advanceweaponframe($select99,$select80);
	self.th_weapon=bloodrain_deselect;
	if(self.wfs==WF_CYCLE_WRAPPED)
		W_SetCurrentAmmo();
}

