void() next_frame =
{
	if (self.frame < self.button1){
		self.frame = self.frame + 1;
	} else {
		self.frame = self.button0;
	}
	self.nextthink = time + 0.1;	
	self.think = next_frame;	
};

/*
Put any model in the map

model = filename of model to have

If button0 and 1 are set it loops the frames:
button0 = startframe to play
button1 = endframe to play

If target is set it follows the path defined by the target path_corner ents.
noise and noise1 then define the noises to play during movement.
button0 & 1 dont work when target is set.
*/
void() misc_model =
{
	precache_model (self.model);
	setmodel (self, self.model);	
	self.solid = SOLID_NOT;
	
	if (self.target) {
		if (!self.speed)
			self.speed = 100;
		self.cnt = 1;
		self.solid = SOLID_NOT;
		self.movetype = MOVETYPE_FAKEPUSH;
		self.blocked = train_blocked;
		self.use = train_use;
		if (!self.noise) self.noise = "misc/null.wav";
		if (!self.noise1) self.noise1 = "misc/null.wav";		
		precache_sound (self.noise);
		precache_sound (self.noise1);		
		setsize (self, self.mins , self.maxs);
		setorigin (self, self.origin);		
		
		// start trains on the second frame, to make sure their targets have had
		// a chance to spawn
		self.nextthink = self.ltime + 0.1;
		self.think = func_train_find;
		return;	
	}
		
	//if (!self.button0){
	//	if (!self.noise4) {
	//		makestatic(self);
	//	}
	//} else {
	if (self.button1) {
		self.think = next_frame;
		self.nextthink = self.ltime + 0.1;
		self.frame = self.button0;
	}
	//}
	self.solid = SOLID_NOT;
	if (self.target)
		self.movetype = MOVETYPE_FAKEPUSH;
	else
		self.movetype = MOVETYPE_NONE;	
};

void() static_brush =
{
	//static_brush == compatibility with old tenebrae maps 
	misc_model();
};

void() rotateengine_use =
{
	local entity	targ;


	targ = find (world, noise4, self.target);
	if (targ)
		if (self.state == STATE_TOP) {
			targ.avelocity = '0 0 0';
			self.state = STATE_DOWN;
		} else {
			targ.avelocity = self.avelocity;
			self.state = STATE_TOP;
		}
	else objerror("No target found");
	
};

void() misc_rotateengine =
{
	self.use = rotateengine_use;
	self.state = STATE_DOWN;
};

/*
The fan is spinning out
*/
void () fan_turnoff = {

	local float reached;
	
	if (self.state == STATE_TOP) {
		reached = 1;
		if (self.avelocity_x > 0) {
			self.avelocity_x = self.avelocity_x - self.waitmin;
			reached = 0;
		}
		
		if (self.avelocity_y > 0) {
			self.avelocity_y = self.avelocity_y - self.waitmin;
			reached = 0;
		}
		
		if (self.avelocity_z > 0) {
			self.avelocity_z = self.avelocity_z - self.waitmin;
			reached = 0;
		}		
	
		if (reached == 0) {
			self.nextthink = time + 0.1;
		} else {
			self.state = STATE_DOWN;
			self.avelocity = '0 0 0';
			self.nextthink = time + 100000;
		}
	}
};

/*
The fan is starting up
*/
void () fan_turnon = {

	local float reached;
	self.state = STATE_TOP;
	
	reached = 1;
	if (self.avelocity_x < self.dest_x) {
		self.avelocity_x = self.avelocity_x + self.waitmax;
		reached = 0;
	}
	
	if (self.avelocity_y < self.dest_y) {
		self.avelocity_y = self.avelocity_y + self.waitmax;
		reached = 0;
	}
	
	if (self.avelocity_z < self.dest_z) {
		self.avelocity_z = self.avelocity_z + self.waitmax;
		reached = 0;
	}		
	
	//We are at the top speed stop thinking
	if (reached == 1) {
		self.nextthink = time + 100000;
	} else {
		self.nextthink = time + 0.1;
	}
};

/*
The fan is toggled
*/
void () fan_use =
{
	//shootable and destroyed?
	if (self.max_health) {
		if (self.health <= 0) {
			return;
		}
	}
	
	if (self.state == STATE_TOP) {
		self.think = fan_turnoff;
		self.nextthink = time + 0.1;
	} else {
		self.think = fan_turnon;
		self.nextthink = time + 0.1;	
	}
};

/*
The fan is shot
*/
void () fan_die =
{
	if (self.state == STATE_TOP) {
		self.think = fan_turnoff;
		self.nextthink = time + 0.1;
	}
};


/*
Put a fan in the map.  A is any model that spins, it spins slowly up until it reaches max speed.
It can be turned on/ off by triggering.  It can be shot out.
model = name of the fan model
avelocity = rotation speed around the 3 axis (0 90 0)
health = how long it takes to destroy. (zero is indestuctible)
waitmin = spin down speed (default 5)
waitmax = spin up speed (default 5)
if spawnlfags 1 is set it starts disabled
*/
void() misc_fan =
{
	precache_model (self.model);
	setmodel (self, self.model);	
	self.solid = SOLID_SLIDEBOX;
	
	if (self.health)
	{
		self.max_health = self.health;
		self.th_die = fan_die;
		self.takedamage = DAMAGE_YES;
	} else {
		self.max_health = 0;
	}
	
	self.dest = self.avelocity;
	self.think = fan_turnon;
	self.nextthink = time + 100000;
	self.use = fan_use;
	self.state = STATE_TOP;
	
	//start off?
	if (self.spawnflags & 1) {
		self.avelocity = '0 0 0';
	}
	
	if (!self.waitmin)
		self.waitmin = 5;
		
	if (!self.waitmax)
		self.waitmax = 5;
		
	setsize(self, self.mins, self.maxs);
	self.movetype = MOVETYPE_FAKEPUSH;	
};