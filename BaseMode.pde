// ============================================
// BASE MODE - Classe abstraite pour tous les modes
// ============================================

abstract class BaseMode {
  
  // Rendering
  protected PGraphics buffer;
  protected boolean useGPU;
  protected PShader shader;
  
  // Audio data
  protected float[] spectrum;
  
  // Metadata
  protected String name;
  protected int renderColorMode;
  
  // ============================================
  // CONSTRUCTEUR
  // ============================================
  BaseMode(String modeName) {
    this.name = modeName;
    this.spectrum = new float[64];
    this.useGPU = false;
    this.renderColorMode = HSB;
    this.buffer = null;
    this.shader = null;
  }
  
  // ============================================
  // METHODES OBLIGATOIRES
  // ============================================
  
  abstract void render(float bass, float mid, float treble, float[] spectrum, ControlsManager controls);
  
  // ============================================
  // METHODES COMMUNES
  // ============================================
  
  void enableGPU(String shaderPath) {
    try {
      shader = loadShader(shaderPath);
      useGPU = true;
      println("GPU active pour " + name);
    } catch (Exception e) {
      println("Shader non trouve pour " + name + ", fallback CPU");
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
      buffer = null;
    }
  }
}
