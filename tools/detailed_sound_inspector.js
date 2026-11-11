const fs = require('fs');
const path = require('path');

function analyzeClipDetailed(filePath) {
    const buf = fs.readFileSync(filePath);
    const numChannels = buf.readUInt16LE(22);
    const sampleRate = buf.readUInt32LE(24);
    const bitsPerSample = buf.readUInt16LE(34);
    const dataSize = buf.readUInt32LE(40);
    const numSamples = dataSize / (numChannels * (bitsPerSample / 8));

    const samples = new Float32Array(numSamples);
    let offset = 44;
    for (let i = 0; i < numSamples; i++) {
        let sum = 0;
        for (let ch = 0; ch < numChannels; ch++) {
            sum += buf.readInt16LE(offset) / 32768.0;
            offset += 2;
        }
        samples[i] = sum / numChannels;
    }

    const duration = samples.length / sampleRate;

    // Detect attack time (time to reach 80% peak)
    let peak = 0;
    for (let i = 0; i < samples.length; i++) {
        if (Math.abs(samples[i]) > peak) peak = Math.abs(samples[i]);
    }
    let attackSample = 0;
    for (let i = 0; i < samples.length; i++) {
        if (Math.abs(samples[i]) >= peak * 0.8) {
            attackSample = i;
            break;
        }
    }
    const attackMs = (attackSample / sampleRate) * 1000;

    // Estimate pitch at beginning, middle, and end (3 windows)
    function estimateWindowPitch(startIdx, endIdx) {
        const wLen = endIdx - startIdx;
        const minPeriod = Math.floor(sampleRate / 1400);
        const maxPeriod = Math.floor(sampleRate / 80);
        if (wLen < maxPeriod * 2) return null;

        let bestCorr = -1;
        let bestLag = 0;
        for (let lag = minPeriod; lag < maxPeriod; lag++) {
            let corr = 0, nA = 0, nB = 0;
            const checkLen = Math.min(wLen - lag, maxPeriod * 2);
            for (let i = 0; i < checkLen; i++) {
                const a = samples[startIdx + i];
                const b = samples[startIdx + i + lag];
                corr += a * b;
                nA += a * a;
                nB += b * b;
            }
            const norm = Math.sqrt(nA * nB);
            const r = norm > 0 ? corr / norm : 0;
            if (r > bestCorr) {
                bestCorr = r;
                bestLag = lag;
            }
        }
        if (bestCorr > 0.45 && bestLag > 0) {
            return Math.round(sampleRate / bestLag);
        }
        return null;
    }

    const w1 = Math.floor(samples.length * 0.15);
    const w2 = Math.floor(samples.length * 0.45);
    const w3 = Math.floor(samples.length * 0.70);
    const wLen = Math.floor(samples.length * 0.25);

    const pitchStart = estimateWindowPitch(w1, w1 + wLen);
    const pitchMid = estimateWindowPitch(w2, w2 + wLen);
    const pitchEnd = estimateWindowPitch(w3, w3 + wLen);

    // Classification heuristics
    let category = "unknown";
    if (duration < 0.35 && attackMs < 30) {
        category = "ui_click_pop";
    } else if (duration > 0.8 && (pitchMid < 220 || pitchStart < 220)) {
        category = "purr_or_low_meow";
    } else if (pitchStart && pitchEnd && pitchEnd < pitchStart * 0.75) {
        category = "downward_fail_or_sad_meow";
    } else if (pitchStart && pitchEnd && pitchEnd > pitchStart * 1.25) {
        category = "rising_inquisitive_meow";
    } else if (duration > 1.2 && (pitchMid > 500 || pitchEnd > 500)) {
        category = "fanfare_or_long_meow";
    } else if (duration >= 0.35 && duration <= 1.2) {
        category = "cat_meow";
    }

    return {
        duration: parseFloat(duration.toFixed(2)),
        attackMs: Math.round(attackMs),
        pitchStart,
        pitchMid,
        pitchEnd,
        category
    };
}

const dir = path.join('assets', 'sounds', 'clips');
const files = fs.readdirSync(dir).filter(f => f.endsWith('.wav')).sort();

const results = [];
for (const f of files) {
    const res = analyzeClipDetailed(path.join(dir, f));
    results.push({ file: f, ...res });
    console.log(`${f}: dur=${res.duration}s, atk=${res.attackMs}ms, pitch=[${res.pitchStart || '-'}, ${res.pitchMid || '-'}, ${res.pitchEnd || '-'}], cat=${res.category}`);
}

fs.writeFileSync(path.join(dir, 'detailed_analysis.json'), JSON.stringify(results, null, 2));
