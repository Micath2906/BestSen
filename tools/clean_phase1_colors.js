const fs = require('fs');

['TrafficSafetyGame.gd', 'RentalContractGame.gd', 'PublicAdminGame.gd', 'LaborRightsGame.gd'].forEach(f => {
  const filePath = './scripts/minigames/' + f;
  let lines = fs.readFileSync(filePath, 'utf8').split('\n');

  // Filter out any lines before line 250 that contain "Color(0.08, 0.35, 0.75, 1.0) if is_selected"
  lines = lines.filter((line, idx) => {
    if (idx < 250 && line.includes('Color(0.08, 0.35, 0.75, 1.0) if is_selected')) {
      return false;
    }
    return true;
  });

  fs.writeFileSync(filePath, lines.join('\n'), 'utf8');
  console.log(`Cleaned Phase 1 colors in ${f}`);
});
