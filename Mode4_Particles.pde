// ============================================
// MODE 4 : PARTICLES
// ============================================

class Mode4_Particles extends BaseMode {
  ArrayList<Particle> modeParticles;
  int maxModeParticles;
  
  Mode4_Particles() {
    super("Particles");
    modeParticles = new ArrayList<Particle>();
    maxModeParticles = 100;
  }
  
  void render(float bass, float mid, float treble, float[] spectrum, ControlsManager controls) {
    pushStyle();
    
    // Dark background with trails
    fill(0, 30);
    rect(0, 0, width, height);
    
    // Spawn particles on beat (utilise constructeur 3 parametres)
    if (bass > 0.6f && modeParticles.size() < maxModeParticles && random(1.0f) < 0.3f) {
      modeParticles.add(new Particle(width/2.0f, height/2.0f, bass));
    }
    
    // Update and draw particles
    for (int i = modeParticles.size() - 1; i >= 0; i--) {
      Particle p = modeParticles.get(i);
      p.update();
      p.display();
      
      if (p.isDead()) {
        modeParticles.remove(i);
      }
    }
    
    // Spectrum as background waves
    noFill();
    stroke(100, 150, 255, 50);
    strokeWeight(2);
    
    for (int j = 0; j < 3; j++) {
      beginShape();
      for (int i = 0; i < spectrum.length; i++) {
        float x = map(i, 0, spectrum.length, 0, width);
        float y = height/2.0f + sin(i * 0.2f + frameCount * 0.03f + j) * spectrum[i] * 100.0f;
        vertex(x, y);
      }
      endShape();
    }
    
    // Info
    fill(255);
    text("Particles: " + modeParticles.size(), 10, 20);
    
    popStyle();
  }
  
  void cleanup() {
    for (Particle p : modeParticles) {
      p.cleanup();
    }
    modeParticles.clear();
  }
}
