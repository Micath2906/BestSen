const fs = require('fs');
const content = fs.readFileSync('scripts/GameManager.gd', 'utf8');
const lines = content.split('\n');
let currentLesson = null;
lines.forEach(line => {
  const m = line.match(/^\s*(\d+):\s*\{/);
  if (m && parseInt(m[1]) <= 30) {
    currentLesson = m[1];
  }
  if (currentLesson) {
    const t = line.match(/\"title\":\s*\"([^\"]+)\"/);
    if (t) {
      console.log(`Lesson ${currentLesson}: ${t[1]}`);
      currentLesson = null;
    }
  }
});
