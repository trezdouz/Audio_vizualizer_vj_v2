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
    <<< "Erreur: fichier non trouvé" >>>;
    me.exit();
}

// Paramètres FFT
1024 => fft.size;
Windowing.hann(1024) => fft.window;
0.5 => input.gain;
0 => buf.pos;

// Variables d'analyse
complex spectrum[1024];
0.0 => float bassEnergy;
0.0 => float midEnergy;
0.0 => float trebleEnergy;
0.0 => float centroid;

<<< "=== ChucK OSC Sender ===" >>>;
<<< "Fichier:", filename >>>;
<<< "Envoi OSC vers localhost:12000" >>>;
<<< "Démarrez Processing pour visualiser" >>>;
<<< "" >>>;

// Fonction: calcul énergies par bande
fun void calculateBandEnergy(complex spec[]) {
    0.0 => bassEnergy;
    0.0 => midEnergy;
    0.0 => trebleEnergy;
    
    // Basses (0-250 Hz)
    for(0 => int i; i < 20; i++) {
        (spec[i]$polar).mag +=> bassEnergy;
    }
    bassEnergy / 20.0 => bassEnergy;
    
    // Mediums (250-2000 Hz)
    for(20 => int i; i < 160; i++) {
        (spec[i]$polar).mag +=> midEnergy;
    }
    midEnergy / 140.0 => midEnergy;
    
    // Aigus (2000+ Hz)
    for(160 => int i; i < 400; i++) {
        (spec[i]$polar).mag +=> trebleEnergy;
    }
    trebleEnergy / 240.0 => trebleEnergy;
}

// Fonction: calcul centroïde
fun float calculateCentroid(complex spec[]) {
    0.0 => float weightedSum;
    0.0 => float totalMag;
    
    for(0 => int i; i < 256; i++) {
        (spec[i]$polar).mag => float mag;
        mag * i +=> weightedSum;
        mag +=> totalMag;
    }
    
    return totalMag > 0.001 ? weightedSum / totalMag : 0.0;
}

// Boucle principale
0 => int frameCount;
while(buf.pos() < buf.samples()) {
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
    
    // Envoi via OSC - Message 3: spectrum (64 bins)
    xmit.start("/audio/spectrum");
    for(0 => int i; i < 64; i++) {
        (spectrum[i * 4]$polar).mag => xmit.add;
    }
    xmit.send();
    
    // Affichage périodique
    frameCount++;
    if(frameCount % 100 == 0) {
        <<< "Envoyé - Bass:", bassEnergy, 
            "Mid:", midEnergy, 
            "Treble:", trebleEnergy >>>;
    }
    
    1024::samp => now;
}

<<< "Lecture terminée" >>>;
