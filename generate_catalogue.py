#!/usr/bin/env python3
"""
Generate a JSON catalogue of all 3D models (.scad and .stl files) in the repository.
This script scans the directory structure and creates a models.json file for the web viewer.
"""

import os
import json
from pathlib import Path
from datetime import datetime

# Directories to skip
SKIP_DIRS = {
    'venv', 'node_modules', '.git', '__pycache__', 'layers', 
    'snapshot', 'result', 'bkstl', 'assets'
}

# File extensions to include
MODEL_EXTENSIONS = {'.stl', '.scad'}


def get_file_info(file_path: Path, base_path: Path) -> dict:
    """Get metadata for a model file."""
    stat = file_path.stat()
    relative_path = file_path.relative_to(base_path)
    
    return {
        'name': file_path.stem,
        'filename': file_path.name,
        'path': str(relative_path),
        'extension': file_path.suffix.lower(),
        'size': stat.st_size,
        'modified': datetime.fromtimestamp(stat.st_mtime).isoformat(),
    }


def get_collection(relative_path: Path) -> str:
    """Get the top-level collection for a file path.
    
    Files in root go to 'root'.
    Files in any subfolder go to the top-level parent folder.
    e.g., BarTool/modules/file.scad -> 'BarTool'
          BarTool/stls/file.stl -> 'BarTool'
          bbs/file.scad -> 'bbs'
    """
    if relative_path.parent == Path('.'):
        return 'root'
    
    # Get the first part of the path (top-level folder)
    parts = relative_path.parts
    if len(parts) > 1:
        return parts[0]  # Top-level folder name
    return 'root'


def scan_directory(base_path: Path) -> dict:
    """Scan directory and build catalogue structure."""
    catalogue = {
        'generated': datetime.now().isoformat(),
        'folders': {},
        'models': []
    }
    
    # Collect all model files - each file gets its own entry
    for root, dirs, files in os.walk(base_path):
        # Skip unwanted directories
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
        
        root_path = Path(root)
        for filename in sorted(files):
            file_path = root_path / filename
            ext = file_path.suffix.lower()
            
            if ext not in MODEL_EXTENSIONS:
                continue
            
            relative_path = file_path.relative_to(base_path)
            
            # Get top-level collection (parent folder, not nested subfolders)
            collection = get_collection(relative_path)
            
            # Get file info
            file_info = get_file_info(file_path, base_path)
            
            # Create unique ID including extension to differentiate .stl from .scad
            file_id = f"{collection}_{file_path.stem}_{ext[1:]}".replace('/', '_').replace(' ', '_')
            
            # Create model entry - each file is separate
            model = {
                'id': file_id,
                'name': format_name(file_path.stem),
                'folder': collection,
                'path': str(relative_path),
                'type': ext[1:],  # 'stl' or 'scad'
                'size': file_info['size'],
                'modified': file_info['modified'],
            }
            
            catalogue['models'].append(model)
            
            # Track folders (only top-level collections)
            if collection not in catalogue['folders']:
                catalogue['folders'][collection] = {
                    'name': format_name(collection) if collection != 'root' else 'Main Collection',
                    'path': collection,
                    'count': 0
                }
            catalogue['folders'][collection]['count'] += 1
    
    return catalogue


def format_name(name: str) -> str:
    """Format a filename into a readable title."""
    # Remove common prefixes/suffixes
    name = name.replace('_', ' ').replace('-', ' ')
    # Capitalize words
    words = name.split()
    formatted = ' '.join(word.capitalize() for word in words)
    return formatted


def main():
    """Main entry point."""
    base_path = Path(__file__).parent
    
    print("🔍 Scanning for 3D models...")
    catalogue = scan_directory(base_path)
    
    # Write catalogue
    output_path = base_path / 'models.json'
    with open(output_path, 'w') as f:
        json.dump(catalogue, f, indent=2)
    
    print(f"✅ Generated catalogue with {len(catalogue['models'])} models")
    print(f"📁 Found {len(catalogue['folders'])} folders")
    print(f"💾 Saved to {output_path}")
    
    # Print summary
    print("\n📊 Summary by folder:")
    for folder, info in sorted(catalogue['folders'].items()):
        print(f"   {info['name']}: {info['count']} models")


if __name__ == '__main__':
    main()

