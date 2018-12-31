
/*
  HIGH-LEVEL GUI FUNCTIONALITY
*/

abstract class Element {
  
  boolean visible = false;
  
  boolean isVisible() {
    return this.visible;
  };
  
  void setVisibility(boolean value) {
    this.visible = value;
  };
  
  abstract Element click();
  abstract void render(); // fancy way of saying "draw"
  
}

class Button extends Element {
 
  String text;
  float x, y;
  int xLength, yLength;
  color accent, contrast;
  PFont font;
  
  Button(String text, float x, float y, int xLength, int yLength, color accent, color contrast, PFont font) {
    this.text = text;
    this.x = x;
    this.y = y;
    this.xLength = xLength;
    this.yLength = yLength; // this is set in stone because the font size always is the same
    this.accent = accent;
    this.contrast = contrast;
    this.font = font;
  }
  
  Element click() {
    if (mouseX > this.x && mouseX < this.x + this.xLength && mouseY > this.y && mouseY < this.y + this.yLength) return this;
    return null;
  }
  
  void render() {
    boolean mouseOver = this.click() != null;
    noStroke();
    fill(mouseOver ? this.accent : this.contrast);
    rect(this.x, this.y, this.xLength, this.yLength);
    fill(mouseOver ? this.contrast : this.accent);
    textSize(42);
    textFont(this.font);
    text(this.text, this.x + 30, this.y + 63);
  }
  
}

class Scene extends Element {
  
  Element[] elements; // the elements contained within this scene
  
  Scene(Element[] elements) {
    this.elements = elements;
  }
  
  @Override
  void setVisibility(boolean value) {
    super.setVisibility(value);
    for (Element elem : elements) elem.setVisibility(value);
  }
  
  Element click() {
    // the scene was clicked
    for (Element element : elements) if (element.isVisible() && element.click() != null) return element;
    return null;
  }
  
  void render() {
    for (Element element : elements) if (element.isVisible()) element.render();
  };
  
}

class Controller {
  
  Scene[] scenes; // the scenes controlled by this class
  
  Controller(Scene[] scenes) {
    this.scenes = scenes;
    this.scenes[0].setVisibility(true);
  }
  
  Scene getActiveScene() {
    for (Scene scene : scenes) if (scene.isVisible()) return scene;
    return null; // this will never be reached
  }
  
  void setActiveScene(Scene scene) {
    // given scene parameter should be a reference to a scene in the controller's list of scenes
    this.getActiveScene().setVisibility(false);
    scene.setVisibility(true);
  }
  
  Element click() {
    return this.getActiveScene().click();
  }
  
  void update() {
    this.getActiveScene().render();
  }
  
}
