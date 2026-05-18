import os
import sys
import subprocess
import platform

def create_installer():
    # Detect separator for --add-data
    sep = ';' if platform.system() == 'Windows' else ':'
    
    # Define assets to include (source, destination)
    # We include directories and single files
    assets = [
        ('sounds', 'sounds'),
        ('texture', 'texture'),
        ('figures.dat', '.')
    ]
    
    # Build the PyInstaller command
    cmd = [
        sys.executable, '-m', 'PyInstaller',
        '--name=TeNRiS',
        '--onefile',      # Single executable
        '--windowed',     # No console window (GUI mode)
        '--noconfirm',    # Overwrite output directory without asking
        '--clean',        # Clean PyInstaller cache before building
    ]
    
    # Add icon if it exists
    if os.path.exists('Tenris.ico'):
        cmd.append(f'--icon=Tenris.ico')
    
    # Add assets
    for src, dst in assets:
        if os.path.exists(src):
            cmd.extend(['--add-data', f'{src}{sep}{dst}'])
    
    # Main script
    cmd.append('tenris.py')
    
    print(f"Running command: {' '.join(cmd)}")
    
    try:
        subprocess.check_call(cmd)
        print("\nSuccess! Your installer (executable) is in the 'dist' folder.")
    except subprocess.CalledProcessError as e:
        print(f"\nError: PyInstaller failed with exit code {e.returncode}")
        sys.exit(1)

if __name__ == "__main__":
    # Check if pyinstaller is installed
    try:
        import PyInstaller
    except ImportError:
        print("Error: PyInstaller not found. Please run 'pip install pyinstaller' first.")
        sys.exit(1)
        
    create_installer()
