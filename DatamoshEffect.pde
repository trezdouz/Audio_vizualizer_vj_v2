// ============================================
// DATAMOSH EFFECT
// Effet de glitch audioreactif
// ============================================

class DatamoshEffect {
  PGraphics buffer;
  PImage backgroundImage;
  boolean enabled;
  String currentImagePath;

  DatamoshEffect(int w, int h) {
    buffer = createGraphics(w, h);
    enabled = false;
    
    // CHARGE L'IMAGE PAR DEFAUT AU DEMARRAGE
    currentImagePath = dataPath("BG.png");
    loadBackgroundImage(currentImagePath);
    
    println("DatamoshEffect initialise");
  }

  // FONCTION DE CHARGEMENT D'IMAGE
  void loadBackgroundImage(String path) {
    File f = new File(path);
    if (f.exists()) {
      backgroundImage = loadImage(path);
      if (backgroundImage != null) {
        backgroundImage.resize(width, height);
        println("Image chargee: " + path);
      } else {
        println("ERREUR: Impossible de charger l'image: " + path);
      }
    } else {
      println("ERREUR: Fichier introuvable: " + path);
    }
  }

  // SELECTION D'IMAGE VIA DIALOGUE
  void selectImage() {
    selectInput("Choisir une image de fond", "imageSelected", dataFile(""), this);
  }

  void imageSelected(File selection) {
    if (selection != null) {
      currentImagePath = selection.getAbsolutePath();
      loadBackgroundImage(currentImagePath);
    }
  }

  void apply(PGraphics pg, float bass, float mid, float treble) {
    if (!enabled || backgroundImage == null) return;

    buffer.beginDraw();
    buffer.background(0);
    
    // DESSINE L'IMAGE DE FOND
    buffer.image(backgroundImage, 0, 0);
    
    // COPIE LE RENDU ACTUEL PAR-DESSUS
    buffer.blend(pg, 0, 0, pg.width, pg.height, 0, 0, buffer.width, buffer.height, BLEND);

    buffer.loadPixels();

    // GLITCHES AUDIO-REACTIFS
    int intensity = int(bass * 50.0f);
    for (int i = 0; i < intensity; i++) {
      int x = int(random(buffer.width));
      int y = int(random(buffer.height));
      int idx = x + y * buffer.width;
      if (idx < buffer.pixels.length - 1) {
        buffer.pixels[idx] = buffer.pixels[idx + 1];
      }
    }

    // Color shift base sur mid
    float shift = mid * 20.0f;
    for (int i = 0; i < buffer.pixels.length; i++) {
      color c = buffer.pixels[i];
      float r = red(c);
      float g = green(c);
      float b = blue(c);
      buffer.pixels[i] = color((r + shift) % 255.0f, g, b);
    }

    // Block displacement base sur treble
    int blockSize = 16;
    int numBlocks = int(treble * 10.0f);
    for (int i = 0; i < numBlocks; i++) {
      int bx = int(random(buffer.width / blockSize)) * blockSize;
      int by = int(random(buffer.height / blockSize)) * blockSize;
      int offsetX = int(random(-20.0f, 20.0f));
      int offsetY = int(random(-20.0f, 20.0f));

      for (int y = 0; y < blockSize; y++) {
        for (int x = 0; x < blockSize; x++) {
          int srcX = constrain(bx + x, 0, buffer.width - 1);
          int srcY = constrain(by + y, 0, buffer.height - 1);
          int destX = constrain(bx + x + offsetX, 0, buffer.width - 1);
          int destY = constrain(by + y + offsetY, 0, buffer.height - 1);

          int srcIdx = srcX + srcY * buffer.width;
          int destIdx = destX + destY * buffer.width;

          if (srcIdx < buffer.pixels.length && destIdx < buffer.pixels.length) {
            buffer.pixels[destIdx] = buffer.pixels[srcIdx];
          }
        }
      }
    }

    buffer.updatePixels();
    buffer.endDraw();

    // AFFICHE LE BUFFER GLITCHE
    image(buffer, 0, 0);
  }

  void toggle() {
    enabled = !enabled;
    println("Datamosh: " + (enabled ? "ON" : "OFF"));
  }
}
