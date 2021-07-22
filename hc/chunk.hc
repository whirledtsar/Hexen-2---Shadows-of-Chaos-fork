/*
 * $Header: /cvsroot/uhexen2/gamecode/hc/portals/chunk.hc,v 1.2 2007-02-07 16:59:30 sezero Exp $
 */
void ThrowSolidHead (float dm);
void MarkForRespawn (void);
void () CorpseThink;
void () feathers;

void blood_splatter()
{
	SpawnPuff(self.origin,normalize(self.velocity)*-20,10,self);
	remove(self);
}

void ThrowBlood (vector org,vector dir)
{
entity blood;
	blood=spawn_temp();
	blood.solid=SOLID_BBOX;
	blood.movetype=MOVETYPE_TOSS;
	blood.touch=blood_splatter;
	blood.velocity=dir;
	blood.avelocity=randomv('-700 -700 -700','700 700 700');
	blood.thingtype=THINGTYPE_FLESH;

	setmodel(blood,"models/bldspot4.spr");  // 8 x 8 sprite size
	setsize(blood,'0 0 0','0 0 0');
	setorigin(blood,org);
}

void ZeBrains (vector spot, vector normal, float scaling, float face, float roll)
{
	newmis=spawn();
	newmis.scale=scaling;
	newmis.angles=vectoangles(normal);
	if(face)
		newmis.angles_y+=180;
	newmis.angles_z=roll;

	setmodel(newmis,"models/brains.mdl");
	setsize(newmis,'0 0 0','0 0 0');
	setorigin(newmis,spot+normal*1);

	newmis.think=corpseblink;
	thinktime newmis : 30;

	spot=newmis.origin;
	makevectors(normal);
	ThrowBlood(spot,(normal+random(0.75,0.75)*v_up+random(0.75,0.75)*v_right)*random(200,400));
	ThrowBlood(spot,(normal+random(0.75,0.75)*v_up+random(0.75,0.75)*v_right)*random(200,400));
	ThrowBlood(spot,(normal+random(0.75,0.75)*v_up+random(0.75,0.75)*v_right)*random(200,400));
	ThrowBlood(spot,(normal+random(0.75,0.75)*v_up+random(0.75,0.75)*v_right)*random(200,400));
	ThrowBlood(spot,(normal+random(0.75,0.75)*v_up+random(0.75,0.75)*v_right)*random(200,400));
}

void ChunkRemove (void)
{
	chunk_cnt-=1;
	SUB_Remove ();
}

vector ChunkVelocity (void)
{
	vector v;

	v_x = 300 * crandom();
	v_y = 300 * crandom();
	v_z = random(100,400);

	v = v * 0.7;

	return v;
}

void ThrowSingleChunk (string chunkname,vector location,float life_time,float skinnum,float scalemod)	//ws: added scale
{
	entity chunk;

	if (chunk_cnt < CHUNK_MAX)
	{
		chunk=spawn_temp();
		setmodel (chunk, chunkname);
		chunk.frame = 0;

		setsize (chunk, '0 0 0', '0 0 0');
		chunk.movetype = MOVETYPE_BOUNCE;
		chunk.solid = SOLID_NOT;
		chunk.takedamage = DAMAGE_NO;
		chunk.velocity = ChunkVelocity();
		chunk.think = ChunkRemove;
		chunk.flags(-)FL_ONGROUND;
		chunk.origin = location;
		if (scalemod>0)
			chunk.scale = scalemod;
	
		chunk.avelocity_x = random(10);
		chunk.avelocity_y = random(10);
		chunk.avelocity_z = random(30);
		chunk.skin = skinnum;
		chunk.ltime = time;
		thinktime chunk : life_time;
		chunk_cnt+=1;
	}
}


void MeatChunks (vector org,vector dir,float chunk_count,entity loser)
{
float final,t_type;
entity chunk;

	if(deathmatch||coop)
	{
		if(dir=='0 0 0')
		{
			dir = ChunkVelocity();
			dir=loser.velocity+dir;
		}
		if(loser.frozen>0)
			t_type=THINGTYPE_ICE;
		else if(loser.model=="models/spider.mdl")
			t_type=THINGTYPE_GREENFLESH;
		else
			t_type=loser.thingtype;
		starteffect(CE_CHUNK, org, t_type, dir, chunk_count);
	}
	else while(chunk_count)
	{
		chunk=spawn_temp();
		chunk_count-=1;
		final = random();

		if(loser.frozen>0)
			setmodel (chunk, "models/shardice.mdl");
		else if(loser.model=="models/spider.mdl")
		{
			if (final < 0.33)
				setmodel (chunk, "models/sflesh1.mdl");
			else if (final < 0.66)
				setmodel (chunk, "models/sflesh2.mdl");
			else
				setmodel (chunk, "models/sflesh3.mdl");
		}
		//else if (final < 0.33)
		//	setmodel (chunk, "models/flesh1.mdl");
		else if (final < 0.33)
			setmodel (chunk, "models/blood.mdl");
		else if (final < 0.66)
			setmodel (chunk, "models/flesh2.mdl");
		else
			setmodel (chunk, "models/flesh3.mdl");
		setsize (chunk, '0 0 0', '0 0 0');
//		chunk.skin=1;
		chunk.movetype = MOVETYPE_BOUNCE;
		chunk.solid = SOLID_NOT;
		if(dir=='0 0 0')
			chunk.velocity = ChunkVelocity();
		else
			chunk.velocity=dir;//+randomv('-200 -200 -200','200 200 200');
		chunk.think = ChunkRemove;
		chunk.avelocity_x = random(1200);
		chunk.avelocity_y = random(1200);
		chunk.avelocity_z = random(1200);

		chunk.scale = .45;

		chunk.ltime = time;
		thinktime chunk : random(2);
		setorigin (chunk, org);
	}
}

void ThrowGib (string gibname, float dm);

void chunk_hurt ()
{
float damage;
	if(!other.takedamage)
		return;

	if(self.attack_finished>time)
		return;
	
	if(self.velocity=='0 0 0')
		return;

	//SOUND
	self.attack_finished = time + 0.5;
	damage = self.scale * vlen(self.velocity)/100 * self.dmg;
	T_Damage(other,self,self.owner,damage);
}

void CreateModelChunks (vector space,float scalemod, float numChunks)
{
	entity chunk;
	float final, tried,t_type;
	vector chunk_vel,org;
	//return;//Magical Network-Friendly Code!

	chunk_vel = ChunkVelocity();
	if(!self.flags&FL_ONGROUND&&self.movetype!=MOVETYPE_NONE)
		chunk_vel=self.velocity+chunk_vel;

	if(deathmatch||coop)
	{
		if(self.origin=='0 0 0'&&self.solid==SOLID_BSP)
			org=(self.absmin+self.absmax)*0.5;
		else
			org=self.origin;
		if(self.frozen>0)
			t_type=THINGTYPE_ICE;
		else if(self.model=="models/spider.mdl")
			t_type=THINGTYPE_GREENFLESH;
		else
			t_type=self.thingtype;
		starteffect(CE_CHUNK, org, t_type, chunk_vel, numChunks);
		return;
	}

	chunk = spawn_temp();

	space_x = space_x * random();
	space_y = space_y * random();
							  

	if(self.solid==SOLID_TRIGGER&&self.thingtype!=THINGTYPE_WEBS)//Trigger event
	{
		traceline(self.absmin + space, self.absmin + space + '0 0 1' * self.maxs_z,TRUE,self);
		tried = 0;
		while((trace_startsolid||pointcontents(trace_endpos)!=CONTENT_EMPTY) && tried < 20)
		{
			space_x = space_x * random();
			space_y = space_y * random();
			traceline(self.absmin + space, self.absmin + space + '0 0 1' * self.maxs_z,TRUE,self);
			tried+=1;
		}
		if(tried == 20)
			return;
		space_z = trace_endpos_z;
		setorigin (chunk, trace_endpos);
		chunk.solid = SOLID_BBOX;
		chunk.touch = chunk_hurt;
	}
	else
	{
		space_z = space_z * random();
		setorigin (chunk, self.absmin + space);
		chunk.solid = SOLID_NOT;
	}

	final = random();
	if ((self.thingtype==THINGTYPE_GLASS) || (self.thingtype==THINGTYPE_REDGLASS) || 
			(self.thingtype==THINGTYPE_CLEARGLASS) || (self.thingtype==THINGTYPE_WEBS))
	{
		if (final<0.20)
			setmodel (chunk, "models/shard1.mdl");
		else if (final<0.40)
			setmodel (chunk, "models/shard2.mdl");
		else if (final<0.60)
			setmodel (chunk, "models/shard3.mdl");
		else if (final<0.80)
			setmodel (chunk, "models/shard4.mdl");
		else 
			setmodel (chunk, "models/shard5.mdl");

		if (self.thingtype==THINGTYPE_CLEARGLASS)
		{
			chunk.skin=1;
			chunk.drawflags (+) DRF_TRANSLUCENT;
		}
		else if (self.thingtype==THINGTYPE_REDGLASS)
			chunk.skin=2;
		else if (self.thingtype==THINGTYPE_WEBS)
		{
			chunk.skin=3;
			chunk.drawflags (+) DRF_TRANSLUCENT;
			if(self.drawflags&MLS_ABSLIGHT)
			{
				chunk.drawflags(+)MLS_ABSLIGHT;
				chunk.abslight=self.abslight;
			}
			chunk_vel*=.1;
			chunk.gravity=random(0.3,0.8);
		}
	}
	else if (self.thingtype==THINGTYPE_WOOD)
	{
		if (final < 0.25)
			setmodel (chunk, "models/splnter1.mdl");
		else if (final < 0.50)
			setmodel (chunk, "models/splnter2.mdl");
		else if (final < 0.75)
			setmodel (chunk, "models/splnter3.mdl");
		else 
			setmodel (chunk, "models/splnter4.mdl");
	}
	else if (self.thingtype==THINGTYPE_METAL)
	{
		if (final < 0.25)
			setmodel (chunk, "models/metlchk1.mdl");
		else if (final < 0.50)
			setmodel (chunk, "models/metlchk2.mdl");
		else if (final < 0.75)
			setmodel (chunk, "models/metlchk3.mdl");
		else 
			setmodel (chunk, "models/metlchk4.mdl");
	}
	else if (self.thingtype==THINGTYPE_FLESH)
	{
		if(self.model=="models/spider.mdl")
		{
			if (final < 0.33)
				setmodel (chunk, "models/sflesh1.mdl");
			else if (final < 0.66)
				setmodel (chunk, "models/sflesh2.mdl");
			else
				setmodel (chunk, "models/sflesh3.mdl");
		}
		else if (final < 0.33)
			setmodel (chunk, "models/flesh1.mdl");
		else if (final < 0.66)
			setmodel (chunk, "models/flesh2.mdl");
		else
			setmodel (chunk, "models/flesh3.mdl");
		if(self.classname=="hive")
			chunk.skin=1;
	}
	else if (self.thingtype==THINGTYPE_BROWNSTONE)
	{
		if (final < 0.25)
			setmodel (chunk, "models/schunk1.mdl");
		else if (final < 0.50)
			setmodel (chunk, "models/schunk2.mdl");
		else if (final < 0.75)
			setmodel (chunk, "models/schunk3.mdl");
		else 
			setmodel (chunk, "models/schunk4.mdl");
		chunk.skin = 1;
	}
  
	else if ((self.thingtype==THINGTYPE_CLAY) || (self.thingtype==THINGTYPE_BONE))
	{
		if (final < 0.25)
			setmodel (chunk, "models/clshard1.mdl");
		else if (final < 0.50)
			setmodel (chunk, "models/clshard2.mdl");
		else if (final < 0.75)
			setmodel (chunk, "models/clshard3.mdl");
		else 
			setmodel (chunk, "models/clshard4.mdl");
		if (self.thingtype==THINGTYPE_BONE)
		{
			chunk.skin = 1;
		}
	}
	else if (self.thingtype==THINGTYPE_LEAVES)
	{
		if (final < 0.33)
			setmodel (chunk, "models/leafchk1.mdl");
		else if (final < 0.66)
			setmodel (chunk, "models/leafchk2.mdl");
		else 
			setmodel (chunk, "models/leafchk3.mdl");
	}
	else if (self.thingtype==THINGTYPE_HAY)
	{
		if (final < 0.33)
			setmodel (chunk, "models/hay1.mdl");
		else if (final < 0.66)
			setmodel (chunk, "models/hay2.mdl");
		else 
			setmodel (chunk, "models/hay3.mdl");
	}
	else if (self.thingtype==THINGTYPE_CLOTH)
	{
		if (final < 0.33)
			setmodel (chunk, "models/clthchk1.mdl");
		else if (final < 0.66)
			setmodel (chunk, "models/clthchk2.mdl");
		else 
			setmodel (chunk, "models/clthchk3.mdl");
	}
	else if (self.thingtype==THINGTYPE_WOOD_LEAF)
	{
		if (final < 0.14)
			setmodel (chunk, "models/splnter1.mdl");
		else if (final < 0.28)
			setmodel (chunk, "models/leafchk1.mdl");
		else if (final < 0.42)
			setmodel (chunk, "models/splnter2.mdl");
		else if (final < 0.56)
			setmodel (chunk, "models/leafchk2.mdl");
		else if (final < 0.70)
			setmodel (chunk, "models/splnter3.mdl");
		else if (final < 0.84)
			setmodel (chunk, "models/leafchk3.mdl");
		else 
			setmodel (chunk, "models/splnter4.mdl");
	}
	else if (self.thingtype==THINGTYPE_WOOD_METAL)
	{
		if (final < 0.125)
			setmodel (chunk, "models/splnter1.mdl");
		else if (final < 0.25)
			setmodel (chunk, "models/metlchk1.mdl");
		else if (final < 0.375)
			setmodel (chunk, "models/splnter2.mdl");
		else if (final < 0.50)
			setmodel (chunk, "models/metlchk2.mdl");
		else if (final < 0.625)
			setmodel (chunk, "models/splnter3.mdl");
		else if (final < 0.75)
			setmodel (chunk, "models/metlchk3.mdl");
		else if (final < 0.875)
			setmodel (chunk, "models/splnter4.mdl");
		else 
			setmodel (chunk, "models/metlchk4.mdl");
	}
	else if (self.thingtype==THINGTYPE_WOOD_STONE)
	{
		if (final < 0.125)
			setmodel (chunk, "models/splnter1.mdl");
		else if (final < 0.25)
			setmodel (chunk, "models/schunk1.mdl");
		else if (final < 0.375)
			setmodel (chunk, "models/splnter2.mdl");
		else if (final < 0.50)
			setmodel (chunk, "models/schunk2.mdl");
		else if (final < 0.625)
			setmodel (chunk, "models/splnter3.mdl");
		else if (final < 0.75)
			setmodel (chunk, "models/schunk3.mdl");
		else if (final < 0.875)
			setmodel (chunk, "models/splnter4.mdl");
		else 
			setmodel (chunk, "models/schunk4.mdl");
	}
	else if (self.thingtype==THINGTYPE_METAL_STONE)
	{
		if (final < 0.125)
			setmodel (chunk, "models/metlchk1.mdl");
		else if (final < 0.25)
			setmodel (chunk, "models/schunk1.mdl");
		else if (final < 0.375)
			setmodel (chunk, "models/metlchk2.mdl");
		else if (final < 0.50)
			setmodel (chunk, "models/schunk2.mdl");
		else if (final < 0.625)
			setmodel (chunk, "models/metlchk3.mdl");
		else if (final < 0.75)
			setmodel (chunk, "models/schunk3.mdl");
		else if (final < 0.875)
			setmodel (chunk, "models/metlchk4.mdl");
		else 
			setmodel (chunk, "models/schunk4.mdl");
	}
	else if (self.thingtype==THINGTYPE_METAL_CLOTH)
	{
		if (final < 0.14)
			setmodel (chunk, "models/metlchk1.mdl");
		else if (final < 0.28)
			setmodel (chunk, "models/clthchk1.mdl");
		else if (final < 0.42)
			setmodel (chunk, "models/metlchk2.mdl");
		else if (final < 0.56)
			setmodel (chunk, "models/clthchk2.mdl");
		else if (final < 0.70)
			setmodel (chunk, "models/metlchk3.mdl");
		else if (final < 0.84)
			setmodel (chunk, "models/clthchk3.mdl");
		else 
			setmodel (chunk, "models/metlchk4.mdl");
	}
	else if (self.thingtype==THINGTYPE_ICE)
	{
		setmodel(chunk,"models/shard.mdl");
		 
		chunk.skin=0;
		
		chunk.frame=random(2);
		chunk.drawflags(+)DRF_TRANSLUCENT|MLS_ABSLIGHT;
		chunk.abslight=0.5;
	}
	else if (self.thingtype==THINGTYPE_ASH)
	{
		setmodel(chunk,"models/shard.mdl");
		chunk.skin=2;
		chunk.frame=rint(random(1,2));
	}
	else// if (self.thingtype==THINGTYPE_GREYSTONE)
	{
		if (final < 0.25)
			setmodel (chunk, "models/schunk1.mdl");
		else if (final < 0.50)
			setmodel (chunk, "models/schunk2.mdl");
		else if (final < 0.75)
			setmodel (chunk, "models/schunk3.mdl");
		else 
			setmodel (chunk, "models/schunk4.mdl");
		chunk.skin = 0;
	}

	if(self.solid==SOLID_TRIGGER)//Trigger event
	{
		setsize(chunk,'-1 -1 -1', '1 1 1');
		chunk.hull = HULL_POINT;
		thinktime chunk :  random(2)+2;
		chunk.dmg = self.dmg;
	}
	else
	{
		setsize (chunk, '0 0 0', '0 0 0');
		thinktime chunk :  random(2);
	}

	chunk.movetype = MOVETYPE_BOUNCE;
						 
								  
	chunk.think = ChunkRemove;
	chunk.velocity=chunk_vel;
	chunk.avelocity_x = random(1200);
	chunk.avelocity_y = random(1200);
	chunk.avelocity_z = random(1200);

	if(self.classname=="monster_eidolon")
		chunk.scale=random(2.1,2.5);
	else
		chunk.scale = random(scalemod,scalemod + .1);

	chunk.ltime = time;
}

void DropBackpack(void);  // in items.hc

float BLOOD_SMALL = 0;
float BLOOD_MED = 1;
float BLOOD_LARGE = 2;
float BLOOD_GREEN = 3;

float bloodsplat_radius[4] =
{
	16, 20, 40, 8
};

string bloodsplat_mdl[4] =	//could also use brains.mdl?
{
	"models/bloodpool.mdl", "models/bloodpool2.mdl", "models/bloodpool3.mdl", "models/bloodpool_green.mdl"
};

void(vector slope, entity forwhom) pitch_roll_for_slope;

void bloodpool_step ()
{	//ws: play bloody step/squish sound when walking over blood
	if (other.classname != "player")
		return;
	
	if (time < other.movetime)
		return;
	
	if (other.velocity_z>=0)	//reset timer if player just jumped
		other.movetime = time-1;
	
	if (other.velocity_x==0 && other.velocity_y==0)
	{
		if (other.velocity_z>=0)
			return;
	}
	
	local string bloodsound[3] =
	{
		"fx/fleshdrop1.wav", "fx/fleshdrop2.wav", "fx/fleshdrop3.wav"
	};
	
	sound (self, CHAN_BODY, bloodsound[rint(random(0,2))], random(0.5,0.8), ATTN_IDLE);
	other.movetime=time+0.5;
	self.scale-=0.025;
	if (self.scale<=0.075)
		remove(self);
}

float bloodpool_check(float type)
{
	vector holdplane,location;
	float length;
	
	location = self.origin;
	length = bloodsplat_radius[type];
	makevectors (self.angles);
	
	//traceline (location + v_up*8 + v_right * 8 + v_forward * 8, location - v_up*32 + v_right * 8 + v_forward * 8, TRUE, self);
	traceline (location + v_up*8, location - v_up*200, TRUE, self);
	holdplane = trace_plane_normal;
	if(trace_fraction==1)	// Nothing below victim
		return FALSE;

	traceline (location + v_up*8 - v_right * length + v_forward * length, location - v_up*32 - v_right * length + v_forward * length, TRUE, self);
	if ((holdplane != trace_plane_normal) || (trace_fraction==1))
		return FALSE;

	traceline (location + v_up*8 + v_right * length - v_forward * length, location - v_up*32 + v_right * length - v_forward * length, TRUE, self);
	if ((holdplane != trace_plane_normal) || (trace_fraction==1))
		return FALSE;

	traceline (location + v_up*8 - v_right * length - v_forward * length, location - v_up*32 - v_right * length - v_forward * length, TRUE, self);
	if ((holdplane != trace_plane_normal) || (trace_fraction==1))
		return FALSE;
	
	return TRUE;
}

void BloodSplat(float type)
{
entity splat;
vector org;
	
	if (type!=BLOOD_GREEN) {
		if (!bloodpool_check(type))
		{	//try smaller splats if bigger splat wont fit
			if (type==BLOOD_LARGE) {
				BloodSplat(BLOOD_MED);
				return;
			}
			else if (type==BLOOD_MED) {
				BloodSplat(BLOOD_SMALL);
				return;
			}
			else
				return;
		}
	}

	traceline (self.origin + v_up*8,self.origin - v_up*32, TRUE, self);

	splat=spawn();
	splat.owner=self;
	splat.classname="bloodsplat";
	splat.movetype=MOVETYPE_NONE;
	splat.solid=SOLID_TRIGGER;		//SOLID_NOT
	splat.drawflags=SCALE_ORIGIN_BOTTOM+SCALE_TYPE_XYONLY;
	if (!self.scale)
		self.scale = 1;
	splat.scale = self.scale*random(0.7,1);
	if (self.flags2&FL_SMALL)
		splat.scale = random(0.25,0.4);
	if (self.model == "models/spider.mdl")
		splat.scale *= 0.5;
	else if (self.netname == "yakman")
		splat.scale *= 1.25;
	else if (self.netname == "maulotaur")
		splat.scale *= 1.5;
	
	org = trace_endpos;
	org_z += random(0,0.4);
	
	setmodel (splat, bloodsplat_mdl[type]);
	setsize(splat,'0 0 0','0 0 0');
	setorigin(splat,org);
	
	splat.angles_y=random(360);
	splat.touch=bloodpool_step;
	if (CheckCfgParm(PARM_FADE)) {
		splat.think=SUB_Remove;
		thinktime splat : random(30,20);
	}
	
	if (trace_plane_normal != '0 0 0')
	{	//on slope
		pitch_roll_for_slope(trace_plane_normal, splat);
	}
}

void() archer_gibs;
void() death_knight_gibs;
void() afrit_gibs;
void() imp_gibs;
void() undying_gibs;

void chunk_reset ()
{
	chunk_cnt=FALSE;
	remove(self);
}

void make_chunk_reset ()
{
	newmis=spawn();
	newmis.think=chunk_reset;
	thinktime newmis : 1.5;
}

void chunk_death (void)
{
	vector space;
	float spacecube,model_cnt,scalemod;
	string deathsound;

	DropBackpack();

	space = self.absmax - self.absmin;

	spacecube = space_x * space_y * space_z;

	model_cnt = spacecube / 8192;   // (16 * 16 * 16)

	if ((self.thingtype==THINGTYPE_GLASS) || (self.thingtype==THINGTYPE_CLEARGLASS) || (self.thingtype==THINGTYPE_REDGLASS))
		deathsound="fx/glassbrk.wav";
	else if ((self.thingtype==THINGTYPE_WOOD) || (self.thingtype==THINGTYPE_WOOD_METAL))
		if(self.classname=="bolt")
			deathsound="assassin/arrowbrk.wav";
		else	
			deathsound="fx/woodbrk.wav";
	else if ((self.thingtype==THINGTYPE_GREYSTONE) || (self.thingtype==THINGTYPE_BROWNSTONE) || 
		(self.thingtype==THINGTYPE_WOOD_STONE) || (self.thingtype==THINGTYPE_METAL_STONE))
		deathsound="fx/wallbrk.wav";
	else if ((self.thingtype==THINGTYPE_METAL) || (self.thingtype==THINGTYPE_METAL_CLOTH))
		deathsound="fx/metalbrk.wav";
	else if ((self.thingtype==THINGTYPE_BONE))
		deathsound="fx/bonebrk.wav";
	else if ((self.thingtype==THINGTYPE_CLOTH) || (self.thingtype==THINGTYPE_WEBS))
		deathsound="fx/clothbrk.wav";
	else if (self.thingtype==THINGTYPE_ASH)
		deathsound="misc/bshatter.wav";
	else if (self.thingtype==THINGTYPE_FLESH)
	{
		if (!self.flags&FL_SWIM)
		{
			if (self.model == "models/spider.mdl")
				BloodSplat(BLOOD_GREEN);
			else if (self.flags2&FL_SMALL)
				BloodSplat(BLOOD_SMALL);
			else if (random(100) < 25)
				BloodSplat(BLOOD_LARGE);
			else if (random(100) < 50)
				BloodSplat(BLOOD_MED);
			else
				BloodSplat(BLOOD_SMALL);
		}
		
		if (self.headmodel) {
			ThrowGib (self.headmodel, self.health);
			self.headmodel = "";
		}
		if (self.netname == "undying")
			undying_gibs();
		if (self.classname == "monster_archer" || self.classname == "monster_archer_lord" || self.classname == "monster_archer_ice")
			archer_gibs();
		if (self.classname == "monster_imp_ice" || self.classname == "monster_imp_fire")
			imp_gibs();
		if (self.netname == "afrit")
			afrit_gibs();
		if (self.classname == "monster_death_knight")
			death_knight_gibs();
		if (self.classname == "monster_raven") {
			local float i;
			for (i = 0; i < 10*self.scale; i++)
				feathers();
		}
		//Made temporary changes to make weapons look and sound
		//better, more blood and gory sounds.
		if(self.enemy.playerclass==CLASS_ASSASSIN && (self.enemy.weapon == IT_WEAPON4))
			deathsound="assassin/rip.wav";
		else
		{
			if(self.health<-50)
				deathsound="player/megagib.wav";
			else if(random()<0.5)
				deathsound="player/gib1.wav";
			else
				deathsound="player/gib2.wav";
		}
		sound(self,CHAN_AUTO,deathsound,1,ATTN_NORM);
		self.level=-666;
	}
	else if (self.thingtype==THINGTYPE_CLAY)
		deathsound="fx/claybrk.wav";
	else if ((self.thingtype==THINGTYPE_LEAVES) || (self.thingtype==THINGTYPE_WOOD_LEAF))
		deathsound="fx/leafbrk.wav";
	else if (self.thingtype==THINGTYPE_ICE)
		deathsound="misc/icestatx.wav";
	else
		deathsound="fx/wallbrk.wav";

	if(self.level!=-666)
		sound (self, CHAN_VOICE, deathsound, 1, ATTN_NORM);
	// Scale        0 - 50,000   small 
	//		   50,000 - 500,000  medium
	//	      500,000            large
	//	    1,000,000 +          huge
	if (spacecube < 5000)
	{
		scalemod = .20;
		model_cnt = model_cnt * 3;	// Because so few pieces come out of a small object
	}
	else if (spacecube < 50000)
	{
		scalemod = .45;
		model_cnt = model_cnt * 3;	// Because so few pieces come out of a small object
	}
	else if (spacecube < 500000)
	{
		scalemod = .50;
	}
	else if (spacecube < 1000000)
	{
		scalemod = .75;
	}
	else
	{
		scalemod = 1;
	}

	if(model_cnt>CHUNK_MAX)
		model_cnt=CHUNK_MAX;

	if(deathmatch||coop)
	{	// this function handles deathmatch specially...
		CreateModelChunks(space,scalemod, model_cnt);
	}
	else
	{
		while (model_cnt>0)
		{
			if (chunk_cnt < CHUNK_MAX*2)
			{
				CreateModelChunks(space,scalemod, 1);
				chunk_cnt+=1;
			}

			model_cnt-=1;
		}
	}
	
	make_chunk_reset();

	if(self.classname=="monster_eidolon")
		return;

	SUB_UseTargets();
	SUB_ResetTarget();
	
	if (self.th_init && self.th_init != SUB_Null)
	{	//set up respawn time
		self.aflag = TRUE;		//tell MarkForRespawn not to gib this entity again
		self.lifetime = time + random(WANDERING_MONSTER_TIME_MIN, WANDERING_MONSTER_TIME_MAX);
		self.think = MarkForRespawn;
		self.nextthink = time + 0.01;
	}
	else if(self.headmodel!=""&&self.classname!="head")
	{
		ThrowSolidHead (50);
	}
	else
	{
		if(self.switchshadstyle)
			lightstyle(self.switchshadstyle, "m");
		remove(self);
	}
}

void bloodspew ()
{
	if (time > self.lifetime || !self.owner || self.count-self.cnt<0)
		remove(self);
	
	setorigin(self, self.owner.origin + self.view_ofs);
	particle2(self.origin,'-10 -10 60','10 10 100',rint (256 + 16*8 + random(9)),PARTICLETYPE_FASTGRAV,self.count-self.cnt);
	//SpawnPuff (self.origin, '0 0 80',self.count-self.cnt,self.owner);
	self.cnt+=self.scalerate;
	thinktime self : HX_FRAME_TIME*0.5;
}

void bloodspew_create (float life, float amt, vector ofs)
{
entity new;
	if (life<1)
		return;
	new = spawn();
	new.lifetime = time+(life*HX_FRAME_TIME*0.5);
	new.scalerate = (amt-amt*0.1)/life;
	new.count = amt;
	new.owner = self;
	new.view_ofs = ofs;
	new.think = bloodspew;
	thinktime new : 0;
}
