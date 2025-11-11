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

int hudUpdateCounter = 0;
interface IAudioProvider {

  AudioManager getAudio();

}
// ============================================
// IMPLEMENTATION DE L'INTERFACE
// ============================================
IAudioProvider getAudioProvider() {
  return new IAudioProvider() {
    public AudioManager getAudio() {
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
  controls.updateParticles(audio.getBass(), audio.getMid(), audio.getTreble());
  
  // Help overlay
  if (controls.showHelp) {
    controls.drawHelpOverlay();
  }
  
  // Update HUD info periodiquement (toutes les 30 frames)
  hudUpdateCounter++;
  if (hudUpdateCounter >= 30) {
    hudUpdateCounter = 0;
    try {
      hud.updateInfo(
        viz.getCurrentModeName(),
        controls.paletteManager.getCurrent().name
      );
    } catch (Exception e) {
      // Ignore si le HUD n'est pas pret
    }
  }
  
  // Info en bas de l'ecran principale
  drawMainInfo();
}

void drawMainInfo() {
  pushStyle();
  colorMode(RGB, 255);
  
  fill(0, 150);
  noStroke();
  rect(0, height - 50, width, 50);
  
  fill(255);
  textAlign(LEFT, CENTER);
  textSize(14);
  text("Mode: " + viz.getCurrentModeName() + " | Palette: " + controls.paletteManager.getCurrent().name, 10, height - 25);
  
  textAlign(RIGHT, CENTER);
  text("Press F for help | H for HUD | P/O for palette", width - 10, height - 25);
  
  popStyle();
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
