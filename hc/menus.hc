/*
 * In-game menus by whirledtsar
*/

void() Options_Info;

void Menu_Project ()
{
vector source, dest;
float ofsdir;
	if (!self.owner) {
		remove(self);
		return;
	}
	
	makevectors(self.owner.v_angle);
	source = self.owner.origin+self.owner.view_ofs+'0 0 2';
	dest = source+v_forward*25.5;		//12 is perfect without fov compensation
	dest -= v_forward*(cvar("fov")*0.15);		//compensate for fov
	dest += v_forward*(-self.owner.v_angle_x*0.04*(self.owner.v_angle_x<15));	//if player is aiming up, spawn graphic further away
	traceline(source, dest, TRUE, self);
	dest = trace_endpos;
	
	traceline(dest, dest+v_right*self.t_width, TRUE, self);		//check right edge of graphic
	if (trace_fraction==1) {
		traceline(dest, dest-v_right*self.t_width, TRUE, self);	//check left edge of graphic
		if (trace_fraction!=1)
			ofsdir = 1;
		else
			ofsdir = 0;
	}
	else
		ofsdir = -1;
	
	if (ofsdir)
		setorigin(self, dest+(v_right*(trace_fraction*self.t_width)*ofsdir));	//adjust destination so edges arent clipped
	else
		setorigin(self, dest);
	
	self.angles = self.owner.v_angle;
	self.angles_x *= -1;
	self.angles_z = 0;
	
	self.think = Menu_Project;
	thinktime self : 0;
}

void Menu_Enable (float type)
{
	if (type==MENU_STATS && !self.statpoints)
	{
		centerprint (self, "You have no remaining stat points\n");
		sprint(self, "You have no remaining stat points\n");
		return;
	}
	
	if (self.flags2&FL2_MENUACTIVE && self.menu)
		Menu_Disable();
	
	if (type==MENU_STATS)
		sprint(self, "You have "); sprint(self, ftos(self.statpoints)); sprint(self, " points remaining\n");
	
	sound (self, CHAN_AUTO, "misc/barmovup.wav", 1, ATTN_STATIC);
	self.flags2(+)FL2_MENUACTIVE;
	
	newmis = spawn();
	self.menu = newmis;
	newmis.owner = self;
	newmis.impulse = type;
	newmis.drawflags = MLS_FULLBRIGHT;
	newmis.scale = 0.25;
	newmis.t_width = 16;	//half of graphic width
	if (type==MENU_STATS) {
		newmis.count = 3;
		newmis.th_run = StatsMenu_Increase;
		setmodel(newmis, "models/menustat.mdl");
	}
	else {
		newmis.count = 3;
		newmis.th_run = OptionsMenu_Toggle;
		setmodel(newmis, "models/menuoptn.mdl");
		Options_Info();
	}
	
	newmis.think = Menu_Project;
	thinktime newmis : 0;
}

void Menu_Disable ()
{
	self.flags2(-)FL2_MENUACTIVE;
	self.menuselection = 0;
	if (self.menu)
		remove(self.menu);
}

void Menu_Toggle (float type)
{
	if (self.flags2&FL2_MENUACTIVE && self.menu.impulse!=type) {
		Menu_Disable();		//disable current menu and bring up new menu
		Menu_Enable(type);
		return;
	}
	else if (self.flags2&FL2_MENUACTIVE)
		Menu_Disable();
	else
		Menu_Enable(type);
}

void Menu_Move (float dir)
{
	if (!self.flags2&FL2_MENUACTIVE)
		return;
	
	sound (self, CHAN_AUTO, "raven/menu3.wav", 1, ATTN_STATIC);
	self.menuselection = wrap(self.menuselection+dir, 0, self.menu.count);
	
	self.menu.skin = self.menuselection;
}

void Menu_Choose ()
{
	if (!self.flags2&FL2_MENUACTIVE)
		return;
	if (!self.menu)
		return;
	
	self.menu.th_run();
}

void StatsMenu_Increase ()
{
float inc;
string stat;
	if (!self.statpoints)
	{
		sprint(self, "You have no remaining stat points\n");
		if (self.flags2&FL2_MENUACTIVE)
			Menu_Disable();
	}
	if (!self.flags2&FL2_MENUACTIVE)
		return;
	
	switch (self.menuselection)
	{
		case 0:
			inc = ++self.strength;
			stat = "strength ";
			break;
		case 1:
			inc = ++self.intelligence;
			stat = "intelligence ";
			break;
		case 2:
			inc = ++self.wisdom;
			stat = "wisdom ";
			break;
		case 3:
			inc = ++self.dexterity;
			stat = "dexterity ";
			break;
	}
	
	--self.statpoints;
	
	sprint(self, "Your "); sprint(self, stat); sprint(self, " has increased to "); sprint(self, ftos(inc)); sprint(self,"\n");
	
	if (self.statpoints<=0)
	{
		self.statpoints = 0;
		centerprint (self, "You have no remaining stat points\n");
		sprint(self, "You have no remaining stat points\n");
		Menu_Disable();
	}
	else
	{
		sprint(self, "You have "); sprint(self, ftos(self.statpoints)); sprint(self, " points remaining\n");
	}
}

void StatsMenu_Dump ()
{
float inc,orgnl_stat;
string stat;
	if (!self.statpoints)
	{
		sprint(self, "You have no remaining stat points\n");
		if (self.flags2&FL2_MENUACTIVE)
			Menu_Disable();
	}
	
	if (self.menuselection==0) {
		stat = "strength ";
		orgnl_stat = self.strength;
		while (self.statpoints) {
			++inc;
			++self.strength;
			--self.statpoints;
		}
	}
	else if (self.menuselection==1) {
		stat = "intelligence ";
		orgnl_stat = self.intelligence;
		while (self.statpoints) {
			++inc;
			++self.intelligence;
			--self.statpoints;
		}
	}
	else if (self.menuselection==2) {
		stat = "wisdom ";
		orgnl_stat = self.wisdom;
		while (self.statpoints) {
			++inc;
			++self.wisdom;
			--self.statpoints;
		}
	}
	else {	//if (self.menuselection==3) {
		stat = "dexterity ";
		orgnl_stat = self.dexterity;
		while (self.statpoints) {
			++inc;
			++self.dexterity;
			--self.statpoints;
		}
	}
	
	inc = orgnl_stat + inc;
	
	sprint(self, "Your "); sprint(self, stat); sprint(self, " has increased to "); sprint(self, ftos(inc)); sprint(self,"\n");
	centerprint (self, "You have no remaining stat points\n");
	sprint(self, "You have no remaining stat points\n");
	Menu_Disable();
}

void OptionsMenu_Toggle ()
{
	if (self.menuselection == 0) {
		if (SetCfgParm(PARM_RESPAWN))
			sprint (self, "Monster respawning enabled\n");
		else 
			sprint (self, "Monster respawning disabled\n");
	}
	else if (self.menuselection == 1) {
		if (SetCfgParm(PARM_FADE))
			sprint (self, "Corpse fading enabled\n");
		else 
			sprint (self, "Corpse fading disabled\n");
	}
	else if (self.menuselection == 2) {
		if (SetCfgParm(PARM_BUFF))
			sprint (self, "Random monster variations enabled\n");
		else
			sprint (self, "Random monster variations disabled\n");
	}
	else if (self.menuselection == 3) {
		if (SetCfgParm(PARM_STATS)) {
			sprint (self, "Randomized stat increases enabled\n");
			if (self.statpoints)		//if player still has points remaining, distribute them randomly
				StatsIncreaseRandom(self.statpoints);
			self.statpoints = 0;
		}
		else
			sprint (self, "Manual stat increases enabled\n");
	}
}

void Options_Info ()
{
string respawning, fade, buff, stats;
	if (CheckCfgParm(PARM_RESPAWN))
		respawning="on";
	else
		respawning="off";
	if (CheckCfgParm(PARM_FADE))
		fade="on";
	else
		fade="off";
	if (CheckCfgParm(PARM_BUFF))
		buff="on";
	else
		buff="off";
	if (CheckCfgParm(PARM_STATS))
		stats="on";
	else
		stats="off";
	
	sprint (self, "Monster respawning is "); sprint(self, respawning); sprint(self, ".\n");
	sprint (self, "Corpse fading is "); sprint(self, fade); sprint(self, ".\n");
	sprint (self, "Random monster variants are "); sprint(self, buff); sprint(self, ".\n");
	sprint (self, "Automatic stat increases are "); sprint(self, stats); sprint(self, ".\n");
}

