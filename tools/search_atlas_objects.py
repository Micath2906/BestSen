import requests
import json

url = "https://huggingface.co/datasets/Angais/pixel-art-atlas-1.4m/raw/main/objects.json"
print("Fetching objects.json...")
r = requests.get(url)
if r.status_code == 200:
    objects = r.json()
    print(f"Total unique objects in dataset: {len(objects)}")
    
    # Check our target items
    targets = [
        "ticket", "bus", "card", "compass", "screw", "bolt", "pen", "key",
        "scroll", "document", "clipboard", "thermometer", "pill", "capsule",
        "medicine", "bandage", "bottle", "flask", "jar", "glass", "magnifying",
        "coffee", "mug", "scissors", "helmet", "scooter", "motorcycle", "map",
        "house", "stethoscope", "coin", "gold", "money", "stamp"
    ]
    
    matches = {}
    for t in targets:
        matched = [obj for obj in objects if t in obj.lower()]
        matches[t] = matched[:5]
        
    for t, m in matches.items():
        if m:
            print(f"[{t}]: {', '.join(m)}")
        else:
            print(f"[{t}]: None")
else:
    print("Failed to fetch objects.json, status code:", r.status_code)
