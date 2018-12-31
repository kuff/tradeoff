
/*
  GAME IMPLEMENTATION USING "GUI" AND "HTTP"
*/

class Game {
  
  Random numberGenerator;
  int difficulty; // how many GameButtons to generate
  int healthPoints;
  int totalScore;
  int potentialScore;
  boolean levelComplete;
  boolean levelFailed;
  boolean completedLastLevel;
  int timeStamp; // the time stamp from when the user starts playing, used to calculate their score at the end of each level
  
  private int lastPressed;
  
  Game() { 
    this.numberGenerator = new Random();
    this.difficulty = 3;
    this.healthPoints = 3;
    this.totalScore = 0;
    this.levelComplete = false;
    this.levelFailed = false;
    this.completedLastLevel = false;
    
    this.timeStamp = millis();
    this.lastPressed = 0;
  }
  
  Game(long seed) {
    this.numberGenerator = new Random();
    this.numberGenerator.setSeed(seed);
    this.difficulty = 3;
    this.healthPoints = 3;
    this.totalScore = 0;
    this.levelComplete = false;
    this.levelFailed = false;
    this.completedLastLevel = false;
    
    this.timeStamp = millis();
    this.lastPressed = 0;
  }
  
  private GameButton generateGameButton(int value) {
    return new GameButton(value + "", 50 + (600 * this.numberGenerator.nextFloat()), 200 + (450 * this.numberGenerator.nextFloat()));
  }
  
  private boolean isTouching(GameButton button, GameButton[] buttons) {
    for (GameButton b : buttons) if (b != null && button.isTouching(b, 125)) return true;
    return false;
  }
  
  GameButton[] generateGameButtons() {
    
    GameButton[] buttons = new GameButton[this.difficulty];
    for (int i = 0; i < this.difficulty; i++) {
      GameButton button = this.generateGameButton(i + 1);
      while (this.isTouching(button, buttons)) button = this.generateGameButton(i + 1);
      buttons[i] = button;
    }
    this.lastPressed = 0;
    return buttons;
    
  }
  
  GameButton[] nextLevel() {
    
    // figure out if the level was won or lost
    if (this.levelComplete) {
      COMPLETE_SOUND.rewind();
      COMPLETE_SOUND.play();
    }
    else {
      FAIL_SOUND.rewind();
      FAIL_SOUND.play();
    }
    // figure out how the difficulty of the next level should be adjusted
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
    
    int value = Integer.parseInt(button.text);
    if (value == 1 && this.lastPressed == 0) this.potentialScore = this.getScore(); 
    if (value > this.lastPressed) {
      if (value == 1 || value - 1 == this.lastPressed) this.lastPressed = value;
      else if (value > this.lastPressed) {
        this.levelFailed = true;
        this.healthPoints--;
      }
    }
    if (this.lastPressed == this.difficulty) {
      this.levelComplete = true;
      this.totalScore += this.potentialScore;
    }
    
  }
  
  int getScore() {
    return round(this.difficulty * 1 / (sqrt(pow(millis() - this.timeStamp, 2)) / 10000));
  }
  
  boolean isOver() {
    return this.healthPoints == 0;
  }
  
}

/*
  CUSTOMIZED GUI CLASSES
*/

class GameButton extends Button {
  
  boolean flipped; // whether or not the underlying number is visible to the player
  
  GameButton(String number, float x, float y) {
    super(number, x, y, 75, 75, COLOR1, COLOR2, FONT1);
    this.flipped = false;
  }
  
  boolean isTouching(GameButton otherButton, int vicinity) {
    boolean isCollidingX = otherButton.x > this.x - vicinity && otherButton.x + otherButton.xLength - vicinity < this.x + this.xLength;
    boolean isCollidingY = otherButton.y > this.y - vicinity && otherButton.y + otherButton.yLength - vicinity < this.y + this.yLength;
    return isCollidingX && isCollidingY;
  }
  
  @Override
  void render() {
    fill(COLOR2);
    textSize(52);
    noStroke();
    if (!this.flipped) text(this.text, this.x + 24, this.y + 54);
    else rect(this.x, this.y, this.xLength, this.yLength);
  }
  
}

class GameScene extends Scene {
  
  Game game;
  int presses; // the amount of times the user has interacted with the Game Scene
  
  GameScene(Game game) {
    super(game.generateGameButtons());
    this.game = game;
    this.presses = 0;
  }
  
  @Override
  Element click() {
    
    this.presses++;
    if (this.presses == 1) {
      this.setVisibility(true);
      this.game.timeStamp = millis();
      return null;
    }
    
    if (this.game.isOver()) {
      // send the user back to the menu screen
      CONTROLLER.setActiveScene(CONTROLLER.scenes[0]);
    }
    
    GameButton clicked = (GameButton) super.click();
    if (clicked == null) return null;
    this.game.input(clicked);
    
    if (this.game.isOver()) {
      FAIL_SOUND.rewind();
      FAIL_SOUND.play();
      this.setVisibility(false);
      this.visible = true;
      SERVER.register();
      SERVER.postScore(this.game.totalScore);
      return clicked;
    }
    else if (this.game.levelComplete || this.game.levelFailed) {
      for (GameButton button : (GameButton[]) this.elements) button.flipped = false;
      this.elements = this.game.nextLevel();
      this.setVisibility(true); 
      return clicked;
    }
    // else
    clicked.flipped = true;
    int amountFlipped = 0;
    for (GameButton button : (GameButton[]) this.elements) if (button.flipped) amountFlipped++;
    if (amountFlipped == 1) for (GameButton button : (GameButton[]) this.elements) button.flipped = !button.flipped;
    else clicked.flipped = false;
    return clicked;
    
  }
  
  @Override
  void render() {
    
    background(COLOR1);
    fill(COLOR2);
    textFont(FONT1);
    if (this.presses == 0) {
      for (Element button : this.elements) button.setVisibility(false);
      textSize(22);
      text("Press anywhere on the screen to start", 150, 400);
    }
    else {
      if (this.game.isOver()) {
        textFont(FONT3);
        text("GAME OVER!", 180, 320);
        textFont(FONT1);
        text("Final score: " + this.game.totalScore, 210, 450);
        textFont(FONT2);
        textSize(18);
        text("Press anywhere on the screen to continue", 185, 700);
      }
      else {
        for (int i = 1; i <= 3; i++) {
          boolean full = this.game.healthPoints - i >= 0;
          if (full) fill(200, 44, 44);
          else fill(100, 100, 100);
          text(full ? "<3" : "</3", 75 + (100 * (i - 1)), 100);
        }
        int score = this.game.potentialScore == 0 ? this.game.getScore() : this.game.potentialScore;
        fill(COLOR2);
        text("SCORE: " + score, 450, 100);
        textFont(FONT1);
      }
    }
    super.render();
  }
  
}

class TutorialScene extends GameScene {
  
  TutorialScene(Game game) {
    super(game);
    this.game.numberGenerator.setSeed(20); // not final value
    this.presses = 0;
  }
  
  @Override
  Element click() {
    
    this.presses++;
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
      CONTROLLER.scenes[0] = new MenuScene(new Button[] {
        new Button("NEW GAME", 269, 360, 264, 95, COLOR2, COLOR1, FONT1),
        new Button("SCOREBOARD", 244, 460, 312, 95, COLOR2, COLOR1, FONT1),
        new Button("TUTORIAL", 270, 560, 262, 95, COLOR2, COLOR1, FONT1)
      });
      CONTROLLER.setActiveScene(CONTROLLER.scenes[0]);
    }
    return null; // this value is never used
    
  }
  
  @Override
  void render() {
    
    background(COLOR1);
    textFont(FONT1);
    textSize(24);
    fill(COLOR2);
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
        fill(200, 44, 44);
        text("The hearts at the top left indicates how many 'lives' you have left.", 330, 590, 400, 800);
        break;
      case 6:
        fill(100, 100, 100);
        text("If you fail a sequence, you loose a life and earn no points...", 330, 590, 400, 800);
        break;
      case 7:
        fill(100, 100, 100);
        text("...And the difficulty of the next sequence is decreased.", 130, 580, 600, 800);
        break;
      case 8:
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
    if (presses > 2) text("SCORE: " + 42, 450, 100);
    if (presses > 4) {
      for (int i = 1; i <= 3; i++) {
        boolean full = this.game.healthPoints - i >= 0;
        if (full) fill(200, 44, 44);
        else fill(100, 100, 100);
        text(full ? "<3" : "</3", 75 + (100 * (i - 1)), 100);
      }
    }
    
  }
  
}
