import random
import os
import re
import subprocess
import time


time.sleep(300)


# Path to your SCSS file
scss_file_path = "/home/matsuko/.config/eww/dashboard/dashboard.scss"

# Directory containing the images
image_dir = "/home/matsuko/waifu/"
images = ["elysia1.jpg", "elysia22.png", "elysia3.png", "elysia4.jpg", "elysia5.png", "elysia8.jpg", "elysia9.jpg", "elysia10.png", "elysia12.jpg", "elysia13.png"]  # Ensure all .jpg

# Define a mapping between the images and their respective background-size values
background_sizes = {
    "elysia1.jpg": 305,
    "elysia22.png": 260,
    "elysia3.png": 460,
    "elysia4.jpg": 350, 
    "elysia5.png": 340,
    "elysia8.jpg": 330,   
    "elysia9.jpg": 328,
    "elysia12.jpg": 328,
    "elysia10.png": 305,
    "elysia13.png": 300,
}

# Randomly select an image
selected_image = random.choice(images)

# Full path to the selected image
selected_image_path = os.path.join(image_dir, selected_image)

# Get the corresponding background-size for the selected image
background_size_value = background_sizes.get(selected_image, 305)  # Default size is 305px

# Debug: Print the selected image and its size
print(f"Selected image: {selected_image_path}")
print(f"Background size for {selected_image}: {background_size_value}px")

# Read the SCSS file and replace the background-image URL and background-size
with open(scss_file_path, 'r') as file:
    content = file.read()

# Update the background-image URL in SCSS
new_content = re.sub(
    r'background-image:\s*url\(\'/home/matsuko/waifu/.*?\.\w+\'\);',
    f'background-image: url(\'{selected_image_path}\');',
    content
)

# Update the background-size in SCSS
new_content = re.sub(
    r'background-size:\s*\d+px;',  # Match the current background-size value
    f'background-size: {background_size_value}px;',  # Replace with the new size
    new_content
)

# Write the updated content back to the SCSS file
with open(scss_file_path, 'w') as file:
    file.write(new_content)

# Reload EWW to apply the changes
subprocess.run(["eww", "reload"])

print(f"Updated background image to: {selected_image_path} with size: {background_size_value}px")
