// ============================================
// CONTROLS MANAGER
// Gestion centralisee de tous les controles
// ============================================

class ControlsManager {

  // === ETATS ===
  boolean particlesEnabled;
  boolean showHelp;
  boolean datamoshEnabled;
  boolean showBackground;
  
  // === PARAMETRES SPECTRUM ===
  boolean spectrumCentered;
  boolean spectrumMirror;
  float spectrumGain;
  
  //=== WaveForms ===
  boolean waveformTrail = true;
  boolean waveformMultiple = false;
  boolean waveformParticles = true;

  // === PARTICULES ===
  ArrayList<Particle> particles;
  int maxParticles;
  


  
  // === PALETTE ===
  PaletteManager paletteManager;
  
  // === CONSTRUCTOR ===
  ControlsManager() {
    particles = new ArrayList<Particle>();
    particlesEnabled = false;
    showHelp = false;
    datamoshEnabled = false;
    spectrumCentered = false;
    spectrumMirror = false;
    spectrumGain = 1.0f;
    maxParticles = 200;
    
    // Initialiser le gestionnaire de palettes
    paletteManager = new PaletteManager();
  }
  
  // ============================================
  // GESTION CLAVIER
  // ============================================
  void handleKey(char k, int kCode, VisualizationEngine viz, AudioManager audio, HUDWindow hud) {
    
    // Modes (1-9)
    if (k >= '1' && k <= '9') {
      viz.switchMode(k - '1');
    }
    // datamosh
    else if (key == 'g' || key == 'G') {
  viz.datamoshEffect.toggle();
}
// image
else if (key == 'i' || key == 'I') {
    viz.datamoshEffect.selectImage();
  }
    // Controles principaux
    else if (k == ' ') {
      particlesEnabled = !particlesEnabled;
      println("Particles: " + (particlesEnabled ? "ON" : "OFF"));
    }
    else if (k == 'h' || k == 'H') {
      hud.toggle();
    }
    else if (kCode == TAB) {
      viz.nextMode();
    }
    else if (k == 'd' || k == 'D') {
      audio.debugOSC();
    }
    else if (k == 'f' || k == 'F') {
      showHelp = !showHelp;
    }
   
    // PALETTE CONTROLS
    else if (k == 'p' || k == 'P') {
      paletteManager.next();
    }
    else if (k == 'o' || k == 'O') {
      paletteManager.previous();
    }
    
    // SPECTRUM CONTROLS
    else if (k == 'c' || k == 'C') {
      spectrumCentered = !spectrumCentered;
      println("Spectrum centered: " + spectrumCentered);
    }
    else if (k == 'm' || k == 'M') {
      spectrumMirror = !spectrumMirror;
      println("Spectrum mirror: " + spectrumMirror);
    }
    else if (k == '+' || k == '=') {
      spectrumGain = constrain(spectrumGain + 0.1f, 0.1f, 5.0f);
      println("Spectrum gain: " + nf(spectrumGain, 1, 1));
    }
    else if (k == '-' || k == '_') {
      spectrumGain = constrain(spectrumGain - 0.1f, 0.1f, 5.0f);
      println("Spectrum gain: " + nf(spectrumGain, 1, 1));
    }
  }
  
  
  // ============================================
  // AIDE
  // ============================================
  void printHelp() {
    println("CONTROLS:");
    println("   1-9    : Switch mode");
    println("   TAB    : Next mode");
    println("   SPACE  : Toggle particles");
    println("   H      : Toggle HUD");
    println("   F      : Toggle help overlay");
    println("   P      : Next palette");
    println("   O      : Previous palette");
    println("   C      : Center spectrum");
    println("   M      : Mirror spectrum");
    println("   +/-    : Spectrum gain");
    println("   D      : Debug OSC");
  }
  
  void drawHelpOverlay() {
    pushStyle();
    fill(0, 200);
    rect(20.0f, 20.0f, 320.0f, 320.0f);
    int y = 80;
    
    fill(255);
    textAlign(LEFT, TOP);
    textSize(14);
    
    text("CONTROLS", 40.0f, 40.0f);
    text("1-9 : Switch mode", 40.0f, 70.0f);
    text("TAB : Next mode", 40.0f, 90.0f);
    text("SPACE : Particles", 40.0f, 110.0f);
    text("H : HUD", 40.0f, 130.0f);
    text("P/O : Change palette", 40.0f, 150.0f);
    text("C : Center spectrum", 40.0f, 170.0f);
    text("M : Mirror spectrum", 40.0f, 190.0f);
    text("+/- : Spectrum gain", 40.0f, 210.0f);
    text("D : Debug OSC", 40.0f, 230.0f);
    text("[G] Toggle Datamosh", 40, y); y += 30;
    text("[I] Charger image de fond", 40, y); y += 30;

    text("F : Toggle this help", 40.0f, 250.0f);
    
    // Afficher la palette actuelle
    text("Palette: " + paletteManager.getCurrent().name, 40.0f, 280.0f);
    
    popStyle();
  }
}
