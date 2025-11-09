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
  int windowWidth = 400;
  int windowHeight = 400;
  
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
    // Si invisible, on dessine quand meme (mais on pourrait cacher la fenetre)
    if (!visible) {
      background(0);
      return;
    }
    
    // Fond noir
    background(30);
    
    // Recupere les donnees depuis la fenetre principale
    float bass = parent.getAudio().getBass();
    float mid = parent.getAudio().getMid();
    float treble = parent.getAudio().getTreble();
    
    // Met a jour l'historique
    bassHistory[historyIndex] = bass;
    midHistory[historyIndex] = mid;
    trebleHistory[historyIndex] = treble;
    historyIndex = (historyIndex + 1) % bassHistory.length;
    
    // Dessine le HUD
    drawHUD(bass, mid, treble);
  }
  
  void drawHUD(float bass, float mid, float treble) {
    pushStyle();
    
    fill(255);
    textSize(16);
    text("AUDIO LEVELS", 10, 20);
    
    textSize(12);
    fill(255, 100, 100);
    text("BASS: " + nf(bass, 0, 3), 10, 50);
    
    fill(100, 255, 100);
    text("MID: " + nf(mid, 0, 3), 10, 70);
    
    fill(100, 200, 255);
    text("TREBLE: " + nf(treble, 0, 3), 10, 90);
    
    // Dessine les waveforms
    drawWaveform();
    
    popStyle();
  }
  
  void drawWaveform() {
    pushStyle();
    noFill();
    
    // Bass (red)
    stroke(255, 0, 0, 150);
    beginShape();
    for (int i = 0; i < bassHistory.length; i++) {
      float x = map(i, 0.0f, bassHistory.length, 10.0f, windowWidth - 10.0f);
      float y = map(bassHistory[i], 0.0f, 1.0f, windowHeight - 50.0f, 150.0f);
      vertex(x, y);
    }
    endShape();
    
    // Mid (green)
    stroke(0, 255, 0, 150);
    beginShape();
    for (int i = 0; i < midHistory.length; i++) {
      float x = map(i, 0.0f, midHistory.length, 10.0f, windowWidth - 10.0f);
      float y = map(midHistory[i], 0.0f, 1.0f, windowHeight - 50.0f, 150.0f);
      vertex(x, y);
    }
    endShape();
    
    // Treble (blue)
    stroke(0, 150, 255, 150);
    beginShape();
    for (int i = 0; i < trebleHistory.length; i++) {
      float x = map(i, 0.0f, trebleHistory.length, 10.0f, windowWidth - 10.0f);
      float y = map(trebleHistory[i], 0.0f, 1.0f, windowHeight - 50.0f, 150.0f);
      vertex(x, y);
    }
    endShape();
    
    popStyle();
  }
  
  void toggle() {
    visible = !visible;
    println("HUD: " + (visible ? "ON" : "OFF"));
  }
  
  void dispose() {
    // Cleanup if needed
  }
}
