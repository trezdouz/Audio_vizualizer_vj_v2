class Mode3_Radial extends BaseMode {
  
  Mode3_Radial() {
    super("Radial");  // ✅ Appel explicite au constructeur parent
  }
  
  // ✅ MÉTHODE OBLIGATOIRE render()
  void render(float bass, float mid, float treble, float[] spectrum, ControlsManager controls) {
    pushMatrix();
    translate(width/2, height/2);
    
    pushStyle();
    noFill();
    strokeWeight(2);
    
    beginShape();
    for (int i = 0; i < spectrum.length; i++) {
      float angle = map(i, 0, spectrum.length, 0, TWO_PI);
      float r = 100 + spectrum[i] * 300 * (1 + bass);
      
      float hue = map(i, 0, spectrum.length, 0, 360);
      stroke(hue, 80, 90);
      
      float x = cos(angle) * r;
      float y = sin(angle) * r;
      vertex(x, y);
    }
    endShape(CLOSE);
    
    popStyle();
    popMatrix();
  }
}
