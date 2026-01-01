# Killy the Klown - Godot Setup Guide

## Quick Start

### 1. Install Godot 4.3+

Download from: https://godotengine.org/download

**Important:** You need Godot 4.3 or newer!

### 2. Import the Project

1. Open Godot
2. Click **"Import"**
3. Navigate to this folder and select `project.godot`
4. Click **"Import & Edit"**

### 3. First-Time Setup in Godot

Once the project opens:

#### A. Import Killy's 3D Model

1. In the **FileSystem** panel (bottom-left), navigate to `assets/models/`
2. Click on `KtK.stl`
3. In the **Import** tab, make sure these settings are correct:
   - **Meshes → Storage:** Set to "Embedded"
   - Click **"Reimport"**

4. Drag `KtK.stl` into the scene to create a MeshInstance3D
5. In the Killy scene (`scenes/killy.tscn`):
   - Open the scene
   - Delete the placeholder MeshInstance3D
   - Drag `KtK.stl` from FileSystem into the Killy node
   - Position it at (0, 0, 0)
   - Add a StandardMaterial3D to make it visible:
     - Click on the mesh
     - In Inspector → Material → New StandardMaterial3D
     - Set Albedo color to red/dark colors for scary effect

#### B. Set Up Navigation (For AI Pathfinding)

1. Open `scenes/main.tscn`
2. Add a **NavigationRegion3D** node:
   - Right-click "Main" → Add Child Node
   - Search for "NavigationRegion3D"
   - Add it
3. Create Navigation Mesh:
   - Select NavigationRegion3D
   - In Inspector → NavigationMesh → New NavigationMesh
   - Click on the newly created NavigationMesh
   - Click **"Bake NavigationMesh"** button at the top

#### C. Link Player to Killy AI

1. Open `scenes/main.tscn`
2. Select the **Killy** node
3. In Inspector → Script Variables → **Player**
4. Drag the **Player** node from the scene tree into this field

### 4. Test the Game

Press **F5** or click the **Play** button (▶️) at the top-right

**Controls:**
- WASD - Move
- Mouse - Look around
- Shift - Sprint
- Space - Jump
- ESC - Toggle mouse

### 5. What You Should See

- You spawn in a dark room with walls
- Killy (red capsule for now, or your 3D model if imported) patrols
- When Killy sees you, he chases you
- Your stamina drains when sprinting (green bar top-left)
- Fear increases when near Killy (red bar top-left)
- Walk through the center trigger for a jump scare test

## Troubleshooting

### "No NavigationAgent3D found"
- Make sure you added NavigationRegion3D and baked the mesh

### "Player is null"
- Link the Player node to Killy's "player" export variable

### Killy doesn't move
- Ensure Navigation Mesh is baked
- Check that Killy has NavigationAgent3D child node

### Can't see Killy's model
- Make sure KtK.stl is imported
- Add a material to the mesh (StandardMaterial3D with a color)

## Next Steps - Making It Scary

### Lighting
- Adjust DirectionalLight3D energy (make it darker)
- Add flickering lights
- Add SpotLight3D for dramatic shadows

### Killy's Appearance
- Import KtK.stl into Killy scene
- Add scary textures/materials
- Add glowing red eyes (OmniLight3D nodes)

### Sound (Critical for Horror!)
- Add ambient music (creepy atmosphere)
- Footstep sounds for both player and Killy
- Heavy breathing when stamina is low
- Jumpscare sound effects
- Killy's laughter when chasing

### Level Design
- Add more rooms and corridors
- Add props (boxes, furniture)
- Create hiding spots
- Add more jump scare triggers

### Polish
- Particle effects (fog, dust)
- Post-processing (vignette, chromatic aberration)
- Screenshake on jumpscares
- Game over screen
- Win condition

## Web Export

When ready to export for web:

1. Go to **Project → Export**
2. Add **Web** export template
3. Download export templates if needed
4. Configure settings
5. Export to a folder
6. Host the HTML files on a web server

---

**Need Help?** Check the Godot documentation: https://docs.godotengine.org
