// ============================================
// AUDIO VISUALIZER VJ - Architecture modulaire
// Version 2.0 - FULLSCREEN FIX
// ============================================

import oscP5.*;
import netP5.*;
import java.awt.*;
import java.util.Arrays;
import javax.swing.JOptionPane;

// Sender actif selon OS
String senderType = "none";

import codeanticode.syphon.*;
SyphonServer syphon; // macOS

// Core components
OscP5 oscP5;
AudioManager audio;
VisualizationEngine viz;
ControlsManager controls;
HUDWindow hud;
HelpWindow helpWin;
PresetManager presetManager;

// Background image
PImage bgImage;
boolean bgLoaded = false;
boolean showBackground = true;
boolean blackout = false;
boolean freeze = false;
PImage freezeFrame;

// FULLSCREEN MANAGEMENT
boolean fullScreenOn = false;  // Démarre en mode fenêtré
int displayIndex = 0;          // Écran par défaut
int windowW = 1280;
int windowH = 720;

// Interface pour le HUD
interface IAudioProvider {
  AudioManager getAudio();
}



// ============================================
// SETTINGS - Configuration initiale
// ============================================
void settings() {
  if (fullScreenOn) {
    fullScreen(P3D, displayIndex);
  } else {
    size(windowW, windowH, P3D);
  }
}

// ============================================
// SETUP
// ============================================
void setup() {
  frameRate(60);
  smooth(8);
  
  // Configuration fenêtre mode windowed
  if (!fullScreenOn) {
    surface.setResizable(false);
    surface.setLocation(150, 200);
  } else {
    surface.setAlwaysOnTop(true);
    noCursor();
  }
  
  println("|=== AUDIO VISUALIZER VJ v2.0 ===|");
  println("Mode: " + (fullScreenOn ? "Fullscreen" : "Windowed"));
  println("Display: " + displayIndex);

  // Choix du sender selon OS
  String os = System.getProperty("os.name").toLowerCase();
  try {
    if (os.contains("mac")) {
      syphon = new SyphonServer(this, "AudioVisualizer");
      senderType = "Syphon";
    } else if (os.contains("win")) {
      // spout = new Spout(this);
      // spout.createSender("AudioVisualizer");
      senderType = "Spout";
    } else {
      println("Pas de sender sous Linux (pour le moment).");
      senderType = "none";
    }
    println("Sender actif : " + senderType);
  }
  catch (Exception e) {
    println("Sender erreur : " + e.getMessage());
    senderType = "none";
  }

  // Initialize OSC
  oscP5 = new OscP5(this, 12000);
  println("OSC listening on port 12000");

  // Initialize managers
  audio = new AudioManager(64);
  viz = new VisualizationEngine();
  controls = new ControlsManager();
  helpWin = new HelpWindow();
  hud = new HUDWindow(getAudioProvider());
  hud.setControls(controls);
  presetManager = new PresetManager();

  println("\nREADY!\n");
  println("Appuyez sur H pour AIDE.\n");
  
  // Load background image
  loadBackgroundImage();
}

// ============================================
// DRAW
// ============================================
void draw() {
  if (blackout) {
    background(0);
    return;
  }
  if (freeze && freezeFrame != null) {
    image(freezeFrame, 0, 0);
    return;
  }

  // Background
  background(0);

  // Image de fond
  if (bgLoaded && controls.showBackground) {
    PImage toDraw = controls.datamoshEnabled
      ? viz.datamoshEffect.getGlitchedImage()
      : bgImage;
    image(toDraw, 0, 0);
  }

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

  // HUD update toutes les 30 frames
  if (frameCount % 30 == 0) {
    hud.updateInfo(
      viz.getCurrentModeName(),
      controls.paletteManager.getCurrent().name
    );
  }

  // Envoi vers Syphon/Spout
  if (senderType.equals("Syphon")) syphon.sendScreen();
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
  if (key == 'i' || key == 'I') {
    selectInput("Select background image:", "imageSelected");
  } else if (key == 'h' || key == 'H') {
    helpWin.toggle();
  } else if (key == 'b' || key == 'B') {
    blackout = !blackout;
    println("Blackout : " + (blackout ? "ON" : "OFF"));
  } else if (key == 'f' || key == 'F') {
    // TOGGLE FULLSCREEN
    toggleFullscreen();
  } else if (key == 'e' || key == 'E') {
    // CHANGER D'ÉCRAN
    changeDisplay();
  } else if (key == 'z' || key == 'Z') {
    // FREEZE (anciennement F)
    freeze = !freeze;
    if (freeze) freezeFrame = get();
    println("Freeze : " + (freeze ? "ON" : "OFF"));
  } else if (key == '!') {
    tapTempo();
  } else {
    controls.handleKey(key, keyCode, viz, audio, hud);
  }
}

// ============================================
// FULLSCREEN MANAGEMENT
// ============================================
void toggleFullscreen() {
  fullScreenOn = !fullScreenOn;
  println("Switching to " + (fullScreenOn ? "Fullscreen" : "Windowed") + " mode...");
  
  // Sauvegarder l'état actuel
  saveCurrentState();
  
  // Redémarrer l'application
  surface.setVisible(false);
  
  // Relancer avec nouveau mode
  String[] args = {"--display=" + displayIndex};
  PApplet.main(concat(new String[] { this.getClass().getName() }, args));
  
  // Fermer l'ancienne instance
  exit();
}

void changeDisplay() {
  GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
  int numScreens = ge.getScreenDevices().length;
  
  if (numScreens <= 1) {
    println("Un seul écran détecté.");
    return;
  }
  
  displayIndex = (displayIndex + 1) % numScreens;
  println("Écran sélectionné : " + displayIndex + " / " + numScreens);
  
  // Redémarrer sur le nouvel écran
  toggleFullscreen();
  toggleFullscreen(); // Double toggle pour appliquer le changement
}

void saveCurrentState() {
  // Sauvegarder automatiquement l'état actuel
  if (presetManager != null) {
    presetManager.save("_autosave_fullscreen");
  }
}

// ============================================
// IMAGE SELECTOR
// ============================================
void imageSelected(File selection) {
  if (selection != null) {
    try {
      bgImage = loadImage(selection.getAbsolutePath());
      bgImage.resize(width, height);
      bgLoaded = true;
      viz.datamoshEffect.setSourceImage(bgImage);
      println("Background image loaded: " + selection.getName());
    }
    catch (Exception e) {
      println("Error loading image: " + e.getMessage());
    }
  }
}

// ============================================
// BACKGROUND LOADER
// ============================================
void loadBackgroundImage() {
  File f = new File(dataPath("BG.png"));
  if (f.exists()) {
    try {
      bgImage = loadImage("BG.png");
      bgImage.resize(width, height);
      bgLoaded = true;
      if (viz != null && viz.datamoshEffect != null) {
        viz.datamoshEffect.setSourceImage(bgImage);
      }
      println("Background image loaded: BG.png");
    }
    catch (Exception e) {
      println("Error loading BG.png: " + e.getMessage());
      bgLoaded = false;
    }
  } else {
    println("BG.png not found in data folder");
    bgLoaded = false;
  }
}

// ============================================
// CLEANUP
// ============================================
void exit() {
  println("Shutting down...");
  if (viz != null) viz.cleanup();
  if (senderType.equals("Syphon") && syphon != null) {
    // syphon.stop();
  }
  if (hud != null) hud.dispose();
  if (helpWin != null) helpWin.dispose();
  super.exit();
}

// ============================================
// TAP TEMPO
// ============================================
float bpm = 120;
int lastTapTime = 0;

void tapTempo() {
  int now = millis();
  if (lastTapTime > 0) {
    int dt = now - lastTapTime;
    if (dt > 200 && dt < 2000) { // Entre 30 et 300 BPM
      bpm = 60000.0 / dt;
      println("Tap BPM : " + nf(bpm, 0, 1));
    }
  }
  lastTapTime = now;
}
