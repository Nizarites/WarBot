///////////////////////////////////////////////////////////////////////////
//
// The main program
// ================
// v 1.2 (c) Guillaume Hutzler, 2022
//
///////////////////////////////////////////////////////////////////////////
// TODO
// - ajouter la possibilite de détruire les murs avec des bullets 
// - optimiser la recherche de patch libre autour
// - optimiser la perception
// - ajouter un coût à l'envoi de messages
// !!!!!!!!
// - ajouter la possibilité de reply/forward les messages
// - possibilité de placer les bases
// - ajouter une capacité max de transport de nourriture pour les robots
///////////////////////////////////////////////////////////////////////////

// the main object to control the game
Simulation game;
// the main object to organize a tournament
Tournament tournament;
// the mouse
Mouse mouse;

///////////////////////////////////////////////////////////////////////////
//
// defines the dimensions of the window depending on
// - the dimensions of the environment 
// - the size of a patch (in pixels) 
//
///////////////////////////////////////////////////////////////////////////
void settings() {
  size(nbPatchesX * patchSize, nbPatchesY * patchSize + 100);
}

///////////////////////////////////////////////////////////////////////////
//
// creates and initializes the game
// ================================
//
///////////////////////////////////////////////////////////////////////////
void setup() {
  imageMode(CENTER);
  textAlign(CENTER, CENTER);
  if (!tournamentMode) {
    game = new Simulation();
    game.setup();
  } else {
    tournament = new Tournament();
    tournament.go();
    noLoop();
  }
}

///////////////////////////////////////////////////////////////////////////
//
// main loop
// =========
//
///////////////////////////////////////////////////////////////////////////
void draw() {
  if (!tournamentMode) {
    // activates every agent of the game
    game.go();
    // updates the display
    game.display();
    // makes the clock advance 
    game.tick();
  }
}

///////////////////////////////////////////////////////////////////////////
//
// user interaction
// ================
//
///////////////////////////////////////////////////////////////////////////
void keyTyped() {
  switch(key) {
    // to display the state of the "brain"
  case '0':
  case '1':
  case '2':
  case '3':
  case '4':
  case '5':
  case '6':
  case '7':
  case '8':
  case '9':
    if (display == 10 + key - '0')
      display = -1;
    else
      display = 10 + key - '0';
    break;
  case 'h':
    // to display help
    fill(255);
    text("'e' : display energy", 50, 50);
    text("'f' : display food", 50, 70);
    text("'m' : display missiles", 50, 90);
    text("'p' : display patches", 50, 110);
    text("'r' : display ranges", 50, 130);
    break;
  case 'e':
    // to display energy
    if (display == ENERGY)
      display = -1;
    else
      display = ENERGY;
    break;
  case 'f':
    // to display the amount of food carried by the agents
    if (display == C_FOOD)
      display = -1;
    else
      display = C_FOOD;
    break;
  case 'm':
    // to display the number of missiles carried by the agents
    if (display == MISSILES)
      display = -1;
    else
      display = MISSILES;
    break;
  case 'p':
    // to display (or not) the patches
    displayPatches = !displayPatches;
    break;
  case 'r':
    // to display (or not) the range of perception
    displayRange = !displayRange;
    break;
  }
}
