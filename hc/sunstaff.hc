/*
 * $Header: /cvsroot/uhexen2/gamecode/hc/h2/sunstaff.hc,v 1.2 2007-02-07 16:57:11 sezero Exp $
 */

/*
==============================================================================

Q:\art\models\weapons\sunstaff\final\newfinal\sunstaff.hc
MG
==============================================================================
*/

// For building the model
$cd Q:\art\models\weapons\sunstaff\final\newfinal
$origin 0 0 0
$base BASE skin
$skin skin
$flags 0

//
$frame fircyc1      fircyc2      fircyc3      fircyc4      fircyc5      
$frame fircyc6      fircyc7      fircyc8      fircyc9      fircyc10     

//
$frame fire1        fire2        fire3        fire4        

//
$frame idle1        idle2        idle3        idle4        idle5        
$frame idle6        idle7        idle8        idle9        idle10       
$frame idle11       idle12       idle13       idle14       idle15       
$frame idle16       idle17       idle18       idle19       idle20       
$frame idle21       idle22       idle23       idle24       idle25       
$frame idle26       idle27       idle28       idle29       idle30       
$frame idle31       

//
$frame select1      select2      select3      select4      select5      
$frame select6      select7      select8      select9      select10     
$frame select11     select12     select13     select14     

//
$frame settle1      settle2      settle3      settle4      settle5      

float SUN_BALL_COST = 8;

void FireSunstaff (vector dir, float ofs)
{
vector  org1,org2, vec, endspot,endplane;
float remainder, reflect_count,damg;
//Draw a larger pulsating transparent yellow beam,
//rotating, with a smaller solid white beam in the
//center.  Player casts brightlight while using it.
//each point reflection has a double-sphere similar
//to the beam.  Each reflection does 3/4 less damage.
//primary damage = 37?

	if(self.attack_finished>time)
		return;

	if(self.t_width<time)
	{
		sound(self,CHAN_WEAPON,"crusader/sunhum.wav",1,ATTN_NORM);
		self.t_width=time+0.2;
	}

	self.effects(+)EF_BRIGHTLIGHT;
	if(self.artifact_active&ART_TOMEOFPOWER&&!ofs)
		damg=17;
	else
		damg=7;

//If powered up, start a quake
	if(!ofs)
		remainder=1000;
	else
		remainder=750;
	makevectors(self.v_angle);
	org1 = self.origin + self.proj_ofs+ v_forward*7;
	org2 = org1 + dir*20;
    vec = org2 + dir*remainder;
    traceline (org2, vec, TRUE, self);
	endspot=trace_endpos;
	endplane=trace_plane_normal;
	remainder-=remainder*trace_fraction;

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_STREAM_SUNSTAFF1);
	WriteEntity (MSG_BROADCAST, self);
	WriteByte (MSG_BROADCAST, ofs+STREAM_ATTACHED);
	WriteByte (MSG_BROADCAST, 1);
	WriteCoord (MSG_BROADCAST, org2_x);
	WriteCoord (MSG_BROADCAST, org2_y);
	WriteCoord (MSG_BROADCAST, org2_z);
	WriteCoord (MSG_BROADCAST, trace_endpos_x);
	WriteCoord (MSG_BROADCAST, trace_endpos_y);
	WriteCoord (MSG_BROADCAST, trace_endpos_z);

    LightningDamage (org1 - v_forward*7, trace_endpos+normalize(dir)*7, self, damg,"sunbeam");

   while(remainder>0&&reflect_count<2)
   {
		org1 = endspot;
	    dir +=2*endplane;

		vec = org1 + normalize(dir)*remainder;
//FIXME: what about reflective triggers?
		traceline (org1,vec,TRUE,self);
		endspot=trace_endpos;
		endplane=trace_plane_normal;
		remainder-=remainder*trace_fraction;
		reflect_count+=1;

		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_STREAM_SUNSTAFF1);
		WriteEntity (MSG_BROADCAST, self);
		WriteByte (MSG_BROADCAST, ofs+reflect_count);
		WriteByte (MSG_BROADCAST, 2);
		WriteCoord (MSG_BROADCAST, org1_x);
		WriteCoord (MSG_BROADCAST, org1_y);
		WriteCoord (MSG_BROADCAST, org1_z);
		WriteCoord (MSG_BROADCAST, trace_endpos_x);
		WriteCoord (MSG_BROADCAST, trace_endpos_y);
		WriteCoord (MSG_BROADCAST, trace_endpos_z);

	    LightningDamage (org1, trace_endpos+normalize(dir)*7, self, damg/2,"sunbeam");
	}
}

void() FireSunstaffPower =
{
/*
Will fire a main thick beam that will reflect off walls
and cut through stuff.
Two beams on side will waver a bit and track at + & - 45 degrees.
If the main beam hits something, the two secondary beams will
pull forward and lock on as well.
*/
vector dir1,dir2;
	makevectors(self.v_angle);
//NOTE: Maybe extra beams cycle around- rotate around 1st beam.
	dir1=(v_forward+v_right)*0.5;
	dir2=(v_forward+(v_right*-1))*0.5;
	FireSunstaff(normalize(v_forward),0);
	FireSunstaff(dir1,4);
	FireSunstaff(dir2,8);
};

void()sunstaff_ready_loop;
void() Cru_Sun_Fire;

void sunstaff_fire_settle ()
{
	self.wfs = advanceweaponframe($settle1,$settle5);
	self.th_weapon=sunstaff_fire_settle;
	if(self.wfs==WF_CYCLE_WRAPPED)
	{
		self.effects(-)EF_BRIGHTLIGHT;
		self.last_attack=time;
		sunstaff_ready_loop();
	}
}

void sunstaff_fire_loop ()
{
	self.wfs = advanceweaponframe($fircyc1,$fircyc10);
	self.th_weapon=sunstaff_fire_loop;
	if(self.attack_finished<=time&&(self.button0||self.button1)&&self.greenmana>=2&&self.bluemana>=2)
	{
		if(self.artifact_active&ART_TOMEOFPOWER)
		{
			FireSunstaffPower();
			self.greenmana-=2;
			self.bluemana-=2;
		}
		else
		{
			makevectors(self.v_angle);
			FireSunstaff(v_forward,0);
			self.greenmana-=0.35;
			self.bluemana-=0.35;
		}
		self.attack_finished=time + 0.05;
	}

	if(self.wfs==WF_CYCLE_WRAPPED&&(!(self.button0||self.button1)||self.greenmana<2||self.bluemana<2))
	{
		self.effects(-)EF_BRIGHTLIGHT;
		sunstaff_fire_settle();
	}
}

void sunstaff_fire (void)
{
	self.wfs = advanceweaponframe($fire1,$fire4);
	self.th_weapon=sunstaff_fire;
	if(self.wfs==WF_CYCLE_WRAPPED)
		sunstaff_fire_loop();
}

void sun_ray ()
{
vector  org1,org2, vec, dir;
	
	if (self.lifetime<time || !self.controller || self.controller.origin==VEC_ORIGIN){	//sunball died and controller was reset to world
		remove(self);
		return;
	}
	
	dir = self.movedir;
	if (self.enemy) {	//finaldest = enemy position
		org1 = org2 = self.controller.origin + self.controller.proj_ofs;
		vec = self.finaldest;
	}
	else {
		org1 = self.controller.origin + self.controller.proj_ofs;
		org2 = org1 + dir*10;
		vec = org2 + dir*self.level;
	}
	traceline (org2, vec, TRUE, self);
	
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_STREAM_SUNSTAFF1);
	WriteEntity (MSG_BROADCAST, self);
	WriteByte (MSG_BROADCAST, STREAM_ATTACHED);
	WriteByte (MSG_BROADCAST, 1);
	WriteCoord (MSG_BROADCAST, org2_x);
	WriteCoord (MSG_BROADCAST, org2_y);
	WriteCoord (MSG_BROADCAST, org2_z);
	WriteCoord (MSG_BROADCAST, trace_endpos_x);
	WriteCoord (MSG_BROADCAST, trace_endpos_y);
	WriteCoord (MSG_BROADCAST, trace_endpos_z);
	
    LightningDamage (org1 - dir*7, trace_endpos+dir*7, self.owner, 15, "sunbeam");
	
	if (self.level<self.t_length)
		self.level+=self.speed;
	
	self.think = sun_ray;
	thinktime self : 0.001;
}

void sun_think ()
{
	if (self.scale>=self.target_scale)
		self.check_ok=TRUE;
	
	if (!self.check_ok)
		self.scale+=0.025;
	
	T_RadiusDamage(self,self.owner,40,self.owner);
	
	if (self.attack_finished<time) {
		local entity dummy;
		dummy = spawn();
		makevectors(self.angles);
		local float r = random();
		if (r<0.25)
			dummy.movedir = v_up;
		else if (r<0.5)
			dummy.movedir = v_forward;
		else if (r<0.75)
			dummy.movedir = v_right;
		else
			dummy.movedir = (-v_right);
		dummy.level = 50;					//initial beam length
		dummy.t_length = 1000;				//max beam length
		dummy.speed = random(20,35);		//beam growth speed
		dummy.lifetime = time+random(2,3);
		dummy.controller = self;
		dummy.owner = self.owner;
		dummy.think = sun_ray;
		thinktime dummy : 0;
		
		if (self.t_length < time) {
			local entity find, oself;
			oself = self;
			self = self.owner;
			find = HomeFindTarget();
			self = oself;
			if (find && find.flags&FL_ALIVE && find!=self.enemy) {
				self.t_length = time+0.3;
				self.enemy = find;
				dummy.enemy = find;
				dummy.finaldest = find.origin+find.proj_ofs;
				makevectors(self.origin+self.proj_ofs - dummy.finaldest);
				dummy.movedir = v_forward;
			}
		}
		
		if (self.t_width < time) {
			sound (self, CHAN_AUTO, "crusader/sunstart.wav", 1, ATTN_NORM);
			self.t_width=time+random(0.25,0.4);
		}
		
		self.attack_finished = time+random(0.033,0.33);
	}
	
	self.think = sun_think;
	thinktime self : HX_FRAME_TIME*0.25;
}

void sun_touch ()
{
	if(other.takedamage)
		T_Damage(other,self,self.owner,self.dmg);
	T_RadiusDamage(self,self.owner,self.dmg,other);
	
	sound(self,CHAN_AUTO,"weapons/exphuge.wav",1,0.75);	//weapons/fbfire
	
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	
	remove(self);
	//self.think = sun_shrink;
}

void FireSunstaffPowerAlt ()
{
vector org, size;
entity sun;
	self.bluemana -= SUN_BALL_COST;
	self.greenmana -= SUN_BALL_COST;
	
	makevectors (self.v_angle);
	org = self.origin+self.proj_ofs+v_forward*4;
	size = '16 16 16';
	
	sun = spawn ();
	sun.owner = self;
	sun.movetype = MOVETYPE_FLYMISSILE;
	sun.solid = SOLID_BBOX;
	
	setmodel (sun,"models/blast.mdl");
	setsize (sun, (-size), size);	
	setorigin (sun, org);
	
	sun.velocity = v_forward * 500;
	sun.angles = vectoangles(sun.velocity);
	sun.avelocity_x = 50;
	sun.avelocity_y = random(200,400);
	
	sun.classname = "sun";
	sun.attack_finished = time+0.1;
	sun.dmg = 100;
	sun.effects = EF_BRIGHTLIGHT;
	sun.proj_ofs = '0 0 12';
	//sun.scale = 0.5;
	sun.scale = 0.1;
	sun.target_scale = 0.5;
	
	sun.touch = sun_touch;
	sun.think = sun_think;
	thinktime sun : 0;
}

void sunstaff_altfire ()
{
	self.wfs = advanceweaponframe($fire1,$fire4);
	self.th_weapon=sunstaff_altfire;
	if (self.wfs==WF_CYCLE_WRAPPED) {
		self.attack_finished = time+0.75;
		self.effects(+)EF_MUZZLEFLASH;
		FireSunstaffPowerAlt();
		sunstaff_fire_settle();
	}
	if (self.wfs==WF_CYCLE_WRAPPED && (!self.button1 || self.greenmana<SUN_BALL_COST || self.bluemana<SUN_BALL_COST)) {
		self.attack_finished = time+0.75;
		sunstaff_fire_settle();
	}
}

void() Cru_Sun_Fire =
{
	if(self.weaponframe<$idle1 || self.weaponframe>$idle31)
		return;
	
	if (self.button1 && self.artifact_active&ART_TOMEOFPOWER && self.bluemana>=SUN_BALL_COST && self.greenmana>=SUN_BALL_COST) {
		sound (self, CHAN_WEAPON, "eidolon/fireball.wav", 1, ATTN_NORM);
		self.th_weapon=sunstaff_altfire;
	}
	else {
		sound (self, CHAN_AUTO, "crusader/sunstart.wav", 1, ATTN_NORM);
		self.th_weapon=sunstaff_fire;
	}
	thinktime self : 0;
};

void sunstaff_ready_loop (void)
{
	self.wfs = advanceweaponframe($idle1,$idle31);
	self.th_weapon=sunstaff_ready_loop;
}

void sunstaff_select (void)
{
//go to ready loop, not relaxed?
	self.wfs = advanceweaponframe($select1,$select14);
	self.weaponmodel = "models/sunstaff.mdl";
	self.th_weapon=sunstaff_select;
	self.last_attack=time;
	if(self.wfs==WF_CYCLE_WRAPPED)
	{
		self.attack_finished = time - 1;
		sunstaff_ready_loop();
	}
}

void sunstaff_deselect (void)
{
//go to ready loop, not relaxed?
	self.wfs = advanceweaponframe($select14,$select1);
	self.th_weapon=sunstaff_deselect;
	if(self.wfs==WF_CYCLE_WRAPPED)
		W_SetCurrentAmmo();
}

