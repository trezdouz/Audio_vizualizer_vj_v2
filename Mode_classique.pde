//===========
class SpectrumMode extends BaseMode {

  SpectrumMode() {
    super("Spectrum Analyzer");
  }

  void render(float bass, float mid, float treble, float[] spectrum, ControlsManager controls) {

    if (spectrum == null || spectrum.length == 0) return;

    ColorPalette palette = controls.paletteManager.getCurrent();

    noStroke();
    float barWidth = width / float(spectrum.length);

    // ⭐ Récupérer l'alpha depuis controls
    float alpha = controls.getModesAlpha();

    if (controls.spectrumCentered) {
      pushMatrix();
      translate(0, height/2.0f);

      for (int i = 0; i < spectrum.length; i++) {
        float x = i * barWidth;
        float amplification = map(i, 0, spectrum.length, 20.0f, 200.0f);
        float h = spectrum[i] * height * amplification * 0.4f;

        if (h < 2.0f) h = 2.0f;
        if (h > height/2.0f) h = height/2.0f;

        float position = (float)i / spectrum.length;
        color barColor = palette.getColorSmooth(position);

        // ⭐ Appliquer l'alpha contrôlé
        fill(red(barColor), green(barColor), blue(barColor), alpha);
        rect(x, 0, barWidth - 1, -h);

        if (controls.spectrumMirror) {
          fill(red(barColor), green(barColor), blue(barColor), alpha * 0.6);
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

        float position = (float)i / spectrum.length;
        color barColor = palette.getColorSmooth(position);

        // ⭐ Appliquer l'alpha contrôlé
        fill(red(barColor), green(barColor), blue(barColor), alpha);
        rect(x, height - h, barWidth - 1, h);

        if (controls.spectrumMirror) {
          fill(red(barColor), green(barColor), blue(barColor), alpha * 0.6);
          rect(x, height - h - h * 0.3f, barWidth - 1, h * 0.3f);
        }
      }
    }
  }
}

// =================================
// MODE 2 : OSCILLOSCOPE HORIZONTAL
// =================================
class Mode_Waveform extends BaseMode {

  Mode_Waveform() {
    super("Waveform");
  }

  void render(float bass, float mid, float treble, float[] spectrum, ControlsManager controls) {

    if (spectrum == null || spectrum.length == 0) return;

    ColorPalette palette = controls.paletteManager.getCurrent();

    // ⭐ Récupérer l'alpha
    float alpha = controls.getModesAlpha();

    int waveResolution = min(spectrum.length, 256);
    float spacing = width / float(waveResolution);

    // Forme remplie
    noStroke();
    beginShape();
    vertex(0, height / 2.0f);

    for (int i = 0; i < waveResolution; i++) {
      float x = i * spacing;
      float amplification = map(i, 0, waveResolution, 20.0f, 200.0f);
      float h = spectrum[i] * height * amplification * 0.4f;
      float y = height / 2.0f - h;

      float position = (float)i / waveResolution;
      color c = palette.getColorSmooth(position);

      // ⭐ Appliquer alpha
      fill(red(c), green(c), blue(c), alpha * 0.3);
      vertex(x, y);
    }

    vertex(width, height / 2.0f);
    endShape(CLOSE);

    // Contour haut
    noFill();
    strokeWeight(3.0f);
    beginShape();

    for (int i = 0; i < waveResolution; i++) {
      float x = i * spacing;
      float amplification = map(i, 0, waveResolution, 20.0f, 200.0f);
      float h = spectrum[i] * height * amplification * 0.4f;
      float y = height / 2.0f - h;

      float position = (float)i / waveResolution;
      color c = palette.getColorSmooth(position);

      // ⭐ Appliquer alpha
      stroke(red(c), green(c), blue(c), alpha);
      vertex(x, y);
    }
    endShape();

    // Miroir bas
    strokeWeight(2.0f);
    beginShape();

    for (int i = 0; i < waveResolution; i++) {
      float x = i * spacing;
      float amplification = map(i, 0, waveResolution, 20.0f, 200.0f);
      float h = spectrum[i] * height * amplification * 0.4f;
      float y = height / 2.0f + h;

      float position = (float)i / waveResolution;
      color c = palette.getColorSmooth(position);

      // ⭐ Appliquer alpha
      stroke(red(c), green(c), blue(c), alpha * 0.6);
      vertex(x, y);
    }
    endShape();
  }
}
// ============================================
// MODE 3 : CIRCULAIRE 3D
// (BasÃ© sur draw3DCircular du projet monolithique)
// ============================================

class Mode_Radial extends BaseMode {

  Mode_Radial() {
    super("Circulaire 3D");
  }

  void render(float bass, float mid, float treble, float[] spectrum, ControlsManager controls) {
    pushStyle();
    colorMode(HSB, 360, 100, 100);

    // Get palette
    ColorPalette palette = controls.paletteManager.getCurrent();

    pushMatrix();
    translate(width/2, height/2, 0);
    rotateY(frameCount * 0.01f);
    rotateX(sin(frameCount * 0.005f) * 0.2f);

    float radius = 150; // REDUIT de 300 Ã  150
    float angleStep = TWO_PI / spectrum.length;
    strokeWeight(3);

    for (int i = 0; i < spectrum.length; i++) {
      float angle = i * angleStep;
      float amp = constrain(spectrum[i] * 500, 0, 400); // AMPLIFIE

      // Get color from palette
      float position = (float)i / spectrum.length;
      color barColor = palette.getColorSmooth(position);

      stroke(hue(barColor), saturation(barColor), brightness(barColor));

      float x1 = cos(angle) * radius;
      float y1 = sin(angle) * radius;
      float x2 = cos(angle) * (radius + amp);
      float y2 = sin(angle) * (radius + amp);

      // LIGNE depuis le centre
      line(x1, y1, 0, x2, y2, amp * 0.5f);

      // Sphere at end
      pushMatrix();
      translate(x2, y2, amp * 0.5f);
      noStroke();
      fill(hue(barColor), saturation(barColor) * 0.8f, brightness(barColor));
      sphere(5 + bass * 3);
      popMatrix();
    }

    popMatrix();
    popStyle();
  }
}

// ============================================
// MODE 5 : 64 OSCILLOSCOPES
// (BasÃ© sur draw64Oscilloscopes du projet monolithique)
// ============================================

class Mode_Oscilloscopes extends BaseMode {

  float[] smoothSpectrum;

  Mode_Oscilloscopes() {
    super("64 Oscilloscopes");
    smoothSpectrum = new float[64];
  }

  void render(float bass, float mid, float treble, float[] spectrum, ControlsManager controls) {
    // Smooth spectrum
    for (int i = 0; i < min(spectrum.length, smoothSpectrum.length); i++) {
      smoothSpectrum[i] = lerp(smoothSpectrum[i], spectrum[i], 0.3f);
    }

    pushStyle();
    colorMode(HSB, 360, 100, 100);

    int cols = 8;
    int rows = 8;
    float cellW = width / (float)cols;
    float cellH = height / (float)rows;

    for (int i = 0; i < 64; i++) {
      int col = i % cols;
      int row = i / cols;
      float x = col * cellW;
      float y = row * cellH;
      float hue = map(i, 0, 64, 0, 360);
      float amp = constrain(smoothSpectrum[i] * 200, 0, cellH * 0.4f); // AMPLIFIE x200

      // Get color from palette
      ColorPalette palette = controls.paletteManager.getCurrent();
      float position = (float)i / 64.0f;
      color cellColor = palette.getColorSmooth(position);

      pushMatrix();
      translate(x + cellW/2, y + cellH/2);

      // Border
      noFill();
      stroke(cellColor);
      strokeWeight(1);
      rect(-cellW/2 + 5, -cellH/2 + 5, cellW - 10, cellH - 10);

      // Center line
      stroke(hue, 30, 50);
      line(-cellW/2 + 5, 0, cellW/2 - 5, 0);

      // Waveform
      stroke(hue, 80, 100);
      strokeWeight(2);
      noFill();

      beginShape();
      int points = 50;
      for (int p = 0; p < points; p++) {
        float px = map(p, 0, points - 1, -cellW/2 + 5, cellW/2 - 5);
        float phase = frameCount * 0.05f + i * 0.5f;
        float wave = sin(p * 0.3f + phase) * amp;
        wave += sin(p * 0.6f + phase * 2) * amp * 0.3f;
        vertex(px, wave);
      }
      endShape();

      // Glow on strong signal
      if (amp > 5) {
        stroke(hue, 80, 100, 30);
        strokeWeight(4);
        beginShape();
        for (int p = 0; p < points; p++) {
          float px = map(p, 0, points - 1, -cellW/2 + 5, cellW/2 - 5);
          float phase = frameCount * 0.05f + i * 0.5f;
          float wave = sin(p * 0.3f + phase) * amp;
          wave += sin(p * 0.6f + phase * 2) * amp * 0.3f;
          vertex(px, wave);
        }
        endShape();
      }

      // Label
      fill(hue, 60, 80);
      textAlign(CENTER, CENTER);
      textSize(8);
      text(i, 0, cellH/2 - 15);

      popMatrix();
    }

    popStyle();
  }
}
// ============================================
// MODE 6 : CIRCULAIRE STATIQUE
// (BasÃ© sur drawCircularStatic du projet monolithique)
// ============================================

class Mode_CircularStatic extends BaseMode {

  Mode_CircularStatic() {
    super("Circulaire Static");
  }

  void render(float bass, float mid, float treble, float[] spectrum, ControlsManager controls) {
    pushStyle();
    colorMode(HSB, 360, 100, 100);

    // Get palette
    ColorPalette palette = controls.paletteManager.getCurrent();

    pushMatrix();
    translate(width/2, height/2);

    float radius = 150;
    int numBars = 32;
    float barWidth = TWO_PI / numBars;

    for (int i = 0; i < numBars; i++) {
      float avgAmp = 0;
      int binsPerBar = spectrum.length / numBars;
      int startIdx = i * binsPerBar;
      int endIdx = min(startIdx + binsPerBar, spectrum.length);

      for (int j = startIdx; j < endIdx; j++) {
        avgAmp += spectrum[j];
      }
      avgAmp /= binsPerBar;

      float angle = i * barWidth;
      float amp = constrain(avgAmp * 500, 0, 300); // AMPLIFIE x500

      // Get color from palette
      float position = (float)i / numBars;
      color barColor = palette.getColorSmooth(position);

      // Draw layered arcs
      for (float r = radius; r < radius + amp; r += 5) {
        float alpha = map(r, radius, radius + amp, 100, 50);
        fill(hue(barColor), 80, 90, alpha);
        noStroke();
        arc(0, 0, r * 2, r * 2,
          angle - barWidth/2, angle + barWidth/2, PIE);
      }
    }

    // Center dark circle
    fill(0, 0, 0, 150);
    noStroke();
    ellipse(0, 0, radius * 2, radius * 2);

    // Center outline
    noFill();
    stroke(0, 0, 100, 50);
    strokeWeight(2);
    ellipse(0, 0, radius * 2, radius * 2);

    popMatrix();
    popStyle();
  }
}

// ============================================
// MODE 7 : BARRES DE FREQUENCE AMELIOREES
// (BasÃ© sur drawFrequencyBarsImproved du projet monolithique)
// ============================================

class Mode_FrequencyBars extends BaseMode {

  Mode_FrequencyBars() {
    super("Frequency Bars");
  }

  void render(float bass, float mid, float treble, float[] spectrum, ControlsManager controls) {
    pushStyle();
    colorMode(HSB, 360, 100, 100);

    float barWidth = width / (float)spectrum.length;
    float barSpacing = 2;

    for (int i = 0; i < spectrum.length; i++) {
      float h = constrain(spectrum[i] * 50, 0, height * 0.8f);
      float hue = map(i, 0, spectrum.length, 240, 0);
      float sat = map(h, 0, height, 50, 100);

      // Main bar
      fill(hue, sat, 90);
      noStroke();
      rect(i * barWidth, height - h, barWidth - barSpacing, h, 2);

      // Top glow
      fill(hue, sat, 60, 30);
      rect(i * barWidth, height - h - 5, barWidth - barSpacing, h * 0.3f, 2);
    }

    popStyle();
  }
}
