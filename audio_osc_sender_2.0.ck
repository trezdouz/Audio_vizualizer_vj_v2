// ============================================
// CHUCK OSC SENDER - OPTIMISÉ v2.1
// ============================================

if(me.args() == 0) {
    <<< "Usage: chuck audio_osc_sender.ck:fichier.wav" >>>;
    me.exit();
}

// ============================================
// CONFIGURATION
// ============================================
OscOut xmit;
xmit.dest("localhost", 12000);

SndBuf buf => Gain input => dac;
buf => FFT fft => blackhole;

me.arg(0) => string filename;
buf.read(filename);

if(buf.samples() == 0) {
    <<< "Erreur: fichier non trouvé" >>>;
    me.exit();
}

// ============================================
// PARAMÈTRES FFT (OPTIMISÉS)
// ============================================
512 => int FFT_SIZE;                    // ← Divisé par 2
FFT_SIZE => fft.size;
Windowing.hann(FFT_SIZE) => fft.window;
0.7 => input.gain;                      // ← Volume augmenté
1 => buf.loop;                          // ← Loop auto

// ============================================
// NORMALISATION (AJUSTABLE)
// ============================================
10.0 => float ENERGY_DIV;               // ← Sensibilité
1.0 => float SPECTRUM_DIV;

// ============================================
// VARIABLES
// ============================================
complex spectrum[FFT_SIZE];
float bassEnergy, midEnergy, trebleEnergy, centroid;

// Bandes (adaptées à FFT 512)
10 => int BASS_END;
80 => int MID_END;
200 => int TREBLE_END;
128 => int CENTROID_BINS;              // ← Réduit de 256 à 128
64 => int SPECTRUM_BINS;

<<< "=== ChucK OSC Sender OPTIMISÉ ===" >>>;
<<< "Fichier:", filename >>>;
<<< "Durée:", buf.length() / second, "sec" >>>;
<<< "🚀 Démarrage..." >>>;
<<< "" >>>;

// ============================================
// FONCTION: Normalisation
// ============================================
fun float norm(float val, float div) {
    val / div => float n;
    if(n > 1.0) return 1.0;
    if(n < 0.0) return 0.0;
    return n;
}

// ============================================
// FONCTION: Énergies (OPTIMISÉE)
// ============================================
fun void calcEnergy(complex spec[]) {
    0.0 => bassEnergy => midEnergy => trebleEnergy;
    
    for(0 => int i; i < BASS_END; i++) {
        (spec[i]$polar).mag +=> bassEnergy;
    }
    
    for(BASS_END => int i; i < MID_END; i++) {
        (spec[i]$polar).mag +=> midEnergy;
    }
    
    for(MID_END => int i; i < TREBLE_END; i++) {
        (spec[i]$polar).mag +=> trebleEnergy;
    }
    
    // Normalisation directe
    norm(bassEnergy, ENERGY_DIV) => bassEnergy;
    norm(midEnergy, ENERGY_DIV) => midEnergy;
    norm(trebleEnergy, ENERGY_DIV) => trebleEnergy;
}

// ============================================
// FONCTION: Centroid (OPTIMISÉE)
// ============================================
fun float calcCentroid(complex spec[]) {
    0.0 => float wSum;
    0.0 => float tMag;
    
    for(0 => int i; i < CENTROID_BINS; i++) {
        (spec[i]$polar).mag => float mag;
        mag * i +=> wSum;
        mag +=> tMag;
    }
    
    if(tMag > 0.001) return wSum / tMag / CENTROID_BINS;
    return 0.0;
}

// ============================================
// BOUCLE PRINCIPALE
// ============================================
0 => int frame;
now => time start;

while(true) {
    // Analyse
    fft.upchuck() @=> UAnaBlob blob;
    blob.cvals() @=> spectrum;
    
    calcEnergy(spectrum);
    calcCentroid(spectrum) => centroid;
    
    // OSC 1: Énergies
    xmit.start("/audio/energy");
    bassEnergy => xmit.add;
    midEnergy => xmit.add;
    trebleEnergy => xmit.add;
    xmit.send();
    
    // OSC 2: Centroid
    xmit.start("/audio/centroid");
    centroid => xmit.add;
    xmit.send();
    
    // OSC 3: Spectrum
    xmit.start("/audio/spectrum");
    for(0 => int i; i < SPECTRUM_BINS; i++) {
        norm((spectrum[i * 2]$polar).mag, SPECTRUM_DIV) => xmit.add;
    }
    xmit.send();
    
    // Affichage toutes les 2 sec
    if(frame % 200 == 0) {
        (now - start) / second => float elapsed;
        <<< Std.ftoi(elapsed), "s",
            "| B:", Std.ftoa(bassEnergy, 2),
            "M:", Std.ftoa(midEnergy, 2),
            "T:", Std.ftoa(trebleEnergy, 2),
            "C:", Std.ftoa(centroid, 2) >>>;
    }
    
    frame++;
    10::ms => now;  // ← CLÉ: Attente minimale
}
