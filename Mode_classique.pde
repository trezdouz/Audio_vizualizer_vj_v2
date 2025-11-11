// ============================================
// MODE 1 : SPECTRUM ANALYZER
// ============================================

class SpectrumMode extends BaseMode {
  
  SpectrumMode() {
    super("Spectrum Analyzer");
  }
  
  void render(float bass, float mid, float treble, float[] spectrum, ControlsManager controls) {
    background(0);
    
    // Si pas de donnees, stop
    if (spectrum == null || spectrum.length == 0) return;
    
    // Get current palette
    ColorPalette palette = controls.paletteManager.getCurrent();
    
    noStroke();
    float barWidth = width / float(spectrum.length);
    
    if (controls.spectrumCentered) {
      // MODE CENTRE
      pushMatrix();
      translate(0, height/2.0f);
      
      for (int i = 0; i < spectrum.length; i++) {
        float x = i * barWidth;
        float amplification = map(i, 0, spectrum.length, 20.0f, 200.0f);
        float h = spectrum[i] * height * amplification * 0.4f;
        
        if (h < 2.0f) h = 2.0f;
        if (h > height/2.0f) h = height/2.0f;
        
        // Get color from palette
        float position = (float)i / spectrum.length;
        color barColor = palette.getColorSmooth(position);
        
        // Barre vers le haut
        fill(barColor);
        rect(x, 0, barWidth - 1, -h);
        
        // Barre vers le bas (miroir)
        if (controls.spectrumMirror) {
          fill(red(barColor), green(barColor), blue(barColor), 150);
          rect(x, 0, barWidth - 1, h);
        }
      }
      
      popMatrix();
      
    } else {
      // MODE BAS (classique)
      for (int i = 0; i < spectrum.length; i++) {
        float x = i * barWidth;
        float amplification = map(i, 0, spectrum.length, 20.0f, 200.0f);
        float h = spectrum[i] * height * amplification;
        
        if (h < 2.0f) h = 2.0f;
        if (h > height) h = height;
        
        // Get color from palette
        float position = (float)i / spectrum.length;
        color barColor = palette.getColorSmooth(position);
        
        fill(barColor);
        rect(x, height - h, barWidth - 1, h);
        
        // Effet miroir (reflection en haut)
        if (controls.spectrumMirror) {
          fill(red(barColor), green(barColor), blue(barColor), 100);
          rect(x, height - h - h * 0.3f, barWidth - 1, h * 0.3f);
        }
      }
    }
  }
}

//==========|
// WaveForm |
//==========|

// ============================================
// MODE 2 : WAVEFORM
// ============================================

class Mode_Waveform extends BaseMode {
  
  float[] smoothedSpectrum;
  float phase;
  
  Mode_Waveform() {
    super("Waveform");
    smoothedSpectrum = new float[64];
    phase = 0.0f;
  }
  
  void render(float bass, float mid, float treble, float[] spectrum, ControlsManager controls) {
    
    // Smooth spectrum
    for (int i = 0; i < min(spectrum.length, smoothedSpectrum.length); i++) {
      smoothedSpectrum[i] = lerp(smoothedSpectrum[i], spectrum[i], 0.2f);
    }
    
    // Animated phase
    phase += 0.02f + bass * 0.05f;
    
    pushStyle();
    
    // Dark gradient background
    noStroke();
    for (int i = 0; i < height; i++) {
      float inter = map(i, 0, height, 0.0f, 1.0f);
      float darkness = lerp(8.0f, 20.0f, abs(inter - 0.5f) * 2.0f);
      fill(darkness, darkness * 1.1f, darkness * 1.3f);
      rect(0, i, width, 1);
    }
    
    // Get current palette
    ColorPalette palette = controls.paletteManager.getCurrent();
    
    // Grid lines
    stroke(30, 40, 60, 80);
    strokeWeight(1);
    for (int i = 0; i < 5; i++) {
      float y = map(i, 0, 4, height * 0.1f, height * 0.9f);
      line(0, y, width, y);
    }
    
    // Main waveform with palette colors
    noFill();
    
    // Outer glow layer
    strokeWeight(6);
    color glowColor = palette.getColorSmooth(0.3f);
    stroke(red(glowColor), green(glowColor), blue(glowColor), 50);
    beginShape();
    for (int i = 0; i < smoothedSpectrum.length; i++) {
      float x = map(i, 0, smoothedSpectrum.length, 0, width);
      float wave = sin(i * 0.15f + phase) * smoothedSpectrum[i] * height * 0.35f;
      float y = height/2.0f + wave + sin(i * 0.05f + phase * 0.5f) * mid * 30.0f;
      vertex(x, y);
    }
    endShape();
    
    // Main waveform with gradient from palette
    for (int i = 1; i < smoothedSpectrum.length; i++) {
      float x1 = map(i - 1, 0, smoothedSpectrum.length, 0, width);
      float x2 = map(i, 0, smoothedSpectrum.length, 0, width);
      
      float wave1 = sin((i - 1) * 0.15f + phase) * smoothedSpectrum[i - 1] * height * 0.35f;
      float y1 = height/2.0f + wave1 + sin((i - 1) * 0.05f + phase * 0.5f) * mid * 30.0f;
      
      float wave2 = sin(i * 0.15f + phase) * smoothedSpectrum[i] * height * 0.35f;
      float y2 = height/2.0f + wave2 + sin(i * 0.05f + phase * 0.5f) * mid * 30.0f;
      
      // Get color from palette based on position
      float position = (float)i / smoothedSpectrum.length;
      color lineColor = palette.getColorSmooth(position);
      
      strokeWeight(3);
      stroke(lineColor, 220);
      line(x1, y1, x2, y2);
    }
    
    // Bright core line
    strokeWeight(1);
    beginShape();
    for (int i = 0; i < smoothedSpectrum.length; i++) {
      float x = map(i, 0, smoothedSpectrum.length, 0, width);
      float wave = sin(i * 0.15f + phase) * smoothedSpectrum[i] * height * 0.35f;
      float y = height/2.0f + wave + sin(i * 0.05f + phase * 0.5f) * mid * 30.0f;
      
      color brightColor = palette.getColorSmooth((float)i / smoothedSpectrum.length);
      stroke(red(brightColor) * 1.2f, green(brightColor) * 1.2f, blue(brightColor) * 1.2f);
      vertex(x, y);
    }
    endShape();
    
    // Mirror waveform (inverted) with inverted palette
    for (int i = 1; i < smoothedSpectrum.length; i++) {
      float x1 = map(i - 1, 0, smoothedSpectrum.length, 0, width);
      float x2 = map(i, 0, smoothedSpectrum.length, 0, width);
      
      float wave1 = sin((i - 1) * 0.15f + phase) * smoothedSpectrum[i - 1] * height * 0.35f;
      float y1 = height/2.0f - wave1 - sin((i - 1) * 0.05f + phase * 0.5f) * mid * 30.0f;
      
      float wave2 = sin(i * 0.15f + phase) * smoothedSpectrum[i] * height * 0.35f;
      float y2 = height/2.0f - wave2 - sin(i * 0.05f + phase * 0.5f) * mid * 30.0f;
      
      // Get color from palette (inverted position)
      float position = 1.0f - (float)i / smoothedSpectrum.length;
      color lineColor = palette.getColorSmooth(position);
      
      strokeWeight(2);
      stroke(lineColor, 180);
      line(x1, y1, x2, y2);
    }
    
    // Center reference line with bass pulse
    stroke(100, 150, 200, 100 + bass * 100.0f);
    strokeWeight(2);
    line(0, height/2.0f, width, height/2.0f);
    
    // Bass reactive circles along centerline
    if (bass > 0.5f) {
      noStroke();
      color bassColor = palette.getColorSmooth(0.5f);
      fill(red(bassColor), green(bassColor), blue(bassColor), bass * 150.0f);
      for (int i = 0; i < 10; i++) {
        float x = map(i, 0, 9, 0, width);
        circle(x, height/2.0f, 10.0f + bass * 30.0f);
      }
    }
    
    popStyle();
  }
}

// ============================================
// MODE 3 : RADIAL
// ============================================

class Mode_Radial extends BaseMode {
  
  float rotation;
  float[] smoothedSpectrum;
  
  Mode_Radial() {
    super("Radial");
    rotation = 0.0f;
    smoothedSpectrum = new float[64];
  }
  
  void render(float bass, float mid, float treble, float[] spectrum, ControlsManager controls) {
    
    // Smooth spectrum
    for (int i = 0; i < min(spectrum.length, smoothedSpectrum.length); i++) {
      smoothedSpectrum[i] = lerp(smoothedSpectrum[i], spectrum[i], 0.25f);
    }
    
    // Background with vignette
    pushStyle();
    noStroke();
    for (int i = 0; i < height; i++) {
      float inter = map(i, 0, height, 0.0f, 1.0f);
      float darkness = lerp(15.0f, 5.0f, inter);
      fill(darkness);
      rect(0, i, width, 1);
    }
    popStyle();
    
    pushMatrix();
    translate(width/2.0f, height/2.0f);
    
    // Rotate slowly
    rotation += bass * 0.02f + 0.001f;
    rotate(rotation);
    
    pushStyle();
    
    // Get current palette
    ColorPalette palette = controls.paletteManager.getCurrent();
    
    // Concentric circles
    noFill();
    for (int i = 1; i <= 8; i++) {
      float alpha = map(i, 1, 8, 80.0f, 20.0f);
      color circleColor = palette.getColorSmooth((float)i / 8.0f);
      stroke(red(circleColor), green(circleColor), blue(circleColor), alpha);
      strokeWeight(1);
      circle(0, 0, i * 80.0f + bass * 30.0f);
    }
    
    // Radial spectrum bars
    float angleStep = TWO_PI / smoothedSpectrum.length;
    
    for (int i = 0; i < smoothedSpectrum.length; i++) {
      float angle = i * angleStep;
      float radius = 80.0f + smoothedSpectrum[i] * 350.0f * controls.spectrumGain;
      
      // Get color from palette
      float position = (float)i / smoothedSpectrum.length;
      color barColor = palette.getColorSmooth(position);
      
      // Outer glow
      pushMatrix();
      rotate(angle);
      
      noStroke();
      fill(red(barColor), green(barColor), blue(barColor), 100);
      triangle(
        0, -8.0f,
        radius + 20.0f, -8.0f,
        radius + 20.0f, 8.0f
      );
      
      // Main bar
      fill(red(barColor), green(barColor), blue(barColor));
      triangle(
        0, -5.0f,
        radius, -5.0f,
        radius, 5.0f
      );
      
      // Tip glow
      if (smoothedSpectrum[i] > 0.4f) {
        fill(255, 255, 255, 200);
        circle(radius, 0, 15.0f + bass * 10.0f);
      }
      
      popMatrix();
    }
    
    // Center orb with multiple layers
    noStroke();
    
    // Use palette center color
    color centerColor = palette.getColorSmooth(0.5f);
    
    // Outer glow
    fill(red(centerColor), green(centerColor), blue(centerColor), 50);
    circle(0, 0, 100.0f + bass * 80.0f);
    
    // Middle layer
    fill(red(centerColor), green(centerColor), blue(centerColor), 150);
    circle(0, 0, 60.0f + bass * 50.0f);
    
    // Core
    fill(red(centerColor), green(centerColor), blue(centerColor));
    circle(0, 0, 30.0f + bass * 30.0f);
    
    // Inner bright spot
    fill(255, 200);
    circle(0, 0, 10.0f + bass * 10.0f);
    
    popStyle();
    popMatrix();
  }
}
