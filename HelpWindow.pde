// ============================================
// HELP WINDOW - Popup des contrôles
// ============================================

class HelpWindow extends PApplet {

  boolean visible = false;

  HelpWindow() {
    super();
    PApplet.runSketch(new String[]{this.getClass().getSimpleName()}, this);
  }



  void draw() {
    if (!visible) {
      background(0);
      return;
    }

    background(20);
    fill(255);
    textAlign(LEFT, TOP);
    textSize(18);
    text("CONTROLS", 20, 20);
    textSize(14);
    HelpRenderer.drawHelpOverlay(20, 50, this);
  }


  void toggle() {
    visible = !visible;
    surface.setVisible(visible);
    if (visible) surface.setLocation(displayWidth - width - 50, 50); // coin écran 2
  }
}

// ============================================
// HELP RENDERER - Centralise l'affichage de l'aide
// ============================================

static class HelpRenderer {
  static void drawHelpOverlay(int x, int y, PApplet app) {
    app.pushStyle();
    app.fill(255);
    app.textAlign(LEFT, TOP);
    app.textSize(14);
    for (String line : KeyBindings.LINES) {
      app.text(line, x, y);
      y += 20;
    }
    app.popStyle();
  }
}
