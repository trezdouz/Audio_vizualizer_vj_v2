// ============================================
// HELP WINDOW - Popup des contrôles
// ============================================

class HelpWindow extends PApplet {

  boolean visible = false;

  HelpWindow() {
    super();
    PApplet.runSketch(new String[]{this.getClass().getSimpleName()}, this);
  }

  void settings() {
    size(400, 500);
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
    int y = 50;
    String[] lines = {
      "1-9 : Switch mode",
      "TAB : Next mode",
      "SPACE : Particles",
      "H : Toggle this help",
      "P/O : Change palette",
      "G : Toggle Datamosh",
      "B : Toggle Background",
      "I : Load image",
      "C : Center spectrum",
      "M : Mirror spectrum",
      "+/- : Spectrum gain",
      "F : Full-screen viz",
      "ESC : Quit"
    };

    for (String l : lines) {
      text(l, 20, y);
      y += 20;
    }
  }

  void toggle() {
    visible = !visible;
    surface.setVisible(visible);
    if (visible) surface.setLocation(displayWidth - width - 50, 50); // coin écran 2
  }
}
