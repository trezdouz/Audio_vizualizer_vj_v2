// ============================================
// MODE 1 : SPECTRUM ANALYZER (AMELIORE)
// ============================================

class SpectrumMode extends BaseMode {
  
  float[] smoothedSpectrum;
  
  SpectrumMode() {
    super("Spectrum");
    smoothedSpectrum = new float[128];
  }
  
  void render(float bass, float mid, float treble, float[] spectrum, ControlsManager controls) {
    
    // Smooth spectrum for fluid animation
    for (int i = 0; i < min(spectrum.length, smoothedSpectrum.length); i++) {
      smoothedSpectrum[i] = lerp(smoothedSpectrum[i], spectrum[i], 0.3f);
    }
    
    // Background gradient
    pushStyle();
    noStroke();
    for (int i = 0; i < height; i++) {
      float inter = map(i, 0, height, 0.0f, 1.0f);
      float r = lerp(5, 20, inter);
      float g = lerp(0, 10, inter);
      float b = lerp(15, 30, inter);
      stroke(r, g, b);
      line(0, i, width, i);
    }
    popStyle();
    
    float barWidth = (float)width / smoothedSpectrum.length;
    
    if (controls.spectrumCentered) {
      renderCentered(smoothedSpectrum, barWidth, controls, bass);
    } else {
      renderBottom(smoothedSpectrum, barWidth, controls, bass);
    }
  }
  
  void renderBottom(float[] spectrum, float barWidth, ControlsManager controls, float bass) {
    pushStyle();
    
    for (int i = 0; i < spectrum.length; i++) {
      float h = constrain(spectrum[i] * height * controls.spectrumGain * 1.5f, 0.0f, height * 0.85f);
      
      // Improved colors
      float hue = map(i, 0, spectrum.length, 200.0f, 320.0f);
      float saturation = map(h, 0.0f, height, 60, 100);
      float brightness = map(h, 0.0f, height, 50.0f, 100.0f);
      
      float x = i * barWidth;
      
      // Glow effect
      noStroke();
      fill(hue, saturation * 0.5f, brightness, 100);
      rect(x, height - h - 10.0f, barWidth * 0.95f, h + 10.0f, 2.0f);
      
      // Main bar
      fill(hue, saturation, brightness);
      rect(x, height - h, barWidth * 0.95f, h, 2.0f);
      
      // Top highlight
      if (h > 50.0f) {
        fill(hue, saturation * 0.3f, 100, 200);
        rect(x, height - h, barWidth * 0.95f, 3.0f);
      }
      
      // Bass reaction
      if (bass > 0.7f && i < spectrum.length * 0.2f) {
        fill(350, 100, 100, 150);
        rect(x, height - h - bass * 20.0f, barWidth * 0.95f, 3.0f);
      }
    }
    
    popStyle();
  }
  
  void renderCentered(float[] spectrum, float barWidth, ControlsManager controls, float bass) {
    pushMatrix();
    translate(width/2.0f, height/2.0f);
    pushStyle();
    
    for (int i = 0; i < spectrum.length; i++) {
      float h = constrain(spectrum[i] * height * controls.spectrumGain * 1.2f, 0.0f, height * 0.4f);
      
      float hue = map(i, 0, spectrum.length, 200.0f, 320.0f);
      float saturation = map(h, 0.0f, height, 60, 100);
      float brightness = map(h, 0.0f, height, 50.0f, 100.0f);
      
      float x = map(i, 0, spectrum.length, -width/2.0f, width/2.0f);
      
      // Symmetric glow
      noStroke();
      fill(hue, saturation * 0.5f, brightness, 80);
      rect(x, -h/2.0f - 5.0f, barWidth * 0.95f, h + 10.0f, 2.0f);
      
      // Main bars
      fill(hue, saturation, brightness);
      rect(x, -h/2.0f, barWidth * 0.95f, h, 2.0f);
      
      // Center line highlight
      fill(hue, 50, 100, 200);
      rect(x, -2.0f, barWidth * 0.95f, 4.0f);
    }
    
    // Center pulse with bass
    fill(280, 80, 100, bass * 200.0f);
    noStroke();
    circle(0, 0, 30.0f + bass * 50.0f);
    
    popStyle();
    popMatrix();
  }
}
