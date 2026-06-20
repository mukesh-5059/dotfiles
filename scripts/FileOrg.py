import os
import shutil
import sys
from pathlib import Path

def get_folder_name(extension):
    """
    Returns custom folder name based on file extension
    """
    # Image files
    if extension in ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'svg', 'webp', 'ico']:
        return "Images"
    
    # Video files
    elif extension in ['mp4', 'avi', 'mkv', 'mov', 'wmv', 'flv', 'webm', 'm4v']:
        return "Videos"
    
    # Audio files
    elif extension in ['mp3', 'wav', 'flac', 'aac', 'ogg', 'm4a', 'wma']:
        return "Music"
    
    # Document files
    elif extension in ['pdf', 'doc', 'docx', 'txt', 'rtf', 'odt']:
        return "Documents"
    
    # Spreadsheet files
    elif extension in ['xls', 'xlsx', 'csv', 'ods']:
        return "Spreadsheets"
    
    # Presentation files
    elif extension in ['ppt', 'pptx', 'odp']:
        return "Presentations"
    
    # Archive files
    elif extension in ['zip', 'rar', '7z', 'tar', 'gz', 'bz2']:
        return "Archives"
    
    # Code files
    elif extension in ['py', 'js', 'html', 'css', 'java', 'cpp', 'c', 'php', 'rb', 'go', 'json', 'xml']:
        return "Code"
    
    # Executable files
    elif extension in ['exe', 'msi', 'app', 'deb', 'rpm']:
        return "Executables"
    
    # Default for unknown extensions
    else:
        return f"{extension.upper()}_Files" if extension else "No_Extension"

def sort_files_by_extension(directory):
    """
    Sort files in the given directory into subfolders based on their extensions.
    Leaves subfolders untouched.
    """
    # Convert to absolute path
    directory = os.path.abspath(directory)
    
    # Check if directory exists
    if not os.path.exists(directory):
        print(f"Error: Directory '{directory}' does not exist.")
        return
    
    if not os.path.isdir(directory):
        print(f"Error: '{directory}' is not a directory.")
        return
    
    # Statistics
    files_moved = 0
    folders_created = set()
    
    print(f"\n📁 Sorting files in: {directory}")
    print("=" * 50)
    
    # Walk through all items in the directory
    for item in os.listdir(directory):
        item_path = os.path.join(directory, item)
        
        # Skip if it's a directory (leave folders as they are)
        if os.path.isdir(item_path):
            print(f"Skipping folder: {item}")
            continue
        
        # Process only files
        if os.path.isfile(item_path):
            # Get file extension
            file_name, file_extension = os.path.splitext(item)
            
            # Handle files without extension
            if file_extension:
                # Remove the dot from extension
                extension = file_extension[1:].lower()
                # Handle empty extension (like .gitignore)
                if not extension:
                    extension = "no_extension"
            else:
                extension = "no_extension"
            
            # Get custom folder name
            folder_name = get_folder_name(extension)
            subfolder_path = os.path.join(directory, folder_name)
            
            # Create the subfolder if it doesn't exist
            if not os.path.exists(subfolder_path):
                os.makedirs(subfolder_path)
                print(f"Created folder: {folder_name}")
                folders_created.add(folder_name)
            
            # Move the file to the subfolder
            destination = os.path.join(subfolder_path, item)
            
            # Handle duplicate filenames
            if os.path.exists(destination):
                base, ext = os.path.splitext(item)
                counter = 1
                while os.path.exists(os.path.join(subfolder_path, f"{base}_{counter}{ext}")):
                    counter += 1
                destination = os.path.join(subfolder_path, f"{base}_{counter}{ext}")
            
            shutil.move(item_path, destination)
            files_moved += 1
            print(f"Moved: {item} -> {folder_name}/")
    # Summary
    print("=" * 50)
    print(f"📊 Summary:")
    print(f"   • Files moved: {files_moved}")
    print(f"   • Folders created: {len(folders_created)}")
    if folders_created:
        print(f"   • Created folders: {', '.join(sorted(folders_created))}")
    print("=" * 50)

def main():
    # Check if folder path is provided as command line argument
    if len(sys.argv) != 2:
        print("Usage: python sort_files.py <folder_path>")
        print("Example: python sort_files.py /path/to/your/folder")
        sys.exit(1)
    
    folder_path = sys.argv[1]

    folder_path = folder_path.strip('"').strip("'")
    
    # Confirm with user before proceeding
    print(f"Are you sure you want to sort files in: {folder_path}")
    print("This will create subfolders for each file extension.")
    response = input("Continue? (yes/no): ").lower()
    
    if response in ['yes', 'y']:
        sort_files_by_extension(folder_path)
        print("\nDone! Files have been sorted by extension.")
    else:
        print("Operation cancelled.")

if __name__ == "__main__":
    main()