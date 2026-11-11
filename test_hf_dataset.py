from datasets import load_dataset
import sys

print("Loading streaming dataset...")
try:
    ds = load_dataset("Angais/pixel-art-atlas-1.4m", split="train", streaming=True)
    sample = next(iter(ds))
    print("SUCCESS! Keys:", list(sample.keys()))
    print("Caption:", sample.get("caption"))
    print("Subject:", sample.get("subject"))
    print("Image size:", sample.get("image").size if "image" in sample else None)
except Exception as e:
    print("ERROR:", e, file=sys.stderr)
