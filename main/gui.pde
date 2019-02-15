
/*
  HIGH-LEVEL GUI FUNCTIONALITY
*/

abstract class Element { // the fundamental element in the gui framework
  
  boolean visible = false; // whether or not this element should be visible
  
  boolean isVisible() { // accessor method for convenience
    return this.visible;
  }
  
  void setVisibility(boolean value) { // modification method, becomes more useful when overwritten by child elements
    this.visible = value;
  }
  
  abstract Element click(); // should detail how this element responds to user input
  abstract void render(); // should detail how this element looks on screen
  
}

class Button extends Element { // simple button, inheriting functionality from element
 
  String text; // the text displayed on the button
  float x, y; // the x- and y coordinates of the button
  int xLength, yLength; // the button's dimensions on the x- and y axis
  color accent, contrast; // the two different colors that the button will incoorporate
  PFont font; // the font used for the text on the button
  
  Button(String text, float x, float y, int xLength, int yLength, color accent, color contrast, PFont font) {
    this.text = text;
    this.x = x;
    this.y = y;
    this.xLength = xLength;
    this.yLength = yLength;
    this.accent = accent;
    this.contrast = contrast;
    this.font = font;
  }
  
  Element click() {
    // returns this instance if the mouse cursor is within the confines of this Button, otherwise null
    if (mouseX > this.x && mouseX < this.x + this.xLength && mouseY > this.y && mouseY < this.y + this.yLength) return this;
    return null;
  }
  
  void render() {
    // draws the Button, depending on whether or not the cursor is placed on top of it
    boolean mouseOver = this.click() != null;
    noStroke();
    fill(mouseOver ? this.accent : this.contrast); // inline-if to switch between the two color states
    rect(this.x, this.y, this.xLength, this.yLength);
    fill(mouseOver ? this.contrast : this.accent);
    textSize(42);
    textFont(this.font);
    text(this.text, this.x + 30, this.y + 63);
  }
  
}

class Scene extends Element { // a collection of elements, centrally controlled
  
  Element[] elements; // the elements contained within this scene
  
  Scene(Element[] elements) {
    this.elements = elements;
  }
  
  @Override
  void setVisibility(boolean value) {
    super.setVisibility(value); // call the parent method
    for (Element elem : elements) elem.setVisibility(value); // do the same with the elements contained within this scene
  }
  
  Element click() {
    // return the element that was clicked, if any - otherwise return null
    for (Element element : elements) if (element.isVisible() && element.click() != null) return element;
    return null;
  }
  
  void render() {
    // render the scene by rendering all sub components
    for (Element element : elements) if (element.isVisible()) element.render();
  }
  
}

class Controller { // a collection of scenes, globally controlled
  
  Scene[] scenes; // the scenes controlled by this class
  
  Controller(Scene[] scenes) {
    this.scenes = scenes;
    this.scenes[0].setVisibility(true); // set the first scene to be the "active" one
  }
  
  Scene getActiveScene() {
    // returns the scene that is currently visible. By funnelling all operations through this class, we can ensure there's always only one
    for (Scene scene : scenes) if (scene.isVisible()) return scene;
    return null; // this will never be reached
  }
  
  void setActiveScene(Scene scene) {
    // given scene parameter should be a reference to a scene in the controller's list of scenes
    this.getActiveScene().setVisibility(false); // "disable" the current active scene
    scene.setVisibility(true); // "enable" the new active scene
  }
  
  Element click() {
    // pass the click event on to the active scene
    return this.getActiveScene().click(); // return whatever the active scene returns
  }
  
  void update() {
    // update the controller by drawing the active scene
    this.getActiveScene().render();
  }
  
}
