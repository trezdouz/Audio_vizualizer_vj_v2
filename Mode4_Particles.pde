class Mode4_Particles extends BaseMode {
  ArrayList<Particle> particles;
  
  Mode4_Particles() {
    super("Particles");
    particles = new ArrayList<Particle>();
  }
  
  void render(float bass, float mid, float treble, float[] spectrum, ControlsManager controls) {
    background(0);
    
    // Crée des particules sur les pics de bass
    if (bass > 0.6f && random(1) < 0.3f) {
      particles.add(new Particle(width/2, height/2, bass));  // ✅ Maintenant ça marche !
    }
    
    // Update et affichage
    for (int i = particles.size() - 1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.update();
      p.display();
      
      if (p.isDead()) {
        particles.remove(i);
      }
    }
    
    // Affiche le nombre de particules
    fill(255);
    text("Particles: " + particles.size(), 10, 20);
  }
  
  void cleanup() {
    for (Particle p : particles) {
      p.cleanup();
    }
    particles.clear();
  }
}
