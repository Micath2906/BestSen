import re
from datasets import load_dataset
import os

target_specs = {
    "loot_01_ticket": r"\b(ticket|stub)\b",
    "loot_02_bus_card": r"\b(id card|smart card|card|credit card|membership card)\b",
    "loot_03_compass": r"\b(compass)\b",
    "loot_04_screw": r"\b(screw|bolt|wrench)\b",
    "loot_05_pen": r"\b(pen|fountain pen|ballpoint|pencil)\b",
    "loot_06_key": r"\b(key|golden key|iron key|door key|keychain)\b",
    "loot_07_scroll": r"\b(scroll|parchment|letter|document|contract)\b",
    "loot_08_clipboard": r"\b(clipboard|checklist|notebook|notepad)\b",
    "loot_09_thermometer": r"\b(thermometer)\b",
    "loot_10_pill": r"\b(pill|capsule|blister pack|medicine bottle)\b",
    "loot_11_first_aid": r"\b(first aid|medical kit|bandage|medicine box)\b",
    "loot_12_thermos": r"\b(thermos|canteen|water bottle|flask)\b",
    "loot_13_jars": r"\b(glass jar|jar|potion|mason jar)\b",
    "loot_14_magnifier": r"\b(magnifying glass|magnifier|lens)\b",
    "loot_15_coffee": r"\b(coffee cup|coffee mug|espresso|cup of coffee)\b",
    "loot_16_scissors": r"\b(scissors|shears)\b",
    # Extra life skills & UI icons
    "icon_helmet": r"\b(helmet|safety helmet|biker helmet)\b",
    "icon_motorcycle": r"\b(motorcycle|scooter|moped)\b",
    "icon_traffic_light": r"\b(traffic light)\b",
    "icon_stethoscope": r"\b(stethoscope)\b",
    "icon_money_bag": r"\b(money bag|pouch of gold|coins|wallet)\b"
}

out_dir = "assets/UI/CatUIPaid/slices/pixel_atlas_icons"
os.makedirs(out_dir, exist_ok=True)

needed = dict(target_specs)
found = {}

print(f"Loading streaming dataset for {len(needed)} refined pixel sprites...")
ds = load_dataset("Angais/pixel-art-atlas-1.4m", split="train", streaming=True)

count = 0
for row in ds:
    count += 1
    subj = (row.get("subject") or "").lower()
    caption = (row.get("caption") or "").lower()
    text = f"{subj} {caption}"
    img = row.get("image")
    
    for key, pattern in list(needed.items()):
        if re.search(pattern, text):
            # Exclude bad false positives (e.g. keyboard, tablet computer)
            if "keyboard" in text and key == "loot_06_key":
                continue
            if "tablet computer" in text and key == "loot_10_pill":
                continue
            if "coffee table" in text and key == "loot_15_coffee":
                continue
                
            path = os.path.join(out_dir, f"{key}.png")
            img.save(path)
            print(f"[{count}] MATCH {key} -> '{caption}' (subj: {subj})")
            found[key] = (caption, subj)
            del needed[key]
            break
            
    if not needed or count >= 15000:
        break

print(f"\nRefined extraction complete! Scanned {count} samples. Found {len(found)}/{len(target_specs)} items:")
for k, (cap, sub) in sorted(found.items()):
    print(f"  - {k}: \"{cap}\" (subject: {sub})")
