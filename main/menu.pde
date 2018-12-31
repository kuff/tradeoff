
/*
  THE SCENE REPRESENTING THE MAIN MENU SCREEN
*/

class MenuScene extends Scene {
  
  MenuScene(Button[] buttons) {
    super(buttons);
  }
  
  @Override
  Element click() {
    Button clicked = (Button) super.click();
    if (clicked == null) return null;
    switch (clicked.text) {
      
      case "NEW GAME":
        CONTROLLER.scenes[1] = new GameScene(new Game());
        CONTROLLER.setActiveScene(CONTROLLER.scenes[1]);
        break;
      case "SCOREBOARD":
        CONTROLLER.setActiveScene(CONTROLLER.scenes[2]); // navigate to the scoreboard
        break;
      case "TUTORIAL":
        CONTROLLER.scenes[3] = new TutorialScene(new Game(20));
        CONTROLLER.setActiveScene(CONTROLLER.scenes[3]);
        break;
      
    }
    return clicked;
  }
  
  @Override
  void render() {
    background(COLOR1);
    textFont(FONT3);
    fill(COLOR2);
    textSize(82);
    text("TRADEOFF", 213, 265);
    if (SERVER.getScoreboard() == null) {
      // render the scoreboard button as "unclickable" since there does not seem to be a connection to the server
      this.elements[1].setVisibility(false);
      textFont(FONT1);
      fill(100, 100, 100);
      textSize(42);
      text("SCOREBOARD", 274, 523);
      textFont(FONT2);
      textSize(14);
      fill(COLOR2);
      text("Unable to connect to game server! Retrying in " + Math.round((10000 - (millis() - SERVER.timeStamp)) / 1000) + " seconds...", 170, 730);
    }
    else this.elements[1].setVisibility(true);
    super.render();
  }
  
}
