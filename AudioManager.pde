// ============================================
// AUDIO MANAGER - Gestion OSC + Lissage
// ============================================

class AudioManager {
  // Raw values from OSC
  private float rawBass;
  private float rawMid;
  private float rawTreble;
  private float[] rawSpectrum;
  
  // Smoothed values
  private float smoothBass;
  private float smoothMid;
  private float smoothTreble;
  private float[] smoothSpectrum;
  
  private float SMOOTHING;
  private float DECAY;
  
  private boolean oscReceived;
  private int lastOscTime;
  
  AudioManager(int spectrumSize) {
    rawBass = 0.0f;
    rawMid = 0.0f;
    rawTreble = 0.0f;
    rawSpectrum = new float[spectrumSize];
    
    smoothBass = 0.0f;
    smoothMid = 0.0f;
    smoothTreble = 0.0f;
    smoothSpectrum = new float[spectrumSize];
    
    SMOOTHING = 0.2f;
    DECAY = 0.95f;
    
    oscReceived = false;
    lastOscTime = 0;
    
    println("AudioManager initialized (spectrum: " + spectrumSize + ")");
  }
  
  // ============================================
  // OSC HANDLING (appele depuis oscEvent())
  // ============================================
  void handleOSC(OscMessage msg) {
    lastOscTime = millis();
    oscReceived = true;
    
    if (msg.checkAddrPattern("/audio/energy")) {
      if (msg.arguments().length >= 3) {
        rawBass = msg.get(0).floatValue();
        rawMid = msg.get(1).floatValue();
        rawTreble = msg.get(2).floatValue();
        println("Energy -> Bass: " + rawBass + " | Mid: " + rawMid + " | Treble: " + rawTreble);
      }
    }
    else if (msg.checkAddrPattern("/audio/spectrum")) {
      int bands = min(rawSpectrum.length, msg.arguments().length);
      for (int i = 0; i < bands; i++) {
        rawSpectrum[i] = msg.get(i).floatValue();
      }
      println("Spectrum: " + bands + " bands");
    }
  }
  
  // ============================================
  // UPDATE
  // ============================================
  void update() {
    smoothBass = lerp(smoothBass, rawBass, SMOOTHING);
    smoothMid = lerp(smoothMid, rawMid, SMOOTHING);
    smoothTreble = lerp(smoothTreble, rawTreble, SMOOTHING);
    
    for (int i = 0; i < smoothSpectrum.length; i++) {
      smoothSpectrum[i] = lerp(smoothSpectrum[i], rawSpectrum[i], SMOOTHING);
    }
    
    if (millis() - lastOscTime > 100) {
      smoothBass *= DECAY;
      smoothMid *= DECAY;
      smoothTreble *= DECAY;
    }
    
    if (millis() - lastOscTime > 2000) {
      oscReceived = false;
    }
  }
  
  // ============================================
  // GETTERS
  // ============================================
  float getBass() { 
    return smoothBass; 
  }
  
  float getMid() { 
    return smoothMid; 
  }
  
  float getTreble() { 
    return smoothTreble; 
  }
  
  float[] getSpectrum() { 
    return smoothSpectrum; 
  }
  
  boolean isOSCActive() { 
    return oscReceived && (millis() - lastOscTime < 1000); 
  }
  
  // ============================================
  // DEBUG
  // ============================================
  void debugOSC() {
    println("=== DEBUG OSC ===");
    println("Raw    -> Bass: " + rawBass + " | Mid: " + rawMid + " | Treble: " + rawTreble);
    println("Smooth -> Bass: " + smoothBass + " | Mid: " + smoothMid + " | Treble: " + smoothTreble);
    println("OSC Active: " + isOSCActive());
    println("Last OSC: " + (millis() - lastOscTime) + "ms ago");
  }
}
