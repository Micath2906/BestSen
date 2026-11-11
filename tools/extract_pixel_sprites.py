from datasets import load_dataset
import os

target_queries = {
    "loot_01_ticket": ["ticket", "coupon", "stub"],
    "loot_02_bus_card": ["card", "id card", "badge", "license"],
    "loot_03_compass": ["compass"],
    "loot_04_screw": ["screw", "bolt", "nut", "nail"],
    "loot_05_pen": ["pen", "quill", "pencil"],
    "loot_06_key": ["key", "keychain"],
    "loot_07_scroll": ["scroll", "parchment", "document", "letter"],
    "loot_08_clipboard": ["clipboard", "checklist", "book", "diary"],
    "loot_09_thermometer": ["thermometer"],
    "loot_10_pill": ["pill", "capsule", "tablet", "medicine"],
    "loot_11_first_aid": ["first aid", "bandage", "cross", "medical box"],
    "loot_12_thermos": ["flask", "thermos", "canteen", "bottle"],
    "loot_13_jars": ["jar", "potion", "vase", "urn"],
    "loot_14_magnifier": ["magnifying", "glass", "lens"],
    "loot_15_coffee": ["coffee", "cup", "mug"],
    "loot_16_scissors": ["scissors", "shears"]
}

found = {}
needed = set(target_queries.keys())

out_dir = "assets/UI/CatUIPaid/slices/pixel_atlas_icons"
os.makedirs(out_dir, exist_ok=True)

print(f"Streaming dataset to find {len(needed)} pixel sprites...")
ds = load_dataset("Angais/pixel-art-atlas-1.4m", split="train", streaming=True)

count = 0
for row in ds:
    count += 1
    subj = (row.get("subject") or "").lower()
    caption = (row.get("caption") or "").lower()
    img = row.get("image")
    
    for key in list(needed):
        keywords = target_queries[key]
        if any(kw in subj or kw in caption for kw in keywords):
            path = os.path.join(out_dir, f"{key}.png")
            # Save 16x16 original and also scale 2x/3x or keep crisp 16x16
            img.save(path)
            print(f"[{count}] FOUND {key} -> '{caption}' (subj: {subj}) -> Saved to {path}")
            found[key] = (caption, subj)
            needed.remove(key)
            break
            
    if not needed or count >= 20000:
        break

print(f"\nDone! Scanned {count} samples. Found {len(found)}/{len(target_queries)} items.")
for k, v in found.items():
    print(f"  {k}: {v[0]}")
