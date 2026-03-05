# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **SketchyBar** configuration for macOS featuring a "Geek Glass" aesthetic — translucent glass effect with blur. SketchyBar is a menu bar customization framework that uses event-driven shell scripts to render dynamic components.

**Layout:**
- **Left:** Logo + AeroSpace workspaces (1-10)
- **Center:** Focused application icon + name
- **Right:** Weather • Memory • CPU • Date Time • Battery • Input Method

## Common Commands

### SketchyBar Control

```bash
# Reload configuration (apply changes to sketchybarrc or plugins)
sketchybar --reload

# Restart SketchyBar (full restart)
brew services restart sketchybar

# View current item configuration (debugging)
sketchybar --query <item_name>

# Manually trigger an item update (testing plugins)
sketchybar --set <item_name> script="<plugin_path> [args]"
```

### AeroSpace Integration

```bash
# List workspaces
aerospace list-workspaces

# List windows in a workspace
aerospace list-windows --workspace 1

# Switch to workspace
aerospace workspace 3
```

### Testing Plugin Changes

```bash
# Test a plugin directly
./plugins/<plugin_name>.sh

# Test with sketchybar item context (NAME, SENDER env vars)
NAME="space.1" FOCUSED_WORKSPACE="1" SENDER="aerospace_workspace_change" ./plugins/aerospace.sh 1
```

## Architecture

### Global Variables

The `sketchybarrc` defines `$PLUGIN_DIR="$HOME/.config/sketchybar/plugins"` which is referenced by all plugin scripts for:
- Sourcing theme/icon mapping files
- Script paths in event subscriptions

### Modular Plugin System

Each bar component is a separate shell script in `plugins/` that can be sourced or executed independently:

```
plugins/
├── theme.sh           # Shared color/font definitions (sourced by other plugins)
├── icon_map.sh        # App name → Nerd Font icon mapping (sourced)
├── aerospace.sh       # AeroSpace workspace renderer
├── sys_rainbow.sh     # CPU/MEM with rainbow gradient colors
├── battery.sh         # Battery status with color coding
├── clock.sh           # Time/date display
├── front_app.sh       # Focused application display
├── input.sh           # Input method detector (Squirrel/Rime)
├── weather.sh         # Weather from Open-Meteo API
└── auto_gaps.sh       # Auto-adjust AeroSpace window gaps on monitor change
```

### Plugin Conventions

All plugins follow this pattern:

1. **Source theme** if colors needed (using `$PLUGIN_DIR` defined in sketchybarrc):
   ```bash
   THEME_FILE="$PLUGIN_DIR/theme.sh"
   [[ -f "$THEME_FILE" ]] && source "$THEME_FILE"
   ```

2. **Find sketchybar binary** (LaunchAgent PATH is limited):
   ```bash
   if command -v sketchybar >/dev/null 2>&1; then
     SB="$(command -v sketchybar)"
   elif [[ -x /opt/homebrew/bin/sketchybar ]]; then
     SB="/opt/homebrew/bin/sketchybar"
   ...
   ```

3. **Update items** using `$SB --set`:
   ```bash
   "$SB" --set <item_name> <property>=<value> ...
   ```

### Event-Driven Architecture

SketchyBar uses a subscription model where items subscribe to events and execute scripts when triggered:

```bash
# Item subscribes to events
sketchybar --add item <name> <position> \
  --subscribe <name> <event1> <event2> ... \
  --set <name> script="<plugin_path> [args]"
```

**Key Events:**
- `aerospace_workspace_change` — Custom event from AeroSpace
- `space_change` / `space_windows_change` — macOS space events
- `front_app_switched` — Application focus changed
- `system_woke` — System woke from sleep
- `display_change` — Monitor hot-plug
- `input_change` — macOS input source notification

**Environment Variables Passed to Scripts:**
- `$NAME` — The item name (e.g., "space.1", "cpu.slider")
- `$SENDER` — The event that triggered the script
- `$FOCUSED_WORKSPACE` — Currently focused workspace number (AeroSpace events)

Example from `aerospace.sh`:
```bash
# $NAME is "space.1" when rendering workspace 1
# $SENDER is "aerospace_workspace_change" when triggered by AeroSpace
sketchybar --set "$NAME" drawing="$DRAWING" ...
```

### Color Format

All colors use **ARGB format**: `0xAARRGGBB`
- `AA` — Alpha (00=transparent, FF=opaque)
- `RR` — Red channel
- `GG` — Green channel
- `BB` — Blue channel

Example: `0x703F3F3F` = ~44% opacity dark gray

### Icon Mapping System

The `icon_map.sh` plugin provides a mapping function used by `aerospace.sh` and `front_app.sh`:

```bash
source "$PLUGIN_DIR/icon_map.sh"
__icon_map "Google Chrome"
echo "$icon_result"  # Output: 
```

To add new app icons, edit the case statement in `icon_map.sh`. Apps returning empty string are hidden (e.g., Finder).

### Slider Components (v2.23+)

For progress bars (CPU, MEM, Battery):
```bash
sketchybar --add slider <name> <position> \
  --set <name> \
    slider.width=48 \
    slider.percentage=50 \
    slider.highlight_color=0xFF00FF6A \
    slider.background.height=10 \
    ...
```

Update via: `sketchybar --set <name> slider.percentage=<value> slider.highlight_color=<color>`

**Batch Update Pattern:** `sys_rainbow.sh` updates both CPU and MEM sliders in a single script execution for efficiency.

### Battery Color Coding (battery.sh)

- **Charging (↑)**: Deep cyan `0xFF1E7AA6` for all levels
- **Discharging (↓)**:
  - `≤ 20%`: Red `0xFFFF3B30` (low)
  - `≤ 50%`: Yellow `0xFFFFCC00` (medium)
  - `≤ 80%`: Deep cyan `0xFF1E7AA6` (good)
  - `> 80%`: Green `0xFF00FF6A` (high)

### Workspace Visibility Rules

The `aerospace.sh` plugin implements these visibility rules:
- **Focused workspace:** Always visible (even if empty) — shows user's current location
- **Non-focused workspace:** Visible only if it has visible apps
- **App visibility:** Controlled by `icon_map.sh` (apps returning empty string are hidden, e.g., Finder)

### Rainbow Color Scale (sys_rainbow.sh)

The 7-tier color scale provides visual feedback:
- `< 15%`: Cyan `0xFF66D9EF` (idle)
- `< 30%`: Dark cyan `0xFF1E7AA6` (good)
- `< 45%`: Yellow `0xFFFFFF00` (moderate)
- `< 60%`: Orange `0xFFFFA500` (elevated)
- `< 75%`: Orange-red `0xFFFF4500` (high)
- `< 90%`: Red `0xFFFF0000` (very high)
- `≥ 90%`: Purple `0xFFB000FF` (critical)

### Input Method Detection (input.sh)

Uses JXA (JavaScript for Automation) via `osascript` to query the Carbon framework:
```bash
osascript -l JavaScript -e "
  ObjC.import('Carbon');
  var source = $.TISCopyCurrentKeyboardInputSource();
  // Returns input source ID like 'com.sogou.inputmethod.sogou' or 'ABC'
"
```

## Adding New Items

To add a new bar component:

1. **Create plugin script** in `plugins/` following conventions
2. **Add item(s) to sketchybarrc**:
   ```bash
   sketchybar --add item <name> <position> \
     --set <name> script="$PLUGIN_DIR/<script>.sh" \
     --subscribe <name> <relevant_events>
   ```
3. **Add to reorder section** if right-side:
   ```bash
   sketchybar --reorder ... <name> ...
   ```
4. **Reload**: `sketchybar --reload`

## Theme Customization

Edit `plugins/theme.sh` to modify:
- Colors (FG, ACCENT, BAR_BG, etc.)
- Font (Nerd Font required for icons)
- Transparency (adjust AA in ARGB)

## Debugging Tips

- Enable script debugging by adding `set -x` at plugin script top
- Check LaunchAgent logs: `log show --predicate 'process == "sketchybar"'`
- Test plugins standalone with environment variables set
- Use `sketchybar --query <item>` to inspect current state
