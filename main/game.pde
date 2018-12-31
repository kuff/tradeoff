
/*
  GAME IMPLEMENTATION USING "GUI" AND "HTTP"
*/

class Game {
  
  Random numberGenerator; // used to generate the random positions of GameButtons
  int difficulty; // the difficulty of the level being generated, used to know how many GameButtons to generate
  int healthPoints; // how many lives the player has left
  int totalScore; // the total score accumulated by the player
  int potentialScore; // the potential point payout for completing a specific level in progress
  boolean levelComplete; // whether or not the level in progress has been completed
  boolean levelFailed; // whether or not the player has failed the level in progress
  int timeStamp; // the time stamp from when the user starts playing, used to calculate their score at the end of each level
  
  private int lastPressed; // the numerical value of the GameButton that was previously pressed by the player, used to validate a given numerical sequence
  
  Game() { 
    this.numberGenerator = new Random(); // instanciate Random object
    this.difficulty = 3; // starting difficulty is three (3 GameButtons)
    this.healthPoints = 3; // starting health is three (3 hearts)
    this.totalScore = 0; // starting score is zero
    this.levelComplete = false;
    this.levelFailed = false;
    
    this.timeStamp = millis(); // the first level is generated right away, which means we start counting the score right away
    this.lastPressed = 0; // set to zero so that the initial user input of one is valid
  }
  
  Game(long seed) { // this contructor is the same as above, except for the fact that...
    this.numberGenerator = new Random();
    this.numberGenerator.setSeed(seed); // ... a specific seed is passed to the Random object, ensuring the same outcome every time - used for the tutorial level
    this.difficulty = 3;
    this.healthPoints = 3;
    this.totalScore = 0;
    this.levelComplete = false;
    this.levelFailed = false;
    
    this.timeStamp = millis();
    this.lastPressed = 0;
  }
  
  private GameButton generateGameButton(int value) {
    // generates a GameButton with random x- and y coordinates, passing the given value onto it
    return new GameButton(value + "", 50 + (600 * this.numberGenerator.nextFloat()), 200 + (450 * this.numberGenerator.nextFloat()));
  }
  
  private boolean isTouching(GameButton button, GameButton[] buttons) {
    // checks whether or not a newly generated GameButton overlaps with any existing ones
    for (GameButton b : buttons) if (b != null && button.isTouching(b, 125)) return true;
    return false;
  }
  
  GameButton[] generateGameButtons() {
    
    // generates all buttons based on the difficulty of the given level, ensuring no buttons are overlapping
    GameButton[] buttons = new GameButton[this.difficulty];
    for (int i = 0; i < this.difficulty; i++) {
      GameButton button = this.generateGameButton(i + 1);
      while (this.isTouching(button, buttons)) button = this.generateGameButton(i + 1);
      buttons[i] = button;
    }
    // also resets the lastPressed instance variable to ensure the initial user input of "1" is valid
    this.lastPressed = 0;
    return buttons;
    
  }
  
  GameButton[] nextLevel() {
    
    // progresses to next level
    // start by figuring out if the level was won or lost
    if (this.levelComplete) {
      // if the level was won, play the "completed" sound effect
      COMPLETE_SOUND.rewind();
      COMPLETE_SOUND.play();
    }
    else {
      // if the level was lost, play the "failed" sound effect
      FAIL_SOUND.rewind();
      FAIL_SOUND.play();
    }
    // figure out how the difficulty of the next level should be adjusted, depending on the outcome of the previous level
    if (this.levelComplete && this.difficulty < 9) this.difficulty ++;
    else if (this.difficulty > 3) this.difficulty--;
    // reset some instance variables
    this.levelComplete = false;
    this.levelFailed = false;
    this.timeStamp = millis();
    this.lastPressed = 0;
    this.potentialScore = 0;
    // return the new set of buttons for the next level
    return this.generateGameButtons();
    
  }
  
  void input(GameButton button) {
    
    // validate a given user input
    // start by parsing the Integer value held inside the GameButton
    int value = Integer.parseInt(button.text);
    // register the initial user input and freeze the score count
    if (value == 1 && this.lastPressed == 0) this.potentialScore = this.getScore();
    if (value > this.lastPressed) {
      // if the input value is greater than the last input value, the user answred correctly and value is saved as the previous value
      if (value == 1 || value - 1 == this.lastPressed) this.lastPressed = value;
      else {
        // otherwise, the user has failed the level and their health points are reduced by one
        this.levelFailed = true;
        this.healthPoints--;
      }
    }
    if (this.lastPressed == this.difficulty) {
      // if this.lastPressed (which is the same as value when input was correct) is equal to the difficulty of the level, 
      // it means the user has selected the final number in the sequence and has won the level
      this.levelComplete = true;
      this.totalScore += this.potentialScore; // payout points
    }
    
  }
  
  int getScore() {
    // returns the potential score of the player in this very moment depending on when the level started
    return round(this.difficulty * 1 / (sqrt(pow(millis() - this.timeStamp, 2)) / 10000));
  }
  
  boolean isOver() {
    // whether or not the user has lost all their health points
    return this.healthPoints == 0;
  }
  
}

/*
  CUSTOMIZED GUI CLASSES
*/

class GameButton extends Button {
  
  boolean flipped; // whether or not the underlying number is visible to the player
  
  GameButton(String number, float x, float y) {
    // call the contructor of Button
    super(number, x, y, 75, 75, COLOR1, COLOR2, FONT1);
    this.flipped = false; // start out by showing the underlying number
  }
  
  boolean isTouching(GameButton otherButton, int vicinity) {
    // whether or not a given GameButton intersects with this button within a given vicinity, used when generating new GameButtons
    boolean isCollidingX = otherButton.x > this.x - vicinity && otherButton.x + otherButton.xLength - vicinity < this.x + this.xLength;
    boolean isCollidingY = otherButton.y > this.y - vicinity && otherButton.y + otherButton.yLength - vicinity < this.y + this.yLength;
    return isCollidingX && isCollidingY;
  }
  
  @Override
  void render() {
    // draw the button, depending on whether or not the underlying text is visible
    fill(COLOR2);
    textSize(52);
    noStroke();
    if (!this.flipped) text(this.text, this.x + 24, this.y + 54);
    else rect(this.x, this.y, this.xLength, this.yLength);
  }
  
}

class GameScene extends Scene {
  
  Game game; // the local instance of the game
  int presses; // the amount of times the user has interacted with the Game Scene
  
  GameScene(Game game) {
    // call the Scene contructor with the elements generated from the game
    super(game.generateGameButtons());
    this.game = game; // save the game instance
    this.presses = 0; // initial amount of interactions by the user is zero
  }
  
  @Override
  Element click() {
    
    this.presses++; // each interaction with this scene is counted
    if (this.presses == 1) {
      // after the first press by the user, start the game
      this.setVisibility(true);
      this.game.timeStamp = millis();
      return null;
    }
    
    if (this.game.isOver()) {
      // send the user back to the menu screen if the game is over
      CONTROLLER.setActiveScene(CONTROLLER.scenes[0]);
    }
    
    // save the Element return by Scene.click() and return if it is null
    GameButton clicked = (GameButton) super.click(); // typecast the Element to type GameButton
    if (clicked == null) return null;
    this.game.input(clicked); // pass the clicked GameButton onto the game
    
    if (this.game.isOver()) {
      // if the game is over, play the "failed sound" and hide the elements contained within this scene
      FAIL_SOUND.rewind();
      FAIL_SOUND.play();
      this.setVisibility(false);
      this.visible = true;
      SERVER.register(); // register with the server, retrieving a session cookie for verification
      SERVER.postScore(this.game.totalScore); // post the score to the server
      return clicked; // return the clicked element of type GameButton
    }
    else if (this.game.levelComplete || this.game.levelFailed) {
      // if the level is over, but not the game, advance to next level
      this.elements = this.game.nextLevel(); // save the newly generated buttons as the new set of elements controlled by this scene
      this.setVisibility(true); // render them all visible
      return clicked; // return the clicked element of type GameButton
    }
    // else
    clicked.flipped = true;
    int amountFlipped = 0;
    for (GameButton button : (GameButton[]) this.elements) if (button.flipped) amountFlipped++;
    // if only one button is flipped, reverse all boolean values, since all elements go from shown to hidden when the user inputs the starting value of the sequence (1)
    if (amountFlipped == 1) for (GameButton button : (GameButton[]) this.elements) button.flipped = !button.flipped;
    else clicked.flipped = false;
    return clicked; // return the clicked element of type GameButton
    
  }
  
  @Override
  void render() {
    
    // draw the scene, depending on the state of the game
    // start by overriding the gui with a blank canvas and style the text
    background(COLOR1);
    fill(COLOR2);
    textFont(FONT1);
    if (this.presses == 0) {
      // if the game has not begun yet, notify the user how to proceed
      for (Element button : this.elements) button.setVisibility(false);
      textSize(22);
      text("Press anywhere on the screen to start", 150, 400);
    }
    else {
      if (this.game.isOver()) {
        // if the game is over report that to the user
        textFont(FONT3);
        text("GAME OVER!", 180, 320);
        textFont(FONT1);
        text("Final score: " + this.game.totalScore, 210, 450); // report their final score
        textFont(FONT2);
        textSize(18);
        text("Press anywhere on the screen to continue", 185, 700);
      }
      else {
        for (int i = 1; i <= 3; i++) {
          // render each of the three hearts in the top left corner depending on the player health points
          boolean full = this.game.healthPoints - i >= 0;
          if (full) fill(200, 44, 44); // red if full
          else fill(100, 100, 100); // otherwise grey
          text(full ? "<3" : "</3", 75 + (100 * (i - 1)), 100); // account for the different hearts with an in-line if
        }
        // display the player score in the top right corner
        int score = this.game.potentialScore == 0 ? this.game.getScore() : this.game.potentialScore;
        fill(COLOR2);
        text("SCORE: " + score, 450, 100);
        textFont(FONT1);
      }
    }
    super.render(); // call the parent class Scene.render() method to render the elements contained within this scene
  }
  
}

class TutorialScene extends GameScene {
  
  TutorialScene(Game game) {
    // initialize instance variables as with the GameScene, but set a seed for the number generator 
    super(game);
    this.game.numberGenerator.setSeed(20); // not final value
    this.presses = 0;
  }
  
  @Override
  Element click() {
    
    this.presses++; // each interaction with this scene is counted
    // manipulate the GameButtons according to the tutorial progression
    if (this.presses == 2) {
      GameButton button = (GameButton) this.elements[0];
      button.flipped = true;
      for (int i = 0; i < this.elements.length; i++) {
        button = (GameButton) this.elements[i]; 
        button.flipped = !button.flipped;
      }
    }
    else if (this.presses == 3) {
      GameButton button = (GameButton) this.elements[1];
      button.flipped = false;
    }
    else if (this.presses == 4) {
      this.game.input((GameButton) this.elements[0]);
      this.game.input((GameButton) this.elements[1]);
      this.game.input((GameButton) this.elements[2]);
      this.elements = this.game.nextLevel();
      this.setVisibility(true);
      
      GameButton button = (GameButton) this.elements[0];
      button.flipped = true;
      for (int i = 0; i < this.elements.length; i++) {
        button = (GameButton) this.elements[i]; 
        button.flipped = !button.flipped;
      }
    }
    else if (this.presses == 5) {
      GameButton button = (GameButton) this.elements[1];
      button.flipped = false;
    }
    else if (this.presses == 6) {
      FAIL_SOUND.rewind();
      FAIL_SOUND.play();
      GameButton button = (GameButton) this.elements[3];
      button.flipped = false;
      this.game.input(button);
    }
    else if (this.presses == 7) {
      this.elements = this.game.nextLevel();
      this.setVisibility(true);
      
      GameButton button = (GameButton) this.elements[0];
      button.flipped = true;
      for (int i = 0; i < this.elements.length; i++) {
        button = (GameButton) this.elements[i]; 
        button.flipped = !button.flipped;
      }
    }
    else if (this.presses == 8) {
      FAIL_SOUND.rewind();
      FAIL_SOUND.play();
      this.game.healthPoints = 0;
      this.elements = new Element[] {};
    }
    else if (this.presses == 9) {
      // initialize a new MenuScene to make sure the correct one is displayed, since it is initialized differently for new players
      CONTROLLER.scenes[0] = new MenuScene(new Button[] {
        new Button("NEW GAME", 269, 360, 264, 95, COLOR2, COLOR1, FONT1),
        new Button("SCOREBOARD", 244, 460, 312, 95, COLOR2, COLOR1, FONT1),
        new Button("TUTORIAL", 270, 560, 262, 95, COLOR2, COLOR1, FONT1)
      });
      CONTROLLER.setActiveScene(CONTROLLER.scenes[0]); // go to the newly instanciated menu screen
    }
    return null; // return null, since only a few clicking sounds should play during the tutorial
    
  }
  
  @Override
  void render() {
    
    // draw the scene, depending on the state of the tutorial game
    // start by overriding the gui with a blank canvas and style the text
    background(COLOR1);
    textFont(FONT1);
    textSize(24);
    fill(COLOR2);
    // depending on the tutorial progress, display different text boxes on the screen
    switch(this.presses) {
      
      case 0:
        text("Welcome to TRADEOFF!", 250, 330); 
        break;
      case 1:
        text("You will be asked to remember a numerical sequence like the one you see bellow.", 100, 200, 600, 800);
        break;
      case 2:
        text("As soon as you click on the first number in the sequence, the rest will be covered.", 100, 200, 600, 800);
        break;
      case 3:
        text("Your score depends on how quickly you select the first number in the sequence - but it only counts if you get the sequence right!", 100, 200, 600, 800);
        break;
      case 4:
        text("If you answer correctly, the sequences will increase in difficulty - as will the payouts for completing them fast!", 330, 580, 400, 800);
        break;
      case 5:
        fill(200, 44, 44); // red, like the full hearts
        text("The hearts at the top left indicates how many 'lives' you have left.", 330, 590, 400, 800);
        break;
      case 6:
        fill(100, 100, 100); // dark grey, like the lost hearts
        text("If you fail a sequence, you loose a life and earn no points...", 330, 590, 400, 800);
        break;
      case 7:
        fill(100, 100, 100); // dark grey, like the lost hearts
        text("...And the difficulty of the next sequence is decreased.", 130, 580, 600, 800);
        break;
      case 8:
        // the tutorial has ended
        textFont(FONT3);
        text("GAME OVER!", 180, 380);
        textFont(FONT1);
        textSize(24);
        text("If you loose all three hearts you loose the game. Good luck and have fun!", 130, 470, 600, 800);
        text("Press anywhere to go back to the menu", 128, 655);
     
    }
    if (presses < 1) text("Press anywhere on the screen to continue", 100, 385);
    if (presses > 0) for (Element elem : this.elements) elem.render();
    textSize(42);
    if (presses > 2) text("SCORE: " + 42, 450, 100); // display the user score
    if (presses > 4) {
      // draw the game hearts
      for (int i = 1; i <= 3; i++) {
        boolean full = this.game.healthPoints - i >= 0;
        if (full) fill(200, 44, 44);
        else fill(100, 100, 100);
        text(full ? "<3" : "</3", 75 + (100 * (i - 1)), 100);
      }
    }
    
  }
  
}
