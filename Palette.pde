class ColorPalette {
  String name;
  color[] colors;
  
  ColorPalette(String name, color[] colors) {
    this.name = name;
    this.colors = colors;
  }
  
  color getColor(float position) {
    // position entre 0.0 et 1.0
    int index = (int)(position * (colors.length - 1));
    index = constrain(index, 0, colors.length - 1);
    return colors[index];
  }
  
  // Interpolation entre deux couleurs (optionnel, pour gradients fluides)
  color getColorSmooth(float position) {
    float scaledPos = position * (colors.length - 1);
    int index1 = (int)scaledPos;
    int index2 = min(index1 + 1, colors.length - 1);
    float lerp = scaledPos - index1;
    
    return lerpColor(colors[index1], colors[index2], lerp);
  }
}
class PaletteManager {
  ArrayList<ColorPalette> palettes;
  int currentIndex;
  
  PaletteManager() {
    palettes = new ArrayList<ColorPalette>();
    currentIndex = 0;
    initPalettes();
  }
  
  void initPalettes() {
    // Palette 1: Rainbow classique
    palettes.add(new ColorPalette("Rainbow", new color[] {
      color(255, 0, 0),     // Rouge
      color(255, 127, 0),   // Orange
      color(255, 255, 0),   // Jaune
      color(0, 255, 0),     // Vert
      color(0, 0, 255),     // Bleu
      color(75, 0, 130),    // Indigo
      color(148, 0, 211)    // Violet
    }));
    
    // Palette 2: Fire (chaud)
    palettes.add(new ColorPalette("Fire", new color[] {
      color(0, 0, 0),       // Noir
      color(128, 0, 0),     // Bordeaux
      color(255, 0, 0),     // Rouge
      color(255, 128, 0),   // Orange
      color(255, 255, 0),   // Jaune
      color(255, 255, 255)  // Blanc
    }));
    
    // Palette 3: Ocean (froid)
    palettes.add(new ColorPalette("Ocean", new color[] {
      color(0, 0, 64),      // Bleu nuit
      color(0, 0, 128),     // Bleu foncé
      color(0, 64, 255),    // Bleu
      color(0, 128, 255),   // Bleu clair
      color(64, 224, 208),  // Turquoise
      color(255, 255, 255)  // Blanc
    }));
    
    // Palette 4: Neon
    palettes.add(new ColorPalette("Neon", new color[] {
      color(255, 0, 255),   // Magenta
      color(0, 255, 255),   // Cyan
      color(255, 255, 0),   // Jaune
      color(0, 255, 0)      // Vert
    }));
    
    // Palette 5: Monochrome violet
    palettes.add(new ColorPalette("Purple", new color[] {
      color(20, 0, 40),     // Très sombre
      color(80, 0, 120),    
      color(160, 0, 200),   
      color(200, 100, 255), 
      color(255, 200, 255)  // Très clair
    }));
  }
  
  ColorPalette getCurrent() {
    return palettes.get(currentIndex);
  }
  
  void next() {
    currentIndex = (currentIndex + 1) % palettes.size();
    println("Palette: " + getCurrent().name);
  }
  
  void previous() {
    currentIndex = (currentIndex - 1 + palettes.size()) % palettes.size();
    println("Palette: " + getCurrent().name);
  }
  
  void setByIndex(int index) {
    if (index >= 0 && index < palettes.size()) {
      currentIndex = index;
      println("Palette: " + getCurrent().name);
    }
  }
}
