// ============================================
// HUD WINDOW - Affichage des informations
// ============================================

class HUDWindow extends PApplet {
  
  IAudioProvider parent;
  boolean visible;
  
  // Levels history
  float[] bassHistory;
  float[] midHistory;
  float[] trebleHistory;
  int historyIndex;
  
  // Taille
  int windowWidth = 600;
  int windowHeight = 500;
  
  // Cache pour eviter les appels constants
  String cachedModeName = "Loading...";
  String cachedPaletteName = "Loading...";
  
  // compteur
  int updateCounter = 0;
  
  HUDWindow(IAudioProvider p) {
    super();
    this.parent = p;
    visible = true;
    bassHistory = new float[100];
    midHistory = new float[100];
    trebleHistory = new float[100];
    historyIndex = 0;
    
    // Lance la fenetre separee
    PApplet.runSketch(new String[]{this.getClass().getSimpleName()}, this);
  }
  
  void settings() {
    size(windowWidth, windowHeight);
  }
  
  void draw() {
    // Si invisible, fond noir
    if (!visible) {
      background(0);
      fill(255);
      textAlign(CENTER, CENTER);
      text("HUD HIDDEN (press H to show)", width/2, height/2);
      return;
    }
    
    // Fond avec gradient
    for (int i = 0; i < height; i++) {
      float inter = map(i, 0, height, 0.0f, 1.0f);
      float darkness = lerp(20.0f, 40.0f, inter);
      stroke(darkness);
      line(0, i, width, i);
    }
    
    // Recupere les donnees depuis la fenetre principale
    float bass = parent.getAudio().getBass();
    float mid = parent.getAudio().getMid();
    float treble = parent.getAudio().getTreble();
    
    // Met a jour l'historique
    bassHistory[historyIndex] = bass;
    midHistory[historyIndex] = mid;
    trebleHistory[historyIndex] = treble;
    historyIndex = (historyIndex + 1) % bassHistory.length;
    
    // Update cache periodiquement
     updateCounter++;
    if (updateCounter % 30 == 0) {
      try {
      } catch (Exception e) {
        // Ignore
      }
    }
    
    // Dessine le HUD
    drawHUD(bass, mid, treble);
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
    
    // Mode et Palette info (FIXE - pas de clignotement)
    fill(255);
    textAlign(RIGHT, TOP);
    text("Mode: " + cachedModeName, width - 15, 15);
    text("Palette: " + cachedPaletteName, width - 15, 35);
    
    // Section Levels
    fill(255, 200);
    textAlign(LEFT, CENTER);
    textSize(16);
    text("AUDIO LEVELS", 15, 80);
    
    textSize(14);
    
    // Bass bar
    fill(255, 100, 100);
    textAlign(LEFT, CENTER);
    text("BASS", 15, 110);
    drawLevelBar(100, 110, 300, 20, bass, color(255, 100, 100));
    text(nf(bass, 0, 3), 410, 110);
    
    // Mid bar
    fill(100, 255, 100);
    text("MID", 15, 140);
    drawLevelBar(100, 140, 300, 20, mid, color(100, 255, 100));
    text(nf(mid, 0, 3), 410, 140);
    
    // Treble bar
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
    
    // Level bar
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
    
    // Background
    fill(30, 150);
    rect(15, startY, graphWidth, graphHeight);
    
    // Grid
    stroke(60);
    strokeWeight(1);
    for (int i = 0; i <= 4; i++) {
      float y = startY + (graphHeight / 4.0f) * i;
      line(15, y, 15 + graphWidth, y);
    }
    
    // Bass (red)
    stroke(255, 100, 100, 200);
    strokeWeight(2);
    beginShape();
    for (int i = 0; i < bassHistory.length; i++) {
      float x = map(i, 0, bassHistory.length, 15, 15 + graphWidth);
      float y = map(bassHistory[i], 0.0f, 1.0f, startY + graphHeight, startY);
      vertex(x, y);
    }
    endShape();
    
    // Mid (green)
    stroke(100, 255, 100, 200);
    strokeWeight(2);
    beginShape();
    for (int i = 0; i < midHistory.length; i++) {
      float x = map(i, 0, midHistory.length, 15, 15 + graphWidth);
      float y = map(midHistory[i], 0.0f, 1.0f, startY + graphHeight, startY);
      vertex(x, y);
    }
    endShape();
    
    // Treble (blue)
    stroke(100, 200, 255, 200);
    strokeWeight(2);
    beginShape();
    for (int i = 0; i < trebleHistory.length; i++) {
      float x = map(i, 0, trebleHistory.length, 15, 15 + graphWidth);
      float y = map(trebleHistory[i], 0.0f, 1.0f, startY + graphHeight, startY);
      vertex(x, y);
    }
    endShape();
    
    // Legend
    fill(255, 100, 100);
    text("BASS", 20, startY + graphHeight + 10);
    fill(100, 255, 100);
    text("MID", 80, startY + graphHeight + 10);
    fill(100, 200, 255);
    text("TREBLE", 130, startY + graphHeight + 10);
    
    popStyle();
  }
  
  void toggle() {
    visible = !visible;
    println("HUD: " + (visible ? "VISIBLE" : "HIDDEN"));
  }
  
  // Methode pour update les infos depuis le main thread
  void updateInfo(String modeName, String paletteName) {
    cachedModeName = modeName;
    cachedPaletteName = paletteName;
  }
  
  void dispose() {
    // Cleanup if needed
  }
}
