import os
import subprocess
import yaml
import json
from moviepy.editor import ImageClip, concatenate_videoclips, AudioFileClip, CompositeAudioClip, TextClip, ColorClip, CompositeVideoClip
from moviepy.video.fx.all import lum_contrast

def apply_retro_filter(clip):
    # Simulating 80s look: contrast, grain, and slight vignette
    clip = lum_contrast(clip, lum=0, contrast=0.1)
    # For real grain we'd overlay a grain loop, here we simulate with simple effects
    return clip

def create_short(config, gag):
    shots_clips = []

    for i, shot in enumerate(gag['shots']):
        # Generate frames for this shot (simplified: 1 frame per shot for the preview/demo)
        # In a full version, we'd generate a sequence for pans/zooms
        from scripts.shot_generator import generate_background, compose_shot

        bg = generate_background(config, shot['description'])
        frame = compose_shot(config, shot, bg)

        # Save temp frame
        frame_path = f"shots/temp_shot_{i}.jpg"
        import cv2
        cv2.imwrite(frame_path, frame)

        # Create Clip
        clip = ImageClip(frame_path).set_duration(shot['duration'])

        # Add Caption (Retro comic style)
        if shot['dialogue']:
            txt_clip = TextClip(
                shot['dialogue'],
                fontsize=70,
                color='white',
                font='Arial-Bold', # Fallback, user should install Comic font
                stroke_color='black',
                stroke_width=2,
                method='caption',
                size=(config['resolution'][0] * 0.8, None)
            ).set_duration(shot['duration']).set_position(('center', 1400))

            clip = CompositeVideoClip([clip, txt_clip])

        shots_clips.append(clip)

    # Concatenate shots
    video = concatenate_videoclips(shots_clips, method="compose")

    # Audio Processing (Simulated)
    # In a real run, we'd use Piper for dialogue and load from ./audio/sfx/
    # For the demo, we use a silent audio clip
    # To avoid the "0-dimensional arrays" error in moviepy 1.0.3, we just set the audio to None
    # or use a simple AudioFileClip if we had one. For preview, no audio is fine.

    video = apply_retro_filter(video)

    output_path = f"out/{gag['title'].replace(' ', '_')}.mp4"
    video.write_videofile(output_path, fps=config['fps'], codec="libx264")
    return output_path

if __name__ == "__main__":
    with open("config.yaml", "r") as f:
        config = yaml.safe_load(f)

    # Dummy gag for testing
    test_gag = {
        "title": "Cooking Fail",
        "shots": [
            {"asset": "view_front", "duration": 2, "dialogue": "Time to cook!", "description": "Kitchen"},
            {"asset": "exp_shocked", "duration": 2, "dialogue": "OH NO!", "description": "Explosion"}
        ]
    }

    create_short(config, test_gag)
