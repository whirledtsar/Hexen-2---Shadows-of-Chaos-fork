float PULL_TOTAL = 470;
float PULL_RESISTGRAVITY = 80;
float WHIP_LENGTH = 400;



void whip_pull_solid (vector dir, vector endpos)
{
	vector upvec;
	float totalpull;
	
	upvec = '0 1 0';
	totalpull = PULL_TOTAL;
	
	//pull player
	self.velocity+=(dir * totalpull) / 1.2;
	self.velocity+=upvec * PULL_RESISTGRAVITY;//get off ground
	self.flags(-)FL_ONGROUND;
	
	sound(self,CHAN_AUTO,"weapons/ric2.wav",1,ATTN_NORM);
	//self.think = self.storethink;
	//thinktime self : 0.2;
}

void whip_pull (vector dir, entity targetent)
{
	vector upvec;
	float totalmass, pullstr1, pullstr2;
	float stationary;
	
	if (targetent.thingtype == THINGTYPE_FLESH)
		sound(targetent,CHAN_AUTO,"assassin/chntear.wav",1,ATTN_NORM);
	T_Damage (targetent, self, self.owner, 5);
	if (targetent.movetype == MOVETYPE_NONE)
		return;
		
	//break up total pull into equal parts
	totalmass = targetent.mass + self.mass;
	pullstr1 = (self.mass / totalmass) * PULL_TOTAL;
	pullstr2 = (targetent.mass / totalmass) * PULL_TOTAL;

	if (targetent.mass > 1000 || !targetent.flags2&FL_ALIVE)
	{
		pullstr1 = PULL_TOTAL;
		stationary = TRUE;
	}
	
	upvec = '0 0 1';
	if (targetent.flags2&FL_ALIVE)
	{
		targetent.storethink = targetent.think;
		targetent.think = targetent.th_pain;
		targetent.nextthink = time + 1.1;
		targetent.think = targetent.storethink;
		targetent.nextthink = time + 0.1;
	}
	
	
	
	//pull player
	self.velocity+=dir * pullstr1 / 2;
	self.velocity+=upvec * PULL_RESISTGRAVITY;//get off ground
	self.flags(-)FL_ONGROUND;

	if (!stationary)
	{
		//pull target
		targetent.velocity+=(dir * -1) * pullstr2;
		targetent.velocity+=upvec * PULL_RESISTGRAVITY;//get off ground
		targetent.velocity_z+=110;
		targetent.flags(-)FL_ONGROUND;
	}
	//self.think = self.storethink;
	//thinktime self : 0.2;
}

void DrawWhip(void)
{
//These seem to lock up game if there are too many of them
vector org, dir,pos;
	org = self.origin;
	pos = self.view_ofs + v_up * 38 + v_right * -8;
	dir=normalize(self.view_ofs-org);
	org+=dir*15;
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_STREAM_CHAIN);
	WriteEntity (MSG_BROADCAST, self);
	WriteByte (MSG_BROADCAST, 1+STREAM_ATTACHED);
	WriteByte (MSG_BROADCAST, 1);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
	WriteCoord (MSG_BROADCAST, pos_x);
	WriteCoord (MSG_BROADCAST, pos_y);
	WriteCoord (MSG_BROADCAST, pos_z);
	
}

void whip_fire ()
{
	vector	source, dir;
	float wdistance;
	
	//self.owner = self.owner.owner;
	
	//whip limit
	if (self.whiptime > time)
	{
		return;
	}
	
	self.whiptime = time + 0.8;
	
	wdistance = WHIP_LENGTH;
	
	makevectors (self.v_angle);
	source = self.origin + self.proj_ofs;
	source += normalize(v_right) * -8;
	source += normalize(v_up) * -4; //get left hand location offset
	dir = normalize(v_forward);
	traceline (source, source + dir * wdistance, FALSE, self);

	self.enemy = trace_ent;
	
	if (trace_ent.takedamage) //can be hurt
	{
		whip_pull(dir, trace_ent);		
	}
	else if (trace_fraction < 1.0 && pointcontents(trace_endpos) != CONTENT_SKY) //walls (but not sky)
	{
		whip_pull_solid(dir, trace_endpos);
	}

	// Draw chain
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_STREAM_CHAIN);
	WriteEntity (MSG_BROADCAST, self);
	WriteByte (MSG_BROADCAST, 1+STREAM_ATTACHED);
	WriteByte (MSG_BROADCAST, 6);
	WriteCoord (MSG_BROADCAST, source_x);
	WriteCoord (MSG_BROADCAST, source_y);
	WriteCoord (MSG_BROADCAST, source_z);
	WriteCoord (MSG_BROADCAST, trace_endpos_x);
	WriteCoord (MSG_BROADCAST, trace_endpos_y);
	WriteCoord (MSG_BROADCAST, trace_endpos_z);
	
	//play sound
	//sound(self,CHAN_WEAPON,"assassin/chain.wav",1,ATTN_NORM);
	
	self.think = self.storethink;
	thinktime self : 0.2;
}

void DrawLinks(void);

void ChainWTouch(void)
{
//	if(other==self.owner.owner)
//		return;
	if(other==self.owner)
		return;

	self.owner.storethink = self.owner.think;
	self.touch=SUB_Null;
	if(other.takedamage)
	{
		self.owner.think=whip_fire;
		self.owner.nextthink=time;
		remove(self);
	}
	else
	{
		//sound(self,CHAN_BODY,"weapons/met2stn.wav",1,ATTN_NORM);
		self.movetype=MOVETYPE_NONE;
		self.velocity='0 0 0';
		//self.owner.storethink = self.owner.think;
		self.owner.think=whip_fire;
		self.owner.nextthink=time;
		remove(self);
	}
}

void ChainWThink (void)
{
	DrawWhip();
	//self.movetype = MOVETYPE_NONE;
	
	traceline(self.origin,self.view_ofs,FALSE,self);
	if((vlen(self.origin-self.owner.origin)>640&&self.movetype==MOVETYPE_FLYMISSILE)||
//		self.movetype=MOVETYPE_BOUNCE;
	(trace_fraction<1))
	{
	    //self.owner.think=whip_fire;
		//self.owner.nextthink=time;
		remove(self);
	}
	self.nextthink=time+0.05;
}

void FireChainW (void)
{
vector dir, source;

	if (time < self.attack_finished)
		return;
	sound(self,CHAN_BODY,"assassin/chainwhip.wav",1,ATTN_NORM);
	dir=normalize(self.v_angle);
	newmis=spawn();
	newmis.classname="chain_head";
	newmis.owner=self;
	//self.goalentity=newmis;
	newmis.movetype=MOVETYPE_FLYMISSILE;
	newmis.solid=SOLID_BBOX;
	//newmis.velocity=dir*750;
	newmis.touch=ChainWTouch;
	newmis.think=ChainWThink;
	//newmis.drawflags=MLS_POWERMODE;
	newmis.nextthink=time;
	makevectors (self.v_angle);
	source = self.origin + self.proj_ofs;
	source += normalize(v_right) * -12;
	source += normalize(v_up) * -2; //get left hand location offset
	newmis.view_ofs=self.origin;
	
	newmis.velocity=normalize(v_forward)*3000;
	newmis.angles = vectoangles ('0 0 0' - newmis.velocity);
	newmis.avelocity_z = 300;
	
	newmis.angles=vectoangles(newmis.velocity);
	self.attack_finished=time+0.5;
	//if (time > self.attack_finished)
	//	whip_fire();
	setmodel(newmis,"models/twspike.mdl");
	setsize(newmis,'0 0 0','0 0 0');
	//setorigin(newmis,self.origin+dir*8);
	setorigin(newmis,source);
}

