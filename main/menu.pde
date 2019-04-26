
/*
  THE SCENE REPRESENTING THE MAIN MENU SCREEN
*/

class MenuScene extends Scene {
  
  MenuScene(Button[] buttons) {
    super(buttons); // call the parent class contructor with provided arguments
  }
  
  @Override
  Element click() {
    
    // call parent.click() method and save the response as a Button
    Button clicked = (Button) super.click();
    if (clicked == null) return null; // return if nothing was clicked
    // change scenes to the appropriate one, determined by the label text on the clicked Button
    switch (clicked.text) {
      
      case "NEW GAME":
        // navigate to the game screen
        CONTROLLER.scenes[1] = new GameScene(new Game());
        CONTROLLER.setActiveScene(CONTROLLER.scenes[1]);
        break;
      case "SCOREBOARD":
        // navigate to the scoreboard screen
        CONTROLLER.setActiveScene(CONTROLLER.scenes[2]); // navigate to the scoreboard
        break;
      case "TUTORIAL":
        // navigate to the tutorial screen
        CONTROLLER.scenes[3] = new TutorialScene(new Game(20));
        CONTROLLER.setActiveScene(CONTROLLER.scenes[3]);
      
    }
    return clicked; // return the element that was clicked
    
  }
  
  @Override
  void render() {
    
    // draw the scene, start by clearing the canvas and setting text formatting
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
    else this.elements[1].setVisibility(true); // render the scoreboard if data was retrieved from the api
    super.render(); // render the elements within the scene
    
  }
  
}
