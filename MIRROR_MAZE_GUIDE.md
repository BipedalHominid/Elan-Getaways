# 🪞 Mirror Maze - Horror Level Guide

## What is the Mirror Maze?

A **procedurally generated maze** with **reflective mirror walls** that creates maximum confusion and terror!

### Features:
- 🌫️ **Thick fog** - You can barely see ahead
- 🪞 **Mirror walls** - Reflective surfaces everywhere
- 💡 **Flickering lights** - Random power surges
- 😱 **8-12 random jump scares** - Never the same twice!
- 🤡 **Killy hunts you** - He knows the maze...
- 🎲 **Procedural generation** - Different layout every time

## Horror Mechanics

### 1. Mirror Confusion
The walls are **highly reflective** (metallic material) making it hard to tell:
- Where you've been
- Which way is forward
- If that's Killy or your reflection...

### 2. Multiple Jump Scare Types
Random scares include:
- **killy_popup** - Killy appears suddenly
- **shadow_figure** - Dark figure in periphery
- **whisper** - Creepy voice
- **mirror_reflection** - Something in the mirror
- **breathing** - Heavy breathing sounds

### 3. Suspense Building
- Fog limits visibility (you can only see ~10-15 feet)
- Flickering lights create sudden darkness
- Footstep echoes in the maze
- Fear meter rises constantly

### 4. The Chase
- Killy spawns far from you
- He patrols the maze
- When he spots you = **FULL SPRINT CHASE**
- The mirrors confuse YOU but not him...

## How to Use the Mirror Maze

### In Godot:

**Option 1: Make it the Main Scene**
1. **Project → Project Settings**
2. **Application → Run → Main Scene**
3. Set to: `res://scenes/mirror_maze_level.tscn`
4. Save

**Option 2: Test Directly**
1. Open `scenes/mirror_maze_level.tscn`
2. Press **F5** (or click ▶️ to run current scene)

### Adjust Maze Settings:

1. Open `mirror_maze_level.tscn`
2. Select **MirrorMaze** node
3. In Inspector, adjust:
   - **Maze Width**: 25 (larger = more complex)
   - **Maze Height**: 25
   - **Cell Size**: 4.0 (bigger cells = more room to run)
   - **Wall Height**: 4.5 (taller = more claustrophobic)

### Make It Scarier:

**Increase Fog:**
- Select **WorldEnvironment**
- Environment → Fog → **Density: 0.15** (thicker)

**Darker Lighting:**
- Select **DirectionalLight3D**
- **Light Energy: 0.05** (nearly dark!)

**More Jump Scares:**
- Open `scripts/mirror_maze.gd`
- Line 110: Change `randi_range(8, 12)` to `randi_range(15, 20)`

## Gameplay Tips (For Testing)

- **W/A/S/D** - Move carefully
- **Mouse** - Look around (check mirrors!)
- **Shift** - Sprint when Killy chases
- **Listen** - Footsteps, breathing, flickering lights
- **Watch stamina** - Don't sprint too early!

## Technical Details

### Maze Generation Algorithm:
- **Recursive Backtracker** - Creates perfect mazes (one solution)
- Always solvable
- No isolated sections
- Generates in ~0.1 seconds

### Materials:
- **Mirrors**: Metallic 1.0, Roughness 0.1, Rim enabled
- **Floor**: Dark gray, slightly metallic
- **Fog**: Exponential height fog

### Performance:
- 25x25 maze = ~300-400 wall segments
- Should run smoothly on most PCs
- For web export, reduce to 15x15 if laggy

---

**Ready to get lost in the mirrors?** 🪞🤡

Press F5 and try to survive...
