const fs = require('fs');
const path = require('path');

const dir = './scripts/minigames';
const files = fs.readdirSync(dir).filter(f => f.endsWith('.gd'));

files.forEach(f => {
  const filePath = path.join(dir, f);
  let content = fs.readFileSync(filePath, 'utf8');
  let original = content;

  // Replace selected_step_card.clear() -> selected_step_card = {}
  content = content.replace(/selected_step_card\.clear\(\)/g, 'selected_step_card = {}');

  // Replace selected_classify_card.clear() -> selected_classify_card = {}
  content = content.replace(/selected_classify_card\.clear\(\)/g, 'selected_classify_card = {}');

  // Replace selected_action_card.clear() -> selected_action_card = {}
  content = content.replace(/selected_action_card\.clear\(\)/g, 'selected_action_card = {}');

  // Also when assigning: selected_step_card = s_info.duplicate() or scen.duplicate()
  content = content.replace(/selected_step_card = s_info/g, 'selected_step_card = s_info.duplicate()');
  content = content.replace(/selected_classify_card = scen/g, 'selected_classify_card = scen.duplicate()');
  content = content.replace(/selected_action_card = step_info/g, 'selected_action_card = step_info.duplicate()');

  if (content !== original) {
    fs.writeFileSync(filePath, content, 'utf8');
    console.log(`Updated dictionary usage in ${f}`);
  }
});

console.log('Finished updating readonly dictionary references!');
