import io
from PIL import Image, ImageOps
from pyscript import document, window, when

ASCII_CHARS = ["@", "#", "S", "%", "?", "*", "+", ";", ":", ",", "."]
current_ascii_output = ""
current_filename = "ascii_art.txt"

def resize_image(image, new_width=100):
    width, height = image.size
    # 1.65 factor compensates for monospace fonts being taller than they are wide
    ratio = height / width / 1.65 
    new_height = int(new_width * ratio)
    return image.resize((new_width, new_height))

def grayify(image):
    return image.convert("L")

def pixels_to_ascii(image):
    #pixels = image.getdata() # Fixed from get_flattened_data()
    pixels = image.get_flattened_data()
    # Map 0-255 pixel values to 11 ASCII characters smoothly
    characters = "".join([ASCII_CHARS[pixel // 24] if pixel // 24 < len(ASCII_CHARS) else ASCII_CHARS[-1] for pixel in pixels])
    return characters

async def process_image(file_bytes, width, original_name):
    global current_ascii_output, current_filename
    
    # Load image from memory bytes
    image = Image.open(io.BytesIO(file_bytes))
    image = ImageOps.exif_transpose(image)
    
    # Process
    image = resize_image(image, width)
    image = grayify(image)
    ascii_str = pixels_to_ascii(image)
    
    # Construct rows
    pixel_count = len(ascii_str)
    ascii_img = "\n".join([ascii_str[i : (i + width)] for i in range(0, pixel_count, width)])
    
    # Save to global variable for downloads
    current_ascii_output = ascii_img
    base_name = original_name.rsplit('.', 1)[0] if '.' in original_name else "image"
    current_filename = f"{base_name}_ascii_{width}.txt"
    
    # Render to the screen
    preview_element = document.getElementById("ascii-preview")
    preview_element.innerHTML = ascii_img
    preview_element.style.display = "block"
    
    # Reveal download button
    document.getElementById("download-btn").style.display = "inline-block"
    document.getElementById("status-message").innerText = "Conversion successful!"

@when("click", "#convert-btn")
async def on_convert_click(event):
    status = document.getElementById("status-message")
    file_input = document.getElementById("file-upload")
    width_input = document.getElementById("width-input")
    
    if not file_input.files or len(file_input.files) == 0:
        status.innerText = "Please select an image file first."
        return
        
    status.innerText = "Processing..."
    
    # Snag the file metadata from JS
    js_file = file_input.files.item(0)
    file_name = js_file.name
    width = int(width_input.value)
    
    # Read the file data asynchronously as an ArrayBuffer
    array_buffer = await js_file.arrayBuffer()
    file_bytes = array_buffer.to_py().tobytes()
    
    # Process image
    await process_image(file_bytes, width, file_name)

@when("click", "#download-btn")
def on_download_click(event):
    global current_ascii_output, current_filename
    if not current_ascii_output:
        return
        
    # Trigger a browser download using JavaScript Blob and URL APIs
    blob = window.Blob.new([current_ascii_output], { 'type': 'text/plain' })
    url = window.URL.createObjectURL(blob)
    
    link = document.createElement('a')
    link.href = url
    link.download = current_filename
    link.click()
    
    window.URL.revokeObjectURL(url)
