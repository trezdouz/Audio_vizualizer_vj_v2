// ============================================
// MODE 1 : SPECTRUM ANALYZER
// ============================================

class SpectrumMode extends BaseMode {
  
  SpectrumMode() {
    super("Spectrum");
  }
  
  void render(float bass, float mid, float treble, float[] spectrum, ControlsManager controls) {
    float barWidth = (float)width / spectrum.length;
    
    if (controls.spectrumCentered) {
      renderCentered(spectrum, barWidth, controls);
    } else {
      renderBottom(spectrum, barWidth, controls);
    }
  }
  
  // --- RENDU CLASSIQUE (BAS) ---
  void renderBottom(float[] spectrum, float barWidth, ControlsManager controls) {
    for (int i = 0; i < spectrum.length; i++) {
      float h = constrain(spectrum[i] * height * controls.spectrumGain, 0, height * 0.9f);
      
      float hue = map(i, 0, spectrum.length, 180, 280);
      float brightness = map(h, 0, height, 40, 90);
      
      fill(hue, 80, brightness);
      noStroke();
      
      float x = i * barWidth;
      
      if (controls.spectrumMirror) {
        rect(x, height - h, barWidth * 0.9f, h, 3);
        
        pushStyle();
        fill(hue, 60, brightness * 0.5f, 100);
        rect(x, height - h * 0.3f, barWidth * 0.9f, h * 0.3f, 3);
        popStyle();
      } else {
        rect(x, height - h, barWidth * 0.9f, h);
      }
    }
  }
  
  // --- RENDU CENTRÉ ---
  void renderCentered(float[] spectrum, float barWidth, ControlsManager controls) {
    pushMatrix();
    translate(width/2, height/2);
    
    for (int i = 0; i < spectrum.length; i++) {
      float h = constrain(spectrum[i] * height * controls.spectrumGain, 0, height * 0.9f);
      
      float hue = map(i, 0, spectrum.length, 180, 280);
      float brightness = map(h, 0, height, 40, 90);
      
      fill(hue, 80, brightness);
      noStroke();
      
      float x = map(i, 0, spectrum.length, -width/2, width/2);
      
      if (controls.spectrumMirror) {
        rect(x, -h/2, barWidth * 0.9f, h, 3);
        
        pushStyle();
        fill(hue, 60, brightness * 0.5f, 100);
        rect(x, h/2, barWidth * 0.9f, h * 0.3f, 3);
        popStyle();
      } else {
        rect(x, -h/2, barWidth * 0.9f, h);
      }
    }
    
    popMatrix();
  }
}
