# [RELEASE][STANDALONE/VORP/RSG] cagan-animpos - 3D Transform Gizmo Animation Positioning

Hello CFX Community,

I am pleased to share **cagan-animpos**, an intuitive **3D Gizmo Animation & Emote Positioning** resource developed specifically for **RedM**.

Players frequently find that animations or emotes do not perfectly align with chairs, benches, bars, campfires, wagons, or other players. **cagan-animpos** gives players complete control to position and rotate their ped seamlessly in 3D space using an interactive Three.js 3D Gizmo and authentic RedM native prompts.

---

### Features

- **Interactive 3D Gizmo**: Directly click and drag translation arrows (X, Y, Z) and rotation rings to place your ped with millimeter precision.
- **RedM Native Prompt UI**: Uses native RedM bottom-right prompt controls styled like in-game shops for full immersion.
- **Dynamic Orbit Camera**: Hold **Right Mouse Button** and move your mouse to inspect your character from any angle; zoom in and out with the mouse wheel.
- **Snap to Ground**: Press **[Space]** to automatically detect ground collision and snap your ped to the terrain or floor.
- **Abuse & Leash Limits**: Includes configurable horizontal and vertical leash bounds to prevent glitching or exploiting movement.
- **Ghost Opacity**: Semi-transparent character preview while adjusting position.
- **Network Sync**: Synchronizes final placement and orientation across all nearby clients smoothly.
- **Zero Resmon**: 0.00ms idle, extremely lightweight Three.js webview renderer.
- **Framework Support**: Standalone by default with automatic bridge detection for **VORP Core** and **RSG Core**.

---

### Controls

- **Left Mouse Drag**: Move or rotate along the selected 3D Gizmo axis handle
- **Right Mouse Drag**: Orbit camera around character
- **Mouse Scroll**: Zoom camera in / out
- **[ E ]**: Toggle Gizmo Mode (Move / Rotate)
- **[ Space ]**: Snap to Ground
- **[ Enter ]**: Confirm position
- **[ Esc ]**: Cancel and restore original position

---

### Requirements / Compatibility

- Works on **Standalone**, **VORP Core**, and **RSG Core** (auto-detected).
- Compatible with all emote menus (`cagan-emotemenu`, `rpemotes-reborn`, `vorp_emotes`, etc.) via export.

---

### Exports

```lua
-- Open positioning
exports["cagan-animpos"]:OpenAnimPos()

-- Close positioning
exports["cagan-animpos"]:CloseAnimPos()
```

---

### Configuration Preview

```lua
Config = {}

Config.Locale = "tr" -- "tr" or "en"
Config.Framework = "auto" -- "auto", "vorp", "rsg", "standalone"

Config.AnimPos = {
    active = true,
    command = "animpos",

    requireAnimation = true,
    anchorModel = "scriptedball",

    maxDistance = {
        xy = 4.0,
        z = 2.0
    },

    abuseControl = true,

    playerOpacity = {
        active = true,
        opacity = 200
    },

    camera = {
        distance = 2.8,
        height = 0.35,
        fov = 55.0,
        minDistance = 1.0,
        maxDistance = 6.0
    },

    groundSnapOffset = 0.98
}
```

---

### Release Information

| Key | Value |
| :--- | :--- |
| **Code is accessible** | Yes |
| **Subscription-based** | No |
| **Lines of code** | ~500 Lua |
| **Support** | Yes |
