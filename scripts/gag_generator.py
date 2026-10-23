import os
import json
import random
import yaml

def generate_gags(config):
    # Mocked generation for testing when API key is missing or fails
    print("Using mock gag generator for testing...")

    themes = ["cooking disasters", "chasing a mouse", "sports fails", "sleepwalking", "haunted house"]
    theme = random.choice(themes)

    # Sample gag data mirroring the desired JSON format
    gags = [
        {
            "title": f"Atunny's {theme} Fail 1",
            "youtube_title": f"Atunny vs {theme}! 😂 #Shorts #Cartoon",
            "youtube_description": f"Watch Atunny struggle with {theme}! #Atunny #80sCartoon #Funny",
            "shots": [
                {
                    "description": "Atunny looking confident in a kitchen",
                    "asset": "view_front",
                    "camera": "static",
                    "duration": 3,
                    "dialogue": "I've got this!",
                    "sfx": "boing"
                },
                {
                    "description": "Atunny panics as something catches fire",
                    "asset": "exp_shocked",
                    "camera": "zoom_in",
                    "duration": 3,
                    "dialogue": "YIKES!",
                    "sfx": "crash"
                },
                {
                    "description": "Atunny covered in soot, looking smug",
                    "asset": "exp_smug",
                    "camera": "static",
                    "duration": 3,
                    "dialogue": "Perfectly cooked.",
                    "sfx": "slide_whistle"
                }
            ]
        },
        {
            "title": f"Atunny's {theme} Fail 2",
            "youtube_title": f"Epic {theme} Fail! 🙀 #Shorts",
            "youtube_description": f"Classic Atunny clumsiness! #Atunny #Slapstick",
            "shots": [
                {
                    "description": "Atunny sneaking around",
                    "asset": "view_side",
                    "camera": "pan_left",
                    "duration": 3,
                    "dialogue": "Sssh...",
                    "sfx": "none"
                },
                {
                    "description": "Atunny trips over his own shoes",
                    "asset": "exp_worried",
                    "camera": "static",
                    "duration": 3,
                    "dialogue": "Whoa-oh-oh!",
                    "sfx": "splat"
                },
                {
                    "description": "Atunny laughing it off",
                    "asset": "exp_laughing",
                    "camera": "zoom_out",
                    "duration": 3,
                    "dialogue": "Haha, planned that!",
                    "sfx": "boing"
                }
            ]
        }
    ]

    return gags

if __name__ == "__main__":
    with open("config.yaml", "r") as f:
        config = yaml.safe_load(f)
    gags = generate_gags(config)
    print(json.dumps(gags, indent=2))
