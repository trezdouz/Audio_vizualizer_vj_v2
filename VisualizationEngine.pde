class VisualizationEngine {
  BaseMode[] modes;
  int currentModeIndex = 0;
  BaseMode currentMode;
  
  VisualizationEngine() {
    modes = new BaseMode[] {
      new SpectrumMode(),
      new Mode2_Waveform(),
      new Mode3_Radial(),
      
    };
    currentMode = modes[0];
    println("✓ Engine initialisé avec " + modes.length + " modes");
  }
  
  void update(float bass, float mid, float treble, float[] spectrum, ControlsManager controls) {
    currentMode.render(bass, mid, treble, spectrum, controls);
  }
  
  void nextMode() {
    currentModeIndex = (currentModeIndex + 1) % modes.length;
    currentMode = modes[currentModeIndex];
    println("✓ Mode: " + currentMode.name);
  }
  
  void previousMode() {
    currentModeIndex = (currentModeIndex - 1 + modes.length) % modes.length;
    currentMode = modes[currentModeIndex];
    println("✓ Mode: " + currentMode.name);
  }
  void switchMode(int index) {
    if (index >= 0 && index < modes.length) {
      currentModeIndex = index;
      currentMode = modes[index];
      println("✓ Mode changé: " + currentMode.name);
    } else {
      println("⚠ Index invalide: " + index);
    }
  }
  
  int getCurrentModeIndex() {
    return currentModeIndex;
  }
  
  String getCurrentModeName() {
    return currentMode.name;
  }
  
  void cleanup() {
    println("→ Nettoyage des modes...");
    for (BaseMode mode : modes) {
      if (mode != null) {
        mode.cleanup();
      }
    }
    println("✓ Modes nettoyés");
  }
}  
