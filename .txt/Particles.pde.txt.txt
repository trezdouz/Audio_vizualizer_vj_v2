// ============================================
// PARTICLE SYSTEM
// ============================================

class Particle {
  PVector pos;
  PVector vel;
  float lifespan;
  float particleSize;
  color particleColor;
  float rotation;
  float rotSpeed;
  
  // Constructeur pour ControlsManager (4 parametres)
  Particle(float x, float y, float vx, float vy) {
    pos = new PVector(x, y);
    vel = new PVector(vx, vy);
    lifespan = 255.0f;
    particleSize = 8.0f;
    rotation = 0.0f;
    rotSpeed = random(-0.1f, 0.1f);
    
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
    rotation = 0.0f;
    rotSpeed = random(-0.2f, 0.2f);
    
    colorMode(HSB, 360, 100, 100);
    particleColor = color(map(energy, 0.0f, 1.0f, 180.0f, 360.0f), 80, 100);
    colorMode(RGB, 255);
  }
  
  void update() {
    pos.add(vel);
    vel.mult(0.98f);
    vel.y += 0.1f;
    lifespan -= 3.0f;
    rotation += rotSpeed;
  }
  
  // Update avec audio (mid/treble)
  void updateWithAudio(float mid, float treble) {
    pos.add(vel);
    vel.mult(0.98f - mid * 0.02f);  // Mid affecte la friction
    vel.y += 0.1f + treble * 0.05f;  // Treble affecte la gravite
    lifespan -= 3.0f;
    rotation += rotSpeed * (1.0f + mid * 2.0f);  // Mid affecte la rotation
    
    // Treble cree des "pulsations" de taille
    particleSize = particleSize * (1.0f + treble * 0.1f);
  }
  
  void display() {
    pushStyle();
    pushMatrix();
    
    translate(pos.x, pos.y);
    rotate(rotation);
    
    colorMode(RGB, 255);
    
    // Outer glow
    noStroke();
    fill(red(particleColor), green(particleColor), blue(particleColor), lifespan * 0.3f);
    circle(0, 0, particleSize * 1.5f);
    
    // Core
    fill(red(particleColor), green(particleColor), blue(particleColor), lifespan);
    circle(0, 0, particleSize);
    
    // Inner bright
    fill(255, lifespan * 0.5f);
    circle(0, 0, particleSize * 0.3f);
    
    popMatrix();
    popStyle();
  }
  
  boolean isDead() {
    return lifespan <= 0.0f || pos.x < 0.0f || pos.x > width || pos.y < 0.0f || pos.y > height;
  }
  
  void cleanup() {
    // Nettoyage si necessaire
  }
}
