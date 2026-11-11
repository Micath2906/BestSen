const fs = require('fs');
const path = require('path');

const dir = './scripts/minigames';
const files = fs.readdirSync(dir).filter(f => f.endsWith('.gd'));

files.forEach(f => {
  const filePath = path.join(dir, f);
  let content = fs.readFileSync(filePath, 'utf8');
  let original = content;

  // Fix set_border_width_bottom(X) -> border_width_bottom = X
  content = content.replace(/\.set_border_width_bottom\((\d+)\)/g, '.border_width_bottom = $1');

  // Fix theme_override_font_sizes = {"font_size": X} -> add_theme_font_size_override("font_size", X)
  content = content.replace(/(\w+)\.theme_override_font_sizes = \{"font_size":\s*(\d+)\}/g, '$1.add_theme_font_size_override("font_size", $2)');

  if (content !== original) {
    fs.writeFileSync(filePath, content, 'utf8');
    console.log(`Updated ${f}`);
  }
});

console.log('Finished updating style and font calls!');
