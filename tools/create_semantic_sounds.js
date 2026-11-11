const fs = require('fs');
const path = require('path');

const clipsDir = path.join('assets', 'sounds', 'clips');
const soundsDir = path.join('assets', 'sounds');

const mappings = {
    'cat_meow_curious.wav': 'clip_29.wav',    // "Meo-o?" (rising inquisitive pitch)
    'cat_meow_cheerful.wav': 'clip_19.wav',   // "Méo meo!" (bright cheerful exclamation)
    'cat_meow_sweet.wav': 'clip_31.wav',      // "Meoo~" (sweet tender meow)
    'cat_meow_bold.wav': 'clip_37.wav',       // "Ngoao!" (firm determined meow)
    'cat_meow_general.wav': 'clip_08.wav',    // General happy meow
    'cat_purr.wav': 'clip_44.wav',            // Long soothing purr (2.28s)
    'cat_fail_ngoao.wav': 'clip_35.wav',      // Whining disappointed "Ngoao..." (1.68s)
    'cat_fail_short.wav': 'clip_22.wav',      // Short grumpy "Ngoao." (0.76s)
    'cat_success_fanfare.wav': 'clip_45.wav', // Joyful celebration fanfare (1.52s)
    'cat_success_chime.wav': 'clip_43.wav',   // Sweet victory chime (1.24s)
    'ui_click.wav': 'clip_01.wav',            // Crisp UI tap/click (0.20s)
    'ui_card_pop.wav': 'clip_03.wav',         // Snappy pop when placing card (0.18s)
    'ui_cancel.wav': 'clip_05.wav',           // Light dismiss / unslot (0.16s)
    'cat_eat_chomp.wav': 'clip_07.wav',       // Cute eating / munching (0.40s)
    'cat_bounce.wav': 'clip_12.wav',          // Springy bounce sound (0.28s)
    'cat_giggle.wav': 'clip_38.wav',          // Ticklish giggle chirp (0.48s)
    'cat_talking.wav': 'clip_30.wav'          // Playful chatter mimic (0.66s)
};

for (const [dest, src] of Object.entries(mappings)) {
    const srcPath = path.join(clipsDir, src);
    const destPath = path.join(soundsDir, dest);
    if (fs.existsSync(srcPath)) {
        fs.copyFileSync(srcPath, destPath);
        console.log(`Copied ${src} -> ${dest}`);
    } else {
        console.error(`Missing source: ${srcPath}`);
    }
}
