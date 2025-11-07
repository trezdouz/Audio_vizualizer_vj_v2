//============================================
// MODE 3 : RADIAL
// ============================================

class Mode3_Radial extends BaseMode {
  
  Mode3_Radial() {
    super("Radial");
  }
  
  void render(float bass, float mid, float treble, float[] spectrum, ControlsManager controls) {
    pushStyle();
    pushMatrix();
    
    translate(width/2.0f, height/2.0f);
    
    // Background circles
    noFill();
    stroke(50, 80);
    for (int i = 1; i <= 5; i++) {
      circle(0, 0, i * 100.0f);
    }
    
    // Radial spectrum
    float angleStep = TWO_PI / spectrum.length;
    
    for (int i = 0; i < spectrum.length; i++) {
      float angle = i * angleStep - HALF_PI;
      float radius = 50.0f + spectrum[i] * 300.0f * controls.spectrumGain;
      
      // Color based on position
      float hue = map(i, 0, spectrum.length, 180.0f, 320.0f);
      float brightness = map(spectrum[i], 0.0f, 1.0f, 40.0f, 90.0f);
      
      fill(hue, 80, brightness, 200);
      noStroke();
      
      // Draw segment
      pushMatrix();
      rotate(angle);
      triangle(
        0, 0,
        radius, -5.0f,
        radius, 5.0f
      );
      popMatrix();
      
      // Outer glow
      if (spectrum[i] > 0.5f) {
        fill(hue, 60, brightness, 100);
        pushMatrix();
        rotate(angle);
        circle(radius, 0, 10.0f + bass * 20.0f);
        popMatrix();
      }
    }
    
    // Center circle (reacts to bass)
    fill(200, 100, 255, 150);
    noStroke();
    circle(0, 0, 20.0f + bass * 50.0f);
    
    popMatrix();
    popStyle();
  }
}
