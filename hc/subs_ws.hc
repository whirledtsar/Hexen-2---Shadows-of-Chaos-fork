void SUB_UseWakeTargets()	//ws: monsters use self.waketarget upon sighting player
{
	if (self.waketarget=="")
		return;
	
	string otarget, okill;
	otarget = self.target;
	okill = self.killtarget;
	self.target = self.waketarget;
	self.killtarget = "";
	SUB_UseTargets();	//its that simple!
	self.target = otarget;
	self.killtarget = okill;
	self.waketarget = "";	//only use waketarget once!
}

void SUB_ResetTarget()
{
	self.target = self.killtarget = "";
}

/*
 * SUB_TraceRange -- Traces forward, up/down by vrange units, and side-to-side by hrange units. Assumes that makevectors has been run.
 */
void SUB_TraceRange(vector v1, vector v2, float nomonsters, entity forent, float vrange, float hrange)
{
	traceline(v1, v2, nomonsters, forent);
	
	if (trace_fraction==1.0) {
		traceline(v1, v2+(v_up*vrange), nomonsters, forent);
		if (trace_fraction==1.0)
			traceline(v1, v2-(v_up*vrange), nomonsters, forent);
	}
	
	if (trace_fraction==1.0)
		if (!hrange)
			return;
	
	if (trace_fraction==1.0) {
		traceline(v1, v2+(v_right*hrange), nomonsters, forent);
		if (trace_fraction==1.0)
			traceline(v1, v2-(v_right*hrange), nomonsters, forent);
	}
}

/*
 *	ReflectMissile - Reflects entity other, behaving like mode, and generating effect (see constant.hc) at reflection spot. In deflection mode, missile is deflected between minangofs and maxangofs degrees of self's angles. If checkheading, only reflect missiles actually heading towards self. If ignoremonsterclass, ignore missiles spawned by monsters of this class (most useful for CLASS_BOSS).
 */

void() bone_shard_touch;
void() reflect_touch;
float(entity ent) IsMissile;

float REFLECT_REFLECT = 0;
float REFLECT_DEFLECT = 1;
float REFLECT_AIMED = 2;
float REFLECT_BLOCK = 3;

float ReflectMissile (entity other, float mode, float effect, float speedmod, float minangofs, float maxangofs, float checkheading, float ignoremonsterclass)
{
vector org, vec, dir;//, endspot,endplane, dif;
float magnitude;//remainder, reflect_count,
entity us;

	if (!other || other == self)	return FALSE;
	if (self.owner && other.owner == self.owner)	return FALSE;
	if (!IsMissile(other))			return FALSE;
	if (other.safe_time>time) 		return FALSE;
	if (ignoremonsterclass && other.owner.monsterclass >= ignoremonsterclass)	return FALSE;
	
	if(other.classname=="funnal"||other.classname=="tornato")
		return FALSE;
	
	if (self.owner)		//self is trigger field owned by monster, owner is monster
		us = self.owner;
	else
		us = self;
	
	if (!speedmod)
		speedmod = 1;
	
	dir = normalize(other.velocity);
	magnitude=vlen(other.velocity);
	
	if (checkheading) {		//dont block projectiles not heading directly towards self
		org = other.origin;
		vec = org + dir*100;
		traceline (org, vec, FALSE, other);
		if(trace_ent!=us)
			return FALSE;
		org = trace_endpos;
	}
	else
		org = other.origin;
	
	//new direction
	dir *= (-1);
	if(magnitude<other.speed)
		magnitude=other.speed;
	
	if (mode==REFLECT_BLOCK) {
		if(!other.flags2&FL_ALIVE) {
			other.flags2(+)FL_NODAMAGE;
			return TRUE;
		}
		else
			return FALSE;
	}
	
	if (effect)
		starteffect(effect, org);
	
	if (maxangofs<=0 && mode==REFLECT_DEFLECT)
		mode = REFLECT_REFLECT;
	
	if (mode == REFLECT_AIMED) {	//fallen angel lord
		v_forward=normalize(other.owner.origin+other.owner.view_ofs-other.origin);
		dir+= 2*v_forward;	//?
		dir=normalize(dir);
	}
	
	if(other.movedir)
		other.movedir=dir;
	if(other.o_angle)
		other.o_angle=dir;
	if(other.speed)
		other.speed*=speedmod;
	
	other.velocity = dir*magnitude*speedmod;	
	if (mode == REFLECT_DEFLECT) {
		makevectors(other.velocity);
		other.velocity += v_up*random(minangofs,maxangofs)*randomsign();
		other.velocity += v_right*random(minangofs,maxangofs)*randomsign();
	}
	other.angles = vectoangles(other.velocity);
	
	other.safe_time=time+100/magnitude;
	
	if (other.effects&EF_NODRAW && other.touch==bone_shard_touch)		//ws: don't know why bone shards become invisible, but they do
		other.effects(-)EF_NODRAW;
	
	if(!other.controller)
		other.controller=other.owner;
	if(other.enemy==us)
		other.enemy=other.owner;
	if(other.goalentity==us)
		other.goalentity=other.owner;
	
	other.owner=us;
	
	return TRUE;
}

/*
 * SUB_TraceThroughObstacles -- Traces a line like normal, but continues the trace if it hits a weak or see-through breakable entity, so monsters can shoot them out of the way
 */
void SUB_TraceThroughObstacles (vector source, vector dest, float ignoremonsters, entity ignore, entity victim)
{
	trace_ent = world;
	
	traceline(source,dest,ignoremonsters,ignore);
	if (trace_ent!=victim && (trace_ent.thingtype==THINGTYPE_WEBS||trace_ent.thingtype==THINGTYPE_GLASS||trace_ent.thingtype==THINGTYPE_CLEARGLASS||trace_ent.thingtype==THINGTYPE_REDGLASS|| (trace_ent.thingtype==THINGTYPE_ICE&&trace_ent.takedamage) || (trace_ent.thingtype==THINGTYPE_CLAY && trace_ent.solid!=SOLID_BSP)))
	{
		traceline(trace_endpos,dest,ignoremonsters,trace_ent);
	}
	else
		return;
}

float SUB_IsTargeted (entity ent)
{
	if (ent.targetname && ent.targetname!="")
		return TRUE;
	if (ent.targetid)
		return TRUE;
	return FALSE;
}
