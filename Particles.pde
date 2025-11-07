// ============================================
// PARTICLE SYSTEM
// ============================================

class Particle {
  PVector pos;
  PVector vel;
  float lifespan;
  float size;
  color col;
  
  // Constructeur pour ControlsManager (4 parametres)
  Particle(float x, float y, float vx, float vy) {
    pos = new PVector(x, y);
    vel = new PVector(vx, vy);
    lifespan = 255.0f;
    size = 8.0f;
    colorMode(HSB, 360, 100, 100);
    col = color(280, 80, 100);
    colorMode(RGB, 255);
  }
  
  // Constructeur pour Mode4_Particles (3 parametres)
  Particle(float x, float y, float energy) {
    pos = new PVector(x, y);
    
    float angle = random(TWO_PI);
    float speed = energy * 5.0f;
    vel = new PVector(cos(angle) * speed, sin(angle) * speed);
    
    lifespan = 255.0f;
    size = map(energy, 0.0f, 1.0f, 5.0f, 20.0f);
    
    colorMode(HSB, 360, 100, 100);
    col = color(map(energy, 0.0f, 1.0f, 180, 360), 80, 100);
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
    fill(col, lifespan);
    circle(pos.x, pos.y, size);
    popStyle();
  }
  
  boolean isDead() {
    return lifespan <= 0.0f || pos.x < 0 || pos.x > width || pos.y < 0 || pos.y > height;
  }
  
  void cleanup() {
    // Nettoyage si necessaire
  }
}
