// ============================================
// PARTICLE SYSTEM
// ============================================

class Particle {
  PVector pos;
  PVector vel;
  float lifespan;
  float size;
  
  Particle(float x, float y, float vx, float vy) {
    pos = new PVector(x, y);
    vel = new PVector(vx, vy);
    lifespan = 255.0f;
    size = 8.0f;
  }
  
  void update() {
    pos.add(vel);
    vel.mult(0.98f);
    lifespan -= 3.0f;
  }
  
  void display() {
    pushStyle();
    noStroke();
    fill(200, 100, 255, lifespan);
    circle(pos.x, pos.y, size);
    popStyle();
  }
  
  boolean isDead() {
    return lifespan <= 0.0f;
  }
}
