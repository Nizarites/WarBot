class Team { //<>// //<>// //<>// //<>//
  Team() {
  }
}

///////////////////////////////////////////////////////////////////////////
//
// Turtle
// ======
// > a generic agent
// > turtles are caracterized by:
//   - heading = the orientation of the turtle
//   - colour = the colour of the turtle
//   - pos = the position of the turtle
//   - shape = an image for the display
//   - size = the size for the display
//   - energy = the total amount of energy
//   - metabolism = the amount of energy consumed at each timestep
//   - breed = the breed of the turtle
//   - who = a unique identifier
//
///////////////////////////////////////////////////////////////////////////
class Turtle {
  float heading;
  color colour;
  PVector pos;
  PImage shape;
  float size;
  float energy;
  float metabolism;
  int breed;
  int who;

  //
  // empty constructor
  // =================
  //
  Turtle() {
  }

  //
  // constructor
  // ===========
  //
  // input
  // -----
  // > p = the position of the turtle
  // > c = the colour of the turtle
  // > img = the image for the display
  //
  Turtle(PVector p, color c, String img) {
    // location is p
    pos = p;
    // heading is random
    heading = random(TWO_PI);
    // colour is c
    colour = c;
    // shape is img
    shape = loadImage(img);
    // the size is defined relatively to the global scale
    size = scale;
    // a unique identifier is given (and the number of turtles is increased)
    who = game.nbTurtles;
    game.nbTurtles++;
  }

  //
  // right
  // =====
  // > turn right by an angle of a
  //
  // input
  // -----
  // > a = the angle of rotation (in degrees)
  //
  void right(float a) {
    // rotation is modulo 2 PI
    heading = (heading + radians(a)) % TWO_PI;
  }

  //
  // left
  // ====
  // > turn left by an angle of a
  //
  // input
  // -----
  // > a = the angle of rotation (in degrees)
  //
  void left(float a) {
    // rotation is modulo 2 PI
    heading = (heading - radians(a)) % TWO_PI;
  }

  //
  // distance
  // ========
  // > computes the distance to bob
  //
  // input
  // -----
  // > bob = the other turtle
  //
  // output
  // ------
  // > the distance to bob
  //
  float distance(Turtle bob) {
    return game.distance(this, bob);
  }

  //
  // distance
  // ========
  // > computes the distance to p
  //
  // input
  // -----
  // > p = the other position
  //
  // output
  // ------
  // > the distance to p
  //
  float distance(PVector p) {
    return game.distance(pos, p);
  }

  //
  // towards
  // =======
  // > returns the angle towards turtle b
  //
  // input
  // -----
  // > b = the other turtle
  //
  // output
  // ------
  // > the angle towards b
  //
  float towards(Turtle b) {
    return game.towards(this, b);
  }

  //
  // towards
  // =======
  // > returns the angle towards position p
  //
  // input
  // -----
  // > p = the target position
  //
  // output
  // ------
  // > the angle towards p
  //
  float towards(PVector p) {
    return game.towards(this.pos, p);
  }


  //
  // display
  // =======
  // > displays the turtle
  //
  void display() {
    // shift to the location of the turtle
    translate(pos.x, pos.y);
    // choose the right size and colour
    scale(size);
    tint(colour);
    // display the image
    image(shape, 0, 0);
    // reset the coordinates system
    resetMatrix();
  }

  //
  // setup
  // =====
  // > called at the creation of the turtle
  //
  void setup() {
  }

  //
  // prepareToGo
  // ===========
  // > called at the beginning of a timestep to prepare the activation of the agent
  //
  void prepareToGo() {
    // updates the energy due to the metabolism of the turtle
    energy -= metabolism;
  }

  //
  // go
  // ==
  // > called at each timestep to activate the turtle
  //
  void go() {
  }

  //
  // getEnergy
  // =========
  // > returns the amount of energy of the turtle to compute the score of the team
  //
  // output
  // ------
  // the energy of the turtle
  //
  float getEnergy() {
    return energy;
  }
}

///////////////////////////////////////////////////////////////////////////
//
// Mouse
// =====
// > follows the mouse
//
///////////////////////////////////////////////////////////////////////////
class Mouse extends Turtle {
  //
  // constructor
  // ===========
  //
  Mouse() {
    // like a normal turtle with a "turtle" shape
    super(new PVector(mouseX, mouseY), color(0, 0, 255), "Turtle.png");
  }

  //
  // go
  // ==
  // > follows the mouse
  //
  void go() {
    pos.x = mouseX;
    pos.y = mouseY;
  }

  //
  // display
  // =======
  // > like a normal turtle except it has no specific colour
  //
  void display() {
    translate(pos.x, pos.y);
    scale(size);
    noTint();
    image(shape, 0, 0);
    resetMatrix();
  }
}

///////////////////////////////////////////////////////////////////////////
//
// Robot
// =====
// > a generic robot
// > robots are turtles that are caracterized by:
//   - carryingFood = the current amount of food carried by the robot
//   - detectionRange = the radius of perception
//   - speed = the speed of movement
//   - fdOK = is the robot allowed to move in the current timestep?
//   - myBases = the robots know their bases
//   - brain = the memory of the agent (an array of 5 PVectors)
//   - friend = the colour of my team
//   - ennemy = the colour of the other team
//   - deathBurgers = number of burgers released when the agent dies
//   - bullets = the number of bullets
//   - fafs = the number of "fire and forget" missiles
//   - waiting = the delay before next possible shoot
//   - messages = the messages queue
//
///////////////////////////////////////////////////////////////////////////
class Robot extends Turtle {
  float carryingFood;     // carried food quantity
  int detectionRange;     // the range of perception
  float speed;            // the speed
  boolean fdOK;           // is the agent allowed to move in the current time step?
  ArrayList myBases;      // the bases of the agent
  Team team;              // the team of the agent
  PVector[] brain;        // memory of the agent
  int[] acquaintances;    // memory of the agent
  color friend;           // the color of my team
  color ennemy;           // the color of the ennemy
  int deathBurgers;       // number of burgers released when the agent dies
  int bullets;            // the number of bullets
  int fafs;               // the number of "fire and forget" missiles
  int waiting;            // delay before next possible shoot
  ArrayList<Message> messages;

  //
  // empty constructor
  // =================
  //
  Robot() {
  }

  //
  // constructor
  // ===========
  //
  // input
  // -----
  // p = the position of the robot
  // c = the colour of the robot
  // b = the list of bases of the team
  // t = the team of the robot
  // img = the image for the display of the agent
  //
  Robot(PVector p, color c, ArrayList b, Team t, String img) {
    // robot is a turtle
    super(p, c, img);
    // initialize friend and ennemy colours
    if (c == green) {
      friend = green;
      ennemy = red;
    } else {
      friend = red;
      ennemy = green;
    }
    // my bases are b
    myBases = b;
    // my team is t
    team = t;
    // create acquaintances
    acquaintances = new int[5];
    for (int i=0; i<acquaintances.length; i++)
      acquaintances[i] = -1;
    // create a new brain
    brain = new PVector[5];
    for (int i=0; i<brain.length; i++)
      brain[i] = new PVector();
    // initially no carried food
    carryingFood = 0;
    // allowed to move
    fdOK = true;
    // no bullets nor fafs
    bullets = fafs = waiting = 0;
    // empty message queue
    messages = new ArrayList<Message>();
  }

  //
  // display
  // =======
  // > displays the agent
  //
  void display() {
    // display the image of the agent
    super.display();

    // add informations about the state of the robot
    fill(255);
    switch(display) {
    case BRAIN0:
    case BRAIN1:
    case BRAIN2:
    case BRAIN3:
    case BRAIN4:
      text("("+brain[display-BRAIN0].x+","+brain[display-BRAIN0].y+","+brain[display-BRAIN0].z+")", pos.x, pos.y);
      break;
    case ENERGY:
      fill(255);
      text(int(energy), pos.x, pos.y);
      break;
    case C_FOOD:
      fill(255);
      text(int(carryingFood), pos.x, pos.y);
      break;
    case MISSILES:
      if ((breed == LAUNCHER) || (breed == BASE)) {
        fill(255);
        text("(" + bullets + " / " + fafs + ")", pos.x, pos.y);
      }
      break;
    }
    // add (or not) a white circle to visualize the range of perception
    if (displayRange) {
      stroke(255);
      noFill();
      ellipse(pos.x, pos.y, 2 * detectionRange * patchSize, 2 * detectionRange * patchSize);
    }
  }

  //
  // prepareToGo
  // ===========
  // > called at the beginning of a timestep to prepare the activation of the agent
  //
  void prepareToGo() {
    super.prepareToGo();
    // the robot is again allowed to move
    fdOK = true;
  }

  //
  // leavePatch
  // ==========
  // > remove the robot from its current patch
  //
  void leavePatch() {
    game.patches[int(pos.x / patchSize)][int(pos.y / patchSize)].removeRobot(this);
  }

  //
  // die
  // ===
  // > kill the robot
  //
  void die() {
    // destruction generates debris
    game.generateBurgers(pos, deathBurgers);
    // the robot is killed
    game.killBot(this);
  }

  //
  // randomMove
  // ==========
  // > make a random move
  //
  // input
  // -----
  // angle = the possible variation around current heading (in degrees)
  //
  void randomMove(float angle) {
    // randomly computes the new heading
    heading += random(-radians(angle), radians(angle));
    // if the environment is free ahead of the robot
    if (freeAhead(speed, collisionAngle))
    // move forward at full speed
    forward(speed);
  }

  //
  // forward
  // =======
  // > move forward
  //
  // input
  // -----
  // dist = the distance
  //
  void forward(float dist) {
    // if the robot has not moved yet in the current timestep
    if (fdOK) {
      // it has moved!
      fdOK = false;
      // robot is not allowed to move faster than speed
      dist = min(dist, speed);

      // check if there are robots ahead
      Robot bob = (Robot)game.minDist(this, game.perceiveRobotsInCone(this, collisionAngle, dist));
      float dBob = game.w;
      if (bob != null)
      dBob = distance(bob);
      // check if there are walls ahead
      Wall wally = (Wall)game.minDist(this, game.perceiveWallsInCone(this, collisionAngle, dist));
      float dWally= game.w;
      if (wally != null)
      dWally = distance(wally);

      // if there is a wall and closer than bob
      if ((wally != null) && (dWally < dBob)) {
        // the moving robot is damaged
        energy -= botCollisionDamage;
        // the wall is damaged
        wally.energy -= botCollisionDamage;
      } else if (bob != null) {
        // if there is a base ahead
        if (bob.breed == BASE) {
          // the moving robot is destroyed
          energy = 0;
          // the base ahead is damaged
          bob.energy -= baseCollisionDamage;
        } else {
          // the moving robot is damaged
          energy -= botCollisionDamage;
          // the robot ahead is damaged
          bob.energy -= botCollisionDamage;
        }
      } else {
        // no obstacles ahead, the robot can move forward
        game.forward(this, dist);
        // when moving, it can crush seeds at that position
        if (breed != HARVESTER)
        game.crushSeeds(pos);
      }
    }
  }

  //
  // backward
  // =======
  // > move backward
  //
  // input
  // -----
  // dist = the distance
  //
  void backward(float dist) {
    // if the robot has not moved yet in the current timestep
    if (fdOK) {
      // it has moved!
      fdOK = false;
      // robot is not allowed to move faster than speed
      dist = min(dist, speed);

      // check if there are robots ahead
      heading = (heading + 180) % 360;
      Robot bob = (Robot)game.minDist(this, game.perceiveRobotsInCone(this, collisionAngle, dist));
      float dBob = game.w;
      if (bob != null)
      dBob = distance(bob);
      // check if there are walls ahead
      Wall wally = (Wall)game.minDist(this, game.perceiveWallsInCone(this, collisionAngle, dist));
      float dWally= game.w;
      if (wally != null)
      dWally = distance(wally);

      // if there is a wall and closer than bob
      if ((wally != null) && (dWally < dBob)) {
        // the moving robot is damaged
        energy -= botCollisionDamage;
        // the wall is damaged
        wally.energy -= botCollisionDamage;
      } else if (bob != null) {
        // if there is a base ahead
        if (bob.breed == BASE) {
          // the moving robot is destroyed
          energy = 0;
          // the base ahead is damaged
          bob.energy -= baseCollisionDamage;
        } else {
          // the moving robot is damaged
          energy -= botCollisionDamage;
          // the robot ahead is damaged
          bob.energy -= botCollisionDamage;
        }
      } else {
        // no obstacles ahead, the robot can move forward
        game.backward(this, dist);
        // when moving, it can crush seeds at that position
        if (breed != HARVESTER)
        game.crushSeeds(pos);
      }
      heading = (heading + 180) % 360;
    }
  }

  //
  // freeAhead
  // =========
  // > checks if the way is free ahead
  //
  // input
  // -----
  // dist = the distance
  //
  // output
  // ------
  // true if the way is free ahead in a cone of size dist and aperture collisionAngle
  //
  boolean freeAhead(float dist) {
    return game.freeAhead(this, dist, collisionAngle);
  }

  //
  // freeAhead
  // =========
  // > checks if the way is free ahead
  //
  // input
  // -----
  // dist = the distance
  // angle = the aperture of the cone (in degrees)
  //
  // output
  // ------
  // true if the way is free ahead in a cone of size dist and aperture angle
  //
  boolean freeAhead(float dist, float angle) {
    return game.freeAhead(this, dist, angle);
  }

  //
  // freePatch
  // =========
  // > search a free patch around the robot
  //
  // output
  // ------
  // returns free patch (or null if none has been found)
  //
  PVector freePatch() {
    PVector p = null;      // a position
    boolean ok = false;    // has a free patch been found ?
    float angle;           // a direction
    int i = 0;             // the number of tries

    // while a free patch has not been found and less than 10 tries
    while (!ok && (i<10)) {
      // choose a random angle
      angle = random(TWO_PI);
      // compute the corresponding position
      p = new PVector(pos.x + patchSize * cos(angle), pos.y + patchSize * sin(angle));
      // if the patch is free, we found what we were looking for
      if (game.freePatch(p))
      ok = true;
      // else we iterate
      i++;
    }
    // if a free patch has been found, return the corresponding position
    if (ok)
    return p;
    else
      return null;
  }

  //
  // patchesInRadius
  // ===============
  // > returns the list of patches in a given radius around the robot
  //
  // output
  // ------
  // the list of patches in radius detectionRange around the robot
  //
  ArrayList patchesInRadius() {
    return game.patchesInRadius(this, detectionRange);
  }

  //
  // perceiveRobots
  // ==============
  // > returns the list of robots perceived by the robot
  //
  // output
  // ------
  // the list of robots in radius detectionRange around the robot
  //
  ArrayList perceiveRobots() {
    return game.perceiveRobots(this);
  }

  //
  // perceiveRobots
  // ==============
  // > returns the list of robots of a given colour perceived by the robot
  //
  // input
  // -----
  //  c = the colour of robots that we are looking for
  //
  // output
  // ------
  // the list of robots of colour c in radius detectionRange around the robot
  //
  ArrayList perceiveRobots(color c) {
    return game.perceiveRobots(this, c);
  }

  //
  // perceiveRobots
  // ==============
  // > returns the list of robots of a given colour perceived by the robot
  //
  // input
  // -----
  // > c = the colour of robots that we are looking for
  // > b = the breed of robots that we are looking for
  //
  // output
  // ------
  // the list of robots of colour c and breed b in radius detectionRange around the robot
  //
  ArrayList perceiveRobots(color c, int b) {
    return game.perceiveRobots(this, c, b);
  }

  //
  // perceiveRobotsInCone
  // ====================
  // > returns the list of robots in a given cone perceived by the robot
  //
  // input
  // -----
  // > a = the aperture of the cone (in degrees)
  //
  // output
  // ------
  // the list of robots in a cone of size detectionRange and aperture a in front of the robot
  //
  ArrayList perceiveRobotsInCone(float a) {
    return game.perceiveRobotsInCone(this, a);
  }

  //
  // perceiveRobotsInCone
  // ====================
  // > returns the list of robots of a given colour in a given cone perceived by the robot
  //
  // input
  // -----
  // > a = the aperture of the cone (in degrees)
  // > c = the colour of robots that we are looking for
  //
  // output
  // ------
  // the list of robots of colour c in a cone of size detectionRange and aperture a
  // in front of the robot
  //
  ArrayList perceiveRobotsInCone(float a, color c) {
    return game.perceiveRobotsInCone(this, a, c);
  }

  //
  // perceiveRobotsInCone
  // ====================
  // > returns the list of robots of a given colour and a given breed
  // in a given cone perceived by the robot
  //
  // input
  // -----
  // > a = the aperture of the cone (in degrees)
  // > c = the colour of robots that we are looking for
  // > b = the breed of robots that we are looking for
  //
  // output
  // ------
  // the list of robots of colour c and breed b in a cone of size detectionRange and aperture a
  // in front of the robot
  //
  ArrayList perceiveRobotsInCone(float a, color c, int b) {
    return game.perceiveRobotsInCone(this, a, c, b);
  }

  //
  // perceiveRobotsInCone
  // ====================
  // > returns the list of robots in a given cone perceived by the robot
  //
  // input
  // -----
  // > a = the aperture of the cone (in degrees)
  // > d = the size of the cone
  //
  // output
  // ------
  // the list of robots in a cone of size d and aperture a in front of the robot
  //
  ArrayList perceiveRobotsInCone(float a, float d) {
    return game.perceiveRobotsInCone(this, a, d);
  }

  //
  // perceiveRobotsInCone
  // ====================
  // > returns the list of robots of a given colour in a given cone perceived by the robot
  //
  // input
  // -----
  // > a = the aperture of the cone (in degrees)
  // > d = the size of the cone
  // > c = the colour of robots that we are looking for
  //
  // output
  // ------
  // the list of robots of colour c in a cone of size d and aperture a
  // in front of the robot
  //
  ArrayList perceiveRobotsInCone(float a, float d, color c) {
    return game.perceiveRobotsInCone(this, a, d, c);
  }

  //
  // perceiveRobotsInCone
  // ====================
  // > returns the list of robots of a given colour and a given breed
  // in a given cone perceived by the robot
  //
  // input
  // -----
  // > a = the aperture of the cone (in degrees)
  // > d = the size of the cone
  // > c = the colour of robots that we are looking for
  // > b = the breed of robots that we are looking for
  //
  // output
  // ------
  // the list of robots of colour c and breed b in a cone of size d and aperture a
  // in front of the robot
  //
  ArrayList perceiveRobotsInCone(float a, float d, color c, int b) {
    return game.perceiveRobotsInCone(this, a, d, c, b);
  }

  //
  // perceiveSeeds
  // =============
  // > returns the list of seeds perceived by the robot
  //
  // input
  // -----
  // > c = the colour of seeds that we are looking for
  //
  // output
  // ------
  // the list of seeds in radius detectionRange around the robot
  //
  ArrayList perceiveSeeds(color c) {
    return game.perceiveSeeds(this, c);
  }

  //
  // perceiveSeedsInCone
  // ===================
  // > returns the list of seeds in a given cone perceived by the robot
  //
  // input
  // -----
  // > a = the aperture of the cone (in degrees)
  // > c = the colour of seeds that we are looking for
  //
  // output
  // ------
  // the list of seeds of colour c in a cone of size detectionRange and aperture a
  // in front of the robot
  //
  ArrayList perceiveSeedsInCone(float a, color c) {
    return game.perceiveSeedsInCone(this, a, c);
  }

  //
  // perceiveBurgers
  // ===============
  // > returns the list of burgers perceived by the robot
  //
  // output
  // ------
  // the list of burgers in radius detectionRange around the robot
  //
  ArrayList perceiveBurgers() {
    return game.perceiveBurgers(this);
  }

  //
  // perceiveBurgersInCone
  // =====================
  // > returns the list of burgers in a given cone perceived by the robot
  //
  // input
  // -----
  // > a = the aperture of the cone (in degrees)
  //
  // output
  // ------
  // the list of burgers in a cone of size detectionRange and aperture a in front of the robot
  //
  ArrayList perceiveBurgersInCone(float a) {
    return game.perceiveBurgersInCone(this, a);
  }

  //
  // perceiveWalls
  // =============
  // > returns the list of walls perceived by the robot
  //
  // output
  // ------
  // the list of walls in radius detectionRange around the robot
  //
  ArrayList perceiveWalls() {
    return game.perceiveWalls(this);
  }

  //
  // perceiveWallsInCone
  // ===================
  // > returns the list of walls in a given cone perceived by the robot
  //
  // input
  // -----
  // > a = the aperture of the cone (in degrees)
  //
  // output
  // ------
  // the list of walls in a cone of size detectionRange and aperture a in front of the robot
  //
  ArrayList perceiveWallsInCone(float a) {
    return game.perceiveWallsInCone(this, a);
  }

  //
  // perceiveFafs
  // ============
  // > returns the list of "fire and forget" (aka faf) missiles perceived by the robot
  //
  // output
  // ------
  // the list of fafs in radius detectionRange around the robot
  //
  ArrayList perceiveFafs() {
    return game.perceiveFafs(this);
  }

  //
  // perceiveFafsInCone
  // ==================
  // > returns the list of "fire and forget" (aka faf) in a given cone perceived by the robot
  //
  // input
  // -----
  // > a = the aperture of the cone (in degrees)
  //
  // output
  // ------
  // the list of fafs in a cone of size detectionRange and aperture a in front of the robot
  //
  ArrayList perceiveFafsInCone(float a) {
    return game.perceiveFafsInCone(this, a);
  }

  //
  // oneOf
  // =====
  // > returns a randomly chosen turtle from a set of turtles
  //
  // input
  // -----
  // > agentSet = the set of turtles
  //
  // output
  // ------
  // a turtle of the set
  //
  Turtle oneOf(ArrayList agentSet) {
    return game.oneOf(agentSet);
  }

  //
  // minDist
  // =======
  // > returns the closest turtle from a set of turtles
  //
  // input
  // -----
  // > agentSet = the set of turtles
  //
  // output
  // ------
  // the closest turtle of the set
  //
  Turtle minDist(ArrayList agentSet) {
    return game.minDist(this, agentSet);
  }

  //
  // incrementCarryingFood
  // =====================
  // > increments the amount of food carried by the robot
  //
  // input
  // -----
  // > nrj = the amount of food collected
  //
  void incrementCarryingFood(float nrj) {
    carryingFood += nrj;
  }

  //
  // resetWaiting
  // ============
  // > resets the delay between 2 shoots (see Base and RocketLauncher)
  //
  void resetWaiting() {
  }

  //
  // sendMessage
  // ===========
  // > sends a generic message to another robot
  //
  // input
  // -----
  // > bob = the receiver
  // > type = the type of message
  // > args = the list of arguments for the message
  //
  void sendMessage(Robot bob, int type, float[] args) {
    // if bob exists and distance less than max range
    if ((bob != null) && (distance(bob) < messageRange)) {
      // create the message...
      Message msg = new Message(type, who, bob.who, args);
      // ...and add it to bob's messages queue
      bob.messages.add(msg);
    }
  }

  //
  // sendMessage
  // ===========
  // > sends a generic message to another robot
  //
  // input
  // -----
  // > bob = the id (who) of the receiver
  // > type = the type of message
  // > args = the list of arguments for the message
  //
  void sendMessage(int id, int type, float[] args) {
    Robot bob = game.getRobot(id);
    // if bob exists and distance less than max range
    if ((bob != null) && (distance(bob) < messageRange)) {
      // create the message...
      Message msg = new Message(type, who, bob.who, args);
      // ...and add it to bob's messages queue
      bob.messages.add(msg);
    }
  }

  //
  // askForEnergy
  // ============
  // > sends a ASK_FOR_ENERGY message to a base
  //
  // input
  // -----
  // > bob = the receiver
  // > qty = the amount of energy requested
  //
  void askForEnergy(Robot bob, float qty) {
    // check that bob is a base and distance is less than max range
    if ((bob != null) && (bob.breed == BASE) && (distance(bob) < messageRange)) {
      // build the message...
      float[] args = new float[1];
      args[0] = qty;
      Message msg = new Message(ASK_FOR_ENERGY, who, bob.who, args);
      // ...and add it to bob's messages queue
      bob.messages.add(msg);
    }
  }

  //
  // askForEnergy
  // ============
  // > sends a ASK_FOR_ENERGY message to a base
  //
  // input
  // -----
  // > bob = the id (who) of the receiver
  // > qty = the amount of energy requested
  //
  void askForEnergy(int id, float qty) {
    Robot bob = game.getRobot(id);
    // check that bob is a base and distance is less than max range
    if ((bob != null) && (bob.breed == BASE) && (distance(bob) < messageRange)) {
      // build the message...
      float[] args = new float[1];
      args[0] = qty;
      Message msg = new Message(ASK_FOR_ENERGY, who, bob.who, args);
      // ...and add it to bob's messages queue
      bob.messages.add(msg);
    }
  }

  //
  // askForBullets
  // =============
  // > sends a ASK_FOR_BULLETS message to a base
  //
  // input
  // -----
  // > bob = the receiver
  // > qty = the amount of bullets requested
  //
  void askForBullets(Robot bob, int qty) {
    // check that bob is a base and distance is less than max range
    if ((bob != null) && (bob.breed == BASE) && (distance(bob) < messageRange)) {
      // build the message...
      float[] args = new float[1];
      args[0] = qty;
      Message msg = new Message(ASK_FOR_BULLETS, who, bob.who, args);
      // ...and add it to bob's messages queue
      bob. messages.add(msg);
    }
  }

  //
  // askForBullets
  // =============
  // > sends a ASK_FOR_BULLETS message to a base
  //
  // input
  // -----
  // > bob = the id (who) of the receiver
  // > qty = the amount of bullets requested
  //
  void askForBullets(int id, int qty) {
    Robot bob = game.getRobot(id);
    // check that bob is a base and distance is less than max range
    if ((bob != null) && (bob.breed == BASE) && (distance(bob) < messageRange)) {
      // build the message...
      float[] args = new float[1];
      args[0] = qty;
      Message msg = new Message(ASK_FOR_BULLETS, who, bob.who, args);
      // ...and add it to bob's messages queue
      bob. messages.add(msg);
    }
  }

  //
  // informAboutFood
  // ===============
  // > sends a INFORM_ABOUT_FOOD message to another robot
  //
  // input
  // -----
  // > bob = the receiver
  // > p = the position of the food
  //
  void informAboutFood(Robot bob, PVector p) {
    // if bob exists and distance less than max range
    if ((bob != null) && (distance(bob) < messageRange)) {
      // build the message...
      float[] args = new float[2];
      args[0] = p.x;
      args[1] = p.y;
      Message msg = new Message(INFORM_ABOUT_FOOD, who, bob.who, args);
      // ...and add it to bob's messages queue
      bob.messages.add(msg);
    }
  }

  //
  // informAboutFood
  // ===============
  // > sends a INFORM_ABOUT_FOOD message to another robot
  //
  // input
  // -----
  // > bob = the id (who) of the receiver
  // > p = the position of the food
  //
  void informAboutFood(int id, PVector p) {
    Robot bob = game.getRobot(id);
    // if bob exists and distance less than max range
    if ((bob != null) && (distance(bob) < messageRange)) {
      // build the message...
      float[] args = new float[2];
      args[0] = p.x;
      args[1] = p.y;
      Message msg = new Message(INFORM_ABOUT_FOOD, who, bob.who, args);
      // ...and add it to bob's messages queue
      bob.messages.add(msg);
    }
  }

  //
  // informAboutXYTarget
  // ===================
  // > sends a INFORM_ABOUT_XYTARGET message to another robot
  //
  // input
  // -----
  // > bob = the receiver
  // > p = the position of the target
  //
  void informAboutXYTarget(Robot bob, PVector p) {
    // if bob exists and distance less than max range
    if ((bob != null) && (distance(bob) < messageRange)) {
      // build the message...
      float[] args = new float[2];
      args[0] = p.x;
      args[1] = p.y;
      Message msg = new Message(INFORM_ABOUT_XYTARGET, who, bob.who, args);
      // ...and add it to bob's messages queue
      bob.messages.add(msg);
    }
  }

  //
  // informAboutXYTarget
  // ===================
  // > sends a INFORM_ABOUT_XYTARGET message to another robot
  //
  // input
  // -----
  // > bob = the id (who) of the receiver
  // > p = the position of the target
  //
  void informAboutXYTarget(int id, PVector p) {
    Robot bob = game.getRobot(id);
    // if bob exists and distance less than max range
    if ((bob != null) && (distance(bob) < messageRange)) {
      // build the message...
      float[] args = new float[2];
      args[0] = p.x;
      args[1] = p.y;
      Message msg = new Message(INFORM_ABOUT_XYTARGET, who, bob.who, args);
      // ...and add it to bob's messages queue
      bob. messages.add(msg);
    }
  }

  //
  // informAboutTarget
  // =================
  // > sends a INFORM_ABOUT_TARGET message to another robot
  //
  // input
  // -----
  // > bob = the receiver
  // > target = the target robot
  //
  void informAboutTarget(Robot bob, Robot target) {
    // check that bob and target both exist and distance less than max range
    if ((bob != null) && (target != null) && (distance(bob) < messageRange)) {
      // build the message...
      float[] args = new float[4];
      args[0] = target.pos.x;
      args[1] = target.pos.y;
      args[2] = target.breed;
      args[3] = target.who;
      Message msg = new Message(INFORM_ABOUT_TARGET, who, bob.who, args);
      // ...and add it to bob's messages queue
      bob. messages.add(msg);
    }
  }

  //
  // informAboutTarget
  // =================
  // > sends a INFORM_ABOUT_TARGET message to another robot
  //
  // input
  // -----
  // > bob = the id (who) of the receiver
  // > target = the target robot
  //
  void informAboutTarget(int id, Robot target) {
    Robot bob = game.getRobot(id);
    // check that bob and target both exist and distance less than max range
    if ((bob != null) && (target != null) && (distance(bob) < messageRange)) {
      // build the message...
      float[] args = new float[4];
      args[0] = target.pos.x;
      args[1] = target.pos.y;
      args[2] = target.breed;
      args[3] = target.who;
      Message msg = new Message(INFORM_ABOUT_TARGET, who, bob.who, args);
      // ...and add it to bob's messages queue
      bob. messages.add(msg);
    }
  }

  //
  // flushMessages
  // =============
  // > clear the messages queue of the robot
  //
  void flushMessages() {
    messages.clear();
  }
}

///////////////////////////////////////////////////////////////////////////
//
// Base
// ====
// > bases are robots that are caracterized by:
//   - createOK = is the base allowed to create a new robot in the current
//     timeStep ?
// > bases can:
//   - create new robots
//   - create new walls
//   - fire "faf" missiles
//   - reload other robots in energy
//   - reload rocket launchers in bullets
// > bases cannot move
//
///////////////////////////////////////////////////////////////////////////
class Base extends Robot {
  boolean createOK;

  //
  // constructor
  // ===========
  //
  // input
  // -----
  // p = the position of the base
  // c = the colour of the base
  // t = the team of the base
  //
  Base(PVector p, color c, Team t) {
    // a base is a robot
    super(p, c, null, t, "Base.png");
    // of type BASE
    breed = BASE;
    // it can create robots at next timestep
    createOK = true;
    // it cannot move
    fdOK = false;
    // specific parameters
    energy = baseNrj;
    detectionRange = basePerception;
    speed = baseSpeed;
    metabolism = baseMetabolism;
    deathBurgers = baseBurgers;
    // creation of the brain (bases have a larger brain than other robots)
    brain = new PVector[10];
    for (int i=0; i<brain.length; i++)
    brain[i] = new PVector();
  }

  //
  // setPosition
  // ===========
  // > change the position of the base
  //
  // input
  // -----
  // > p = the new position (inside a box (0,0)-(game.w2, game.h))
  //
  void setPosition(PVector p) {
    // if the colour of the base is green, the position is kept unchanged
    if (colour == green)
    pos.x = p.x;
    // if the colour of the base is red, the position is shifted by game.w2
    // (half the width of the environment)
    else
      pos.x = game.w2 + p.x;
    pos.y = p.y;
  }

  //
  // display
  // =======
  // > displays the base
  //
  void display() {
    // standard turtle display
    super.display();
    // add informations about the state of the base
    fill(255);
    switch(display) {
    case BRAIN0:
    case BRAIN1:
    case BRAIN2:
    case BRAIN3:
    case BRAIN4:
    case BRAIN5:
    case BRAIN6:
    case BRAIN7:
    case BRAIN8:
    case BRAIN9:
      text("("+brain[display-BRAIN0].x+","+brain[display-BRAIN0].y+","+brain[display-BRAIN0].z+")", pos.x, pos.y);
      break;
    case ENERGY:
      fill(255);
      text(int(energy), pos.x, pos.y);
      break;
    case C_FOOD:
      fill(255);
      text(int(carryingFood), pos.x, pos.y);
      break;
    case MISSILES:
      fill(255);
      text(int(energy), pos.x, pos.y);
      break;
    }
    // add (or not) a white circle to visualize the range of perception
    if (displayRange) {
      stroke(255);
      noFill();
      ellipse(pos.x, pos.y, 2 * detectionRange * patchSize, 2 * detectionRange * patchSize);
    }
  }

  //
  // prepareToGo
  // ===========
  // > called at the beginning of a timestep to prepare the activation of the base
  //
  void prepareToGo() {
    // a base is a robot
    super.prepareToGo();
    // the base can create a robot at next timestep
    createOK = true;
    // decrements the delay before next shoot
    if (waiting > 0)
    waiting--;
    // food collected is tranformed into energy...
    energy += carryingFood;
    carryingFood = 0;
  }

  //
  // die
  // ===
  // > kill the base
  //
  void die() {
    // destruction generates debris
    game.generateBurgers(pos, deathBurgers);
    // specific actions to kill a base
    game.killBase(this);
  }

  //
  // launchBullet
  // ============
  // > launch a bullet
  //
  // input
  // -----
  // > a = the direction in which the bullet is launched
  //
  void launchBullet(float a) {
    game.launchBullet(this, a);
  }

  //
  // launchFaf
  // =========
  // > launch a faf
  //
  // input
  // -----
  // > bob = the target robot
  //
  void launchFaf(Robot bob) {
    game.launchFaf(this, bob);
  }

  //
  // resetWaiting
  // ============
  // > resets the delay before next shoot
  //
  void resetWaiting() {
    waiting = baseWaiting;
  }

  //
  // foodToEnergy
  // ============
  // > converts food into energy
  //
  void foodToEnergy() {
    energy += carryingFood;
    carryingFood = 0;
  }

  //
  // giveEnergy
  // ==========
  // > gives energy to a robot
  //
  // input
  // -----
  // > agt = the id of the robot
  // > nrj = the amount of energy that is requested
  //
  void giveEnergy(int agt, float nrj) {
    // get the robot of id "agt"
    Robot bob = game.getRobot(agt);
    // if bob exists
    if (bob != null) {
      // if bob is close enough and the energy of the base is sufficient
      if ((game.distance(this, bob) <= 2) && (nrj > 0) && (nrj <= energy)) {
        // transfers some energy to bob
        bob.energy += nrj;
        energy -= nrj;
      }
    }
  }

  //
  // newBullets
  // ==========
  // > creates new bullets
  //
  // input
  // -----
  // > qty = the number of bullets to create
  //
  void newBullets(int qty) {
    // the total amount of bullets cannot be more than baseMaxBullets
    int nb = min(qty, baseMaxBullets - bullets);
    // if the energy of the base is sufficient
    if (energy >= bulletCost * nb) {
      // create the bullets
      bullets += nb;
      energy -= bulletCost * nb;
    }
  }

  //
  // newFafs
  // =======
  // > creates new fafs
  //
  // input
  // -----
  // > qty = the number of fafs to create
  //
  void newFafs(int qty) {
    // the total amount of fafs cannot be more than baseMaxFafs
    int nb = min(qty, baseMaxFafs - fafs);
    // if the energy of the base is sufficient
    if (energy >= fafCost * nb) {
      // create the fafs
      fafs += nb;
      energy -= fafCost * nb;
    }
  }

  //
  // giveBullets
  // ===========
  // > give bullets to a rocket launcher
  //
  // input
  // -----
  // > agt = the id of the robot
  // > qty = the number of bullets to give
  //
  void giveBullets(int agt, float qty) {
    // get the robot of id "agt"
    Robot bob = game.getRobot(agt);
    // if bob exists and is a rocket launcher
    if ((bob != null) && (bob.breed == LAUNCHER)) {
      // if bob is close enough, doesn't request more than it can hold
      // and the energy of the base is sufficient
      if ((game.distance(this, bob) <= 2)
        && (qty >=0) && (bob.bullets + qty <= launcherMaxBullets)
        && (energy >= bulletCost * qty)) {
        // create new bullets and give them to bob
        bob.bullets += qty;
        energy -= bulletCost * qty;
      }
    }
  }

  //
  // newExplorer
  // ===========
  // > create a new explorer
  //
  // output
  // ------
  // true if creation is successfull
  //
  boolean newExplorer() {
    // if the energy is sufficient and the base is allowed to do so
    if ((energy > explorerCost) && createOK) {
      // ask for a free patch around
      PVector p = freePatch();
      // if one is found
      if (p != null) {
        // create a new explorer
        energy -= explorerCost;
        createOK = false;
        game.newExplorer(this, p);
        return true;
      }
    }
    return false;
  }

  //
  // newHarvester
  // ============
  // > create a new harvester
  //
  // output
  // ------
  // true if creation is successfull
  //
  boolean newHarvester() {
    // if the energy is sufficient and the base is allowed to do so
    if ((energy > harvesterCost) && createOK) {
      // ask for a free patch around
      PVector p = freePatch();
      // if one is found
      if (p != null) {
        // create a new harvester
        energy -= harvesterCost;
        createOK = false;
        game.newHarvester(this, p);
        return true;
      }
    }
    return false;
  }

  //
  // newRocketLauncher
  // =================
  // > create a new rocket launcher
  //
  // output
  // ------
  // true if creation is successfull
  //
  boolean newRocketLauncher() {
    // if the energy is sufficient and the base is allowed to do so
    if ((energy > launcherCost) && createOK) {
      // ask for a free patch around
      PVector p = freePatch();
      // if one is found
      if (p != null) {
        // create a new rocket launche
        energy -= launcherCost;
        createOK = false;
        game.newRocketLauncher(this, p);
        return true;
      }
    }
    return false;
  }

  //
  // newWall
  // =======
  // > create a new wall
  //
  // output
  // ------
  // true if creation is successfull
  //
  boolean newWall() {
    // if the energy is sufficient and the base is allowed to do so
    if ((energy > wallCost) && createOK) {
      // ask for a free patch around
      PVector p = freePatch();
      // if one is found
      if (p != null) {
        // create a new wall
        energy -= wallCost;
        game.newWall(p, colour);
        createOK = false;
        return true;
      }
    }
    return false;
  }

  //
  // recycle
  // =======
  // > recycle a robot
  //
  // input
  // -----
  // bob = the robot to recycle
  //
  void recycle(Robot bob) {
    // if bob exists
    if (bob != null) {
      // get some energy from bob
      energy += 1000 + bob.energy;
      // and remove bob
      game.killBot(bob);
    }
  }

  //
  // getEnergy
  // =========
  // > returns the amount of energy of the base to compute the score of the team
  //
  // output
  // ------
  // the energy of the base
  //
  float getEnergy() {
    // take into account the number of bullets and fafs in the energy of the base
    return energy + bullets * bulletCost + fafs * fafCost;
  }
}

///////////////////////////////////////////////////////////////////////////
//
// Explorer
// ========
// > explorers can:
//   - carry food
//
///////////////////////////////////////////////////////////////////////////
class Explorer extends Robot {
  //
  // constructor
  // ===========
  //
  // input
  // -----
  // p = the position of the explorer
  // c = the colour of the explorer
  // b = the list of bases of the team
  // t = the team of the explorer
  //
  Explorer(PVector pos, color c, ArrayList b, Team t) {
    // an explorer is a robot...
    super(pos, c, b, t, "Explorer.png");
    // ...of breed EXPLORER
    breed = EXPLORER;

    // specific initializations
    energy = explorerNrj;
    detectionRange = explorerPerception;
    speed = explorerSpeed;
    metabolism = explorerMetabolism;
    deathBurgers = explorerBurgers;
  }

  //
  // giveFood
  // ========
  //
  // input
  // -----
  // > bob = the robot to whom we give food
  // > qty = the amound of food given
  //
  void giveFood(Robot bob, float qty) {
    // we can only give food to a harvester, an explorer or the base
    if ((bob != null) && ((bob.breed == HARVESTER) || (bob.breed == EXPLORER) || (bob.breed == BASE))) {
      // if bob is next to us and we have enough food
      if ((game.distance(this, bob) <= 2) && (carryingFood >= qty)) {
        // transfer the food to bob
        carryingFood -= qty;
        bob.carryingFood += qty;
      }
    }
  }
}

///////////////////////////////////////////////////////////////////////////
//
// Harvester
// =========
// > harvesters can:
//   - collect food
//   - carry food
//   - carry walls
//
///////////////////////////////////////////////////////////////////////////
class Harvester extends Robot {
  boolean tfOK;
  float[] carriedWallsNrj;
  int nbWalls;

  //
  // constructor
  // ===========
  //
  // input
  // -----
  // p = the position of the explorer
  // c = the colour of the explorer
  // b = the list of bases of the team
  // t = the teamm of the harvester
  //
  Harvester(PVector pos, color c, ArrayList b, Team t) {
    // a harvester is a robot...
    super(pos, c, b, t, "Harvester.png");
    // ...of breed HARVESTER
    breed = HARVESTER;

    // specific initializations
    energy = harvesterNrj;
    detectionRange = harvesterPerception;
    speed = harvesterSpeed;
    metabolism = harvesterMetabolism;
    deathBurgers = harvesterBurgers;

    // the harvester can collect food at next timestep
    tfOK = true;
    // harvesters can carry up to 5 walls
    carriedWallsNrj = new float[5];
    nbWalls = 0;
  }

  //
  // prepareToGo
  // ===========
  // > called at the beginning of a timestep to prepare the activation of the harvester
  //
  void prepareToGo() {
    super.prepareToGo();
    tfOK = true;
  }

  //
  // switchTfOK
  // ==========
  // > change the value of tfOK (that conditions the fact to be allowed to collect food)
  //
  void switchTfOK() {
    tfOK = !tfOK;
  }

  //
  // plantSeed
  // =========
  // > plant a new seed at the position of the harvester
  //
  void plantSeed() {
    game.plantSeed(this, pos, colour);
  }

  //
  // takeFood
  // ========
  // > collect a burger
  //
  // input
  // -----
  // zorg = the burger to collect
  //
  void takeFood(Burger zorg) {
    game.takeFood(this, zorg);
  }

  //
  // giveFood
  // ========
  // > give some food to another robot
  //
  // input
  // -----
  // > bob = the robot to whom food is given
  // > qty = the amount of food that is given
  //
  void giveFood(Robot bob, float qty) {
    // if bob exists and is either another harvester or an explorer or a base
    if ((bob != null) && ((bob.breed == HARVESTER) || (bob.breed == EXPLORER) || (bob.breed == BASE))) {
      // no more than carryingFood
      int nb = (int)min(qty, carryingFood);
      // if bob is close enough and
      if (game.distance(this, bob) <= 2) {
        // transfer food to bob
        carryingFood -= nb;
        bob.carryingFood += nb;
      }
    }
  }

  //
  // takeWall
  // ========
  // > collect a wall
  //
  // input
  // -----
  // > wally = the wall to collect
  //
  void takeWall(Wall wally) {
    // if wally is a wall and no more than 5 walls already collected, and wally is close enough
    if ((wally.breed == WALL) && (nbWalls < 5) &&
      (game.distance(this, wally) <= 2)) {
      // collect wally...
      carriedWallsNrj[nbWalls] = wally.energy;
      nbWalls++;
      // ...and remove it from the environment
      game.removeWall(wally);
    }
  }

  //
  // dropWall
  // ========
  // > drop a wall
  //
  void dropWall() {
    // if at least one wall transported
    if (nbWalls > 0) {
      // ask for a free patch around
      PVector p = freePatch();
      // if one is found
      if (p != null) {
        // drop the last wall collected
        nbWalls--;
        game.newWall(p, colour, carriedWallsNrj[nbWalls]);
      }
    }
  }

  //
  // getEnergy
  // =========
  // > returns the amount of energy of the harvester to compute the score of the team
  //
  // output
  // ------
  // the energy of the harvester
  //
  float getEnergy() {
    // take into account the food collected in the energy of the harvester
    return energy + carryingFood;
  }
}

///////////////////////////////////////////////////////////////////////////
//
// RocketLauncher
// ==============
// > explorers can:
//   - launch bullets
//
///////////////////////////////////////////////////////////////////////////
class RocketLauncher extends Robot {
  //
  // constructor
  // ===========
  //
  // input
  // -----
  // p = the position of the explorer
  // c = the colour of the explorer
  // b = the list of bases of the team
  // t = the team of the rocket launcher
  //
  RocketLauncher(PVector pos, color c, ArrayList b, Team t) {
    // a rocket launcher is a robot...
    super(pos, c, b, t, "RLauncher.png");
    // ...of breed LAUNCHER
    breed = LAUNCHER;

    // specific initializations
    energy = launcherNrj;
    detectionRange = launcherPerception;
    speed = launcherSpeed;
    metabolism = launcherMetabolism;
    deathBurgers = launcherBurgers;
    bullets = launcherNbBullets;
  }

  //
  // prepareToGo
  // ===========
  // > called at the beginning of a timestep to prepare the activation of the rocket launcher
  //
  void prepareToGo() {
    super.prepareToGo();
    if (waiting > 0)
    waiting--;
  }

  //
  // launchBullet
  // ============
  // > launch a bullet
  //
  // input
  // -----
  // > a = the direction in which the bullet is launched
  //
  void launchBullet(float a) {
    game.launchBullet(this, a);
  }

  //
  // resetWaiting
  // ============
  // > resets the delay before next shoot
  //
  void resetWaiting() {
    waiting = launcherWaiting;
  }

  //
  // getEnergy
  // =========
  // > returns the amount of energy of the rocket launcher to compute the score of the team
  //
  // output
  // ------
  // the energy of the rocket launcher
  //
  float getEnergy() {
    // take into account the number of bullets in the energy of the rocket launcher
    return energy + bullets * bulletCost;
  }
}
