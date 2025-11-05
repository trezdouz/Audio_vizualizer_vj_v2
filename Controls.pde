// ============================================
// CONTROLS MANAGER
// Gestion centralisee de tous les controles
// ============================================

class ControlsManager {
  
  // === ETATS ===
  boolean particlesEnabled = false;
  boolean showHelp = false;
  boolean datamoshEnabled = false;
  
  // === PARAMETRES SPECTRUM ===
  boolean spectrumCentered = false;
  boolean spectrumMirror = false;
  float spectrumGain = 1.0f;
  
  // === PARTICULES ===
  ArrayList<Particle> particles;
  int maxParticles = 200;
  
  // === CONSTRUCTOR ===
  ControlsManager() {
    particles = new ArrayList<Particle>();
  }
  
  // ============================================
  // GESTION CLAVIER
  // ============================================
  void handleKey(char k, int kCode, VisualizationEngine viz, AudioManager audio, HUDWindow hud) {
    
    // Modes (1-9)
    if (k >= '1' && k <= '9') {
      viz.switchMode(k - '1');
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
  // PARTICULES
  // ============================================
  void updateParticles(float bass) {
    // Spawn on bass
    if (particlesEnabled && bass > 0.5f && particles.size() < maxParticles) {
      float angle = random(TWO_PI);
      float speed = 2 + bass * 5;
      particles.add(new Particle(
        width/2,
        height/2,
        cos(angle) * speed,
        sin(angle) * speed
      ));
    }
    
    // Update & draw
    for (int i = particles.size() - 1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.update();
      p.display();
      
      if (p.isDead()) {
        particles.remove(i);
      }
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
    println("   C      : Center spectrum");
    println("   M      : Mirror spectrum");
    println("   +/-    : Spectrum gain");
    println("   D      : Debug OSC");
  }
  
  void drawHelpOverlay() {
    pushStyle();
    fill(0, 200);
    rect(20, 20, 300, 280);
    
    fill(255);
    textAlign(LEFT, TOP);
    textSize(14);
    
    text("CONTROLS", 40, 40);
    text("1-9 : Switch mode", 40, 70);
    text("TAB : Next mode", 40, 90);
    text("SPACE : Particles", 40, 110);
    text("H : HUD", 40, 130);
    text("C : Center spectrum", 40, 150);
    text("M : Mirror spectrum", 40, 170);
    text("+/- : Spectrum gain", 40, 190);
    text("D : Debug OSC", 40, 210);
    text("F : Toggle this help", 40, 250);
    
    popStyle();
  }
}
