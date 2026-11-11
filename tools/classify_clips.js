const fs = require('fs');
const path = require('path');

function analyzeClip(filePath) {
    const buf = fs.readFileSync(filePath);
    const numChannels = buf.readUInt16LE(22);
    const sampleRate = buf.readUInt32LE(24);
    const bitsPerSample = buf.readUInt16LE(34);
    const dataSize = buf.readUInt32LE(40);
    const numSamples = dataSize / (numChannels * (bitsPerSample / 8));

    // Convert to float mono
    const samples = new Float32Array(numSamples);
    let offset = 44;
    for (let i = 0; i < numSamples; i++) {
        let sum = 0;
        for (let ch = 0; ch < numChannels; ch++) {
            const intSample = buf.readInt16LE(offset);
            sum += intSample / 32768.0;
            offset += 2;
        }
        samples[i] = sum / numChannels;
    }

    // Zero-crossing rate
    let zcr = 0;
    for (let i = 1; i < samples.length; i++) {
        if ((samples[i] >= 0 && samples[i - 1] < 0) || (samples[i] < 0 && samples[i - 1] >= 0)) {
            zcr++;
        }
    }
    const zcrRate = zcr / (samples.length / sampleRate); // crossings per second ~ 2 * dominant freq

    // Spectral centroid approximation via FFT or autocorrelation / peak energy
    // Max amplitude
    let maxAmp = 0;
    let sumSq = 0;
    for (let i = 0; i < samples.length; i++) {
        const abs = Math.abs(samples[i]);
        if (abs > maxAmp) maxAmp = abs;
        sumSq += samples[i] * samples[i];
    }
    const rms = Math.sqrt(sumSq / samples.length);

    // Estimate fundamental pitch via autocorrelation
    const minPeriod = Math.floor(sampleRate / 1200); // up to 1200 Hz
    const maxPeriod = Math.floor(sampleRate / 100);  // down to 100 Hz
    let bestCorrelation = -1;
    let bestPeriod = 0;

    // Check middle portion
    const midStart = Math.floor(samples.length * 0.2);
    const midEnd = Math.floor(samples.length * 0.8);
    const len = midEnd - midStart;

    if (len > maxPeriod * 2) {
        for (let lag = minPeriod; lag < maxPeriod; lag++) {
            let corr = 0;
            let normA = 0;
            let normB = 0;
            for (let i = 0; i < maxPeriod * 2; i++) {
                const a = samples[midStart + i];
                const b = samples[midStart + i + lag];
                corr += a * b;
                normA += a * a;
                normB += b * b;
            }
            const norm = Math.sqrt(normA * normB);
            const r = norm > 0 ? corr / norm : 0;
            if (r > bestCorrelation) {
                bestCorrelation = r;
                bestPeriod = lag;
            }
        }
    }

    const estimatedPitch = bestCorrelation > 0.45 && bestPeriod > 0 ? Math.round(sampleRate / bestPeriod) : null;
    const duration = samples.length / sampleRate;

    return {
        duration: parseFloat(duration.toFixed(2)),
        rms: parseFloat(rms.toFixed(3)),
        maxAmp: parseFloat(maxAmp.toFixed(3)),
        zcrRate: Math.round(zcrRate),
        estimatedPitch,
        pitchConfidence: parseFloat(bestCorrelation.toFixed(2))
    };
}

const dir = path.join('assets', 'sounds', 'clips');
const manifest = JSON.parse(fs.readFileSync(path.join(dir, 'manifest.json'), 'utf8'));

manifest.forEach(item => {
    const analysis = analyzeClip(path.join(dir, item.fileName));
    Object.assign(item, analysis);
    console.log(`${item.fileName}: dur=${item.duration}s, pitch=${item.estimatedPitch || 'none'}Hz, zcr=${item.zcrRate}`);
});

fs.writeFileSync(path.join(dir, 'manifest.json'), JSON.stringify(manifest, null, 2));
