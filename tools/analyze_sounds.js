const fs = require('fs');
const { MPEGDecoder } = require('mpg123-decoder');

async function run() {
    const decoder = new MPEGDecoder();
    await decoder.ready;
    const mp3Buf = fs.readFileSync('assets/sounds/Cute_Cat_UI_Sounds_Demo_Reel.mp3');
    const { channelData, sampleRate } = decoder.decode(new Uint8Array(mp3Buf));
    console.log('Sample Rate:', sampleRate);
    console.log('Channels:', channelData.length);
    console.log('Total samples per channel:', channelData[0].length);
    const duration = channelData[0].length / sampleRate;
    console.log('Duration:', duration.toFixed(2), 'seconds');

    // Analyze RMS volume in windows of 20ms
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

    // Detect sound segments (threshold > 0.012)
    const threshold = 0.012;
    const segments = [];
    let inSeg = false;
    let segStart = 0;
    let silenceCount = 0;
    const minSilenceWins = Math.floor(0.25 / 0.02); // 250ms silence

    for (let w = 0; w < rmsArr.length; w++) {
        if (rmsArr[w] > threshold) {
            if (!inSeg) {
                inSeg = true;
                segStart = Math.max(0, w - 2); // 40ms pre-pad
            }
            silenceCount = 0;
        } else {
            if (inSeg) {
                silenceCount++;
                if (silenceCount >= minSilenceWins || w === rmsArr.length - 1) {
                    inSeg = false;
                    const segEnd = w - silenceCount + 2; // 40ms post-pad
                    const startSec = (segStart * winSize) / sampleRate;
                    const endSec = (Math.min(channelData[0].length, segEnd * winSize)) / sampleRate;
                    segments.push({ startSec, endSec, duration: endSec - startSec });
                }
            }
        }
    }

    console.log('Total detected sound segments:', segments.length);
    segments.forEach((seg, idx) => {
        console.log(`Clip ${idx + 1}: ${seg.startSec.toFixed(2)}s -> ${seg.endSec.toFixed(2)}s (dur: ${seg.duration.toFixed(2)}s)`);
    });
}
run().catch(console.error);
