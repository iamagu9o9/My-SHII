import os
import cv2
import numpy as np
import yaml
from PIL import Image, ImageDraw, ImageFont

def generate_background(config, shot_description):
    backend = config.get('bg_backend', 'procedural')

    if backend == 'procedural':
        # Create a simple 80s-style gradient background
        width, height = config['resolution']
        # Warm cream/paper base
        img = np.full((height, width, 3), (200, 230, 255), dtype=np.uint8) # BGR

        # Simple gradient
        for y in range(height):
            factor = y / height
            img[y, :] = (
                int(200 * (1 - factor) + 150 * factor),
                int(230 * (1 - factor) + 200 * factor),
                int(255 * (1 - factor) + 220 * factor)
            )
        return img

    # Other backends (ComfyUI/Cloud) would be implemented here
    return np.zeros((config['resolution'][1], config['resolution'][0], 3), dtype=np.uint8)

def compose_shot(config, shot, background_img):
    width, height = config['resolution']

    # Load character asset
    asset_path = f"./sheet/crops/{shot['asset']}.png"
    if not os.path.exists(asset_path):
        asset_path = "./sheet/crops/view_front.png"

    asset = cv2.imread(asset_path, cv2.IMREAD_UNCHANGED)
    if asset is None:
        return background_img

    # 2. Scale sprite relative to frame
    # Character height = ~45% of frame height
    target_h = int(height * 0.45)
    h, w = asset.shape[:2]
    aspect_ratio = w / h
    target_w = int(target_h * aspect_ratio)
    asset = cv2.resize(asset, (target_w, target_h))

    # Position (Allow offset to be passed in shot, otherwise center)
    x_offset = shot.get('x_offset', (width - target_w) // 2)
    y_offset = shot.get('y_offset', (height - target_h) // 2)

    # 1. Clip sprite and alpha mask to frame bounds
    x0 = max(0, x_offset)
    y0 = max(0, y_offset)
    x1 = min(width, x_offset + target_w)
    y1 = min(height, y_offset + target_h)

    if x0 >= x1 or y0 >= y1:
        return background_img # No overlap

    # Slices for the frame
    frame_x0, frame_y0 = x0, y0
    frame_x1, frame_y1 = x1, y1

    # Slices for the sprite (relative to sprite's top-left)
    sprite_x0 = x0 - x_offset
    sprite_y0 = y0 - y_offset
    sprite_x1 = x1 - x_offset
    sprite_y1 = y1 - y_offset

    # Extract the overlapping region from asset
    crop = asset[sprite_y0:sprite_y1, sprite_x0:sprite_x1]

    # Split alpha and BGR
    if crop.shape[2] == 4:
        alpha_asset = crop[:, :, 3] / 255.0
        asset_bgr = crop[:, :, :3]
    else:
        alpha_asset = np.ones((crop.shape[0], crop.shape[1]))
        asset_bgr = crop

    # Composite
    roi = background_img[frame_y0:frame_y1, frame_x0:frame_x1]

    # Expand alpha to 3 channels for broadcasting
    alpha_3 = np.stack([alpha_asset] * 3, axis=-1)

    # Blend: (Asset * Alpha) + (Background * (1 - Alpha))
    blended_roi = (asset_bgr * alpha_3 + roi * (1 - alpha_3)).astype(np.uint8)

    result = background_img.copy()
    result[frame_y0:frame_y1, frame_x0:frame_x1] = blended_roi

    return result

if __name__ == "__main__":
    # Test a single shot
    with open("config.yaml", "r") as f:
        config = yaml.safe_load(f)

    bg = generate_background(config, "a kitchen")
    shot = {"asset": "exp_happy", "description": "Atunny is happy"}
    frame = compose_shot(config, shot, bg)
    cv2.imwrite("shots/test_frame.jpg", frame)
    print("Test frame saved to shots/test_frame.jpg")
