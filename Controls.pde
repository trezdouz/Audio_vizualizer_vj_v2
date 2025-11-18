class ControlsManager {

  boolean particlesEnabled;
  boolean showHelp;
  boolean datamoshEnabled;
  boolean showBackground;
  boolean spectrumCentered;
  boolean spectrumMirror;
  float spectrumGain;
  float modesOpacity = 1.0;  // 0.0 = transparent, 1.0 = opaque
  boolean waveformTrail = true;
  boolean waveformMultiple = false;
  boolean waveformParticles = true;
  ArrayList<Particle> particles;
  int maxParticles;

  PaletteManager paletteManager;
  ControlsManager() {
    particles = new ArrayList<Particle>();
    particlesEnabled = false;
    showHelp = false;
    datamoshEnabled = false;
    
    showBackground = true;
    spectrumCentered = false;
    spectrumMirror = false;
    spectrumGain = 1.0;
    maxParticles = 200;
    paletteManager = new PaletteManager();
  }

  void handleKey(char k, int kCode, VisualizationEngine viz, AudioManager audio, HUDWindow hud) {

    if (k >= '1' && k <= '9') {
      viz.switchMode(k - '1');
    } else if (key == 'g' || key == 'G') {
      datamoshEnabled = !datamoshEnabled;
      viz.datamoshEffect.toggle();
    } else if (kCode == TAB) {
      viz.nextMode();
    } else if (k == 'p' || k == 'P') {
      paletteManager.next();
    } else if (k == 'o' || k == 'O') {
      paletteManager.previous();
    } else if (k == 'c' || k == 'C') {
      spectrumCentered = !spectrumCentered;
      println("Spectrum centered: " + spectrumCentered);
    } else if (k == 'm' || k == 'M') {
      spectrumMirror = !spectrumMirror;
      println("Spectrum mirror: " + spectrumMirror);
    } else if (k == '+' || k == '=') {
      spectrumGain = constrain(spectrumGain + 0.1, 0.1, 5.0);
      println("Spectrum gain: " + nf(spectrumGain, 1, 1));
    } else if (k == '-' || k == '_') {
      spectrumGain = constrain(spectrumGain - 0.1, 0.1, 5.0);
      println("Spectrum gain: " + nf(spectrumGain, 1, 1));
    }
    // NOUVEAU : Contrôle de transparence
    else if (k == 't' || k == 'T') {
      modesOpacity = constrain(modesOpacity + 0.1, 0.0, 1.0);
      println("Modes opacity: " + nf(modesOpacity * 100, 0, 0) + "%");
    } else if (k == 'y' || k == 'Y') {
      modesOpacity = constrain(modesOpacity - 0.1, 0.0, 1.0);
      println("Modes opacity: " + nf(modesOpacity * 100, 0, 0) + "%");
    } else if (k == 's' || k == 'S') {
      String name = javax.swing.JOptionPane.showInputDialog("Nom du preset :");
      if (name != null && !name.trim().isEmpty()) {
        presetManager.save(name.trim());
      }
    } else if (k == 'l' || k == 'L') {
      String[] presets = presetManager.list();
      if (presets.length == 0) {
        println("Aucun preset.");
        return;
      }
      String name = (String) javax.swing.JOptionPane.showInputDialog(
        null, "Choisir preset :", "Presets",
        javax.swing.JOptionPane.QUESTION_MESSAGE, null, presets, presets[0]);
      if (name != null) {
        presetManager.load(name);
      }
    }
  }

  // NOUVELLE MÉTHODE : Pour contrôle MIDI futur
  void setModesOpacity(float value) {
    modesOpacity = constrain(value, 0.0, 1.0);
  }

  //  NOUVELLE MÉTHODE : Obtenir l'alpha à appliquer (0-255)
  float getModesAlpha() {
    return modesOpacity * 255.0;
  }

}

// ============================================
// KEY BINDINGS - Source unique
// ============================================

static class KeyBindings {
  static final String[] LINES = {
    "1-9 : Switch mode",
    "TAB : Next mode",
    "SPACE : Particles",
    "H : Toggle help popup",
    "P/O : Change palette",
    "G : Toggle Datamosh",
    "B : Toggle Background",
    "I : Load image",
    "C : Center spectrum",
    "M : Mirror spectrum",
    "+/- : Spectrum gain",
    "! : Tap tempo",
    "Y : Opacity -",
    "T : Opacity +",
    "F : Freeze ON/OFF",
    "ESC : Quit"
  };
}
