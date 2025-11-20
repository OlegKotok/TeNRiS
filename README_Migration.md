# TeNRiS II - Delphi to Free Pascal Migration

This document describes the migration of TeNRiS II from Delphi to Free Pascal Compiler (FPC).

## Changes Made

### 1. Source Code Migration
- **TeNRiS.dpr** → **TeNRiS.lpr** (Lazarus Project file)
- Added Free Pascal compiler directives: `{$mode objfpc}{$H+}`
- Added cross-platform conditional compilation for Windows/Linux
- Replaced Delphi-specific syntax with FPC-compatible code
- Added proper encoding handling for Cyrillic comments

### 2. Key Modifications
- **Object syntax**: Maintained Delphi-style objects (compatible with FPC)
- **Conditional compilation**: Added `{$IFDEF WINDOWS}` blocks for platform-specific code
- **MessageBox calls**: Wrapped in Windows-only sections
- **File handling**: Made cross-platform compatible
- **Resource files**: Maintained `.res` file support

### 3. Build System
Created multiple build options:

#### Option 1: Direct FPC Compilation
```batch
build_windows.bat
```
- Uses Free Pascal Compiler directly
- Creates `bin/` directory with executable and resources
- Supports both windowed and fullscreen modes

#### Option 2: Lazarus IDE
```batch
build_lazarus.bat
```
- Uses Lazarus IDE build system
- Requires Lazarus installation
- Uses `TeNRiS.lpi` project file

#### Option 3: Makefile (Cross-platform)
```bash
make install
```
- Works on Windows and Linux
- Automatic platform detection
- Supports debug and release builds

## Requirements

### Windows
- **Free Pascal Compiler 3.2.0+** or **Lazarus IDE 2.0+**
- **DGLEngine.dll** (included in project)
- Windows 7+ (32/64-bit)

### Linux (Experimental)
- **Free Pascal Compiler 3.2.0+**
- **Wine** (for DGLEngine.dll compatibility)
- X11 development libraries

## Building Instructions

### Windows - Quick Start
1. Install Free Pascal from https://www.freepascal.org/
2. Run `build_windows.bat`
3. Executable will be in `bin/TeNRiS.exe`

### Windows - Lazarus IDE
1. Install Lazarus from https://www.lazarus-ide.org/
2. Open `TeNRiS.lpi` in Lazarus
3. Press F9 to compile and run

### Cross-platform - Makefile
```bash
# Build and install
make install

# Run the game
make run

# Clean build files
make clean

# Debug build
make debug
```

## File Structure
```
TeNRiS II/
├── TeNRiS.lpr              # Main Free Pascal source
├── TeNRiS.lpi              # Lazarus project file
├── DGLEngine_header.pas    # Engine interface (unchanged)
├── DGLEngine.dll           # Game engine library
├── build_windows.bat       # Windows build script
├── build_lazarus.bat       # Lazarus build script
├── Makefile               # Cross-platform build
├── bin/                   # Output directory
├── lib/                   # Compiled units
├── sounds/                # Game audio files
├── texture/               # Game graphics
└── girls/                 # Additional graphics

Legacy Delphi files (kept for reference):
├── TeNRiS.dpr             # Original Delphi source
├── TeNRiS.cfg             # Delphi configuration
└── TeNRiS.dof             # Delphi options
```

## Compatibility Notes

### What Works
- ✅ All game mechanics (Tetris gameplay)
- ✅ Graphics rendering via DGLEngine
- ✅ Sound effects and music
- ✅ Keyboard input
- ✅ Score system and records
- ✅ Fullscreen/windowed modes

### Platform Limitations
- **DGLEngine.dll**: Windows-only (requires Wine on Linux)
- **DirectSound**: Windows-specific audio system
- **MessageBox**: Windows API (console fallback on Linux)

### Known Issues
- Linux support requires Wine for DGL Engine
- Some Cyrillic text may need encoding adjustments
- Resource file compilation may need manual steps on some systems

## Migration Benefits

1. **Free Compiler**: No need for expensive Delphi license
2. **Cross-platform**: Potential Linux/macOS support
3. **Modern FPC**: Better optimization and language features
4. **Open Source**: Full control over build process
5. **Lazarus IDE**: Free alternative to Delphi IDE

## Future Improvements

1. **Replace DGLEngine**: Port to SDL2 or OpenGL for true cross-platform support
2. **Audio System**: Replace DirectSound with OpenAL or SDL_mixer
3. **Resource Management**: Convert to cross-platform resource system
4. **Modern Pascal**: Utilize advanced FPC features (generics, etc.)

## Running the Game

### Command Line Options
```bash
# Windowed mode (default)
TeNRiS.exe

# Fullscreen mode
TeNRiS.exe fullscrean
```

### Controls
- **Arrow Keys**: Move pieces
- **Up Arrow**: Rotate piece
- **Space**: Drop piece quickly
- **Down Arrow**: Accelerated drop
- **R**: Restart game
- **S**: Toggle music
- **F1**: Show help
- **Escape**: Quit game

## Support

For issues with the migration:
1. Check Free Pascal installation
2. Verify DGLEngine.dll is present
3. Ensure all resource files are copied
4. Check Windows compatibility mode if needed

Original game by NiCketT-software
Migration documentation by Q Assistant
