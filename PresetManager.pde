import processing.data.*;

class PresetManager {
  String presetPath = sketchPath("presets/");
  JSONObject current;

  PresetManager() {
    File dir = new File(presetPath);
    if (!dir.exists()) dir.mkdir();
    current = new JSONObject();
  }

  void save(String name) {
    current.setInt("modeIndex", viz.getCurrentModeIndex());
    current.setString("palette", controls.paletteManager.getCurrent().name);
    current.setFloat("opacity", controls.modesOpacity);
    current.setBoolean("datamosh", controls.datamoshEnabled);
    current.setBoolean("background", controls.showBackground);
    current.setInt("displayIndex", displayIndex);
current.setBoolean("fullScreenOn", fullScreenOn);
    saveJSONObject(current, presetPath + name + ".json");
    println("Preset sauvegardé : " + name);
  }

  void load(String name) {
    try {
      current = loadJSONObject(presetPath + name + ".json");
      viz.switchMode(current.getInt("modeIndex"));
      int idw = current.getInt("paletteIndex");

      
      controls.modesOpacity = current.getFloat("opacity");
      controls.datamoshEnabled = current.getBoolean("datamosh");
      controls.showBackground = current.getBoolean("background");
      println("Preset chargé : " + name);
    }
    catch (Exception e) {
      println("Preset introuvable : " + name);
    }
  }

  String[] list() {
    File dir = new File(presetPath);
    String[] names = dir.list();
    if (names == null) return new String[0];
    return Arrays.stream(names)
      .filter(n -> n.endsWith(".json"))
      .map(n -> n.replace(".json", ""))
      .toArray(String[]::new);
  }
}
