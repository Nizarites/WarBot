///////////////////////////////////////////////////////////////////////////
//
// Burger
// ======
// > a burger is food for the robots
// > burgers are considered as "turtles" (they have position, energy, etc.)
// > can be harvested by harvesters
// > can be transported by harvesters and explorers
// > can be transformed into energy by bases
//
///////////////////////////////////////////////////////////////////////////
class Burger extends Turtle {
  //
  // constructor
  // ===========
  // input
  // -----
  // > p = the position of the burger
  //
  Burger(PVector p) {
    // initialize the burger
    breed = BURGER;
    pos = new PVector(p.x, p.y);
    metabolism = burgerDecay;
    shape = loadImage("Burger.png");
    size = scale;
    energy = random(wildBurgerMinNrj, wildBurgerMaxNrj);
  }

  //
  // constructor
  // ===========
  // input
  // -----
  // > p = the position of the burger
  // > int, max = interval to chose the initial energy of the burger
  //
  Burger(PVector p, int min, int max) {
    // initialize the burger
    breed = BURGER;
    pos = new PVector(p.x, p.y);
    metabolism = burgerDecay;
    shape = loadImage("Burger.png");
    size = scale;
    energy = random(min, max);
  }

  //
  // go
  // ==
  // implements the decay of burgers
  //
  void go() {
    // energy is decremented
    energy -= metabolism;
  }

  //
  // display
  // =======
  // > to display the burger in the simulation window
  //
  void display() {
    translate(pos.x, pos.y);
    scale(size / 3);
    noTint();
    image(shape, 0, 0);
    resetMatrix();
  }
}

///////////////////////////////////////////////////////////////////////////
//
// Seed
// ====
// > a seed is a cultivated burger
// > burgers can be used as seeds to produce new burgers
//
///////////////////////////////////////////////////////////////////////////
class Seed extends Turtle {
  // the age of the seed
  int age;

  //
  // constructor
  // ===========
  // input
  // -----
  // > p = the position of the seed
  // > c = the color of the seed
  //
  Seed(PVector p, color c) {
    // initialize the seed
    breed = SEED;
    pos = new PVector(p.x, p.y);
    colour = c;
    age = 0;
    energy = 100;
  }

  //
  // go
  // ==
  // implements the growing of seeds and transformation into burgers
  //
  void go() {
    // age is incremented
    age++;

    // when ages reaches maturation time
    if (age >= maturationTime) {
      // the seed is transformed into a new burger
      Burger b = new Burger(pos, domesticBurgerMinNrj, domesticBurgerMaxNrj);
      // the burger is added to the game
      game.addBurger(b);
      // the energy is set to 0 so that the seed is destroyed at the next timestep
      energy = 0;
    }
  }

  //
  // display
  // =======
  // > to display the seed in the simulation window
  //
  void display() {
    // use a colour scale from black to either red or green 
    if (colour == red)
      fill(int(255.0 * age / maturationTime), 0, 0);
    else
      fill(0, int(255.0 * age / maturationTime), 0);

    // no outline
    noStroke();
    // draw the seed as an ellipse 
    ellipse(pos.x, pos.y, 5, 5);
  }
}

///////////////////////////////////////////////////////////////////////////
//
// Wall
// ====
// > a wall is an obstacle
// > walls can be produced by bases
// > walls can be transported by harvesters
//
///////////////////////////////////////////////////////////////////////////
class Wall extends Turtle {
  //
  // constructor
  // ===========
  // input
  // -----
  // > p = the position of the wall
  // > c = the color of the wall
  //
  Wall(PVector p, color c) {
    // initialize the wall
    breed = WALL;
    pos = new PVector(p.x, p.y);
    energy = wallNrj;
    shape = loadImage("Wall.png");
    size = 2 * scale;
    colour = c;
  }

  //
  // display
  // =======
  // > to display the wall in the simulation window
  //
  void display() {
    translate(pos.x, pos.y);
    scale(size / 3);
    noTint();
    image(shape, 0, 0);
    resetMatrix();
  }
}

///////////////////////////////////////////////////////////////////////////
//
// Missile
// =======
// > abstract class for bullets and fafs
//
///////////////////////////////////////////////////////////////////////////
class Missile extends Robot {
  // the range of the missile
  float range;
}

///////////////////////////////////////////////////////////////////////////
//
// Bullet
// ======
// > simple ammunitions
//
///////////////////////////////////////////////////////////////////////////
class Bullet extends Missile {
  //
  // constructor
  // ===========
  // input
  // -----
  // > p = the position of the bullet
  // > angle = the angle of motion
  //
  Bullet(PVector p, float angle) {
    // the bullet is shifted from the position of the shooter to avoid self hits
    pos = new PVector(p.x + 0.5 * cos(angle) * patchSize, p.y + 0.5 * sin(angle) * patchSize);
    game.wrapPosition(pos);
    heading = angle;
    energy = 100;
    range = bulletRange;
    speed = bulletSpeed;
    // in fact, the hit range
    detectionRange = 1;
    shape = null;
  }

  //
  // go
  // ==
  // implements the motion of the bullet and tests hits
  //
  void go() {
    // get the closest robot ahead of the bullet
    Robot bob = (Robot)minDist(game.perceiveRobotsInCone(this, HALF_PI));
    if (bob != null) {
      // if there is one, the damage depends on the robot
      if (bob.breed == BASE)
        bob.energy -= bulletDamageToBase;
      else
        bob.energy -= bulletDamageToRobot;
      // the energy of the bullet is set to 0 so that the bullet is cleared 
      // at next timestep
      energy = 0;
    } else {
      if (range < 0)
        // when the left range is 0, the bullet is cleared
        energy = 0;
      else {
        // else, the bullet travels in straight line
        pos.x += speed * patchSize * cos(heading);
        pos.y += speed * patchSize * sin(heading);
        range -= speed;
      }
    }
  }

  //
  // display
  // =======
  // > to display the bullet in the simulation window
  //
  void display() {
    // a white ellipse with no outline
    fill(255);
    noStroke();
    ellipse(pos.x, pos.y, 5, 5);
  }
}

///////////////////////////////////////////////////////////////////////////
//
// Faf
// ===
// > "fire and forget" ammunitions
// > fafs are drived towards a target
//
///////////////////////////////////////////////////////////////////////////
class Faf extends Missile {
  // the target of the missile
  Robot target;

  //
  // constructor
  // ===========
  // input
  // -----
  // > p = the position of the faf
  // > bob = the target of the faf 
  //
  Faf(PVector p, Robot bob) {
    // initialize the target
    target = bob;
    // the bullet is shifted from the position of the shooter to avoid self hits
    pos = new PVector(p.x + 0.5 * cos(heading) * patchSize, p.y + 0.5 * sin(heading) * patchSize);
    game.wrapPosition(pos);

    energy = 100;
    range = fafRange;
    speed = fafSpeed;
    detectionRange = 1;
    breed = FAF;
    shape = null;
  }

  //
  // go
  // ==
  // implements the motion of the bullet and tests hits
  //
  void go() {
    // get the closest robot ahead of the bullet
    Robot bob = (Robot)minDist(game.perceiveRobotsInCone(this, HALF_PI));
    if (bob != null) {
      // if there is one, the damage depends on the robot
      if (bob.breed == BASE)
        bob.energy -= fafDamageToBase;
      else
        bob.energy -= fafDamageToRobot;
      // the energy of the faf is set to 0 so that the bullet is cleared 
      // at next timestep
      energy = 0;
    } else {
      if (range < 0)
        // when the left range is 0, the faf is cleared
        energy = 0;
      else {
        // else, the faf travels towards the target
        heading = towards(target);
        pos.x += speed * patchSize * cos(heading);
        pos.y += speed * patchSize * sin(heading);
        range -= speed;
      }
    }
  }

  //
  // display
  // =======
  // > to display the faf in the simulation window
  //
  void display() {
    // a yellow ellipse with no outline
    fill(255, 255, 0);
    noStroke();
    ellipse(pos.x, pos.y, 5, 5);
  }
}
