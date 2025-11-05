class HUDWindow {
  PApplet parent;
  boolean visible = true;
  float[] bassHistory = new float[100];
  float[] midHistory = new float[100];
  float[] trebleHistory = new float[100];
  int historyIndex = 0;
  
  HUDWindow(PApplet p) {
    this.parent = p;
  }
  
  void update(float bass, float mid, float treble, int modeIndex, String modeName, boolean particles, boolean oscActive) {
    if (!visible) return;
    bassHistory[historyIndex] = bass;
    midHistory[historyIndex] = mid;
    trebleHistory[historyIndex] = treble;
    historyIndex = (historyIndex + 1) % bassHistory.length;
    drawHUD(bass, mid, treble, modeIndex, modeName, particles, oscActive);
  }
  
  void drawHUD(float bass, float mid, float treble, int modeIndex, String modeName, boolean particles, boolean oscActive) {
    parent.pushStyle();
    parent.fill(0, 180);
    parent.noStroke();
    parent.rect(10, 10, 300, 180, 5);
    parent.fill(255);
    parent.textAlign(LEFT, TOP);
    parent.textSize(16);
    parent.text("AUDIO VISUALIZER VJ", 20, 20);
    parent.textSize(12);
    if (oscActive) {
      parent.fill(0, 255, 0);
      parent.text("OSC ACTIF", 20, 45);
    } else {
      parent.fill(255, 0, 0);
      parent.text("OSC INACTIF", 20, 45);
    }
    parent.fill(255);
    parent.text("Mode: " + modeName, 20, 70);
    parent.text("Bass: " + parent.nf(bass, 1, 2), 20, 95);
    parent.text("Mid: " + parent.nf(mid, 1, 2), 20, 115);
    parent.text("Treble: " + parent.nf(treble, 1, 2), 20, 135);
    parent.text("Particles: " + (particles ? "ON" : "OFF"), 20, 160);
    drawWaveform();
    parent.popStyle();
  }
  
  void drawWaveform() {
    parent.pushStyle();
    parent.stroke(255, 0, 0, 150);
    parent.noFill();
    parent.beginShape();
    for (int i = 0; i < bassHistory.length; i++) {
      float x = parent.map(i, 0, bassHistory.length, 320, 620);
      float y = parent.map(bassHistory[i], 0, 1, 180, 80);
      parent.vertex(x, y);
    }
    parent.endShape();
    parent.stroke(0, 255, 0, 150);
    parent.beginShape();
    for (int i = 0; i < midHistory.length; i++) {
      float x = parent.map(i, 0, midHistory.length, 320, 620);
      float y = parent.map(midHistory[i], 0, 1, 180, 80);
      parent.vertex(x, y);
    }
    parent.endShape();
    parent.stroke(0, 150, 255, 150);
    parent.beginShape();
    for (int i = 0; i < trebleHistory.length; i++) {
      float x = parent.map(i, 0, trebleHistory.length, 320, 620);
      float y = parent.map(trebleHistory[i], 0, 1, 180, 80);
      parent.vertex(x, y);
    }
    parent.endShape();
    parent.popStyle();
  }
  
  void toggle() {
    visible = !visible;
  }
  
  void dispose() {
  }
}

