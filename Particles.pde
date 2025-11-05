class Particle {
  float x, y;
  float vx, vy;
  float size;
  float lifespan;
  color col;
  
  Particle(float x, float y, float energy) {
    this.x = x;
    this.y = y;
    
    float angle = random(TWO_PI);
    float speed = energy * 5;
    this.vx = cos(angle) * speed;
    this.vy = sin(angle) * speed;
    
    this.size = map(energy, 0, 1, 5, 20);
    this.lifespan = 255;
    
    colorMode(HSB, 360, 100, 100);
    this.col = color(map(energy, 0, 1, 180, 360), 80, 100);
    colorMode(RGB, 255);
  }
  
  void update() {
    x += vx;
    y += vy;
    vx *= 0.98;
    vy *= 0.98;
    vy += 0.1;
    lifespan -= 3;
  }
  
  void display() {
    pushStyle();
    noStroke();
    fill(col, lifespan);
    ellipse(x, y, size, size);
    popStyle();
  }
  
  boolean isDead() {
    return lifespan <= 0 || x < 0 || x > width || y < 0 || y > height;
  }
  
  void cleanup() {
  }
}
