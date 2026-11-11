import re
from datasets import load_dataset
import os

out_dir = "assets/UI/CatUIPaid/slices/pixel_atlas_icons"
patterns = [r"\b(ticket|bus ticket|train ticket|raffle ticket|cinema ticket|boarding pass|admission ticket|stub|receipt)\b"]

print("Streaming to find ticket sprite...")
ds = load_dataset("Angais/pixel-art-atlas-1.4m", split="train", streaming=True)

count = 0
found = False
for row in ds:
    count += 1
    subj = (row.get("subject") or "").lower()
    caption = (row.get("caption") or "").lower()
    text = f"{subj} {caption}"
    if any(re.search(p, text) for p in patterns):
        path = os.path.join(out_dir, "loot_01_ticket.png")
        row["image"].save(path)
        print(f"[{count}] FOUND TICKET -> '{caption}' (subj: {subj})")
        found = True
        break
    if count >= 30000:
        break

if not found:
    print(f"Not found in first {count} rows")
