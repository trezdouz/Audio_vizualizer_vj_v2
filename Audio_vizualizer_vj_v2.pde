// ============================================
// AUDIO VISUALIZER VJ - Architecture modulaire
// Version 2.0
// ============================================

import oscP5.*;
import netP5.*;

// Core components
OscP5 oscP5;
AudioManager audio;
VisualizationEngine viz;
ControlsManager controls;
HUDWindow hud;

interface IAudioProvider {
  AudioManager getAudio();
}

// ============================================
// IMPLEMENTATION DE L'INTERFACE
// ============================================
IAudioProvider getAudioProvider() {
  return new IAudioProvider() {public AudioManager getAudio() {
      return audio;
    }
  };
}

void setup() {
  size(1280, 720, P3D);
  surface.setLocation(150, 200);
  frameRate(60);
  smooth(8);
  
  println("\n===========================");
  println("  AUDIO VISUALIZER VJ v2.0");
  println("===========================\n");
  
  // Initialize OSC
  oscP5 = new OscP5(this, 12000);
  println("OSC listening on port 12000");
  
  // Initialize managers
  audio = new AudioManager(64);
  viz = new VisualizationEngine();
  controls = new ControlsManager();
  
  // HUD - passe l'interface
  hud = new HUDWindow(getAudioProvider());
  
  println("\nREADY!\n");
  controls.printHelp();
}

void draw() {
  background(0);
  
  // Update audio
  audio.update();
  
  // Update visualization
  viz.update(
    audio.getBass(), 
    audio.getMid(), 
    audio.getTreble(), 
    audio.getSpectrum(),
    controls
  );
  
  // Particles
  controls.updateParticles(audio.getBass());
  
  // Help overlay
  if (controls.showHelp) {
    controls.drawHelpOverlay();
  }
}

// ============================================
// OSC
// ============================================
void oscEvent(OscMessage msg) {
  audio.handleOSC(msg);
}

// ============================================
// CONTROLS
// ============================================
void keyPressed() {
  controls.handleKey(key, keyCode, viz, audio, hud);
}

void dispose() {
  viz.cleanup();
  hud.dispose();
  oscP5.dispose();
}
