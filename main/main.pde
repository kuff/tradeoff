import java.net.*; // import the entire java.net library
import java.util.*; // import the entire java.util library
import java.io.InputStreamReader; // used to parse the http response object
import ddf.minim.*;

color COLOR1; // brigt color preset
color COLOR2; // dark color preset
PFont FONT1; // bold font preset
PFont FONT2; // light font preset
PFont FONT3; // title font preset
AudioPlayer CLICK_SOUND;
AudioPlayer COMPLETE_SOUND;
AudioPlayer FAIL_SOUND;

String PLAYER_NAME; // name of the logged in player, to be populated by s.register()
boolean NEW_PLAYER; // whether or not the player is signing in for the first time, to be populated by s.register()
boolean SERVER_CONNECTION; // whether or not the http client is able to fetch data from the game server

Server SERVER; // the class responsible for handling all the http requests to the server
Controller CONTROLLER; // the class responsible for handling the different app scenes, knowing what scene to draw and where to push events

void setup() {
  
  size(800, 800);
  
  COLOR1 = color(22, 22, 22);
  COLOR2 = color(222, 222, 222);
  FONT1 = createFont("./fonts/LeagueMono-Bold.ttf", 42);
  FONT2 = createFont("./fonts/LeagueMono-Regular.ttf", 42);
  FONT3 = createFont("./fonts/VG5000-Regular_web.ttf", 82);
  
  // this will be visible in case the initial http request hangs
  textFont(FONT1);
  fill(COLOR1);
  text("LOADING GAME...", 230, 400);
  
  Minim minim = new Minim(this);
  CLICK_SOUND = minim.loadFile("./sounds/click.mp3");
  COMPLETE_SOUND = minim.loadFile("./sounds/completed.mp3");
  FAIL_SOUND = minim.loadFile("./sounds/failed.mp3");
  
  SERVER = new Server();
  
  JSONObject registration = SERVER.register();
  Button[] menuButtons;
  if (registration != null && !registration.getBoolean("already_registered")) {
    menuButtons = new Button[] {
      new Button("TUTORIAL", 270, 360, 262, 95, COLOR2, COLOR1, FONT1),
      new Button("SCOREBOARD", 244, 460, 312, 95, COLOR2, COLOR1, FONT1)
    };
  }
  else {
    if (registration != null) PLAYER_NAME = registration.getString("name");
    menuButtons = new Button[] {
      new Button("NEW GAME", 269, 360, 264, 95, COLOR2, COLOR1, FONT1),
      new Button("SCOREBOARD", 244, 460, 312, 95, COLOR2, COLOR1, FONT1),
      new Button("TUTORIAL", 270, 560, 262, 95, COLOR2, COLOR1, FONT1)
    };
  }
  CONTROLLER = new Controller(new Scene[] {
    new MenuScene(menuButtons),
    new GameScene(new Game()), // this is locally overwritten in the Menu Scene
    new ScoreScene(),
    new TutorialScene(new Game(20)), // this is locally overwritten in the Menu Scene
  });
  
}

void draw() {
  
  CONTROLLER.update();
  if (!SERVER_CONNECTION && !CONTROLLER.scenes[0].isVisible()) {
    textFont(FONT2);
    fill(100, 100, 100);
    textSize(16);
    text("(No connection to game server. Scores will not be saved!)", 130, 780);
  }
  
}

void mousePressed() {
  
  Element clicked = CONTROLLER.click();
  if (clicked != null) {
    CLICK_SOUND.rewind();
    CLICK_SOUND.play();
  }
  
}
