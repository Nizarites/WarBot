///////////////////////////////////////////////////////////////////////////
//
// The global parameters of the game
// =================================
//
///////////////////////////////////////////////////////////////////////////
// turtle breeds
final int BASE = 0;
final int EXPLORER = 1;
final int HARVESTER = 2;
final int LAUNCHER = 3;
final int SEED = 4;
final int BURGER = 5;
final int WALL = 6;
final int BULLET = 7;
final int FAF = 8;

// predefined colors
final color red = color(255, 0, 0);
final color green = color(0, 255, 0);
final color gray = color(128);

// to handle display
float scale = 0.2;
int patchSize = 10;

// dimensions of the environment
int nbPatchesX = 120;
int nbPatchesY = 60;

// the maximum number of iterations for a game
int maxTicks = 25000;
boolean tournamentMode = false;

// specifies what has to be displayed
int display = 0;
boolean displayPatches = false;
boolean displayRange = true;
final int ENERGY = 0;
final int C_FOOD = 1;
final int MISSILES = 2;
final int BRAIN0 = 10;
final int BRAIN1 = 11;
final int BRAIN2 = 12;
final int BRAIN3 = 13;
final int BRAIN4 = 14;
final int BRAIN5 = 15;
final int BRAIN6 = 16;
final int BRAIN7 = 17;
final int BRAIN8 = 18;
final int BRAIN9 = 19;

// Bases parameters
int baseNrj = 50000;
int basePerception = 10;
float baseSpeed = 0;
int baseNbBullets = 1000;
int baseMaxBullets = 1000;
int baseNbFafs = 20;
int baseMaxFafs = 100;
int baseWaiting = 1;
int baseBurgers = 20;
float baseMetabolism = 1;

// Explorers parameters
int explorerCost = 3000;
int explorerNrj = 1000;
int explorerPerception = 10;
float explorerSpeed = 1;
float explorerMetabolism = 0.1;
int explorerBurgers = 2;

// Harvesters parameters
int harvesterCost = 4000;
int harvesterNrj = 2000;
int harvesterPerception = 3;
float harvesterSpeed = 0.25;
float harvesterMetabolism = 0.1;
int harvesterBurgers = 2;

// RocketLaunchers parameters
int launcherCost = 6000;
int launcherNrj = 4000;
int launcherPerception = 5;
float launcherSpeed = 0.5;
float launcherMetabolism = 0.1;
int launcherBurgers = 2;
int launcherNbBullets = 1000;
int launcherMaxBullets = 1000;
int launcherNbFafs = 0;
int launcherMaxFafs = 0;
int launcherWaiting = 5; 

// Burgers parameters
int burgerQuantity = 100;
int burgerPeriodicity = 2000;
int wildBurgerMinNrj = 50;
int wildBurgerMaxNrj = 100;
int domesticBurgerMinNrj = 100;
int domesticBurgerMaxNrj = 150;
float burgerDecay = 0.1;

// seeds parameters
int seedCost = 20;
int maxSeeds = 5;
int maturationTime = 1000;
int maturationCrush = 100;

// walls parameters
int wallCost = 100;
int wallNrj = 1000;

// bullets parameters
int bulletCost = 1;
int bulletRange = 10;
int bulletDamageToRobot = 50;
int bulletDamageToBase = 20;
float bulletSpeed = 1;

// fafs parameters
int fafCost = 50;
int fafRange = 20;
int fafDamageToRobot = 200;
int fafDamageToBase = 40;
int fafSpeed = 1;

// collisions parameters
int baseCollisionDamage = 100;
int botCollisionDamage = 1000;
float collisionAngle = 3 * PI / 8;

// messages parameters
int messageRange = 10;
