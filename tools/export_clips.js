const fs = require('fs');
const path = require('path');
const { MPEGDecoder } = require('mpg123-decoder');

function writeWav(filePath, channelData, sampleRate) {
    const numChannels = channelData.length;
    const numSamples = channelData[0].length;
    const bytesPerSample = 2; // 16-bit PCM
    const blockAlign = numChannels * bytesPerSample;
    const byteRate = sampleRate * blockAlign;
    const dataSize = numSamples * blockAlign;
    const headerSize = 44;
    const buffer = Buffer.alloc(headerSize + dataSize);

    // RIFF chunk descriptor
    buffer.write('RIFF', 0);
    buffer.writeUInt32LE(36 + dataSize, 4);
    buffer.write('WAVE', 8);

    // fmt sub-chunk
    buffer.write('fmt ', 12);
    buffer.writeUInt32LE(16, 16); // subchunk1 size
    buffer.writeUInt16LE(1, 20);  // PCM format
    buffer.writeUInt16LE(numChannels, 22);
    buffer.writeUInt32LE(sampleRate, 24);
    buffer.writeUInt32LE(byteRate, 28);
    buffer.writeUInt16LE(blockAlign, 32);
    buffer.writeUInt16LE(bytesPerSample * 8, 34);

    // data sub-chunk
    buffer.write('data', 36);
    buffer.writeUInt32LE(dataSize, 40);

    // Interleave samples
    let offset = 44;
    for (let i = 0; i < numSamples; i++) {
        for (let ch = 0; ch < numChannels; ch++) {
            let sample = channelData[ch][i];
            sample = Math.max(-1, Math.min(1, sample));
            const intSample = sample < 0 ? sample * 32768 : sample * 32767;
            buffer.writeInt16LE(Math.round(intSample), offset);
            offset += 2;
        }
    }

    fs.writeFileSync(filePath, buffer);
}

async function run() {
    const decoder = new MPEGDecoder();
    await decoder.ready;
    const mp3Buf = fs.readFileSync('assets/sounds/Cute_Cat_UI_Sounds_Demo_Reel.mp3');
    const { channelData, sampleRate } = decoder.decode(new Uint8Array(mp3Buf));

    const outDir = path.join('assets', 'sounds', 'clips');
    if (!fs.existsSync(outDir)) {
        fs.mkdirSync(outDir, { recursive: true });
    }

    // Windows of 20ms
    const winSize = Math.floor(sampleRate * 0.02);
    const numWindows = Math.floor(channelData[0].length / winSize);
    const rmsArr = [];
    for (let w = 0; w < numWindows; w++) {
        let sum = 0;
        const start = w * winSize;
        for (let i = 0; i < winSize; i++) {
            const s0 = channelData[0][start + i];
            const s1 = channelData.length > 1 ? channelData[1][start + i] : s0;
            sum += s0 * s0 + s1 * s1;
        }
        rmsArr.push(Math.sqrt(sum / (winSize * (channelData.length > 1 ? 2 : 1))));
    }

    const threshold = 0.012;
    const segments = [];
    let inSeg = false;
    let segStart = 0;
    let silenceCount = 0;
    const minSilenceWins = Math.floor(0.22 / 0.02);

    for (let w = 0; w < rmsArr.length; w++) {
        if (rmsArr[w] > threshold) {
            if (!inSeg) {
                inSeg = true;
                segStart = Math.max(0, w - 2);
            }
            silenceCount = 0;
        } else {
            if (inSeg) {
                silenceCount++;
                if (silenceCount >= minSilenceWins || w === rmsArr.length - 1) {
                    inSeg = false;
                    const segEnd = w - silenceCount + 2;
                    const startSample = segStart * winSize;
                    const endSample = Math.min(channelData[0].length, segEnd * winSize);
                    const startSec = startSample / sampleRate;
                    const endSec = endSample / sampleRate;
                    segments.push({ startSample, endSample, startSec, endSec, duration: endSec - startSec });
                }
            }
        }
    }

    console.log(`Writing ${segments.length} sound clips...`);
    const manifest = [];
    segments.forEach((seg, idx) => {
        const id = String(idx + 1).padStart(2, '0');
        const fileName = `clip_${id}.wav`;
        const filePath = path.join(outDir, fileName);
        
        // Extract slice
        const sliceData = [];
        for (let ch = 0; ch < channelData.length; ch++) {
            sliceData.push(channelData[ch].slice(seg.startSample, seg.endSample));
        }
        writeWav(filePath, sliceData, sampleRate);

        manifest.push({
            id: idx + 1,
            fileName,
            startSec: parseFloat(seg.startSec.toFixed(2)),
            endSec: parseFloat(seg.endSec.toFixed(2)),
            duration: parseFloat(seg.duration.toFixed(2))
        });
    });

    fs.writeFileSync(path.join(outDir, 'manifest.json'), JSON.stringify(manifest, null, 2));
    console.log('Saved clips and manifest.json!');
}

run().catch(console.error);
