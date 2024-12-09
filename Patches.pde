///////////////////////////////////////////////////////////////////////////
//
// Patch
// =====
// > patches correspond to a rectangular grid used to cut the environment
//   in small regions
//
///////////////////////////////////////////////////////////////////////////
class Patch {
  // the position of the patch
  PVector ppos;
  // the list of walls on the patch
  ArrayList<Wall> walls;
  // the list of burgers on the patch  
  ArrayList<Burger> burgers;
  // the list of seeds on the patch
  ArrayList<Seed> seeds;
  // the list of robots on the patch
  ArrayList<Robot> robots;

  //
  // constructor
  // ===========
  //
  Patch(int x, int y) {
    // initialize the position
    ppos = new PVector(x, y);
    // create the lists
    walls = new ArrayList<Wall>();
    burgers = new ArrayList<Burger>();
    seeds = new ArrayList<Seed>();
    robots = new ArrayList<Robot>();
  }

  //
  // addRobot
  // ========
  // > adds a robot to the patch
  //
  // input
  // -----
  // > bob = the robot to add
  //
  void addRobot(Turtle bob) {
    robots.add((Robot)bob);
  }

  //
  // removeRobot
  // ========
  // > removes a robot from the patch
  //
  // input
  // -----
  // > bob = the robot to remove
  //
  void removeRobot(Turtle bob) {
    // scan the list of robots
    for (int i=0; i<robots.size(); i++)
      if (robots.get(i) == bob) {
        // if the robot is the robot to remove 
        robots.remove(i);
        break;
      }
  }

  //
  // addBurger
  // =========
  // > adds a burger to the patch
  //
  // input
  // -----
  // > zorg = the burger to add
  //
  void addBurger(Burger zorg) {
    burgers.add(zorg);
  }

  //
  // removeBurger
  // ============
  // > removes a burger from the patch
  //
  // input
  // -----
  // > zorg = the burger to remove
  //
  void removeBurger(Burger zorg) {
    // scan the list of burgers
    for (int i=0; i<burgers.size(); i++)
      // if the burger is the burger to remove 
      if (burgers.get(i) == zorg) {
        burgers.remove(i);
        break;
      }
  }

  //
  // removeBurger
  // ============
  // > removes a burger from the patch
  //
  // input
  // -----
  // > i = the index of the burger to remove
  //
  void removeBurger(int i) {
    burgers.remove(i);
  }

  //
  // addSeed
  // =======
  // > adds a seed to the patch
  //
  // input
  // -----
  // > sid = the seed to add
  //
  void addSeed(Seed sid) {
    seeds.add(sid);
  }

  //
  // removeSeed
  // ==========
  // > removes a seed from the patch
  //
  // input
  // -----
  // > sid = the seed to remove
  //
  void removeSeed(Seed sid) {
    // scan the list of seeds
    for (int i=0; i<seeds.size(); i++)
      if (seeds.get(i) == sid) {
        // if the seed is the seed to remove
        seeds.remove(i);
        break;
      }
  }

  //
  // removeSeed
  // ==========
  // > removes a seed from the patch
  //
  // input
  // -----
  // > i = the index of the seed to remove
  //
  void removeSeed(int i) {
    seeds.remove(i);
  }

  //
  // nbSeeds
  // =======
  // > return the number of seeds on the patch
  //
  // output
  // ------
  // > the number of seeds on the patch
  //
  int nbSeeds() {
    return seeds.size();
  }

  //
  // addWall
  // =======
  // > adds a wall to the patch
  //
  // input
  // -----
  // > wally = the wall to add
  //
  void addWall(Wall wally) {
    walls.add(wally);
  }

  //
  // removeWall
  // =======
  // > removes a wall from the patch
  //
  // input
  // -----
  // > wally = the wall to remove
  //
  void removeWall(Wall wally) {
    // scan the list of walls
    for (int i=0; i<walls.size(); i++)
      if (walls.get(i) == wally) {
        // if the wall is the wall to remove
        walls.remove(i);
        break;
      }
  }

  //
  // crushSeeds
  // ==========
  // > when the robots move on the patch, crush the seeds on that patch
  // > results in postponing the maturation ot the seeds
  //
  void crushSeeds() {
    for (int i=0; i<seeds.size(); i++)
      seeds.get(i).age -= min(maturationCrush, seeds.get(i).age);
  }

  //
  // go
  // ==
  // > activation of the patches
  //
  void go() {
  }

  //
  // display
  // =======
  // > displays information about the patch
  //
  void display() {
    fill(255);
    text(robots.size(), (ppos.x + 0.5) * patchSize, (ppos.y + 0.5) * patchSize);
  }
}
