// ============================================
// HUD WINDOW - Affichage des informations
// ============================================

class HUDWindow extends PApplet {

  IAudioProvider parent;
  ControlsManager controls;
  boolean visible;

  // Historique des niveaux
  float[] bassHistory;
  float[] midHistory;
  float[] trebleHistory;
  int historyIndex;

  // Taille
  int windowWidth = 600;
  int windowHeight = 500;

  // Cache pour éviter les appels constants
  String cachedModeName = "Loading...";
  String cachedPaletteName = "Loading...";

  // Compteur
  int updateCounter = 0;

  HUDWindow(IAudioProvider p) {
    super();
    this.parent = p;
    visible = true;
    bassHistory = new float[100];
    midHistory = new float[100];
    trebleHistory = new float[100];
    historyIndex = 0;

    // Lance la fenêtre séparée
    PApplet.runSketch(new String[]{this.getClass().getSimpleName()}, this);
  }

  

  void draw() {
    // 1. Aide mode
    if (controls != null && controls.showHelp) {
      drawHelpOverlay();
      return;
    }

    // 2. HUD masqué
    if (!visible) {
      background(0);
      return;
    }

    // 3. HUD normal
    for (int i = 0; i < height; i++) {
      float inter = map(i, 0, height, 0, 1);
      float darkness = lerp(20, 40, inter);
      stroke(darkness);
      line(0, i, width, i);
    }

    float bass = parent.getAudio().getBass();
    float mid  = parent.getAudio().getMid();
    float treb = parent.getAudio().getTreble();

    bassHistory[historyIndex] = bass;
    midHistory[historyIndex]  = mid;
    trebleHistory[historyIndex] = treb;
    historyIndex = (historyIndex + 1) % bassHistory.length;

    drawHUD(bass, mid, treb);
  }

  void drawHelpOverlay() {
    pushStyle();
    fill(0, 220);
    rect(20, 20, width - 40, height - 40);

    fill(255);
    textAlign(LEFT, TOP);
    textSize(18);
    text("CONTROLS", 40, 40);

    // Appel statique corrigé
    HelpRenderer.drawHelpOverlay(40, 70, this);

    // Infos dynamiques
    int y = height - 100;
    text("Mode: " + cachedModeName, 40, y);
    text("Palette: " + cachedPaletteName, 40, y + 20);
    text("Sender: " + senderType, 40, y + 40);

    popStyle();
  }

  void drawHUD(float bass, float mid, float treble) {
    pushStyle();

    // Title bar
    fill(0, 100);
    rect(0, 0, width, 60);

    fill(255);
    textAlign(LEFT, TOP);
    textSize(20);
    text("AUDIO VISUALIZER VJ v2.0", 15, 15);

    // OSC Status
    textSize(14);
    boolean oscActive = parent.getAudio().isOSCActive();
    if (oscActive) {
      fill(0, 255, 0);
      text("OSC: CONNECTED", 15, 40);
    } else {
      fill(255, 100, 100);
      text("OSC: WAITING...", 15, 40);
    }

    // Mode et Palette
    fill(255);
    textAlign(RIGHT, TOP);
    text("Mode: " + cachedModeName, width - 15, 15);
    text("Palette: " + cachedPaletteName, width - 15, 35);
    text("Sender: " + senderType, width - 15, 55);

    // Section Levels
    fill(255, 200);
    textAlign(LEFT, CENTER);
    textSize(16);
    text("AUDIO LEVELS", 15, 80);

    textSize(14);

    // Bass
    fill(255, 100, 100);
    text("BASS", 15, 110);
    drawLevelBar(100, 110, 300, 20, bass, color(255, 100, 100));
    text(nf(bass, 0, 3), 410, 110);

    // Mid
    fill(100, 255, 100);
    text("MID", 15, 140);
    drawLevelBar(100, 140, 300, 20, mid, color(100, 255, 100));
    text(nf(mid, 0, 3), 410, 140);

    // Treble
    fill(100, 200, 255);
    text("TREBLE", 15, 170);
    drawLevelBar(100, 170, 300, 20, treble, color(100, 200, 255));
    text(nf(treble, 0, 3), 410, 170);

    // Waveforms
    fill(255, 200);
    textSize(16);
    text("WAVEFORMS", 15, 210);

    drawWaveform();

    popStyle();
  }

  void drawLevelBar(float x, float y, float w, float h, float level, color c) {
    pushStyle();

    // Background
    fill(50);
    noStroke();
    rect(x, y, w, h, 3);

    // Level
    float barWidth = constrain(level * w, 0, w);
    fill(c);
    rect(x, y, barWidth, h, 3);

    // Border
    noFill();
    stroke(100);
    strokeWeight(1);
    rect(x, y, w, h, 3);

    popStyle();
  }

  void drawWaveform() {
    pushStyle();
    noFill();

    float startY = 250;
    float graphHeight = 200;
    float graphWidth = width - 30;

    // Fond
    fill(30, 150);
    rect(15, startY, graphWidth, graphHeight);

    // Grille
    stroke(60);
    strokeWeight(1);
    for (int i = 0; i <= 4; i++) {
      float y = startY + (graphHeight / 4.0f) * i;
      line(15, y, 15 + graphWidth, y);
    }

    // Courbes
    drawWaveformLayer(bassHistory, color(255, 100, 100, 200), startY, graphHeight, graphWidth);
    drawWaveformLayer(midHistory, color(100, 255, 100, 200), startY, graphHeight, graphWidth);
    drawWaveformLayer(trebleHistory, color(100, 200, 255, 200), startY, graphHeight, graphWidth);

    // Légende
    fill(255, 100, 100);
    text("BASS", 20, startY + graphHeight + 10);
    fill(100, 255, 100);
    text("MID", 80, startY + graphHeight + 10);
    fill(100, 200, 255);
    text("TREBLE", 130, startY + graphHeight + 10);

    popStyle();
  }

  void drawWaveformLayer(float[] history, color c, float startY, float graphHeight, float graphWidth) {
    stroke(c);
    strokeWeight(2);
    beginShape();
    for (int i = 0; i < history.length; i++) {
      float x = map(i, 0, history.length, 15, 15 + graphWidth);
      float y = map(history[i], 0.0f, 1.0f, startY + graphHeight, startY);
      vertex(x, y);
    }
    endShape();
  }

  // ------------------------------------------
  // Méthodes publiques
  // ------------------------------------------
  void setControls(ControlsManager c) {
    controls = c;
  }

  void toggle() {
    visible = !visible;
    println("HUD: " + (visible ? "VISIBLE" : "HIDDEN"));
  }

  void setVisible(boolean v) {
    visible = v;
    surface.setVisible(v);
  }

  void updateInfo(String modeName, String paletteName) {
    cachedModeName = modeName;
    cachedPaletteName = paletteName;
  }

  void refresh() {
    surface.setVisible(visible);
  }

  void dispose() {
    // Cleanup si besoin
  }
}
