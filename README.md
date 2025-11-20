# TeNRiS II

**Tetris with Numbers** - OpenGL version with 3D sound.

Original game concept from 2007.

## Game Rules

Instead of traditional Tetris blocks, pieces contain numbers (1-9). When two adjacent numbers sum to 10, they disappear. Freed blocks continue falling, creating chain reactions.

**Examples:**
- 3 + 7 = 10 → blocks disappear
- 4 + 6 = 10 → blocks disappear  
- 1 + 9 = 10 → blocks disappear

## Features

- **3D Positional Audio** - Sound effects positioned in 3D space
- **OpenGL Graphics** - Hardware-accelerated rendering via DGLEngine
- **Chain Reactions** - Falling blocks create cascading combinations
- **Score System** - Points for each combination cleared

## Controls

- **Arrow Keys** - Move pieces
- **Up Arrow** - Rotate piece
- **Space** - Drop quickly
- **Down Arrow** - Accelerated drop
- **R** - Restart game
- **S** - Toggle music
- **F1** - Help
- **Esc** - Quit

## System Requirements

- Windows 7 or later
- DirectX 9.0c compatible graphics
- Sound card for 3D audio

## Building

Requires Free Pascal Compiler:

```bash
# Windows
build_windows.bat

# Cross-platform
make install
```

## Running

```bash
# Windowed mode
TeNRiS.exe

# Fullscreen mode  
TeNRiS.exe fullscrean
```

---

*Original game design and implementation © 2007*
