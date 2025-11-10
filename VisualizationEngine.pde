// ============================================
// VISUALIZATION ENGINE
// Gere les modes et les transitions
// ============================================

class VisualizationEngine {

  BaseMode[] modes;
  int currentModeIndex;
  BaseMode currentMode;

  // ============================================
  // CONSTRUCTOR
  // ============================================
  VisualizationEngine() {
    modes = new BaseMode[] {
      new SpectrumMode(),
      new Mode_Waveform(),
      new Mode_Radial(),
      new Mode_Particles()
    };

    currentModeIndex = 0;
    currentMode = modes[0];
    println("Visualization Engine initialise avec " + modes.length + " modes");
  }

  // ============================================
  // UPDATE & RENDER
  // ============================================
  void update(float bass, float mid, float treble, float[] spectrum, ControlsManager controls) {
    currentMode.render(bass, mid, treble, spectrum, controls);
  }

  void render() {
    // Deja fait dans update
  }

  // ============================================
  // MODE SWITCHING
  // ============================================
  void switchMode(int index) {
    if (index >= 0 && index < modes.length) {
      currentModeIndex = index;
      currentMode = modes[currentModeIndex];
      println("Mode: " + currentMode.getName());
    }
  }

  void nextMode() {
    currentModeIndex = (currentModeIndex + 1) % modes.length;
    currentMode = modes[currentModeIndex];
    println("Mode: " + currentMode.getName());
  }

  // ============================================
  // GETTERS
  // ============================================
  int getCurrentModeIndex() {
    return currentModeIndex;
  }

  String getCurrentModeName() {
    return currentMode.getName();
  }

  // ============================================
  // CLEANUP
  // ============================================
  void cleanup() {
    println("Nettoyage des modes...");
    for (BaseMode mode : modes) {
      if (mode != null) {
        mode.cleanup();
      }
    }
    println("Modes nettoyes");
  }
}
