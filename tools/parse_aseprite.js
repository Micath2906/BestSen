const fs = require('fs');

function parseAsepriteTags(filePath) {
    const buf = fs.readFileSync(filePath);
    console.log('--- File:', filePath, 'Size:', buf.length);
    const magic = buf.readUInt16LE(4);
    if (magic !== 0xA5E0) {
        console.log('Not valid aseprite');
        return;
    }
    const frames = buf.readUInt16LE(6);
    const width = buf.readUInt16LE(8);
    const height = buf.readUInt16LE(10);
    const depth = buf.readUInt16LE(12);
    console.log(`Frames: ${frames}, Size: ${width}x${height}, Depth: ${depth}`);

    let offset = 128; // after header
    for (let f = 0; f < frames; f++) {
        if (offset >= buf.length) break;
        const frameBytes = buf.readUInt32LE(offset);
        const frameMagic = buf.readUInt16LE(offset + 4);
        let numChunks = buf.readUInt16LE(offset + 6);
        let duration = buf.readUInt16LE(offset + 8);
        if (numChunks === 0xFFFF) numChunks = buf.readUInt32LE(offset + 12);
        
        let chunkOffset = offset + 16;
        for (let c = 0; c < numChunks; c++) {
            if (chunkOffset >= offset + frameBytes || chunkOffset >= buf.length) break;
            const chunkSize = buf.readUInt32LE(chunkOffset);
            const chunkType = buf.readUInt16LE(chunkOffset + 4);
            
            if (chunkType === 0x2018) { // Tag chunk
                const numTags = buf.readUInt16LE(chunkOffset + 6);
                console.log(`Found ${numTags} tags in frame ${f}:`);
                let tagPtr = chunkOffset + 16;
                for (let t = 0; t < numTags; t++) {
                    const fromFrame = buf.readUInt16LE(tagPtr);
                    const toFrame = buf.readUInt16LE(tagPtr + 2);
                    const loopDir = buf.readUInt8(tagPtr + 4);
                    const nameLen = buf.readUInt16LE(tagPtr + 17);
                    const tagName = buf.slice(tagPtr + 19, tagPtr + 19 + nameLen).toString('utf8');
                    tagPtr += 19 + nameLen;
                    console.log(`  Tag [${t}]: '${tagName}', frames ${fromFrame}..${toFrame}, dir=${loopDir}`);
                }
            }
            chunkOffset += chunkSize;
        }
        offset += frameBytes;
    }
}

parseAsepriteTags('assets/Free pack/Free pack/cat 16x16 animation list.aseprite');
parseAsepriteTags('assets/Free pack/Free pack/cat 1.aseprite');
