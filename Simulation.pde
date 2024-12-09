///////////////////////////////////////////////////////////////////////////
//
// Simulation
// ==========
// > the main class used to handle the game
//
///////////////////////////////////////////////////////////////////////////
class Simulation {
  // the number of ticks ellapsed since beginning of the game
  int ticks;
  // the number of turtles (to assign a unique id)
  int nbTurtles;
  // dimensions of the game
  float w, h;
  // half dimensions of the game (to compute wrapping)
  float w2, h2;

  // the environment, divided into patches
  Patch[][] patches;
  // the bases of each colour (so that each robot knows its own bases) 
  ArrayList<Base> greenBases;
  ArrayList<Base> redBases;
  // the robots
  ArrayList<Robot> robots;
  // used to randomize the order of activation of robots at each timestep
  ArrayList<Robot> schedule;
  // the ressources
  ArrayList<Missile> missiles;
  ArrayList<Burger> burgers;
  ArrayList<Seed> seeds;
  ArrayList<Wall> walls;

  // to display the graph of energy of each team
  float[] greenNrj, redNrj;
  float maxNrj;

  //
  // constructor
  // ===========
  //
  Simulation() {
    // general initializations
    ticks = 0;
    nbTurtles = 0;
    w = width;
    h = height - 100;
    w2 = w / 2;
    h2 = h / 2;

    // initialization of the lists
    greenBases = new ArrayList<Base>();
    redBases = new ArrayList<Base>();
    robots = new ArrayList<Robot>();
    missiles = new ArrayList<Missile>();
    burgers = new ArrayList<Burger>();
    seeds = new ArrayList<Seed>();
    walls = new ArrayList<Wall>();

    // initializations for the graph
    greenNrj = new float[maxTicks];
    redNrj = new float[maxTicks];
    for (int i=0; i<maxTicks; i++)
      greenNrj[i] = redNrj[i] = -1;
    maxNrj = 0;
    // compute the first levels of energy of each team
    updateEnergy();
  }

  //
  // setup
  // =====
  // > creation of the different teams
  //
  void setup() {
    // creation of the patches
    println("Initialisation du jeu");
    patches = new Patch[nbPatchesX][nbPatchesY];
    for (int i=0; i<nbPatchesX; i++)
      for (int j=0; j<nbPatchesY; j++)
        patches[i][j] = new Patch(i, j);

    // creation of green team
    println("Création de l'équipe verte");
    GreenTeam gt = new GreenTeam();
    // first base
    Base b = new GreenBase(gt.base1, green, gt);
    greenBases.add(b);
    robots.add(b);
    b.setup();
    // second base
    b = new GreenBase(gt.base2, green, gt);
    greenBases.add(b);
    robots.add(b);
    b.setup();

    // creation of red team
    println("Création de l'équipe rouge");
    RedTeam rt = new RedTeam();
    // first base
    b = new RedBase(rt.base1, red, rt);
    redBases.add(b);
    robots.add(b);
    b.setup();
    // second base
    b = new RedBase(rt.base2, red, rt);
    redBases.add(b);
    robots.add(b);
    b.setup();

    // used to interact with robots
    println("Création de la souris");
    mouse = new Mouse();

    // generation of initial burgers
    println("Création des burgers");
    for (int i=1; i<=3; i++)
      newRandomBurgers(burgerQuantity);

    // generation of some walls
    println("Création des murs");
    newRandomWalls(60);
  }

  //
  // go
  // ==
  // > main cycle of the game
  //
  void go() {
    // remove robots and ressources without energy
    removeZombies();

    // activate patches
    for (int i=0; i<nbPatchesX; i++)
      for (int j=0; j<nbPatchesY; j++)
        patches[i][j].go();

    // generate a random list of robots
    shuffleRobots();
    // prepare the robots for activation
    for (Robot agt : schedule)
      agt.prepareToGo();
    // activate the robots
    for (Robot agt : schedule)
      agt.go();

    // activate missiles
    for (Missile miss : missiles)
      miss.go();
    // activate seeds
    for (Seed sid : seeds)
      sid.go();
    // activate burgers
    for (Burger zorg : burgers)
      zorg.go();
    // activate the mouse
    mouse.go();

    // periodically adds new burgers
    if (int(random(burgerPeriodicity)) == 0)
      newRandomBurgers(burgerQuantity);

    // compute the new score of each team
    updateEnergy();
  }

  //
  // tick
  // ====
  // > handle the clock
  //
  void tick() {
    ticks++;
    if (ticks == maxTicks)
      stop();
  }

  //
  // display
  // =======
  // > update the display of the simulation window
  //
  void display() {
    // reset the window to black (except the information tab which is dark gray)
    background(0);

    // display seeds
    for (Seed sid : seeds)
      sid.display();
    // display burgers
    for (Burger zorg : burgers)
      zorg.display();
    // display walls
    for (Wall w : walls)
      w.display();
    // display robots
    for (Robot rob : robots)
      rob.display();
    // display missiles
    for (Missile miss : missiles)
      miss.display();

    // display mouse
    mouse.display();

    // if the patches are to be displayed, display them
    if (displayPatches) {
      for (int i=0; i<nbPatchesX; i++)
        for (int j=0; j<nbPatchesY; j++)
          patches[i][j].display();
    }


    // update information tab 
    fill(32);
    noStroke();
    rect(0, height - 100, width, 100);

    fill(255);
    textAlign(LEFT, CENTER);
    text("Equipe verte", 150, height - 80);
    text("Energie = " + (int)greenNrj[ticks], 170, height - 60); 
    text("Equipe rouge", 1000, height - 80);
    text("Energie = " + (int)redNrj[ticks], 1020, height - 60);
    text("ticks = " + ticks, 20, height - 80);
    stroke(255);
    strokeWeight(5);
    line(120, height - 100, 120, height);
    strokeWeight(1);
    // update energy graph 
    displayNrj();
  }

  //
  // displayNrj
  // ==========
  // > update the energy graph
  //
  void displayNrj() {
    // the background of the graph is white
    fill(255);
    strokeWeight(2);
    rect(350, height - 100, 600, 100);
    // draws the green graph
    stroke(0, 255, 0);
    beginShape();
    for (int i=0; i<ticks; i++) {
      vertex(350 + i * 600 / ticks, height - greenNrj[i] * 100 / maxNrj);
    }
    endShape();
    // draws the red graph
    stroke(255, 0, 0);
    beginShape();
    for (int i=0; i<ticks; i++) {
      vertex(350 + i * 600 / ticks, height - redNrj[i] * 100 / maxNrj);
    }
    endShape();
    strokeWeight(1);
  }

  //
  // wrapPosition
  // ============
  // > compute the wrapping of positions
  //
  // input
  // -----
  // > p = the position to wrap
  //
  void wrapPosition(PVector p) {
    if (p.x < 0)
      p.x += w;
    if (p.x >= w)
      p.x -= w;
    if (p.y < 0)
      p.y += h;
    if (p.y >= h)
      p.y -= h;
  }

  //
  // shuffleRobots
  // =============
  // > randomize the list of robots to obtain a random order of activation
  //
  void shuffleRobots() {
    // adds all the robots to the list
    schedule = new ArrayList<Robot>();
    for (Robot rob : robots)
      schedule.add(rob);

    // randomly swaps robots i & pick
    int pick;
    Robot temp;
    for (int i=0; i<schedule.size(); i++) {
      pick  = (int)random(schedule.size()); // picks a random position in the array
      temp = schedule.get(i);               // stores value of current position
      schedule.set(i, schedule.get(pick));  // copies picked value into current position
      schedule.set(pick, temp);             // store original value in picked position
    }
  }

  //
  // removeZombies
  // =============
  // > remove robots and ressources whose (energy <= 0) 
  //
  void removeZombies() {
    Seed sid;
    Burger zorg;
    Wall wally;
    Robot bob;

    // remove "dead" missiles (out of range or that made a hit)
    for (int i=0; i<missiles.size(); i++)
      if (missiles.get(i).energy <= 0)
        missiles.remove(i);

    // remove "dead" seeds (transformed into a burger)
    for (int i=0; i<seeds.size(); i++) {
      sid = seeds.get(i);
      if (sid.energy <= 0) {
        patches[int(sid.pos.x / patchSize)][int(sid.pos.y / patchSize)].removeSeed(sid);
        seeds.remove(i);
      }
    }

    // remove the "rotten" burgers
    for (int i=0; i<burgers.size(); i++) {
      zorg = burgers.get(i);
      if (zorg.energy <= 0) {
        patches[int(zorg.pos.x / patchSize)][int(zorg.pos.y / patchSize)].removeBurger(zorg);
        burgers.remove(i);
      }
    }

    // remove the dead robots
    for (int i=0; i<robots.size(); i++) {
      bob = robots.get(i);
      if (bob.energy <= 0)
        bob.die();
    }

    // remove the destroyed walls
    for (int i=0; i<walls.size(); i++) {
      wally = walls.get(i);
      if (wally.energy <= 0) {
        patches[int(wally.pos.x / patchSize)][int(wally.pos.y / patchSize)].removeWall(wally);
        walls.remove(i);
      }
    }
  }

  //
  // getRobot
  // ========
  // > return the agent whose id is given
  //
  // input
  // -----
  // > id = the id of the agent to find
  //
  // output
  // ------
  // > the robot whose "who" is equal to "id" 
  //
  Robot getRobot(int id) {
    // search for robot "id"
    for (int i=0; i<robots.size(); i++)
      if (robots.get(i).who == id) {
        return robots.get(i);
      }
    return null;
  }

  //
  // killBot
  // =======
  // > removes the robot
  //
  // input
  // -----
  // > bob = the robot to remove
  //
  void killBot(Robot bob) {
    // remove bob from its patch
    bob.leavePatch();
    // search for bob
    for (int i=0; i<robots.size(); i++)
      if (robots.get(i) == bob) {
        // if bob is found, remove it
        robots.remove(i);
        break;
      }
  }

  //
  // killBase
  // ========
  // > removes a base
  //
  // input
  // -----
  // > bob = the base to remove
  //
  void killBase(Robot bob) {
    // remove bob from its patch
    bob.leavePatch();
    // search for bob
    for (int i=0; i<robots.size(); i++)
      if (robots.get(i) == bob) {
        // if bob is found, remove it
        robots.remove(i);
        break;
      }
    // in addition, remove the base from the list of green or red bases
    if (bob.colour == green) {
      if (greenBases.get(0) == bob)
        greenBases.remove(0);
      else
        greenBases.remove(1);
    } else {
      if (redBases.get(0) == bob)
        redBases.remove(0);
      else
        redBases.remove(1);
    }
  }

  //
  // updateEnergy
  // ============
  // > compute the level of energy (= score) of each team
  //
  void updateEnergy() {
    Robot bob;

    // initialize the scores for time "ticks"
    greenNrj[ticks] = redNrj[ticks] = 0; 
    // add the energy of all the robots to one of the scores
    // depending on the colour of the robot
    for (int i=0; i<robots.size(); i++) {
      bob = robots.get(i);
      if (bob.colour == green)
        greenNrj[ticks] += bob.getEnergy();
      else
        redNrj[ticks] += bob.getEnergy();
    }
    // update maxNrj
    if (greenNrj[ticks] > maxNrj)
      maxNrj = greenNrj[ticks];
    if (redNrj[ticks] > maxNrj)
      maxNrj = redNrj[ticks];
  }

  //
  // newExplorer
  // ===========
  // > create a new explorer
  //
  // input
  // -----
  // > agt = the base that creates the robot
  // > p = the position of the new robot
  //
  void newExplorer(Robot agt, PVector p) {
    Explorer explorer = null;
    // create a green or red explorer depending on the colour of the base
    if (agt.colour == green) {
      explorer = new GreenExplorer(p, green, greenBases, agt.team);
    } else if (agt.colour == red) {
      explorer = new RedExplorer(p, red, redBases, agt.team);
    }
    if (explorer != null) {
      // if creation was succesfull, add explorer to the robots...
      robots.add(explorer);
      // ...and to the patch
      patches[int(p.x / patchSize)][int(p.y / patchSize)].addRobot(explorer);
      // initialize the new robot
      explorer.setup();
    }
  }

  //
  // newHarvester
  // ============
  // > create a new harvester
  //
  // input
  // -----
  // > agt = the base that creates the robot
  // > p = the position of the new robot
  //
  void newHarvester(Robot agt, PVector p) {
    Harvester harvester = null;
    // create a green or red harvester depending on the colour of the base
    if (agt.colour == green) {
      harvester = new GreenHarvester(p, green, greenBases, agt.team);
    } else if (agt.colour == red) {
      harvester = new RedHarvester(p, red, redBases, agt.team);
    }
    if (harvester != null) {
      // if creation was succesfull, add harvester to the robots...
      robots.add(harvester);
      // ...and to the patch
      patches[int(p.x / patchSize)][int(p.y / patchSize)].addRobot(harvester);
      // initialize the new robot
      harvester.setup();
    }
  }

  //
  // newRocketLauncher
  // =================
  // > create a new rocket launcher
  //
  // input
  // -----
  // > agt = the base that creates the robot
  // > p = the position of the new robot
  //
  void newRocketLauncher(Robot agt, PVector p) {
    RocketLauncher launcher = null;
    // create a green or red rocket launcher depending on the colour of the base
    if (agt.colour == green) {
      launcher = new GreenRocketLauncher(p, green, greenBases, agt.team);
    } else if (agt.colour == red) {
      launcher = new RedRocketLauncher(p, red, redBases, agt.team);
    }
    if (launcher != null) {
      // if creation was succesfull, add rocket launcher to the robots...
      robots.add(launcher);
      // ...and to the patch
      patches[int(p.x / patchSize)][int(p.y / patchSize)].addRobot(launcher);
      // initialize the new robot
      launcher.setup();
    }
  }

  //
  // newWall
  // =======
  // > create a new Wall
  //
  // input
  // -----
  // > p = the position of the wall
  // > c = the colour of the wall
  //
  void newWall(PVector p, color c) {
    // only possible to add a new wall if none in the patch
    if (game.freePatch(p)) {
      // create a new wall
      Wall wally = new Wall(p, c);
      // add wally to the walls...
      walls.add(wally);
      // ...and to the patches
      patches[int(p.x / patchSize)][int(p.y / patchSize)].addWall(wally);
    }
  }

  //
  // newWall
  // =======
  // > create a new Wall
  //
  // input
  // -----
  // > p = the position of the wall
  // > c = the colour of the wall
  // > nrj = the amount of energy of the wall
  //
  void newWall(PVector p, color c, float nrj) {
    Wall wally = new Wall(p, c);
    wally.energy = nrj;
    walls.add(wally);
    patches[int(p.x / patchSize)][int(p.y / patchSize)].addWall(wally);
  }

  //
  // distance
  // ========
  // > return the distance between two turtles
  // > takes into account the wrapping of the environment
  // > the unity is the size of a patch
  //
  // input
  // -----
  // > t1 = first turtle
  // > t2 = second turtle
  //
  float distance(Turtle t1, Turtle t2) {
    // compute the smallest x distance
    float dx = abs(t1.pos.x - t2.pos.x);
    if (dx > w2)
      dx = w - dx;
    // compute the smallest y distance
    float dy = abs(t1.pos.y - t2.pos.y);
    if (dy > h2)
      dy = h - dy;
    // compute the distance
    return sqrt(dx * dx + dy * dy) / patchSize;
  }

  //
  // distance
  // ========
  // > return the distance between two positions
  // > takes into account the wrapping of the environment
  //
  // input
  // -----
  // > p1 = first position
  // > p2 = second position
  //
  float distance(PVector p1, PVector p2) {
    // compute the smallest x distance
    float dx = abs(p1.x - p2.x);
    if (dx > w2)
      dx = w - dx;
    // compute the smallest y distance
    float dy = abs(p1.y - p2.y);
    if (dy > h2)
      dy = h - dy;
    // compute the distance
    return sqrt(dx * dx + dy * dy) / patchSize;
  }

  //
  // distance
  // ========
  // > return the distance between two patches
  // > takes into account the wrapping of the environment
  //
  // input
  // -----
  // > x1, y1 = position of first patch
  // > x2, y2 = position of second patch
  //
  float distance(int x1, int y1, int x2, int y2) {
    // compute the smallest x distance
    int dx = abs(x1 - x2);
    if (dx > nbPatchesX / 2)
      dx = nbPatchesX - dx;
    // compute the smallest y distance
    float dy = abs(y1 - y2);
    if (dy > nbPatchesY / 2)
      dy = nbPatchesY - dy;
    // compute the distance
    return sqrt(dx * dx + dy * dy);
  }

  //
  // towards
  // =======
  // > Returns the angle from turtle t1, looking towards turtle t2 
  //
  // input
  // -----
  // > t1 = the origin turtle
  // > t2 = the pointed turtle
  //
  // output
  // ------
  // > the angle seen from t1, pointing towards t2
  //
  float towards(Turtle t1, Turtle t2) {
    // compute the smallest x distance
    float dx = t2.pos.x - t1.pos.x;
    if (dx < -w2)
      dx += w;
    else if (dx > w2)
      dx -= w;
    // compute the smallest y distance
    float dy = t2.pos.y - t1.pos.y;
    if (dy < -h2)
      dy += h;
    else if (dy > h2)
      dy -= h;
    // compute the angle
    return atan2(dy, dx);
  }

  //
  // towards
  // =======
  // > Returns the angle from position p1, looking towards position p2 
  //
  // input
  // -----
  // > t1 = the origin position
  // > t2 = the pointed position
  //
  // output
  // ------
  // > the angle seen from p1, pointing towards p2
  //
  float towards(PVector p1, PVector p2) {
    // compute the smallest x distance
    float dx = p2.x - p1.x;
    if (dx < -w2)
      dx += w;
    else if (dx > w2)
      dx -= w;
    // compute the smallest y distance
    float dy = p2.y - p1.y;
    if (dy < -h2)
      dy += h;
    else if (dy > h2)
      dy -= h;
    // compute the angle
    return atan2(dy, dx);
  }

  //
  // oneOf
  // =====
  // > returns an agent, randomly chosen in the list agentSet
  //
  // input
  // -----
  // > agentSet = a list of agents
  //
  // output
  // ------
  // one agent, randomly chosen in the list 
  //
  Turtle oneOf(ArrayList agentSet) {
    // check that the list is not null and not of length 0
    if ((agentSet != null) && (agentSet.size() != 0)) {
      // choose a random index
      int i = (int)random(agentSet.size());
      // return the chosen agent
      return (Turtle)agentSet.get(i);
    }
    // else return null
    return null;
  }

  //
  // minDist
  // =======
  // > return the agent at minimum distance from the caller bob
  //
  // input
  // -----
  // > bob = the reference agent
  // > agentSet = the list of agents in which to search for the closest one
  //
  // output
  // ------
  // > the agent in the list agentSet that is closest to bob 
  // 
  Turtle minDist(Turtle bob, ArrayList agentSet) {
    // check that the list is not null and not of length 0
    if ((agentSet != null) && (agentSet.size() != 0)) {
      // the minimum distance
      float md = width;
      // the turtle at minimum distance
      Turtle mt = null;
      float d;

      // for all turtles
      for (Object t : agentSet) {
        // compute distance of t
        d = distance((Turtle)t, bob);
        if (d < md) {
          // if it is closest than the closest one
          md = d;
          // it is the new closest
          mt = (Turtle)t;
        }
      }
      // return the closest turtle
      return mt;
    }
    // else return null
    return null;
  }

  //
  // takeFood
  // ========
  // > collects a burger in the environment
  //
  // input
  // -----
  // > bob = the agent that collects the burger
  // > zorg = the burger to collect
  //
  void takeFood(Robot bob, Burger zorg) {
    // check that bob is a harvester, zorg is a burger, and bob has not collected
    // food in that timestep yet
    if ((bob.breed == HARVESTER) && (zorg.breed == BURGER) && ((Harvester)bob).tfOK) {
      // if the distance is ok
      if (distance(zorg, bob) <= 2) {
        // bob has collected food
        ((Harvester)bob).switchTfOK();
        // it has gained energy
        ((Harvester)bob).incrementCarryingFood(zorg.energy);
        // the burger is removed from the environment
        removeBurger(zorg);
      }
    }
  }

  //
  // crushSeeds 
  // ==========
  // > crushes seeds at position p (results in a delayed growth of the seeds)
  //
  // input
  // -----
  // > p = the position at which seeds are crushed
  //
  void crushSeeds(PVector p) {
    patches[int(p.x / patchSize)][int(p.y / patchSize)].crushSeeds();
  }

  //
  // launchBullet
  // ============
  // > launches a bullet
  //
  // input
  // -----
  // > bob = the robot that launches the bullet
  // > angle = the angle towards which the bullet is launched
  //
  void launchBullet(Robot bob, float angle) {
    // check that bob has repected a given delay and that is has at least one bullet
    if ((bob.waiting == 0) && (bob.bullets > 0)) {
      // decrement the number of bullets
      bob.bullets--;
      // reset the delay
      bob.resetWaiting();
      // a new bullet is created...
      Bullet b = new Bullet(bob.pos, angle);
      // ...and added to the missiles
      missiles.add(b);
    }
  }

  //
  // launchFaf
  // =========
  // > launches a faf
  //
  // input
  // -----
  // > bob = the robot that launches the bullet
  // > target = the robot towards which the faf is launched
  //
  void launchFaf(Robot bob, Robot target) {
    // check that bob has repected a given delay and that is has at least one faf
    if ((bob.waiting == 0) && (bob.fafs > 0)) {
      // decrement the number of fafs
      bob.fafs--;
      // reset the delay
      bob.resetWaiting();
      // a new faf is created...
      Faf m = new Faf(bob.pos, target);
      // ...and added to the missiles
      missiles.add(m);
    }
  }

  //
  // patchesnRadius
  // ==============
  // > returns the patches in a given radius around bob 
  //
  // input
  // -----
  // > bob = the reference agent
  // > d = the radius
  //
  ArrayList patchesInRadius(Robot bob, int d) {
    // compute the x,y position of bob in the patches grid
    // (shifted by nbPatchesX,nbPatchesY to take wrapping into account 
    int bx = int(bob.pos.x / patchSize) + nbPatchesX;
    int by = int(bob.pos.y / patchSize) + nbPatchesY;

    // a box of radius d around (bx, by)
    int minX, maxX, minY, maxY;
    minX = bx - d;
    maxX = bx + d;
    minY = by - d;
    maxY = by + d;

    // a new list of patches
    ArrayList liste = new ArrayList<Patch>();

    // for each column i in the box
    for (int i=minX; i<=maxX; i++) {
      // skip the patches too far away
      int j = minY;
      while (distance(i, j, bx, by) > d)
        j++;
      // add the other patches
      for (int k=j; k<=minY+maxY-j; k++)
        liste.add(patches[i%nbPatchesX][k%nbPatchesY]);
    }

    // return the list of patches
    return liste;
  }

  //
  // perceiveWalls
  // =============
  // > returns the list of walls perceived by bob
  //
  // input
  // -----
  // > bob = the reference agent
  //
  // output
  // ------
  // the list of walls in bob's range of detection
  //
  ArrayList perceiveWalls(Robot bob) {
    // create a new list of walls
    ArrayList liste = new ArrayList<Wall>();
    // for all walls
    for (Wall wally : walls)
      // add the wall if closer than detection range
      if (distance(wally, bob) <= bob.detectionRange)
        liste.add(wally);

    // return list only if size is different from 0
    if (liste.size() != 0)
      return liste;
    else
      return null;
  }

  //
  // perceiveWalls
  // =============
  // > returns the list of walls perceived by bob in a given cone in front of it
  //
  // input
  // -----
  // > bob = the reference agent
  // > angle = the aperture of the cone
  //
  // output
  // ------
  // the list of walls in bob's range of detection, inside the cone
  //
  ArrayList perceiveWallsInCone(Robot bob, float angle) {
    // create a new list of walls
    ArrayList liste = new ArrayList<Wall>();
    // for all walls
    for (Wall wally : walls)
      // if the wall is closer than detection range
      if (distance(wally, bob) <= bob.detectionRange) {
        // check if the wall is in the cone
        float a = bob.towards(wally);
        if (((a >= bob.heading - angle/2) && (a <= bob.heading + angle/2)) ||
          ((bob.heading + angle/2 >= TWO_PI) && (a + TWO_PI <= bob.heading + angle/2)) ||
          ((bob.heading - angle/2 <= 0) && (a - TWO_PI >= bob.heading - angle/2)))
          liste.add(wally);
      }

    // return list only if size is different from 0
    if (liste.size() != 0)
      return liste;
    else
      return null;
  }

  //
  // perceiveWalls
  // =============
  // > returns the list of walls perceived by bob in a given cone in front of it
  //
  // input
  // -----
  // > bob = the reference agent
  // > angle = the aperture of the cone
  // > d = the maximum distance
  //
  // output
  // ------
  // the list of walls in bob's range of detection, inside the cone
  //
  ArrayList perceiveWallsInCone(Robot bob, float angle, float d) {
    // create a new list of walls
    ArrayList liste = new ArrayList<Wall>();
    // for all walls
    for (Wall wally : walls)
      // if the wall is closer than distance
      if (distance(wally, bob) <= d) {
        // check if the wall is in the cone
        float a = bob.towards(wally);
        if (((a >= bob.heading - angle/2) && (a <= bob.heading + angle/2)) ||
          ((bob.heading + angle/2 >= TWO_PI) && (a + TWO_PI <= bob.heading + angle/2)) ||
          ((bob.heading - angle/2 <= 0) && (a - TWO_PI >= bob.heading - angle/2)))
          liste.add(wally);
      }

    // return list only if size is different from 0
    if (liste.size() != 0)
      return liste;
    else
      return null;
  }

  //
  // perceiveSeeds
  // =============
  // > returns the list of seeds of a given colour perceived by bob
  //
  // input
  // -----
  // > bob = the reference agent
  // > col = the colour of the seeds
  //
  // ouput
  // -----
  // the list of seeds of the given colour in bob's detection range
  //
  ArrayList perceiveSeeds(Robot bob, color col) {
    // create a new list of seeds
    ArrayList liste = new ArrayList<Seed>();
    for (Seed sid : seeds)
      // a robot can detect all the seeds of its own colour but the seeds of the other colour 
      // only if their age is more than half the total maturation time
      if ((distance(sid, bob) <= bob.detectionRange) &&
        ((col == bob.friend) || ((sid.colour == col) && (sid.age >= maturationTime / 2))))
        liste.add(sid);

    // return list only if size is different from 0
    if (liste.size() != 0)
      return liste;
    else
      return null;
  }

  //
  // perceiveSeeds
  // =============
  // > returns the list of seeds of a given colour and in a given cone perceived by bob
  //
  // input
  // -----
  // > bob = the reference agent
  // > angle = the aperture of the cone
  // > col = the colour of the seeds
  //
  // ouput
  // -----
  // the list of seeds of the given colour in bob's detection range and inside the cone
  //
  ArrayList perceiveSeedsInCone(Robot bob, float angle, color col) {
    // create a new list of walls
    ArrayList liste = new ArrayList<Wall>();
    for (Seed sid : seeds)
      // a robot can detect all the seeds of its own colour but the seeds of the other colour 
      // only if their age is more than half the total maturation time
      if ((distance(sid, bob) <= bob.detectionRange)  &&
        ((col == bob.friend) || ((sid.colour == col) && (sid.age >= maturationTime / 2)))) {
        // check if the seed is inside the cone
        float a = bob.towards(sid);
        if (((a >= bob.heading - angle/2) && (a <= bob.heading + angle/2)) ||
          ((bob.heading + angle/2 >= TWO_PI) && (a + TWO_PI <= bob.heading + angle/2)) ||
          ((bob.heading - angle/2 <= 0) && (a - TWO_PI >= bob.heading - angle/2)))
          liste.add(sid);
      }

    // return list only if size is different from 0
    if (liste.size() != 0)
      return liste;
    else
      return null;
  }

  //
  // perceiveRobots
  // ==============
  // > returns the list of robots perceived by bob
  //
  // input
  // -----
  // > bob = the reference agent
  //
  // output
  // ------
  // the list of robots in bob's range of detection
  //
  ArrayList perceiveRobots(Robot bob) {
    // Create a new list of robots
    ArrayList liste = new ArrayList<Robot>();
    // for all robots
    for (Robot alice : robots)
      // add alice only if different from bob
      // and distance is less than bob's detection range 
      if ((alice != bob) && (distance(alice, bob) <= bob.detectionRange)) 
        liste.add(alice);

    // return list only if size is different from 0
    if (liste.size() != 0)
      return liste;
    else
      return null;
  }

  //
  // perceiveRobots
  // ==============
  // > returns the list of robots of the right colour perceived by bob
  //
  // input
  // -----
  // > bob = the reference agent
  // > c = the target colour
  //
  // output
  // ------
  // the list of robots in bob's range of detection, whose colour is c
  //
  ArrayList perceiveRobots(Robot bob, color c) {
    // Create a new list of robots
    ArrayList liste = new ArrayList<Robot>();
    // for all robots
    for (Robot alice : robots)
      // add alice only if different from bob, of the right colour
      // and distance is less than bob's detection range 
      if ((alice.colour == c) && (alice != bob) && (distance(alice, bob) <= bob.detectionRange)) 
        liste.add(alice);

    // return list only if size is different from 0
    if (liste.size() != 0)
      return liste;
    else
      return null;
  }

  //
  // perceiveRobots
  // ==============
  // > returns the list of robots of the right colour and breed perceived by bob
  //
  // input
  // -----
  // > bob = the reference agent
  // > c = the target colour
  // > b = the target breed
  //
  // output
  // ------
  // the list of robots in bob's range of detection, whose colour is c and breed is b
  //
  ArrayList perceiveRobots(Robot bob, color c, int b) {
    // Create a new list of robots
    ArrayList liste = new ArrayList<Robot>();
    // for all robots
    for (Robot alice : robots)
      // add alice only if different from bob, of the right colour and breed
      // and distance is less than bob's detection range 
      if ((alice.colour == c) && (alice.breed == b) && (alice != bob) && (distance(alice, bob) <= bob.detectionRange)) 
        liste.add(alice);

    // return list only if size is different from 0
    if (liste.size() != 0)
      return liste;
    else
      return null;
  }

  //
  // perceiveRobots
  // ==============
  // > returns the list of robots perceived by bob in a given cone
  //
  // input
  // -----
  // > bob = the reference agent
  // > angle = the aperture of the cone 
  //
  // output
  // ------
  // the list of robots in bob's range of detection, inside the cone
  //
  ArrayList perceiveRobotsInCone(Robot bob, float angle) {
    // Create a new list of robots
    ArrayList liste = new ArrayList<Robot>();
    // for all robots
    for (Robot alice : robots)
      // if alice is different from bob
      // and distance is less than bob's detection range 
      if ((alice != bob) && distance(alice, bob) <= bob.detectionRange) {
        // check if alice is inside the cone
        float a = bob.towards(alice);
        if (((a >= bob.heading - angle/2) && (a <= bob.heading + angle/2)) ||
          ((bob.heading + angle/2 >= TWO_PI) && (a + TWO_PI <= bob.heading + angle/2)) ||
          ((bob.heading - angle/2 <= 0) && (a - TWO_PI >= bob.heading - angle/2)))
          liste.add(alice);
      }

    // return list only if size is different from 0
    if (liste.size() != 0)
      return liste;
    else
      return null;
  }

  //
  // perceiveRobots
  // ==============
  // > returns the list of robots of the right colour perceived by bob in a given cone
  //
  // input
  // -----
  // > bob = the reference agent
  // > angle = the aperture of the cone
  // > c = the target colour
  //
  // output
  // ------
  // the list of robots in bob's range of detection, whose colour is c, inside the cone
  //
  ArrayList perceiveRobotsInCone(Robot bob, float angle, color c) {
    // Create a new list of robots
    ArrayList liste = new ArrayList<Robot>();
    // for all robots
    for (Robot alice : robots)
      // if alice is different from bob, and of the right colour
      // and distance is less than bob's detection range 
      if ((alice.colour == c) && (alice != bob) && distance(alice, bob) <= bob.detectionRange) {
        // check if alice is inside the cone
        float a = bob.towards(alice);
        if (((a >= bob.heading - angle/2) && (a <= bob.heading + angle/2)) ||
          ((bob.heading + angle/2 >= TWO_PI) && (a + TWO_PI <= bob.heading + angle/2)) ||
          ((bob.heading - angle/2 <= 0) && (a - TWO_PI >= bob.heading - angle/2)))
          liste.add(alice);
      }

    // return list only if size is different from 0
    if (liste.size() != 0)
      return liste;
    else
      return null;
  }

  //
  // perceiveRobots
  // ==============
  // > returns the list of robots of the right colour and breed perceived by bob in a given cone
  //
  // input
  // -----
  // > bob = the reference agent
  // > angle = the aperture of the cone
  // > c = the target colour
  // > b = the target breed
  //
  // output
  // ------
  // the list of robots in bob's range of detection, whose colour is c and breed is b,
  // inside the cone
  //
  ArrayList perceiveRobotsInCone(Robot bob, float angle, color c, int b) {
    // Create a new list of robots
    ArrayList liste = new ArrayList<Robot>();
    // for all robots
    for (Robot alice : robots)
      // if alice is different from bob, and of the right colour and breed
      // and distance is less than bob's detection range 
      if ((alice.colour == c) && (alice.breed == b) && (alice != bob) && distance(alice, bob) <= bob.detectionRange) {
        // check if alice is inside the cone
        float a = bob.towards(alice);
        if (((a >= bob.heading - angle/2) && (a <= bob.heading + angle/2)) ||
          ((bob.heading + angle/2 >= TWO_PI) && (a + TWO_PI <= bob.heading + angle/2)) ||
          ((bob.heading - angle/2 <= 0) && (a - TWO_PI >= bob.heading - angle/2)))
          liste.add(alice);
      }

    // return list only if size is different from 0
    if (liste.size() != 0)
      return liste;
    else
      return null;
  }

  //
  // perceiveRobots
  // ==============
  // > returns the list of robots perceived by bob in a given cone
  //
  // input
  // -----
  // > bob = the reference agent
  // > angle = the aperture of the cone
  // > d = the maximum distance
  //
  // output
  // ------
  // the list of robots in bob's range of detection, inside the cone
  //
  ArrayList perceiveRobotsInCone(Robot bob, float angle, float d) {
    // Create a new list of robots
    ArrayList liste = new ArrayList<Robot>();
    // for all robots
    for (Robot alice : robots)
      // if alice is different from bob and distance is less than d 
      if ((alice != bob) && distance(alice, bob) <= d) {
        // check if alice is inside the cone
        float a = bob.towards(alice);
        if (((a >= bob.heading - angle/2) && (a <= bob.heading + angle/2)) ||
          ((bob.heading + angle/2 >= TWO_PI) && (a + TWO_PI <= bob.heading + angle/2)) ||
          ((bob.heading - angle/2 <= 0) && (a - TWO_PI >= bob.heading - angle/2)))
          liste.add(alice);
      }

    // return list only if size is different from 0
    if (liste.size() != 0)
      return liste;
    else
      return null;
  }

  //
  // perceiveRobots
  // ==============
  // > returns the list of robots of the right colour perceived by bob in a given cone
  //
  // input
  // -----
  // > bob = the reference agent
  // > angle = the aperture of the cone
  // > d = the maximum distance
  // > c = the target colour
  //
  // output
  // ------
  // the list of robots in bob's range of detection, whose colour is c, inside the cone
  //
  ArrayList perceiveRobotsInCone(Robot bob, float angle, float d, color c) {
    // Create a new list of robots
    ArrayList liste = new ArrayList<Robot>();
    // for all robots
    for (Robot alice : robots)
      // if alice is different from bob, of the right colour,
      // and distance is less than d 
      if ((alice.colour == c) && (alice != bob) && distance(alice, bob) <= d) {
        // check if alice is inside the cone
        float a = bob.towards(alice);
        if (((a >= bob.heading - angle/2) && (a <= bob.heading + angle/2)) ||
          ((bob.heading + angle/2 >= TWO_PI) && (a + TWO_PI <= bob.heading + angle/2)) ||
          ((bob.heading - angle/2 <= 0) && (a - TWO_PI >= bob.heading - angle/2)))
          liste.add(alice);
      }

    // return list only if size is different from 0
    if (liste.size() != 0)
      return liste;
    else
      return null;
  }

  //
  // perceiveRobots
  // ==============
  // > returns the list of robots of the right colour and breed perceived by bob in a given cone
  //
  // input
  // -----
  // > bob = the reference agent
  // > angle = the aperture of the cone
  // > d = the maximum distance
  // > c = the target colour
  // > b = the target breed
  //
  // output
  // ------
  // the list of robots in bob's range of detection, whose colour is c and breed is b,
  // inside the cone
  //
  ArrayList perceiveRobotsInCone(Robot bob, float angle, float d, color c, int b) {
    // Create a new list of robots
    ArrayList liste = new ArrayList<Robot>();
    // for all robots
    for (Robot alice : robots)
      // if alice is different from bob, of the right colour and breed
      // and distance is less than d 
      if ((alice.colour == c) && (alice.breed == b) && (alice != bob) && distance(alice, bob) <= d) {
        // check if alice is inside the cone
        float a = bob.towards(alice);
        if (((a >= bob.heading - angle/2) && (a <= bob.heading + angle/2)) ||
          ((bob.heading + angle/2 >= TWO_PI) && (a + TWO_PI <= bob.heading + angle/2)) ||
          ((bob.heading - angle/2 <= 0) && (a - TWO_PI >= bob.heading - angle/2)))
          liste.add(alice);
      }

    // return list only if size is different from 0
    if (liste.size() != 0)
      return liste;
    else
      return null;
  }

  //
  // perceiveBurgers
  // ===============
  // > returns the list of burgers in bob's range of perception
  //
  // input
  // -----
  // > bob = the reference agent
  //
  // output
  // ------
  // the list of burgers in bob's detection range
  //
  ArrayList perceiveBurgers(Robot bob) {
    // Create a new list of burgers
    ArrayList liste = new ArrayList<Burger>();
    // for all burgers
    for (Burger zorg : burgers)
      // add zorg only if distance is less than perception range
      if (distance(zorg, bob) <= bob.detectionRange)
        liste.add(zorg);

    // return list only if size is different from 0
    if (liste.size() != 0)
      return liste;
    else
      return null;
  }

  //
  // perceiveBurgers
  // ===============
  // > returns the list of burgers in bob's range of perception in a given cone
  //
  // input
  // -----
  // > bob = the reference agent
  // > angle = the aperture of the cone 
  //
  // output
  // ------
  // the list of burgers in bob's detection range, inside the cone
  //
  ArrayList perceiveBurgersInCone(Robot bob, float angle) {
    // Create a new list of burgers
    ArrayList liste = new ArrayList<Burger>();
    // for all burgers
    for (Burger zorg : burgers)
      // if distance is less than detection range
      if (distance(zorg, bob) <= bob.detectionRange) {
        // check if zorg is inside the cone
        float a = bob.towards(zorg);
        if (((a >= bob.heading - angle/2) && (a <= bob.heading + angle/2)) ||
          ((bob.heading + angle/2 >= TWO_PI) && (a + TWO_PI <= bob.heading + angle/2)) ||
          ((bob.heading - angle/2 <= 0) && (a - TWO_PI >= bob.heading - angle/2)))
          liste.add(zorg);
      }

    // return list only if size is different from 0
    if (liste.size() != 0)
      return liste;
    else
      return null;
  }

  //
  // perceiveFafs
  // ============
  // > returns the list of fafs in bob's detection range
  //
  // input
  // -----
  // > bob = the refernce agent
  //
  // output
  // ------
  // the list of fafs in bob's detection range 
  //
  ArrayList perceiveFafs(Robot bob) {
    // Create a new list of fafs
    ArrayList liste = new ArrayList<Faf>();
    // for all missiles
    for (Missile miss : missiles)
      // add miss only if it is a FAF (bullets cannot be detected)
      // and distance is less than bob's detection range 
      if ((miss.breed == FAF) && (distance(miss, bob) <= bob.detectionRange))
        liste.add(miss);

    // return list only if size is different from 0
    if (liste.size() != 0)
      return liste;
    else
      return null;
  }

  //
  // perceiveFafs
  // ============
  // > returns the list of fafs in bob's detection range, inside a given cone
  //
  // input
  // -----
  // > bob = the refernce agent
  // > angle = the aperture of the cone
  //
  // output
  // ------
  // the list of fafs in bob's detection range, inside the cone 
  //
  ArrayList perceiveFafsInCone(Robot bob, float angle) {
    // Create a new list of fafs
    ArrayList liste = new ArrayList<Wall>();
    // for all missiles
    for (Missile miss : missiles)
      // if miss is a faf and distance is less than bob's detection range
      if ((miss.breed == FAF) && distance(miss, bob) <= bob.detectionRange) {
        // check if miss is inside the cone
        float a = bob.towards(miss);
        if (((a >= bob.heading - angle/2) && (a <= bob.heading + angle/2)) ||
          ((bob.heading + angle/2 >= TWO_PI) && (a + TWO_PI <= bob.heading + angle/2)) ||
          ((bob.heading - angle/2 <= 0) && (a - TWO_PI >= bob.heading - angle/2)))
          liste.add(miss);
      }

    // return list only if size is different from 0
    if (liste.size() != 0)
      return liste;
    else
      return null;
  }

  //
  // forward
  // =======
  // > moves bob forward by a distance of dist
  //
  // input
  // -----
  // > bob = the agent to move
  // > dist = the distance to move forward
  //
  void forward(Robot bob, float dist) {
    // remove bob from its current patch
    patches[int(bob.pos.x / patchSize)][int(bob.pos.y / patchSize)].removeRobot(bob);
    // compute the target position
    bob.pos.x += dist * patchSize * cos(bob.heading);
    bob.pos.y += dist * patchSize * sin(bob.heading);
    // take wrapping into account
    wrapPosition(bob.pos);
    // add bob in the target patch
    patches[int(bob.pos.x / patchSize)][int(bob.pos.y / patchSize)].addRobot(bob);
  }

  //
  // backward 
  // ========
  // > moves bob backward by a distance of dist
  //
  // input
  // -----
  // > bob = the agent to move
  // > dist = the distance to move backward
  //
  void backward(Robot bob, float dist) {
    // remove bob from its current patch
    patches[int(bob.pos.x / patchSize)][int(bob.pos.y / patchSize)].removeRobot(bob);
    // compute the target position
    bob.pos.x += dist * patchSize * cos(bob.heading + PI);
    bob.pos.y += dist * patchSize * sin(bob.heading + PI);
    // take wrapping into account
    wrapPosition(bob.pos);
    // add bob in the target patch
    patches[int(bob.pos.x / patchSize)][int(bob.pos.y / patchSize)].addRobot(bob);
  }

  //
  // freePatch
  // =========
  // > checks if the patch at position p is free
  //
  // input
  // -----
  // > p = the position to check
  //
  // output
  // ------
  // true if no robots nor walls on the patch  
  //
  boolean freePatch(PVector p) {
    return ((patches[int(p.x / patchSize)][int(p.y / patchSize)].robots.size() == 0) &&
      (patches[int(p.x / patchSize)][int(p.y / patchSize)].walls.size() == 0));
  }

  //
  // freeAhead
  // =========
  // > checks if the way is free ahead of bob in a given cone
  //
  // input
  // -----
  // > bob = the robot of reference
  // > dist = the size of the cone
  // > angle = the aperture of the cone
  //
  // output
  // ------
  // true if the way is free (no robot nor wall ahead)
  //
  boolean freeAhead(Robot bob, float dist, float angle) {
    // for all robots
    for (Robot r : robots) {
      // if r is not bob and is close enough
      if ((r != bob) && (distance(bob, r) <= dist)) {
        // check if r is in the cone
        float a = bob.towards(r);
        if (((a >= bob.heading - angle) && (a <= bob.heading + angle)) ||
          ((bob.heading + angle >= TWO_PI) && (a + TWO_PI <= bob.heading + angle)) ||
          ((bob.heading - angle <= 0) && (a - TWO_PI >= bob.heading - angle)))
          return false;
      }
    }
    // for all walls
    for (Wall w : walls) {
      // if w is close enough
      if (distance(bob, w) <= dist) {
        // check if w is in the cone
        float a = bob.towards(w);
        if (((a >= bob.heading - angle) && (a <= bob.heading + angle)) ||
          ((bob.heading + angle >= TWO_PI) && (a + TWO_PI <= bob.heading + angle)) ||
          ((bob.heading - angle <= 0) && (a - TWO_PI >= bob.heading - angle)))
          return false;
      }
    }
    return true;
  }

  //
  // newRandomWalls
  // ==============
  // > randomely creates a number of walls 
  //
  // input
  // -----
  // > qty = half the number of walls to create
  //
  void newRandomWalls(int qty) {
    for (int i=0; i<qty; i++) {
      // create a new wall randomely
      PVector p1 = new PVector(random(width), random(height - 100));
      newWall(p1, gray);
      // create a symmetric wall in the map
      PVector p2 = new PVector((int)(p1.x + width / 2) % width, p1.y);
      newWall(p2, gray);
    }
  }

  //
  // newRandomBurgers
  // ================
  // > randomely creates a number of burgers 
  //
  // input
  // -----
  // > qty = half the number of burgers to create
  //
  void newRandomBurgers(int qty) {
    // randomly choose the position 
    PVector p = new PVector(random(w), random(h));
    // generate a stock of burgers at that place
    generateBurgers(p, qty);
    // create a symmetric stock in the map
    p.x = (p.x + width / 2) % width;
    generateBurgers(p, qty);
  }

  //
  // generateBurgers
  // ===============
  // > generates a stock of burgers at a given position
  //
  // input
  // -----
  // > p = the position
  // > qty = the number of burgers to create 
  //
  void generateBurgers(PVector p, int qty) {
    PVector q;
    float angle, dist;

    // for each burger
    for (int i=1; i<=qty; i++) {
      // choose a random position around p in a radius of 2 patches
      angle = random(TWO_PI);
      dist = random(2) * patchSize;
      q = new PVector(p.x + dist * cos(angle), p.y + dist * sin(angle)); 
      wrapPosition(q);
      // add a new burger at that place
      addBurger(new Burger(q));
    }
  }

  //
  // addBurger
  // =========
  // > adds a burger
  //
  // input
  // -----
  // > zorg = the burger to add
  //
  void addBurger(Burger zorg) {
    // add zorg in the list of burgers
    burgers.add(zorg);
    // add zorg in the corresponding patch
    patches[int(zorg.pos.x / patchSize)][int(zorg.pos.y / patchSize)].addBurger(zorg);
  }

  //
  // removeMissile
  // =============
  // > removes a missile
  //
  // input
  // -----
  // > miss = the missile to remove
  //
  void removeMissile(Missile miss) {
    // search for the missile in the list of missiles
    for (int i=0; i<missiles.size(); i++)
      if (missiles.get(i) == miss) {
        // remove it when found
        missiles.remove(i);
      }
  }

  //
  // removeBurger
  // ============
  // > removes a burger
  //
  // input
  // -----
  // > zorg = the burger to remove
  //
  void removeBurger(Burger zorg) {
    // remove the burger from its patch
    patches[int(zorg.pos.x / patchSize)][int(zorg.pos.y / patchSize)].removeBurger(zorg);
    // search for the burger in the list of burgers
    for (int i=0; i<burgers.size(); i++)
      if (burgers.get(i) == zorg) {
        // remove it when found
        burgers.remove(i);
      }
  }

  //
  // removeSeed
  // ==========
  // > removes a seed
  //
  // input
  // -----
  // > sid = the seed to remove
  //
  void removeSeed(Seed sid) {
    // remove the seed from its patch
    patches[int(sid.pos.x / patchSize)][int(sid.pos.y / patchSize)].removeSeed(sid);
    // search for the seed in the list of seeds
    for (int i=0; i<seeds.size(); i++)
      if (seeds.get(i) == sid) {
        // remove it when found
        seeds.remove(i);
      }
  }

  //
  // plantSeed
  // =========
  // > plants a seed
  //
  // input
  // -----
  // > bob = the robot that wants to plant a seed
  // > p = the position of the plantation
  // > c = the color of the seed 
  //
  void plantSeed(Robot bob, PVector p, color c) {
    if (bob.carryingFood > seedCost) {
      // check for the number of seeds and walls in that location
      int nbSeeds = patches[int(p.x / patchSize)][int(p.y / patchSize)].seeds.size();
      int nbWalls = patches[int(p.x / patchSize)][int(p.y / patchSize)].walls.size();
      // if no walls and maximum number of seeds not reached yet
      if ((nbSeeds < maxSeeds) && (nbWalls == 0)) {
        // create a new seed
        Seed sid = new Seed(p, c);
        // add it to the list of seeds
        seeds.add(sid);
        // add it to the corresponding patch
        patches[int(p.x / patchSize)][int(p.y / patchSize)].seeds.add(sid);
        // it has a cost
        bob.carryingFood -= seedCost;
      }
    }
  }

  //
  // removeWall
  // ==========
  // > removes a wall
  //
  // input
  // -----
  // > wally = the wall to remove
  //
  void removeWall(Wall wally) {
    // remove the wall from its patch
    patches[int(wally.pos.x / patchSize)][int(wally.pos.y / patchSize)].removeWall(wally);
    // search for wally in the list of walls
    for (int i=0; i<walls.size(); i++)
      if (walls.get(i) == wally) {
        // remove it when found
        walls.remove(i);
      }
  }
}
