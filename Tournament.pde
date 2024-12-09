import java.io.*;

class Tournament {
  String[] equipes = {
    "0.green-team", 
    "1.red-team", 
    "2.red-team2"
  };

  int[] Results;
  double[] Results2;

  Tournament() {
    Results = new int[equipes.length];
    Results2 =  new double[equipes.length];
    
    displayTeams();
  }

  void toGreen(String s) {    
    try {
      println(s+".pde");
      // creation d’un flux de lecture de caracteres dans un fichier
      BufferedReader entree = new BufferedReader(new FileReader(s + ".pde"));
      // creation d’un flux d’ecriture de caracteres dans un fichier
      PrintWriter sortie = new PrintWriter(new FileWriter("Greens.pde"));

      // remplace toutes les occurences de Red par Green
      while (entree.ready())
        sortie.println(entree.readLine().replaceAll("Red", "Green"));

      entree.close() ;
      sortie.close();
    }
    catch (Exception e) {
      println("pb dans ToGreen");
    }
  }

  void toRed(String s) {
    try {
      println(s+".pde");
      BufferedReader entree = new BufferedReader(new FileReader(s + ".pde"));
      PrintWriter sortie = new PrintWriter(new FileWriter("Reds.pde"));

      while (entree.ready())
        sortie.println(entree.readLine());

      entree.close() ;
      sortie.close();
    }
    catch (Exception e) {
      println("pb dans ToRed");
    }
  }


  void game(int r, int g) {
    println("-----------------");

    game = new Simulation();
    game.setup();
    while ((game.ticks <= maxTicks) && (game.greenNrj[game.ticks] != 0) && (game.redNrj[game.ticks] != 0)) {
      game.go();
      if ((game.ticks % 100) == 0) {
        println("iter = " + game.ticks + " | (R) " + game.redNrj[game.ticks] +
          " / (G) " + game.greenNrj[game.ticks]);
      }
    }
    println("iter = " + game.ticks + " | (R) " + game.redNrj[game.ticks] +
      " / (G) " + game.greenNrj[game.ticks]);

    if (game.redNrj[game.ticks] > game.greenNrj[game.ticks]) {
      Results[r]+=3;
      println("victoire des Rouges");
    } else {
      Results[g]+=3;
      println("victoire des Verts");
    }

    Results2[r] += game.redNrj[game.ticks];
    Results2[g] += game.greenNrj[game.ticks];

    println("Rouges (" + r + ") vs Verts (" + g + ") : " + Results[r] + " " + Results[g]);
  }

  void go() {
    for (int i = 0; i < equipes.length-1; i++) {
      println("==================================================");
      println("changement de l'équipe " + i + " en équipe rouge");
      toRed(equipes[i]);
      for (int j = i+1; j < equipes.length; j++) {
        println("changement de l'équipe " + j + " en équipe verte");
        toGreen(equipes[j]);
        println("Match entre " + i + " et " + j);
        game(i, j);
      }
    }
    displayResults();
  }

  void displayResults() {
    println("------------------");
    println("Resultats du match");
    println("------------------");

    for (int i=0; i<equipes.length; i++)
      System.out.format("| %12s ", equipes[i]);
    println("|");
    print("--------------");
    for (int i=0; i<equipes.length; i++)
      print("---------------");
    println();

    for (int i=0; i<equipes.length; i++)
      System.out.format("      %2d      |", Results[i]);
    println();

    // creation d’un flux d’ecriture de caracteres dans un fichier
    try {
      PrintWriter sortie = new PrintWriter(new FileWriter("results.xls"));
      for (int i=0; i<equipes.length; i++)
        sortie.print("\t" + equipes[i]);
      sortie.println("");

      for (int i=0; i<equipes.length; i++) {
        sortie.print(equipes[i] + "\t");
        sortie.print(Results[i] + "\t");
      }
      sortie.close();

      sortie = new PrintWriter(new FileWriter("results2.xls"));
      for (int i=0; i<equipes.length; i++)
        sortie.print("\t" + equipes[i]);
      sortie.println("");

      for (int i=0; i<equipes.length; i++) {
        sortie.print(equipes[i] + "\t");
        sortie.print(Results2[i] + "\t");
      }
      sortie.println();
      sortie.close();
    }
    catch (Exception e) {
      println("pb dans DisplayResults");
    }
  }

  void displayTeams() {
    for (String s : equipes)
      println(s);
  }
}
