import os
from PIL import Image

cat_ui_path = r"D:\BestSen\assets\UI\CatUIPaid\CatUIPaid\catUI.png"
if os.path.exists(cat_ui_path):
    img = Image.open(cat_ui_path)
    print("catUI.png size:", img.size)

img1_path = r"C:\Users\thaip\.gemini\antigravity\brain\c8fc8184-69d9-49e6-8f7d-9cd22d11477d\.user_uploaded\media_1793266744105_9016a57a.png"
img2_path = r"C:\Users\thaip\.gemini\antigravity\brain\c8fc8184-69d9-49e6-8f7d-9cd22d11477d\.user_uploaded\media_1793266784923_e6aa8c41.png"

if os.path.exists(img1_path):
    im1 = Image.open(img1_path)
    print("img1 size:", im1.size)
if os.path.exists(img2_path):
    im2 = Image.open(img2_path)
    print("img2 size:", im2.size)
