const fs = require('fs');
const path = require('path');

const dir = './scripts/minigames';
const files = fs.readdirSync(dir).filter(f => f.endsWith('.gd'));

files.forEach(f => {
  const filePath = path.join(dir, f);
  let content = fs.readFileSync(filePath, 'utf8');
  let original = content;

  // Fix theme_override_constants["separation"] = X
  content = content.replace(/(\w+)\.theme_override_constants\["separation"\]\s*=\s*(\d+)/g, '$1.add_theme_constant_override("separation", $2)');

  // Fix theme_override_colors = {"font_color": Color(...)}
  content = content.replace(/(\w+)\.theme_override_colors\s*=\s*\{"font_color":\s*(Color\([^)]+\))\}/g, '$1.add_theme_color_override("font_color", $2)');

  if (content !== original) {
    fs.writeFileSync(filePath, content, 'utf8');
    console.log(`Updated theme overrides in ${f}`);
  }
});

console.log('Finished updating theme overrides!');
