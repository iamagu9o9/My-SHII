import cv2
import numpy as np
from PIL import Image
import os

def remove_background(img):
    # Simple color-based background removal for a model sheet
    # Assuming the background is a consistent light color (off-white/cream)
    # Convert to HSV for better color segmentation
    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

    # Define range for 'background' color (adjusting for cream/white)
    lower_bg = np.array([0, 0, 200])
    upper_bg = np.array([180, 50, 255])

    mask = cv2.inRange(hsv, lower_bg, upper_bg)
    mask_inv = cv2.bitwise_not(mask)

    # Refine mask: remove small noise and fill holes
    kernel = np.ones((3,3), np.uint8)
    mask_inv = cv2.morphologyEx(mask_inv, cv2.MORPH_CLOSE, kernel)
    mask_inv = cv2.morphologyEx(mask_inv, cv2.MORPH_OPEN, kernel)

    # Convert to BGRA
    b, g, r = cv2.split(img)
    alpha = mask_inv
    bgra = cv2.merge([b, g, r, alpha])
    return bgra

def crop_assets(image_path, output_dir):
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    img = cv2.imread(image_path)
    if img is None:
        print(f"Error: Could not read image {image_path}")
        return

    # Since we don't have the actual coordinates of the model sheet,
    # we use a grid-based heuristic or object detection for this demo.
    # In a real scenario, we'd use specific coordinates or an AI segmenter.
    # Here we'll simulate the cropping by dividing the image into regions.

    h, w, _ = img.shape

    # Defining regions based on the prompt's model sheet description:
    # Views: Front, 3/4, Side, Back
    # Expressions: Happy, Confused, Shocked, Laughing, Worried, Smug
    # Action Poses: (assume 4 poses)

    regions = {
        "view_front": (0, 0, w//4, h//2),
        "view_3_4": (w//4, 0, w//2, h//2),
        "view_side": (w//2, 0, 3*w//4, h//2),
        "view_back": (3*w//4, 0, w, h//2),

        "exp_happy": (0, h//2, w//6, h),
        "exp_confused": (w//6, h//2, 2*w//6, h),
        "exp_shocked": (2*w//6, h//2, 3*w//6, h),
        "exp_laughing": (3*w//6, h//2, 4*w//6, h),
        "exp_worried": (4*w//6, h//2, 5*w//6, h),
        "exp_smug": (5*w//6, h//2, w, h),
    }

    for name, (x1, y1, x2, y2) in regions.items():
        crop = img[y1:y2, x1:x2]
        transparent = remove_background(crop)

        # Save as PNG
        file_path = os.path.join(output_dir, f"{name}.png")
        cv2.imwrite(file_path, transparent)
        print(f"Saved {name} to {file_path}")

if __name__ == "__main__":
    crop_assets("./sheet/model_sheet.jpg", "./sheet/crops/")
