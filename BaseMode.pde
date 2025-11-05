// ============================================
// BASE MODE - Classe abstraite pour tous les modes
// ============================================

abstract class BaseMode {
  
  // Rendering
  protected PGraphics buffer;
  protected boolean useGPU = false;
  protected PShader shader;
  
  // Audio data
  protected float[] spectrum;
  
  // Metadata
  protected String name = "Unnamed";
  protected int renderColorMode = HSB; // ← RENOMMÉ (évite conflit avec colorMode())
  
  // ============================================
  // CONSTRUCTEUR
  // ============================================
  BaseMode(String modeName) {
    this.name = modeName;
    this.spectrum = new float[64];
  }
  
  // ============================================
  // MÉTHODES OBLIGATOIRES
  // ============================================
  
  abstract void render(float bass, float mid, float treble, float[] spectrum, ControlsManager controls);
  
  // ============================================
  // MÉTHODES COMMUNES
  // ============================================
  
  void enableGPU(String shaderPath) {
    try {
      shader = loadShader(shaderPath);
      useGPU = true;
      println("✓ GPU activé pour " + name);
    } catch (Exception e) {
      println("⚠ Shader non trouvé pour " + name + ", fallback CPU");
      useGPU = false;
    }
  }
  
  void setRenderColorMode(int mode) {
    this.renderColorMode = mode;
  }
  
  String getName() {
    return name;
  }
  
  void cleanup() {
    if (buffer != null) {
      buffer.dispose();
    }
  }
}
