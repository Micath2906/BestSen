import re
from datasets import load_dataset
import os

out_dir = "assets/UI/CatUIPaid/slices/pixel_atlas_icons"
patterns = [r"\b(token|postage stamp|stamp|coupon|voucher)\b"]

ds = load_dataset("Angais/pixel-art-atlas-1.4m", split="train", streaming=True)

for row in ds:
    subj = (row.get("subject") or "").lower()
    caption = (row.get("caption") or "").lower()
    text = f"{subj} {caption}"
    if any(re.search(p, text) for p in patterns):
        path = os.path.join(out_dir, "loot_01_ticket.png")
        row["image"].save(path)
        print(f"FOUND TICKET -> '{caption}' (subj: {subj})")
        break
