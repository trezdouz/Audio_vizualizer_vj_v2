// ============================================
// MODE 2 : WAVEFORM
// ============================================

class Mode2_Waveform extends BaseMode {
  
  Mode2_Waveform() {
    super("Waveform");
  }
  
  void render(float bass, float mid, float treble, float[] spectrum, ControlsManager controls) {
    pushStyle();
    
    // Background gradient
    for (int i = 0; i < height; i++) {
      float inter = map(i, 0, height, 0, 1);
      float c = lerp(10, 30, inter);
      stroke(c);
      line(0, i, width, i);
    }
    
    // Waveform from spectrum
    stroke(100, 200, 255, 200);
    strokeWeight(2);
    noFill();
    
    beginShape();
    for (int i = 0; i < spectrum.length; i++) {
      float x = map(i, 0, spectrum.length, 0, width);
      float y = height/2 + sin(i * 0.1f + frameCount * 0.05f) * spectrum[i] * height * 0.3f;
      vertex(x, y);
    }
    endShape();
    
    // Mirror effect
    beginShape();
    for (int i = 0; i < spectrum.length; i++) {
      float x = map(i, 0, spectrum.length, 0, width);
      float y = height/2 - sin(i * 0.1f + frameCount * 0.05f) * spectrum[i] * height * 0.3f;
      vertex(x, y);
    }
    endShape();
    
    // Center line
    stroke(255, 50);
    strokeWeight(1);
    line(0, height/2, width, height/2);
    
    popStyle();
  }
}
