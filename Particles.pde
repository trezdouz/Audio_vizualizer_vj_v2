// ============================================
// PARTICLE SYSTEM
// ============================================

class Particle {
  PVector pos;
  PVector vel;
  float lifespan;
  float particleSize;  // RENOMME: "size" peut causer des conflits
  color particleColor; // RENOMME: "col" peut causer des conflits
  
  // Constructeur pour ControlsManager (4 parametres)
  Particle(float x, float y, float vx, float vy) {
    pos = new PVector(x, y);
    vel = new PVector(vx, vy);
    lifespan = 255.0f;
    particleSize = 8.0f;
    
    colorMode(HSB, 360, 100, 100);
    particleColor = color(280, 80, 100);
    colorMode(RGB, 255);
  }
  
  // Constructeur pour Mode4_Particles (3 parametres)
  Particle(float x, float y, float energy) {
    pos = new PVector(x, y);
    
    float angle = random(TWO_PI);
    float speed = energy * 5.0f;
    vel = new PVector(cos(angle) * speed, sin(angle) * speed);
    
    lifespan = 255.0f;
    particleSize = map(energy, 0.0f, 1.0f, 5.0f, 20.0f);
    
    colorMode(HSB, 360, 100, 100);
    particleColor = color(map(energy, 0.0f, 1.0f, 180.0f, 360.0f), 80, 100);
    colorMode(RGB, 255);
  }
  
  void update() {
    pos.add(vel);
    vel.mult(0.98f);
    vel.y += 0.1f;
    lifespan -= 3.0f;
  }
  
  void display() {
    pushStyle();
    noStroke();
    fill(particleColor, lifespan);
    circle(pos.x, pos.y, particleSize);
    popStyle();
  }
  
  boolean isDead() {
    return lifespan <= 0.0f || pos.x < 0.0f || pos.x > width || pos.y < 0.0f || pos.y > height;
  }
  
  void cleanup() {
    // Nettoyage si necessaire
  }
}
