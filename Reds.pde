  ///////////////////////////////////////////////////////////////////////////
//
// The code for the red team
// ===========================
//
///////////////////////////////////////////////////////////////////////////

class RedTeam extends Team {
  PVector base1, base2;

  // coordinates of the 2 bases, chosen in the rectangle with corners
  // (width/2, 0) and (width, height-100)
  RedTeam() {
    // first base
    base1 = new PVector(width/2 + 300, (height - 100)/2 - 150);
    // second base
    base2 = new PVector(width/2 + 300, (height - 100)/2 + 150);
  }  
}

interface RedRobot {
  final int INFORM_ABOUT_COALLITION = 5;
  final int INFORM_ABOUT_QUIT_COALLITION = 6;
  final int INFORM_ABOUT_JOIN_COALLITION = 7;
  final int INFORM_ABOUT_TARGET_COALLITION = 8;
  final int INFORM_ABOUT_TARGET_URGENCY = 9;

}

///////////////////////////////////////////////////////////////////////////
//
// The code for the green bases
// map of the brain:
//   0 = position of one ennemy base
//   1 = position of the other ennemy base
//   4 = the number of ennemy bases known
//
///////////////////////////////////////////////////////////////////////////
class RedBase extends Base implements RedRobot {
  //
  // constructor
  // ===========
  //
  RedBase(PVector p, color c, Team t) {
    super(p, c, t);
  }

  //
  // setup
  // =====
  // > called at the creation of the base
  //
  void setup() {
    // creates a new harvester
    newHarvester();
    // 7 more harvesters to create
    brain[5].x = 7;
  }

  //
  // go
  // ==
  // > called at each iteration of the game
  // > defines the behavior of the agent
  //
  void go() {
    // handle received messages 
    handleMessages();
    // creates new robots depending on energy and the state of brain[5]
    if ((brain[5].x > 0) && (energy >= 1000 + harvesterCost)) {
      // 1st priority = creates harvesters 
      if (newHarvester())
        brain[5].x--;
    } else if ((brain[5].y > 0) && (energy >= 1000 + launcherCost)) {
      // 2nd priority = creates rocket launchers 
      if (newRocketLauncher())
        brain[5].y--;
    } else if ((brain[5].z > 0) && (energy >= 1000 + explorerCost) && brain[4].y != 2) {
      // 3rd priority = creates explorers 
      if (newExplorer())
        brain[5].z--;
    } else if (energy > 12000) {
      // if no robot in the pipe and enough energy 
      if ((int)random(2) == 0){
        // creates a new harvester with 50% chance
        brain[5].x++;
      } else if ((int)random(2) == 0 || brain[4].y == 2){
        // creates a new rocket launcher with 25% chance or if all bases are known
        brain[5].y++;
      } else {
        // creates a new explorer with 25% chance
        brain[5].z++;
      }
    }

    // creates new bullets and fafs if the stock is low and enought energy
    if ((bullets < 10) && (energy > 1000))
      newBullets(50);
    if ((bullets < 10) && (energy > 1000))
      newFafs(10);

    // if ennemy rocket launcher in the area of perception
    Robot bob = (Robot)minDist(perceiveRobots(ennemy, LAUNCHER));
    if (bob != null) {
      heading = towards(bob);
      // launch a faf if no friend robot on the trajectory...
      if (perceiveRobotsInCone(friend, heading) == null)
        launchFaf(bob);
      else {
        Robot rocketL = (Robot) minDist(perceiveRobots(friend, LAUNCHER));
        if(rocketL != null){
          informAboutTargetImmediatly(rocketL, bob);
        }
      }
    }

    // if ally rocket lancher in the area of perception and we already know at least one base
    if(brain[4].y != 0){
       ArrayList<Robot> bobs = perceiveRobots(ennemy, LAUNCHER);
      if(bobs != null){
        for(Robot rocketL : bobs){
          int base = 0;
          if(brain[4].y == 2){
            base = (int)random(2);
          } else if(brain[1].x != 0 && brain[1].y != 0){
            base = 1;
          }
          informAboutTargetImmediatly(rocketL, game.getRobot(int(brain[base].z)));
        }
      }
    }
  }

  //
  // handleMessage
  // =============
  // > handle messages received since last activation 
  //
  void handleMessages() {
    Message msg;
    // for all messages
    for (int i=0; i<messages.size(); i++) {
      msg = messages.get(i);
      if (msg.type == ASK_FOR_ENERGY) {
        // if the message is a request for energy
        if (energy > 1000 + msg.args[0]) {
          // gives the requested amount of energy only if at least 1000 units of energy left after
          giveEnergy(msg.alice, msg.args[0]);
        }
      } else if (msg.type == ASK_FOR_BULLETS) {
        // if the message is a request for energy
        if (energy > 1000 + msg.args[0] * bulletCost) {
          // gives the requested amount of bullets only if at least 1000 units of energy left after
          giveBullets(msg.alice, msg.args[0]);
        }
      }
      else if (msg.type == INFORM_ABOUT_TARGET) {
        // pour prendre en compte les messages d’information au sujet de la position de bases ennemies.
        // Enregistre la position de la base ennemie dans la structure brain
        if((brain[0].x == msg.args[0] && brain[0].y == msg.args[1]) || (brain[1].x == msg.args[0] && brain[1].y == msg.args[1])){ 
          //La base est déjà connue
          //on skip
        } else if(brain[4].y == 1){
          brain[1].x = msg.args[0];
          brain[1].y = msg.args[1];
          brain[1].z = msg.args[3];
          brain[4].y += 1;
        } else {
          brain[0].x = msg.args[0];
          brain[0].y = msg.args[1];
          brain[0].z = msg.args[3];
          brain[4].y += 1;
        }
        
        
        // Envoie un message à tous les robots pour les informer de la position de la base ennemie présente dans sa zone de perception
        Robot ennemyBase = null;
        for (Robot greenBase : game.greenBases) {
          if (greenBase.pos.equals(brain[0])) {
            ennemyBase = greenBase;
            break;
          }
        }

        if (ennemyBase != null) {
          ArrayList<Robot> robots = this.perceiveRobots(friend, LAUNCHER);
          if(robots != null){
            for (Robot allyRobot : robots ) {
              if(allyRobot != null){
                informAboutTarget(allyRobot, ennemyBase);
              }
            }
          }
        }
      }
      }
    // clear the message queue
    flushMessages();
  }

  //
  // informAboutTargetImmediatly
  // =================
  // > sends a INFORM_ABOUT_TARGET_URGENCY message to another robot
  //
  // input
  // -----
  // > bob = the receiver
  // > target = the target robot
  //
  void informAboutTargetImmediatly(Robot bob, Robot target) {
    // check that bob and target both exist and distance less than max range
    if ((bob != null) && (target != null) && (distance(bob) < messageRange)) {
      // build the message...
      float[] args = new float[4];
      args[0] = target.pos.x;
      args[1] = target.pos.y;
      args[2] = target.breed;
      args[3] = target.who;
      Message msg = new Message(INFORM_ABOUT_TARGET_URGENCY, who, bob.who, args);
      // ...and add it to bob's messages queue
      bob. messages.add(msg);
    }
  }
}

///////////////////////////////////////////////////////////////////////////
//
// The code for the green explorers
//
///////////////////////////////////////////////////////////////////////////
// map of the brain:
//   4.x = (0 = exploration | 1 = go back to base)
//   4.y = (0 = no target | 1 = locked target)
//   0.x / 0.y = coordinates of the target
//   0.z = type of the target
///////////////////////////////////////////////////////////////////////////
class RedExplorer extends Explorer implements RedRobot {
  //
  // constructor
  // ===========
  //
  RedExplorer(PVector pos, color c, ArrayList b, Team t) {
    super(pos, c, b, t);
  }

  //
  // setup
  // =====
  // > called at the creation of the agent
  //
  void setup() {
  }

  //
  // go
  // ==
  // > called at each iteration of the game
  // > defines the behavior of the agent
  //
  void go() {
    handleMessages();

    // if food to deposit or too few energy
    if ((carryingFood > 200) || (energy < 100))
      // time to go back to base
      brain[4].x = 1;

    // depending on the state of the robot
    // go back to base...
    if (brain[4].x == 1) {
      goBackToBase();
    // ...or explore randomly
    } else {
      randomMove(45);
    }

    // tries to localize ennemy bases
    lookForEnnemyBase();
    // inform harvesters about food sources
    driveHarvesters();
    // inform rocket launchers about targets
    driveRocketLaunchers();

    // clear the message queue
    flushMessages();
  }

  
  void handleMessages() {
    Message msg;
    // for each messages
    for (int i = 0; i < messages.size(); i++) {
      msg = messages.get(i);
      if (msg.type == INFORM_ABOUT_TARGET) {
        // Save target position and its type in the brain structure
        brain[0].x = msg.args[0];
        brain[0].y = msg.args[1];
        brain[0].z = int(msg.args[2]);
        brain[4].x = 1; // go back to base
        brain[4].y = 1; // Indique qu'une cible a été localisée
      }
    }
    // Flush the message queue after processing
    flushMessages();
  }

  //
  // setTarget
  // =========
  // > locks a target
  //
  // inputs
  // ------
  // > p = the location of the target
  // > breed = the breed of the target
  //
  void setTarget(PVector p, int breed) {
    brain[0].x = p.x;
    brain[0].y = p.y;
    brain[0].z = breed;
    brain[4].y = 1;
  }

  //
  // goBackToBase
  // ============
  // > go back to the closest base, either to deposit food or to reload energy
  //
  void goBackToBase() {
    // bob is the closest base
    Base bob = (Base)minDist(myBases);
    ArrayList<RedBase> allyBases = (ArrayList<RedBase>) perceiveRobots(friend, BASE);
    if(allyBases != null){
      for(RedBase allyBase : allyBases){
        if(brain[4].y == 1 && brain[0].z == BASE){ // If target locked is ennemy base
          // Identify ennemy base with its position
          Robot ennemyBase = null;
          for (Robot greenBase : game.greenBases) {
            if (greenBase.pos.equals(brain[0])) {
              ennemyBase = greenBase;
              break;
            }
          }
          if(ennemyBase != null){
            informAboutTarget(allyBase, ennemyBase);
          }
          brain[4].y = 0; // Explorer has no more target
        }
      }
    }

    if (bob != null) {
      // if there is one (not all of my bases have been destroyed)
      float dist = distance(bob);

      // if I am next to the base
      if (dist <= 2) {
        if(this.carryingFood > 0){
          // I give the food
          giveFood(bob, this.carryingFood);
        }
        if (energy < 500)
          // if my energy is low, I ask for some more
          askForEnergy(bob, 1500 - energy);
        // switch to the exploration state
        brain[4].x = 0;
        // make a half turn
        right(180);
      } else {
        // if still away from the base
        // head towards the base (with some variations)...
        heading = towards(bob) + random(-radians(20), radians(20));
        // ...and try to move forward 
        tryToMoveForward();
        if(brain[4].y == 1 && brain[0].z == BASE){
          ArrayList<Robot> launcherAlly = perceiveRobots(friend, LAUNCHER);
          if(launcherAlly != null){
            Robot ennemyBase = null;
            for (Robot greenBase : game.greenBases) {
              if (greenBase.pos.equals(brain[0])) {
                ennemyBase = greenBase;
                break;
              }
            }
            if(ennemyBase != null){
              for(Robot ally : launcherAlly){
                  informAboutTarget(ally, ennemyBase);
              }
            }
          }
        }
      }
    }
  }

  //
  // target
  // ======
  // > checks if a target has been locked
  //
  // output
  // ------
  // true if target locket / false if not
  //
  boolean target() {
    return (brain[4].y == 1);
  }

  //
  // driveHarvesters
  // ===============
  // > tell harvesters if food is localized
  //
  void driveHarvesters() {
    // look for burgers
    Burger zorg = (Burger)oneOf(perceiveBurgers());
    if (zorg != null) {
      // if one is seen, look for a friend harvester
      Harvester harvey = (Harvester)oneOf(perceiveRobots(friend, HARVESTER));
      if (harvey != null)
        // if a harvester is seen, send a message to it with the position of food
        informAboutFood(harvey, zorg.pos);
    }
  }

  //
  // driveRocketLaunchers
  // ====================
  // > tell rocket launchers about potential targets
  //
  void driveRocketLaunchers() {
    // look for an ennemy robot 
    Robot bob = (Robot)oneOf(perceiveRobots(ennemy));
    if (bob != null) {
      // if one is seen, look for a friend rocket launcher
      RocketLauncher rocky = (RocketLauncher)oneOf(perceiveRobots(friend, LAUNCHER));
      if (rocky != null)
        // if a rocket launcher is seen, send a message with the localized ennemy robot
        informAboutTarget(rocky, bob);
    }
  }

  //
  // lookForEnnemyBase
  // =================
  // > try to localize ennemy bases...
  // > ...and to communicate about this to other friend explorers
  //
  void lookForEnnemyBase() {
    // look for an ennemy base
    Base babe = (Base)oneOf(perceiveRobots(ennemy, BASE));
    if (babe != null) { 
      // Stock information about localized base
      setTarget(babe.pos, BASE);
      brain[4].x = 1;

      // if one is seen, look for a friend explorer
      Explorer explo = (Explorer)oneOf(perceiveRobots(friend, EXPLORER));
      if (explo != null){
        // if one is seen, send a message with the localized ennemy base
        informAboutTarget(explo, babe);
      }
      // look for a friend base
      // This condition seems weird as it would mean that we look for our base while perceiving an ennemy base
      Base basy = (Base)oneOf(perceiveRobots(friend, BASE));
      if (basy != null){
        // if one is seen, send a message with the localized ennemy base
        informAboutTarget(basy, babe);
      }
    }
  }

  //
  // tryToMoveForward
  // ================
  // > try to move forward after having checked that no obstacle is in front
  //
  void tryToMoveForward() {
    // if there is an obstacle ahead, rotate randomly
    while (!freeAhead(speed) || ((Robot)game.minDist(this, game.perceiveRobotsInCone(this, collisionAngle, speed)) != null)){
      right(random(360));
    }

    // if there is no obstacle ahead, move forward at full speed
    if (freeAhead(speed))
      forward(speed);
  }
}

///////////////////////////////////////////////////////////////////////////
//
// The code for the green harvesters
//
///////////////////////////////////////////////////////////////////////////
// map of the brain:
//   4.x = (0 = look for food | 1 = go back to base) 
//   4.y = (0 = no food found | 1 = food found)
//   0.x / 0.y = position of the localized food
///////////////////////////////////////////////////////////////////////////
class RedHarvester extends Harvester implements RedRobot {
  //
  // constructor
  // ===========
  //
  RedHarvester(PVector pos, color c, ArrayList b, Team t) {
    super(pos, c, b, t);
  }

  //
  // setup
  // =====
  // > called at the creation of the agent
  //
  void setup() {
  }

  //
  // go
  // ==
  // > called at each iteration of the game
  // > defines the behavior of the agent
  //
  void go() {
    // handle messages received
    handleMessages();

    // check for the closest burger
    Burger b = (Burger)minDist(perceiveBurgers());
    if ((b != null) && (distance(b) <= 2))
      // if one is found next to the robot, collect it
      takeFood(b);
    // if harvester has food, give it to nearby explorer
    if(carryingFood > 200){
      RedExplorer nearbyExplorer = (RedExplorer) oneOf(this.perceiveRobots(friend, EXPLORER));
      if(nearbyExplorer != null){
        giveFood(nearbyExplorer, this.carryingFood);
      }  
    }

    // if food to deposit or too few energy
    if ((carryingFood > 200) || (energy < 100))
      // time to go back to the base
      brain[4].x = 1;

    // if in "go back" state
    if (brain[4].x == 1) {
      // go back to the base
      goBackToBase();

      // if enough energy and food
      if ((energy > 100) && (carryingFood > 100)) {
        // check for closest base
        Base bob = (Base)minDist(myBases);
        if (bob != null) {
          // if there is one and the harvester is in the sphere of perception of the base
          if (distance(bob) < basePerception)
            // plant one burger as a seed to produce new ones
            plantSeed();
        }
      }
    } else
      // if not in the "go back" state, explore and collect food
      goAndEat();
  }

  //
  // goBackToBase
  // ============
  // > go back to the closest friend base
  //
  void goBackToBase() {
    // look for the closest base
    Base bob = (Base)minDist(myBases);
    if (bob != null) {
      // if there is one
      float dist = distance(bob);
      if ((dist > basePerception) && (dist < basePerception + 1))
        // if at the limit of perception of the base, drops a wall (if it carries some)
        dropWall();

      if (dist <= 2) {
        // if next to the base, gives the food to the base
        giveFood(bob, carryingFood);
        if (energy < 500)
          // ask for energy if it lacks some
          askForEnergy(bob, 1500 - energy);
        // go back to "explore and collect" mode
        brain[4].x = 0;
        // make a half turn
        right(180);
      } else {
        // if still away from the base
        // head towards the base (with some variations)...
        heading = towards(bob) + random(-radians(20), radians(20));
        // ...and try to move forward
        tryToMoveForward();
      }
    }
  }

  //
  // goAndEat
  // ========
  // > go explore and collect food
  //
  void goAndEat() {
    // look for the closest wall
    Wall wally = (Wall)minDist(perceiveWalls());
    // look for the closest base
    Base bob = (Base)minDist(myBases);
    if (bob != null) {
      float dist = distance(bob);
      // if wall seen and not at the limit of perception of the base 
      if ((wally != null) && ((dist < basePerception - 1) || (dist > basePerception + 2)))
        // tries to collect the wall
        takeWall(wally);
    }

    // look for the closest burger
    Burger zorg = (Burger)minDist(perceiveBurgers());
    if (zorg != null) {
      // if there is one
      if (distance(zorg) <= 2)
        // if next to it, collect it
        takeFood(zorg);
      else {
        // if away from the burger, head towards it...
        heading = towards(zorg) + random(-radians(20), radians(20));
        // ...and try to move forward
        tryToMoveForward();
      }
    } else if (brain[4].y == 1) {
      // if no burger seen but food localized (thank's to a message received)
      if (distance(brain[0]) > 2) {
        // head towards localized food...
        heading = towards(brain[0]);
        // ...and try to move forward
        tryToMoveForward();
      } else
        // if the food is reached, clear the corresponding flag
        brain[4].y = 0;
    } else {
      // if no food seen and no food localized, explore randomly
      heading += random(-radians(45), radians(45));
      tryToMoveForward();
    }
  }

  //
  // tryToMoveForward
  // ================
  // > try to move forward after having checked that no obstacle is in front
  //
  void tryToMoveForward() {
    // if there is an obstacle ahead, rotate randomly
    while (!freeAhead(speed) || ((Robot)game.minDist(this, game.perceiveRobotsInCone(this, collisionAngle, speed)) != null)){
      right(random(360));
    }

    // if there is no obstacle ahead, move forward at full speed
    if (freeAhead(speed))
      forward(speed);
  }

  //
  // handleMessages
  // ==============
  // > handle messages received
  // > identify the closest localized burger
  //
  void handleMessages() {
    float d = width;
    PVector p = new PVector();

    Message msg;
    // for all messages
    for (int i=0; i<messages.size(); i++) {
      // get next message
      msg = messages.get(i);
      // if "localized food" message
      if (msg.type == INFORM_ABOUT_FOOD) {
        // record the position of the burger
        p.x = msg.args[0];
        p.y = msg.args[1];
        if (distance(p) < d) {
          // if burger closer than closest burger
          // record the position in the brain
          brain[0].x = p.x;
          brain[0].y = p.y;
          // update the distance of the closest burger
          d = distance(p);
          // update the corresponding flag
          brain[4].y = 1;
        }
      }
    }
    // clear the message queue
    flushMessages();
  }
}

///////////////////////////////////////////////////////////////////////////
//
// The code for the green rocket launchers
//
///////////////////////////////////////////////////////////////////////////
// map of the brain:
//   0.x / 0.y = position of the target
//   0.z = breed of the target
//   1.x = (0 = No Tactical formation | 1 = Tactical formation)
//   1.y = id of the tactical formation leader 
//   1.z = id of his tactical formation junior
//   2.x = (0 = follow leader | 1 = go attack with coallition)
//   4.x = (0 = look for target | 1 = go back to base) 
//   4.y = (0 = no target | 1 = localized target)
///////////////////////////////////////////////////////////////////////////
class RedRocketLauncher extends RocketLauncher implements RedRobot {
  //
  // constructor
  // ===========
  //
  RedRocketLauncher(PVector pos, color c, ArrayList b, Team t) {
    super(pos, c, b, t);
  }

  //
  // setup
  // =====
  // > called at the creation of the agent
  //
  void setup() {
  }

  void handleMessages() {
    Message msg;
    // pour tous les messages
    for (int i = 0; i < messages.size(); i++) {
      msg = messages.get(i);
      if (msg.type == INFORM_ABOUT_TARGET_URGENCY) {
        // Enregistre la position de la cible et son type dans la structure brain
        setPositionXYTarget(msg.args[0], msg.args[1]);
        setBreedTarget(int(msg.args[2]));
        setTarget(true);
        if(amIInCoalition() && getIdLeader() != who)
          informLeaderAboutTarget();
      } else if (msg.type == INFORM_ABOUT_TARGET_COALLITION && msg.alice == getIdLeader() && amIInCoalition()) {
        // Enregistre la position de la cible et son type
        setPositionXYTarget(msg.args[0], msg.args[1]);
        setBreedTarget(int(msg.args[2]));
        setTarget(true);
        setAttackWithCoalition(true);
        if(getIdJunior() != 0)
          launchInformAboutTargetCoalition();
      } 
      else if (msg.type == INFORM_ABOUT_TARGET) {
        // Enregistre la position de la cible et son type
        if(getBreedTarget() == BASE && isThereEnnemiesBases()) continue; 
        else {
          setPositionXYTarget(msg.args[0], msg.args[1]);
          setBreedTarget(int(msg.args[2]));
          setTarget(true);
        }
      } 
      else if (msg.type == INFORM_ABOUT_COALLITION && !amIInCoalition()) {
        setTacticalFormation(true, msg.alice);
        if(getIdJunior() != msg.alice){
          informAboutJoinCoalition(game.getRobot(getIdLeader()));
        }
      } else if (msg.type == INFORM_ABOUT_JOIN_COALLITION && getIdJunior() == 0 && getIdLeader() != msg.alice) {
        if(getIdLeader() == 0)
          setTacticalFormation(true, who);
        else setTacticalFormation(true, getIdLeader());
        updateIdJunior(msg.alice);
      }
      else if (msg.type == INFORM_ABOUT_QUIT_COALLITION && amIInCoalition()) {
        if(getIdLeader() == msg.alice){ // c'est notre leader qui nous envoie un message (update leader)
          updateIdLeader(int(msg.args[0]));
        } else if(getIdJunior() == msg.alice){ // c'est un sous fifre qui quitte (update sous fifre)
          updateIdJunior(int(msg.args[1]));
        }
      }
    }
    // Effacez la file de messages après traitement
    flushMessages();
  }

  boolean isThereEnnemiesBases(){
    for(Robot r : game.robots){
      if(r.colour == ennemy && r.breed == BASE)
        return true;
    }
    return false;
  }

  //
  // go
  // ==
  // > called at each iteration of the game
  // > defines the behavior of the agent
  //
  void go() {
    // handle messages received
    handleMessages();
    // if no energy or no bullets
    if ((energy < 100) || (bullets == 0))
    {
      // go back to the base
      setBackHome(true);
    }

    if (backToBase()) {
      // get out of the coalliton
      if(amIInCoalition()){
        setTacticalFormation(false, 0);
        updateIdJunior(0);
        updateIdLeader(0);
        setAttackWithCoalition(false);
        launchInformAboutQuitCoalition();
      }
      
      // if in "go back to base" modes
      goBackToBase();
    } else if(!target()){
      // try to find a target
      selectTarget();
      // We check if any ally are in range to make a coallition 
      lookForCoallition();
    }
    if (target()) { // if target identified
      //Check if we see ennemy base
      ArrayList<Robot> ennemiesBase = perceiveRobots(ennemy, BASE);
      if(ennemiesBase != null){
        Robot bob = ennemiesBase.get(0);
        setPositionXYTarget(bob.pos.x, bob.pos.y);
        setBreedTarget(bob.breed);
      }

      //Informed the coallition that a target has been detected, if we have a leader
      if (amIInCoalition() && getIdLeader() != who) { //Junior mode
        informLeaderAboutTarget();
        if(attackWithCoalition()){
          attackTarget();
        } else {
          moveToLeader();    
        }
      } else if(amIInCoalition() && getIdLeader() == who){ // THE leader mode
        launchInformAboutTargetCoalition();
        attackTarget();
      } else {
        attackTarget();
      }
    } else if(amIInCoalition() && getIdLeader() != who) { //Junior mode
      // Follow the leader if there is one
      moveToLeader();    
    } else {// else explore randomly
      randomMove(45);
    }
  }

  // attackTarget
  // ============
  // > try to attack the localized target
  //
  void attackTarget(){
    // if close enough to the target, shoot
    if (distance(brain[0]) <=  bulletRange) {
      launchBullet(towards(brain[0]));
      setTarget(false);
    } else {
      // if not close enough, head towards the target...
      heading = towards(brain[0]);
      // ...and try to move forward
      tryToMoveForward();
    }
  }
  
  // lookForCoallition
  // ============
  // > try to localize a ally to make a coallition
  //
    void lookForCoallition() {
      ArrayList<Robot> allyInformedAboutCoallition = perceiveRobots(friend, LAUNCHER);
      if(allyInformedAboutCoallition != null){
        for(Robot ally : allyInformedAboutCoallition)
        {
          // look for the closest ally rocket launcher
          if (ally != null && ally.who != getIdJunior() && ally.who != getIdLeader() && distance(ally) < messageRange) {
            // if one is found within message range, send a coallition message
            informAboutCoallition(ally);
          }
        }
      }
    }
  
  // informLeaderAboutTarget
  // ============
  // > try to inform the leader of the coallition about the target
  //
  void informLeaderAboutTarget(){
      Robot leader = game.getRobot(getIdLeader()); //Récupère le robot leader

       //Récupère la target identifée
       Robot target = null; 
       ArrayList<Robot> rob = new ArrayList<>();
       for(Robot r : game.robots)
        if(r.ennemy == ennemy)
          rob.add(r);

        for (Robot ennemyRobot : rob) {
          if (ennemyRobot.pos.equals(brain[0])) {
            target = ennemyRobot;
            break;
          }
        }

        if(target != null){
         informAboutTargetImmediatly(leader, target);
        }
  }

  // launchInformAboutTargetCoalition
  // ============
  // > try to inform my juniors of the coallition about the target
  //
  void launchInformAboutTargetCoalition(){
    //Récupère la target identifée
    Robot target = null; 
    for(Robot r : game.robots){
      if(r.ennemy == ennemy && r.pos.equals(brain[0])){
        target = r;
        break;
      }
    }

    if(target != null){
      ArrayList<Robot> robots = perceiveRobots(friend, LAUNCHER);
      if(robots != null){
        for(Robot r : robots){
          informAboutTargetCoalition(r, target);
        }
      }
    }
  }

  // launchInformAboutQuitCoalition
  // ============
  // > try to inform my team that I quit the coalition
  //
  void launchInformAboutQuitCoalition(){
    ArrayList<Robot> robots = perceiveRobots(friend, LAUNCHER);
    if(robots != null){
      for(Robot r : robots){
        informAboutQuitCoalition(r);
      }
    }
  }

  //
  // selectTarget
  // ============
  // > try to localize a target
  //
  void selectTarget() {
    // Check if we see base
    ArrayList<Robot> ennemiesBase = perceiveRobots(ennemy, BASE);
    if(ennemiesBase != null){
      Robot bob = ennemiesBase.get(0);
      setPositionXYTarget(bob.pos.x, bob.pos.y);
      setBreedTarget(bob.breed);
      // locks the target
      setTarget(true);
      Robot explo = (Robot)minDist(perceiveRobots(friend, EXPLORER));
      if(explo != null){
        informAboutTarget(explo, bob);
      }

    } else {
      // look for the closest ennemy robot
      Robot bob = (Robot)minDist(perceiveRobots(ennemy));
      if (bob != null) {
        // if one found, record the position and breed of the target
        setPositionXYTarget(bob.pos.x, bob.pos.y);
        setBreedTarget(bob.breed);
        // locks the target
        setTarget(true);
      } else
        // no target found
        setTarget(false);
      }    
  }

  // moveToLeader
  // ============
  // > move towards the leader
  //
  void moveToLeader() {
    // head towards the leader
    Robot leader = game.getRobot(getIdLeader());
    if(leader != null){
      heading = towards(leader.pos) + random(-radians(20), radians(20));
      // try to move forward
      tryToMoveForward();

    }
  }


  // moveToTarget
  // ============
  // > move towards the locked target
  //
  void moveToTarget() {
    // head towards the target
    heading = towards(brain[0]) + random(-radians(20), radians(20));
    // try to move forward
    tryToMoveForward();
  }

  //
  // goBackToBase
  // ============
  // > go back to the closest base
  //
  void goBackToBase() {
    // look for closest base
    Base bob = (Base)minDist(myBases);
    if (bob != null) {
      // if there is one, compute its distance
      float dist = distance(bob);

      if (dist <= 2) {
        // if next to the base
        if (energy < 500)
          // if energy low, ask for some energy
          askForEnergy(bob, 1500 - energy);
        // go back to "exploration" mode
        setBackHome(false);
        brain[4].x = 0;
        // make a half turn
        right(180);
      } else {
        // if not next to the base, head towards it... 
        heading = towards(bob) + random(-radians(20), radians(20));
        // ...and try to move forward
        tryToMoveForward();
      }
    }
  }

  //
  // tryToMoveForward
  // ================
  // > try to move forward after having checked that no obstacle is in front
  //
  void tryToMoveForward() {
    // if there is an obstacle ahead, rotate randomly
    while (!freeAhead(speed) || ((Robot)game.minDist(this, game.perceiveRobotsInCone(this, collisionAngle, speed)) != null)){
      right(random(360));
    }

    // if there is no obstacle ahead, move forward at full speed
    if (freeAhead(speed))
      forward(speed);
  }


  
  // informAboutCoallition
  // =================
  // > sends a INFORM_ABOUT_COALLITION message to another robot
  //
  // input
  // -----
  // > bob = the receiver
  //
  void informAboutCoallition(Robot bob) {
    // check that bob and target both exist and distance less than max range
    if ((bob != null) && (distance(bob) < messageRange)) {
      Message msg = new Message(INFORM_ABOUT_COALLITION, who, bob.who, new float[1]);

      // ...and add it to bob's messages queue
      bob. messages.add(msg);
    }
  }

  // informAboutJoinCoalition
  // =================
  // > sends a INFORM_ABOUT_JOIN_COALLITION message to my leader
  //
  // input
  // -----
  // > bob = the receiver
  //
  void informAboutJoinCoalition(Robot bob){
    // check that bob and target both exist and distance less than max range
    if ((bob != null) && (distance(bob) < messageRange)) {
      Message msg = new Message(INFORM_ABOUT_JOIN_COALLITION, who, bob.who, new float[1]);
      // ...and add it to bob's messages queue
      bob. messages.add(msg);
    }
  }

  //
  // informAboutTargetImmediatly
  // =================
  // > sends a INFORM_ABOUT_TARGET_URGENCY message to another robot
  //
  // input
  // -----
  // > bob = the receiver
  // > target = the target robot
  //
  void informAboutTargetImmediatly(Robot bob, Robot target) {
    // check that bob and target both exist and distance less than max range
    if ((bob != null) && (target != null) && (distance(bob) < messageRange)) {
      // build the message...
      float[] args = new float[4];
      args[0] = target.pos.x;
      args[1] = target.pos.y;
      args[2] = target.breed;
      args[3] = target.who;
      Message msg = new Message(INFORM_ABOUT_TARGET_URGENCY, who, bob.who, args);
      // ...and add it to bob's messages queue
      bob. messages.add(msg);
    }
  }

  //
  // informAboutTargetCoalition
  // =================
  // > sends a INFORM_ABOUT_TARGET_COALLITION message to another robot
  //
  // input
  // -----
  // > bob = the receiver
  // > target = the target robot
  //
  void informAboutTargetCoalition(Robot bob, Robot target){
    if ((bob != null) && (target != null) && (distance(bob) < messageRange)) {
      // build the message...
      float[] args = new float[4];
      args[0] = target.pos.x;
      args[1] = target.pos.y;
      args[2] = target.breed;
      args[3] = target.who;
      Message msg = new Message(INFORM_ABOUT_TARGET_COALLITION, who, bob.who, args);
      // ...and add it to bob's messages queue
      bob. messages.add(msg);
    }
   }

   //
  // informAboutQuitCoalition
  // =================
  // > sends a INFORM_ABOUT_QUIT_COALLITION message to another robot
  //
  // input
  // -----
  // > bob = the receiver
  //
  void informAboutQuitCoalition(Robot bob){
    if ((bob != null) && (distance(bob) < messageRange)) {
      // build the message...
      float[] args = new float[2];
      if(getIdLeader() == who)
        args[0] = getIdJunior();
      else 
        args[0] = getIdLeader();
      args[1] = getIdJunior();
      Message msg = new Message(INFORM_ABOUT_QUIT_COALLITION, who, bob.who, args);
      // ...and add it to bob's messages queue
      bob. messages.add(msg);
    }
   }


  //---------- Functions for the brain ----------//

  //
  // setPositionXYTarget
  // ======
  // > change the position of the localized target
  //
  void setPositionXYTarget(float x, float y){
    brain[0].x = x;
    brain[0].y = y;

    if(amIInCoalition() && getIdLeader() == who){
        launchInformAboutTargetCoalition();
    }
  }

  //
  // setBreedTarget
  // ======
  // > change the breed of the localized target
  //
  void setBreedTarget(int breed){
    brain[0].z = breed;
  }

  //
  // setTacticalFormation
  // ======
  // > save that I am in a coalition and save my leader
  //
  void setTacticalFormation(boolean coalition, int id){
    if(coalition)
      brain[1].x = 1;
    else brain[1].x = 0;
    updateIdLeader(id);
  }

  //
  // updateIdLeader
  // ======
  // > save my new leader
  //
  void updateIdLeader(int id){
    brain[1].y = id;
  }

  //
  // updateIdJunior
  // ======
  // > save my new junior
  //
  void updateIdJunior(int id){
    brain[1].z = id;
  }

  //
  // setAttackWithCoalition
  // ======
  // > save if I have to attack with my team or follow my leader
  //
  void setAttackWithCoalition(boolean attack){
    if(attack)
      brain[2].x = 1;
    else brain[2].x = 0;
  }

  //
  // setBackHome
  // ======
  // > save if I have to back to home or looking for ennemy
  //
  void setBackHome(boolean home){
    if(home)
      brain[4].x = 1;
    else brain[4].x = 0;
  }

  //
  // setTarget
  // ======
  // > save if I have new target
  //
  void setTarget(boolean target){
    if(target)
      brain[4].y = 1;
    else brain[4].y = 0;
  }

  //
  // getPositionXTarget
  // ======
  // > give the x position of the localized target
  //
  // output
  // ------
  // > x position
  //
  float getPositionXTarget(){
    return brain[0].x; 
  }

  //
  // getPositionYTarget
  // ======
  // > give the y position of the localized target
  //
  // output
  // ------
  // > y position
  //
  float getPositinoYTarget(){
     return brain[0].y; 
  }

  //
  // getBreedTarget
  // ======
  // > give the breed of the localized target
  //
  // output
  // ------
  // > breed
  //
  int getBreedTarget(){ 
    return int(brain[0].z); 
  }

  //
  // amIInCoalition
  // ======
  // > check if i am in a coalition
  //
  // output
  // ------
  // > true if i am / false if not
  //
  boolean amIInCoalition(){ 
    return brain[1].x==1 ;
  }

  //
  // getIdLeader
  // ======
  // > give the id of the leader
  //
  // output
  // ------
  // > id of the leader
  //
  int getIdLeader(){ 
    return int(brain[1].y); 
  }

  //
  // getIdJunior
  // ======
  // > give the id of the junior
  //
  // output
  // ------
  // > id of the junior
  //
  int getIdJunior(){ 
    return int(brain[1].z); 
  }

   //
  // attackWithCoalition
  // ======
  // > check if i have to attack with coalition or follow the leader
  //
  // output
  // ------
  // > true if we attack // false if not, then i follow the leader
  //
  boolean attackWithCoalition(){ 
    return brain[2].x==1; 
  }

  //
  // backToBase
  // ======
  // > check if i have to go back to base or looking for target
  //
  // output
  // ------
  // > true if i got back to base // false if not, then i look for target
  //
  boolean backToBase(){ 
    return brain[4].x==1; 
  }
  

  //
  // target
  // ======
  // > checks if a target has been locked
  //
  // output
  // ------
  // > true if target locket / false if not
  //
  boolean target(){
     return brain[4].y==1; 
  }
  
}