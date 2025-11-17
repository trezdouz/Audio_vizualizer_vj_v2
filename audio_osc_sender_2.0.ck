// Analyse l'audio et envoie les données via OSC à Processing

// Vérification argument
if(me.args() == 0) {
    <<< "Usage: chuck audio_osc_sender.ck:fichier.wav" >>>;
    me.exit();
}

// Configuration OSC
OscOut xmit;
xmit.dest("localhost", 12000);

// Buffer audio
SndBuf buf => Gain input => dac;
buf => FFT fft => blackhole;

// Chargement fichier
me.arg(0) => string filename;
buf.read(filename);

if(buf.samples() == 0) {
    <<< "Erreur: fichier non trouvé ou vide" >>>;
    me.exit();
}

// Paramètres FFT
1024 => int FFT_SIZE;
FFT_SIZE => fft.size;
Windowing.hann(FFT_SIZE) => fft.window;
0.5 => input.gain;
0 => buf.pos;

// Variables d'analyse
complex spectrum[FFT_SIZE];
float bassEnergy;
float midEnergy;
float trebleEnergy;
float centroid;

// ← NOUVEAU : Buffer pour waveform (TAILLE SÉCURISÉE)
128 => int WAVEFORM_SIZE;
float waveformBuffer[WAVEFORM_SIZE];

// Limites des bandes de fréquence (constantes)
20 => int BASS_END;
160 => int MID_END;
400 => int TREBLE_END;
256 => int CENTROID_BINS;
64 => int SPECTRUM_BINS;

<<< "=== ChucK OSC Sender ===" >>>;
<<< "Fichier:", filename >>>;
<<< "Durée:", buf.length() / second, "secondes" >>>;
<<< "Envoi OSC vers localhost:12000" >>>;
<<< "Démarrez Processing pour visualiser" >>>;
<<< "" >>>;

// Fonction: calcul énergies par bande (optimisée)
fun void calculateBandEnergy(complex spec[]) {
    0.0 => bassEnergy;
    0.0 => midEnergy;
    0.0 => trebleEnergy;
    
    // Basses (0-250 Hz) - bins 0-19
    for(0 => int i; i < BASS_END; i++) {
        (spec[i]$polar).mag +=> bassEnergy;
    }
    bassEnergy / BASS_END => bassEnergy;
    
    // Mediums (250-2000 Hz) - bins 20-159
    for(BASS_END => int i; i < MID_END; i++) {
        (spec[i]$polar).mag +=> midEnergy;
    }
    midEnergy / (MID_END - BASS_END) => midEnergy;
    
    // Aigus (2000+ Hz) - bins 160-399
    for(MID_END => int i; i < TREBLE_END; i++) {
        (spec[i]$polar).mag +=> trebleEnergy;
    }
    trebleEnergy / (TREBLE_END - MID_END) => trebleEnergy;
}

// Fonction: calcul centroïde spectral (optimisée)
fun float calculateCentroid(complex spec[]) {
    0.0 => float weightedSum;
    0.0 => float totalMag;
    float mag;
    
    for(0 => int i; i < CENTROID_BINS; i++) {
        (spec[i]$polar).mag => mag;
        mag * i +=> weightedSum;
        mag +=> totalMag;
    }
    
    if(totalMag > 0.001) {
        return weightedSum / totalMag;
    }
    return 0.0;
}

// ← NOUVEAU : Fonction capture waveform (avec downsampling)
fun void captureWaveform() {
    4 => int DOWNSAMPLE_RATIO;  // 1 sample sur 4 (512 samples -> 128)
    
    for(0 => int i; i < WAVEFORM_SIZE; i++) {
        buf.last() => waveformBuffer[i];
        DOWNSAMPLE_RATIO::samp => now;
    }
}

// Boucle principale (optimisée)
0 => int frameCount;
now => time startTime;

while(buf.pos() < buf.samples()) {
    // ← NOUVEAU : Capture waveform AVANT l'analyse FFT
    captureWaveform();
    
    // Analyse FFT
    fft.upchuck() @=> UAnaBlob blob;
    blob.cvals() @=> spectrum;
    
    // Calculs
    calculateBandEnergy(spectrum);
    calculateCentroid(spectrum) => centroid;
    
    // Envoi via OSC - Message 1: énergies
    xmit.start("/audio/energy");
    bassEnergy => xmit.add;
    midEnergy => xmit.add;
    trebleEnergy => xmit.add;
    xmit.send();
    
    // Envoi via OSC - Message 2: centroïde
    xmit.start("/audio/centroid");
    centroid => xmit.add;
    xmit.send();
    
    // Envoi via OSC - Message 3: spectrum (64 bins downsampled)
    xmit.start("/audio/spectrum");
    for(0 => int i; i < SPECTRUM_BINS; i++) {
        (spectrum[i * 4]$polar).mag => xmit.add;
    }
    xmit.send();
    
    // ← NOUVEAU : Message 4 - waveform (128 samples)
    xmit.start("/audio/waveform");
    for(0 => int i; i < WAVEFORM_SIZE; i++) {
        waveformBuffer[i] => xmit.add;
    }
    xmit.send();
    
    // Affichage périodique amélioré
    if(frameCount % 100 == 0) {
        // Debug spectrum
        <<< "=== DEBUG SPECTRUM ===" >>>;
        <<< "FFT_SIZE:", FFT_SIZE >>>;
        <<< "SPECTRUM_BINS envoyés:", SPECTRUM_BINS >>>;
        <<< "WAVEFORM_SIZE:", WAVEFORM_SIZE >>>;
        <<< "Bin 0:", (spectrum[0]$polar).mag >>>;
        <<< "Bin 63:", (spectrum[63]$polar).mag >>>;
        <<< "Waveform[0]:", waveformBuffer[0] >>>;
        <<< "Waveform[127]:", waveformBuffer[127] >>>;
        
        // Progression
        (buf.pos() $ float / buf.samples() $ float * 100.0) => float progress;
        Std.ftoi(progress) => int progressInt;
        
        // Temps écoulé
        (now - startTime) / second => float elapsed;
        
        // Temps restant estimé
        elapsed / (progress / 100.0) - elapsed => float remaining;
        
        <<< "Frame:", frameCount, 
            "| Pos:", progressInt, "% (",
            Std.ftoi(elapsed), "s /",
            Std.ftoi(remaining), "s restant )",
            "| Bass:", bassEnergy, 
            "Mid:", midEnergy, 
            "Treble:", trebleEnergy >>>;
    }
    
    frameCount++;
    
    // Avancer dans le buffer
    FFT_SIZE::samp => now;
}

now => time endTime;
<<< "=== Lecture terminée ===" >>>;
<<< "Frames totales:", frameCount >>>;
<<< "Durée:", (endTime - startTime) / second, "secondes" >>>;
