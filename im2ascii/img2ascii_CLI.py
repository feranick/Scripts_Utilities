import argparse
import os
import sys
from PIL import Image, ImageOps

# ASCII characters used to build the output image
# From darkest to lightest
ASCII_CHARS = ["@", "#", "S", "%", "?", "*", "+", ";", ":", ",", "."]

def resize_image(image, new_width=100):
    """Resizes the image while maintaining the aspect ratio."""
    width, height = image.size
    # 1.65 adjusts for the fact that characters are taller than they are wide
    ratio = height / width / 1.65 
    new_height = int(new_width * ratio)
    resized_image = image.resize((new_width, new_height))
    return resized_image

def grayify(image):
    """Converts the image to grayscale."""
    return image.convert("L")

def pixels_to_ascii(image):
    """Maps each pixel to an ASCII character based on its intensity."""
    #pixels = image.getdata()
    pixels = image.get_flattened_data()
    characters = "".join([ASCII_CHARS[pixel // 25] for pixel in pixels])
    return characters

def convert_to_ascii(image_path, output_file, width):
    try:
        image = Image.open(image_path)
        image = ImageOps.exif_transpose(image)
    except Exception as e:
        print(f"Error: Unable to open image file {image_path}. {e}")
        sys.exit(1)

    image = resize_image(image, width)
    image = grayify(image)
    ascii_str = pixels_to_ascii(image)
    
    pixel_count = len(ascii_str)
    ascii_img = "\n".join([ascii_str[index : (index + width)] for index in range(0, pixel_count, width)])
    
    with open(output_file, "w") as f:
        f.write(ascii_img)
    
    print(f"Successfully converted {image_path} to {output_file} (Width: {width})")

def main():
    parser = argparse.ArgumentParser(description="Convert an image to an ASCII text file.")
    parser.add_argument("input", help="Path to the input image file (e.g., image.jpg)")
    parser.add_argument("-o", "--output", help="Optional: Custom output text file name")
    parser.add_argument("-w", "--width", type=int, default=100, help="Width of the ASCII art (default: 100)")

    args = parser.parse_args()

    # --- Filename Generation Logic ---
    if args.output:
        # Use the custom output name if provided
        final_output_name = args.output
    else:
        # Extract the filename without the extension (e.g., 'input.jpg' -> 'input')
        base_name = os.path.splitext(os.path.basename(args.input))[0]
        
        # Base format: input_ascii
        filename = f"{base_name}_ascii"
        
        # Append width if it is not the default (100)
        if args.width != 100:
            filename += str(args.width)
            
        # Add the .txt extension
        final_output_name = f"{filename}.txt"
    # ---------------------------------

    convert_to_ascii(args.input, final_output_name, args.width)

if __name__ == "__main__":
    main()
