import json
import os
import math

# Representative RGB values for Papirus folder color options
PAPIRUS_COLORS = {
    "black": (40, 40, 40),
    "blue": (74, 144, 226),
    "brown": (160, 100, 75),
    "cyan": (0, 188, 212),
    "green": (76, 175, 80),
    "grey": (138, 138, 138),
    "orange": (255, 152, 0),
    "pink": (233, 30, 99),
    "red": (244, 67, 54),
    "teal": (0, 150, 136),
    "violet": (156, 39, 176),
    "yellow": (255, 235, 59),
    "indigo": (63, 81, 181),
    "paleorange": (255, 204, 128),
    "white": (224, 224, 224),
    "magenta": (216, 27, 96),
}

def hex_to_rgb(hex_str):
    hex_str = hex_str.lstrip('#')
    return tuple(int(hex_str[i:i+2], 16) for i in (0, 2, 4))

def get_vibrant_accent(colors_dict):
    color4_hex = colors_dict.get('color4')
    if not color4_hex:
        return None
        
    r, g, b = hex_to_rgb(color4_hex)
    sat = max(r, g, b) - min(r, g, b)
    
    # If the default accent color is reasonably vibrant, use it
    if sat >= 35:
        return color4_hex
        
    # Otherwise, scan the palette for the color with the highest saturation
    # We exclude color0, color7, color8, and color15 (which are background/foreground tints)
    candidates = [
        'color1', 'color2', 'color3', 'color4', 'color5', 'color6',
        'color9', 'color10', 'color11', 'color12', 'color13', 'color14'
    ]
    
    best_hex = color4_hex
    max_sat = sat
    
    for key in candidates:
        val = colors_dict.get(key)
        if val:
            cr, cg, cb = hex_to_rgb(val)
            csat = max(cr, cg, cb) - min(cr, cg, cb)
            if csat > max_sat:
                max_sat = csat
                best_hex = val
                
    return best_hex

def main():
    json_path = os.path.expanduser('~/.cache/wallust/colors.json')
    if not os.path.exists(json_path):
        print("blue")
        return

    try:
        with open(json_path, 'r') as f:
            data = json.load(f)
        
        # Determine the best accent color to use
        colors_dict = data.get('colors', {})
        accent_hex = get_vibrant_accent(colors_dict)
        if not accent_hex:
            print("blue")
            return
            
        accent_rgb = hex_to_rgb(accent_hex)
    except Exception:
        print("blue")
        return

    # Find the color with the minimum Euclidean distance in RGB space
    min_dist = float('inf')
    best_color = "blue"
    
    for color_name, rgb in PAPIRUS_COLORS.items():
        dist = math.sqrt(sum((a - b) ** 2 for a, b in zip(accent_rgb, rgb)))
        if dist < min_dist:
            min_dist = dist
            best_color = color_name

    print(best_color)

if __name__ == '__main__':
    main()
