
/*
  THE SCENE REPRESENTING THE SCOREBOARD SCREEN
*/

class ScoreScene extends Scene {
  
  ScoreScene() {
    // elements are defined locally
    super(new Button[] {
      new Button("< GO BACK", 30, 30, 306, 95, COLOR2, COLOR1, FONT1) 
    });
  }
  
  @Override
  Element click() {
    Button clicked = (Button) super.click();
    if (clicked == null) return null;
    switch (clicked.text) {
      
      case "< GO BACK":
        CONTROLLER.setActiveScene(CONTROLLER.scenes[0]); // navigate to the menu screen
        break;
      
    }
    return clicked;
  }
  
  @Override
  void render() {
    background(COLOR1);
    super.render();
    JSONArray scoreData = SERVER.getScoreboard(); // due to the program structure, we can expect this variable to be populated
    // draw the scoreboard
    fill(COLOR2);
    JSONObject playerObject = null;
    int playerPosition = -1;
    for (int i = 0; i < scoreData.size() && i < 5; i++) {
      JSONObject score = scoreData.getJSONObject(i);
      if (score.getString("name").equals(PLAYER_NAME)) {
        playerObject = score;
        playerPosition = i + 1;
        textFont(FONT1);
      }
      else textFont(FONT2);
      textSize(32);
      text((i + 1) + ".", 120, 240 + (75 * i));
      text(score.getString("name").toUpperCase() + (score.getString("name").equals(PLAYER_NAME) ? " (you)" : ""), 240, 240 + (75 * i));
      text(score.getInt("score"), 620, 240 + (75 * i));
    }
    textFont(FONT2);
    textSize(22);
    if (playerObject != null && PLAYER_NAME != null) {
      text(" Your personal highscore is " + playerObject.getInt("score") + ", ", 180, 660);
      text("ranking you nr. " + playerPosition + " on the leaderboard!", 150, 700);
    }
  }
  
}
