// ============================================
// MODE 4 : PARTICLES
// ============================================

class Mode_Particles extends BaseMode {
  ArrayList<AudioParticle> modeParticles;
  int maxModeParticles;
  
  Mode_Particles() {
    super("Particles");
    modeParticles = new ArrayList<AudioParticle>();
    maxModeParticles = 150;
  }
  
  void render(float bass, float mid, float treble, float[] spectrum, ControlsManager controls) {
    pushStyle();
    
    // Dark background with trails
    fill(0, 30);
    rect(0, 0, width, height);
    
    // Get current palette
    ColorPalette palette = controls.paletteManager.getCurrent();
    
    // Spawn particles on beat
    if (bass > 0.5f && modeParticles.size() < maxModeParticles) {
      int numParticles = int(bass * 5.0f);
      for (int i = 0; i < numParticles; i++) {
        float position = random(1.0f);
        color particleColor = palette.getColorSmooth(position);
        modeParticles.add(new AudioParticle(
          width/2.0f, 
          height/2.0f, 
          bass, 
          mid, 
          treble,
          particleColor
        ));
      }
    }
    
    // Update and draw particles
    for (int i = modeParticles.size() - 1; i >= 0; i--) {
      AudioParticle p = modeParticles.get(i);
      p.update(bass, mid, treble);
      p.display();
      
      if (p.isDead()) {
        modeParticles.remove(i);
      }
    }
    
    // Spectrum as background waves with palette
    noFill();
    strokeWeight(2);
    
    for (int j = 0; j < 3; j++) {
      color waveColor = palette.getColorSmooth((float)j / 3.0f);
      stroke(red(waveColor), green(waveColor), blue(waveColor), 50);
      
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
    modeParticles.clear();
  }
}

// ============================================
// AUDIO PARTICLE CLASS (amélioration)
// ============================================
class AudioParticle {
  PVector pos;
  PVector vel;
  PVector acc;
  float lifespan;
  float size;
  color particleColor;
  float rotation;
  float rotSpeed;
  
  AudioParticle(float x, float y, float bass, float mid, float treble, color col) {
    pos = new PVector(x, y);
    
    float angle = random(TWO_PI);
    float speed = 2.0f + bass * 8.0f;
    vel = new PVector(cos(angle) * speed, sin(angle) * speed);
    acc = new PVector(0.0f, 0.0f);
    
    size = 5.0f + mid * 15.0f;
    particleColor = col;
    rotSpeed = random(-0.2f, 0.2f);
    lifespan = 255.0f;
    rotation = 0.0f;
  }
  
  void update(float bass, float mid, float treble) {
    // Physics
    vel.add(acc);
    pos.add(vel);
    vel.mult(0.98f);
    rotation += rotSpeed;
    
    // Lifespan
    lifespan -= 2.0f;
    
    // Audio reactivity
    if (bass > 0.7f) {
      PVector push = PVector.random2D();
      push.mult(bass * 2.0f);
      acc.add(push);
    }
    acc.mult(0.9f);
  }
  
  void display() {
    pushStyle();
    pushMatrix();
    
    translate(pos.x, pos.y);
    rotate(rotation);
    
    // Outer glow
    noStroke();
    fill(red(particleColor), green(particleColor), blue(particleColor), lifespan * 0.3f);
    circle(0, 0, size * 2.0f);
    
    // Core
    fill(red(particleColor), green(particleColor), blue(particleColor), lifespan);
    circle(0, 0, size);
    
    // Inner bright spot
    fill(255, lifespan * 0.5f);
    circle(0, 0, size * 0.3f);
    
    popMatrix();
    popStyle();
  }
  
  boolean isDead() {
    return lifespan <= 0.0f || pos.x < -50.0f || pos.x > width + 50.0f || 
           pos.y < -50.0f || pos.y > height + 50.0f;
  }
}
