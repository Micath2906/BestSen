const fs = require('fs');

function enhanceScript(filePath) {
  let content = fs.readFileSync(filePath, 'utf8');

  // Check if slot_btn exists and style it
  if (content.includes('var slot_btn = Button.new()')) {
    const slotTarget = /var slot_btn = Button\.new\(\)\s*slot_btn\.custom_minimum_size = Vector2\(0, 36\)\s*slot_btn\.add_theme_font_size_override\("font_size", 11\)/;
    if (slotTarget.test(content)) {
      const slotReplacement = `var slot_btn = Button.new()
			slot_btn.custom_minimum_size = Vector2(0, 36)
			slot_btn.add_theme_font_size_override("font_size", 11)
			var slot_sb = StyleBoxFlat.new()
			slot_sb.set_corner_radius_all(8)
			slot_sb.set_border_width_all(1)
			slot_sb.border_color = Color(0.85, 0.75, 0.65, 1.0)
			slot_sb.bg_color = Color(0.97, 0.95, 0.92, 1.0)
			slot_sb.content_margin_left = 10
			slot_sb.content_margin_right = 10
			slot_btn.add_theme_stylebox_override("normal", slot_sb)`;
      content = content.replace(slotTarget, slotReplacement);
      console.log(`Styled slot_btn in ${filePath}`);
    }
  }

  // Ensure btn.add_theme_color_override in cards_pool
  const poolColorTarget = /btn\.add_theme_stylebox_override\("normal", style\)/g;
  if (content.includes('cards_pool') && poolColorTarget.test(content)) {
    content = content.replace(/btn\.add_theme_stylebox_override\("normal", style\)/g, 
      `btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_color_override("font_color", Color(0.08, 0.35, 0.75, 1.0) if is_selected else Color(0.25, 0.2, 0.15, 1.0))`
    );
    console.log(`Added font_color to cards_pool in ${filePath}`);
  }

  fs.writeFileSync(filePath, content, 'utf8');
}

['TrafficSafetyGame.gd', 'RentalContractGame.gd', 'PublicAdminGame.gd', 'LaborRightsGame.gd'].forEach(f => {
  enhanceScript('./scripts/minigames/' + f);
});

// Also check HospitalBHYTProcessGame.gd
let bhyt = fs.readFileSync('./scripts/minigames/HospitalBHYTProcessGame.gd', 'utf8');
const bhytSlotTarget = /var slot_btn = Button\.new\(\)\s*slot_btn\.custom_minimum_size = Vector2\(0, 32\)\s*slot_btn\.add_theme_font_size_override\("font_size", 11\)/;
if (bhytSlotTarget.test(bhyt)) {
  const bhytSlotReplacement = `var slot_btn = Button.new()
			slot_btn.custom_minimum_size = Vector2(0, 32)
			slot_btn.add_theme_font_size_override("font_size", 11)
			var slot_sb = StyleBoxFlat.new()
			slot_sb.set_corner_radius_all(8)
			slot_sb.set_border_width_all(1)
			slot_sb.border_color = Color(0.85, 0.75, 0.65, 1.0)
			slot_sb.bg_color = Color(0.97, 0.95, 0.92, 1.0)
			slot_sb.content_margin_left = 10
			slot_sb.content_margin_right = 10
			slot_btn.add_theme_stylebox_override("normal", slot_sb)`;
  bhyt = bhyt.replace(bhytSlotTarget, bhytSlotReplacement);
  console.log('Styled slot_btn in HospitalBHYTProcessGame.gd');
}
fs.writeFileSync('./scripts/minigames/HospitalBHYTProcessGame.gd', bhyt, 'utf8');

console.log('Done enhancing button styles!');
