# Killy the Klown - Horror Chase Game

A first-person horror chase game built with Godot 4.3 where you must escape from Killy the Klown while navigating through a terrifying environment filled with jump scares.

## Game Overview

**Genre:** First-Person Horror / Chase

**Platform:** PC (Web-based - playable in browser)

**Engine:** Godot 4.3

## Gameplay

- **Objective:** Survive and escape from Killy the Klown
- **Mechanics:**
  - First-person movement with WASD controls
  - Sprint system with stamina management (hold Shift, but don't run out!)
  - Dynamic chase AI that hunts the player
  - Random jump scare triggers throughout the environment
  - Fear system that affects gameplay

## Controls

- **W/A/S/D** - Move forward/left/backward/right
- **Mouse** - Look around
- **Shift** - Sprint (drains stamina)
- **Space** - Jump
- **ESC** - Toggle mouse cursor

## Features

### Player Mechanics
- **Stamina System:** Sprint to escape, but manage your stamina carefully
- **Head Bob:** Realistic camera movement while walking/running
- **Fear Meter:** Increases when Killy is nearby, affects breathing and vision
- **First-Person Camera:** Immersive horror experience

### Killy AI
- **Multiple States:** Patrol, Chase, Search, and Jumpscare modes
- **Smart Navigation:** Uses Godot's NavigationAgent3D for pathfinding
- **Detection System:** Line-of-sight raycast detection
- **Dynamic Behavior:** Killy hunts you down intelligently

### Jump Scares
- **Trigger-Based:** Walk through invisible triggers to activate scares
- **Configurable:** Different scare types and intensities
- **One-Time or Repeating:** Design flexible horror experiences

## Project Structure

```
Killy-the-Klown/
├── project.godot          # Main Godot project file
├── assets/
│   ├── models/
│   │   └── KtK.stl       # Killy the Klown 3D model
│   ├── textures/         # Textures and materials
│   └── audio/
│       ├── music/        # Background music
│       └── sfx/          # Sound effects
├── scenes/               # Godot scene files
├── scripts/
│   ├── player.gd         # Player controller
│   ├── killy_ai.gd       # Killy AI behavior
│   └── jumpscare_trigger.gd  # Jump scare system
└── README.md
```

## Development Setup

### Requirements
- Godot 4.3 or later
- Web browser (for web export testing)

### How to Run
1. Open Godot 4.3
2. Click "Import" and select the `project.godot` file
3. Once imported, click "Run" (F5) to test the game

### Web Export
The game is configured for web export (HTML5):
1. In Godot, go to Project → Export
2. Add "Web" export template
3. Export the project
4. Host the HTML files on a web server

## Current Status

✅ **Completed:**
- Godot project setup and configuration
- Player movement controller with stamina system
- Killy AI with chase mechanics
- Jump scare trigger system
- Project structure and organization

🔄 **In Progress:**
- Integrating Killy 3D model (STL imported)
- Creating test environment/level
- Adding materials and textures
- Implementing audio system

📋 **Planned:**
- Complete level design
- Additional jump scare types
- Game over and win conditions
- UI/HUD (stamina bar, fear meter)
- Sound effects and music
- Web export optimization
- Playtesting and balancing

## Technical Details

- **Renderer:** GL Compatibility (for web export)
- **Display:** 1920x1080, fullscreen/windowed
- **Physics:** Godot's built-in 3D physics
- **Navigation:** NavigationAgent3D for AI pathfinding

## Credits

- **Game Design:** BipedalHominid
- **Engine:** Godot 4.3
- **Character Model:** Killy the Klown (KtK.stl)

## License

This project is for educational/entertainment purposes.

---

**Stay scared. Run fast. Don't look back.** 🤡
