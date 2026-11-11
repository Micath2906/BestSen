import os

terms = ["175cc", "Dừng xe ngay", "DẠY BOSS", "Thoát", "Chụp ảnh"]
found = set()

for root, dirs, files in os.walk("."):
    if ".git" in dirs:
        dirs.remove(".git")
    for f in files:
        if f.endswith((".gd", ".tscn", ".json")):
            p = os.path.join(root, f)
            try:
                with open(p, "r", encoding="utf-8") as fp:
                    content = fp.read()
                    for t in terms:
                        if t in content:
                            found.add((t, p))
            except Exception:
                pass

for t, p in sorted(found):
    print(f"[{t}] -> {p}")
