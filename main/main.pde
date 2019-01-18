import java.net.*; // import the entire java.net library
import java.util.*; // import the entire java.util library
import java.io.InputStreamReader; // used to parse the http response object
import ddf.minim.*; // import the minim sound library

color COLOR1; // brigt color preset
color COLOR2; // dark color preset
PFont FONT1; // bold font preset
PFont FONT2; // light font preset
PFont FONT3; // title font preset
AudioPlayer CLICK_SOUND; // button click sound
AudioPlayer COMPLETE_SOUND; // level completed sound
AudioPlayer FAIL_SOUND; // level failed sound

String PLAYER_NAME; // name of the logged in player, to be populated by s.register()
boolean NEW_PLAYER; // whether or not the player is signing in for the first time, to be populated by s.register()
boolean SERVER_CONNECTION; // whether or not the http client is able to fetch data from the game server

Server SERVER; // the class responsible for handling all the http requests to the server
Controller CONTROLLER; // the class responsible for handling the different app scenes, knowing what scene to draw and where to push events

void setup() {
  
  size(800, 800); // set the canvas dimensions
  
  // assign values to the global variables
  COLOR1 = color(22, 22, 22);
  COLOR2 = color(222, 222, 222);
  FONT1 = createFont("./fonts/LeagueMono-Bold.ttf", 42);
  FONT2 = createFont("./fonts/LeagueMono-Regular.ttf", 42);
  FONT3 = createFont("./fonts/VG5000-Regular_web.ttf", 82);
  
  // this will be visible in case the initial http request hangs, timing out after five seconds
  textFont(FONT1);
  fill(COLOR1);
  text("LOADING GAME...", 230, 400);
  
  // initialize a Minim instance and use it to load the different sound files onto their global variables
  Minim minim = new Minim(this);
  CLICK_SOUND = minim.loadFile("./sounds/click.mp3");
  COMPLETE_SOUND = minim.loadFile("./sounds/completed.mp3");
  FAIL_SOUND = minim.loadFile("./sounds/failed.mp3");
  
  SERVER = new Server(); // initialize the game API handler
  
  // attempt to register the client to the server and format the menu screen accordingly
  JSONObject registration = SERVER.register();
  Button[] menuButtons;
  if (registration != null && !registration.getBoolean("already_registered")) {
    // if the user is recognized as a new user, do not give them the ability to start a new game before completing the tutorial
    menuButtons = new Button[] {
      new Button("TUTORIAL", 270, 360, 262, 95, COLOR2, COLOR1, FONT1),
      new Button("SCOREBOARD", 244, 460, 312, 95, COLOR2, COLOR1, FONT1)
    };
  }
  else {
    // if the user is not new or no connection to the server could be established, set up the default menu screen
    if (registration != null) PLAYER_NAME = registration.getString("name");
    menuButtons = new Button[] {
      new Button("NEW GAME", 269, 360, 264, 95, COLOR2, COLOR1, FONT1),
      new Button("SCOREBOARD", 244, 460, 312, 95, COLOR2, COLOR1, FONT1),
      new Button("TUTORIAL", 270, 560, 262, 95, COLOR2, COLOR1, FONT1)
    };
  }
  // instanctiate the scene controller with the different application windows
  CONTROLLER = new Controller(new Scene[] {
    new MenuScene(menuButtons),
    new GameScene(new Game()), // this is overwritten in the Menu Scene
    new ScoreScene(),
    new TutorialScene(new Game(20)), // this is overwritten in the Menu Scene
  });
  
}

void draw() {
  
  // update the scene controller in order to draw the appropriate scene
  CONTROLLER.update();
  if (!SERVER_CONNECTION && !CONTROLLER.scenes[0].isVisible()) {
    // if there are problems with the server connection and the user is not on the menu screen, notify them
    textFont(FONT2);
    fill(100, 100, 100);
    textSize(16);
    text("(No connection to game server. Scores will not be saved!)", 130, 780);
  }
  
}

void mousePressed() {
  
  // push the mouse press event to the appropriate scene
  Element clicked = CONTROLLER.click();
  if (clicked != null) {
    // if an element is returned, it means it was clicked and we should play the CLICK_SOUND sound effect
    CLICK_SOUND.rewind();
    CLICK_SOUND.play();
  }
  
}
