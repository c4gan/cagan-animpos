# 🧭 cagan-animpos | 3D Transform Gizmo Animation Positioning for RedM

An interactive **3D Transform Gizmo** animation & emote positioning tool developed for **RedM**.
Allows players to freely reposition and rotate their character in real-time while performing animations/emotes using direct mouse drag on 3D axis handles and authentic RedM native prompts.

Built with a lightweight Three.js webview gizmo and modular framework bridge supporting **Standalone**, **VORP Core**, and **RSG-Core**.

---

## 📺 Video Showcase
[![Watch Preview](https://img.shields.io/badge/Streamable-Watch%20Showcase%20Video-blue?style=for-the-badge&logo=playstation)](https://streamable.com/fq7vxe)

👉 **[Click here to watch the full showcase preview](https://streamable.com/fq7vxe)**

## ✨ Features

- 🎯 **Interactive 3D Gizmo**:
  - Click and drag translation arrows (**X**, **Y**, **Z**) to move your ped with millimeter precision.
  - Rotation rings for seamless yaw/pitch orientation adjustment.
- 🎮 **Native RedM Prompt HUD**:
  - Clean bottom-right in-game prompts for mode switching, ground snap, camera orbit, confirm, and cancel.
- 🎥 **Smooth Orbit Camera**:
  - Hold **Right Mouse Button** to rotate the camera around your character in 360 degrees.
  - Use **Mouse Scroll** to zoom in and out smoothly.
- 🦶 **Snap to Ground**:
  - Press **[Space]** to instantly calculate terrain/floor collision and snap character feet to the ground height.
- 🛡️ **Abuse & Leash Limits**:
  - Configurable max distance leash (horizontal and vertical) to prevent players from clipping through walls or glitching across the map.
- 👻 **Ghost Opacity**:
  - Semi-transparent character preview while actively adjusting position.
- 🌐 **Framework Agnostic**:
  - Automatically adapts to **VORP Core**, **RSG-Core**, or **Standalone** servers.
- ⚡ **Zero Resmon**:
  - **0.00ms** idle Resmon, fully optimized webview rendering.

---

## 🕹️ Controls

| Input | Action |
| :--- | :--- |
| **Mouse Left Drag** | Move or Rotate entity along selected 3D Gizmo axis |
| **Mouse Right Drag** | Orbit camera around character |
| **Mouse Scroll** | Zoom camera in / out |
| **[ E ]** | Switch between Translation (Move) and Rotation Mode |
| **[ Space ]** | Snap character to ground |
| **[ Enter ]** | Confirm and save position |
| **[ Esc ]** | Cancel positioning and revert |

---

## 📥 Installation

1. Download or clone cagan-animpos into your RedM server's 
esources directory:
   `ash
   git clone https://github.com/c4gan/cagan-animpos.git
   `
2. Add the resource to your server.cfg:
   `cfg
   ensure cagan-animpos
   `
3. *(Optional)* Adjust preferences in config.lua.

---

## 💻 Commands & Client Exports

### Chat Command
- /animpos - Opens the 3D positioning editor.

### Client Exports
`lua
-- Open editor programmatically from any script or emote menu
exports['cagan-animpos']:OpenAnimPos()

-- Close editor programmatically
exports['cagan-animpos']:CloseAnimPos()
`

### Emote Menu Integration
You can trigger xports['cagan-animpos']:OpenAnimPos() directly from your favorite emote menu (e.g. cagan-emotemenu, 
pemotes-reborn, orp_emotes).

---

## ⚙️ Configuration Preview

`lua
Config = {}

Config.Locale = 'tr' -- 'tr', 'en', 'de', 'fr'
Config.Framework = 'auto' -- 'auto', 'vorp', 'rsg', 'standalone'

Config.AnimPos = {
    active = true,
    command = 'animpos',

    -- Require player to be currently playing an animation to open animpos
    requireAnimation = false,

    -- Anchor model used for positioning
    anchorModel = 'scriptedball',

    -- Maximum distance leash from the starting emote position
    maxDistance = {
        xy = 4.0, -- Horizontal limit in meters
        z = 2.0   -- Vertical limit in meters
    },

    -- Abuse control: if true, returns player to starting position when animation finishes
    abuseControl = false,

    -- Player ghost opacity during placement (0 to 255)
    playerOpacity = {
        active = true,
        opacity = 200
    },

    -- Orbit camera settings during positioning
    camera = {
        distance = 2.8,
        height = 0.35,
        fov = 55.0,
        minDistance = 1.0,
        maxDistance = 6.0
    },

    groundSnapOffset = 0.98
}
`

---

## 📜 License & Credits

- **Author**: [c4gan](https://github.com/c4gan)
- **License**: MIT
- Created for the RedM / CFX.re community.
