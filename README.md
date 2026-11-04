# mod-twow-camps / TurtleCamps

![TurtleCamps Banner](docs/images/turtle_camps_banner.jpg)

A standalone decorative campsite housing system and GM open-world builder for the Tortoise Turtle WoW 1.18.1 (build 7272) core. Open `/tc`, search through safe props, buildings, creatures, or items, preview them in the world, move/raise/rotate/snap them with precision 3D controls, and save them persistently. Manage account camps, adjust territory size, toggle public/private visibility, or force-delete spawns anytime.

**Status:** Implementation compiles and `mangosd` links cleanly on Windows x64 Release. Full protocol tests (10,042 assertions + 10,000 fuzz checks) and static verification pass.

---

## Features
- **Draggable Minimap Button**: Circular, draggable minimap button styled with native tracking borders and an initial randomized outdoor/camp icon. Left-click toggles the window, Right-click re-randomizes the icon, and Left-drag rotates smoothly around the minimap rim. Supports `/tc minimap` and `/tc icon`.
- **Categorized Catalogue**: Dedicated browsing tabs for **Props**, **Buildings**, **Creatures & NPCs**, and placeable **Items / Ground Clutter**.
- **Contextual Filter Chips**: Quick preset chips dynamically adapted per category (e.g., Tents, Seats, Fires, Storage, Nature; Houses, Towers, Pavilions; Humanoids, Beasts, Critters; Weapons, Armor, Food, Potions).
- **Interactive 2D Portrait Cards**: Real-time icon inspection, category badge, and entity ID info card for any selected or edited object.
- **Database & 3D Web Viewer Integration**: One-click URL generation to view selected entities in the Classic Wowhead database, Turtle WoW Database, or the Tortoise 3D Web Model Viewer.
- **Mouse Scroll Wheel Navigation**: Scroll through catalog, owned spawns, and public camp listing pages using the mouse scroll wheel over the table or row buttons.
- **Camp Territory Management**: Claim or relocate personal camps with customizable territory sizes (20y, 40y, 60y, 80y) and Public/Private visitor permissions.
- **Camp Group Filtering**: Cycle between viewing All props, Camp-assigned props, or free World props in the Owned list.
- **Force Delete**: Unconditional server force-deletion of placed spawns directly from the world and database, with instant client cleanup and `/tc delete <guid>` support.
- **Precision 3D Transform Controls**: Character-relative nudge buttons (Forward, Back, Left, Right, Up, Down, Ground Snap, Rotate Yaw) with Fine / Normal / Coarse step toggles.
- **Mouse & Keyboard Shortcuts**: Wheel for elevation (Z), Shift+Wheel for rotation (Yaw), Ctrl+Wheel for forward/back, Alt+Wheel for strafe.
- **Double-Click & Shift-Click**: Double-click any row to preview immediately; Shift-click to paste item or entity links into chat.
- **Informative Delayed Tooltips**: Rich 3-second hover tooltips on all UI buttons explaining exact actions and keybindings.
- **Dual Authority**: Normal Player Camp mode vs. GM World Mode (`SEC_DEVELOPER`); cross-editor locks, 20-action undo stack, and ownership validation.
- **Personal Bookmarks**: 50 persistent favorites and 20 recent placement history slots saved per character.

---

## Installation and Build Integration

From the TortoiseWoW source root, clone or copy the module directly into `modules/mod-twow-camps/`.

```bash
git clone https://github.com/Ildourol/mod-twow-camps.git modules/mod-twow-camps
```

**Linux**

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DMODULE_MOD_TWOW_CAMPS=static
cmake --build build --parallel
```

**Windows** (PowerShell, Visual Studio 2022 with C++ tools)

```powershell
cmake -S . -B build -G "Visual Studio 17 2022" -A x64 -DMODULE_MOD_TWOW_CAMPS=static
cmake --build build --config Release --parallel
```

Preserve the CMake options for your existing server and modules. Deploy the rebuilt `mangosd` (`mangosd.exe` on Windows). Copy the module’s `conf/mod-twow-camps.conf.dist` to `modules/mod-twow-camps.conf` beside the active `mangosd.conf` and restart after completing any setup below.

**Database.** No manual import is needed when `Database.AutoUpdate.Enabled = 1`, `Database.AutoUpdate.AllowedModules` is `all` or includes `mod-twow-camps`, and the server can read the module’s SQL at the source path used by the build. With the standard database folder names, the core applies `data/sql/world/` at startup. Keep `Database.AutoUpdate.SortByName = 1` and check the startup log. For a manual install, back up the affected databases, apply the files in filename order to the matching databases, and exclude this module from the updater.

Copy `addon/TurtleCamps` to the client’s `Interface/AddOns/` and enable it at character selection.

## Database and Configuration

The initial world SQL seeds the curated catalogue. The optional `tools/prepare-transactional-tables.sql` is separate from the fresh install. Review its storage engine changes before using it in a maintenance window.

### MySQL / MariaDB compatibility and existing installations

The initial schema uses `CREATE TABLE IF NOT EXISTS`, with `radius FLOAT NOT NULL DEFAULT 40` defined directly in `camps_camp`. Startup and configuration reloads do not run `ALTER TABLE`. Repeated starts preserve existing tables and camp data.

The former `20260912_01_camps_radius.sql` migration has been removed because its `ADD COLUMN IF NOT EXISTS` syntax is unsupported by MySQL. Update the module checkout and any separately copied updater SQL directory so that this obsolete file is no longer queued. Rebuild and deploy `mangosd` as well: updating SQL alone does not remove the old statement from an existing executable.

Before loading saved camps, the module checks all required module-table columns and the schema version. If columns are missing or cannot be verified, Camps remains disabled and logs a module-specific error rather than attempting an automatic database alteration. Check that the configured world database is correct and the server account has the required database permissions.

`CREATE TABLE IF NOT EXISTS` does not modify an older table that already exists. A legacy database without `radius` requires a separately reviewed upgrade to preserve its data; it cannot be repaired by reimporting the initial SQL. Do not drop module tables or reset the database to bypass validation: existing placed native spawns depend on their ownership records.


---

## Configuration Reference

The configuration file `conf/mod-twow-camps.conf.dist` is organized into 7 logical categories:

### 1. Master Controls & Module Initialization
| Key | Type | Default | Description |
| :--- | :---: | :---: | :--- |
| `Camps.Enable` | Boolean | `1` | Master enable switch for the module. When enabled (`1`), database tables are verified, saved camps/props are loaded, and the `.camp` command interface is registered. |

### 2. Player Permissions & Feature Switches
| Key | Type | Default | Description |
| :--- | :---: | :---: | :--- |
| `Camps.Players` | Boolean | `1` | Enables personal campsite claiming and prop placement for regular non-GM players (`1` = All players, `0` = GM-only mode). |
| `Camps.Visits` | Boolean | `1` | Enables public camp visitation and player fast-travel via `.camp visit` (`1` = Enabled, `0` = Disabled). |

### 3. Camp Boundaries, Density & Spacing Restrictions
| Key | Type | Default | Allowed Range | Description |
| :--- | :---: | :---: | :---: | :--- |
| `Camps.PropCap` | Integer | `100` | `1 – 500` | Maximum number of placed scenery props, creatures, and items allowed per account campsite. |
| `Camps.Radius` | Float | `40` | `5 – 100 yds` | Default personal campsite territory boundary radius in yards. |
| `Camps.MinimumSpacing` | Float | `100` | `10 – 1000 yds` | Minimum horizontal spacing required between separate player camps (must be `>= 2 * Camps.Radius`). |

### 4. Preview Timeouts & Travel Mechanics
| Key | Type | Default | Allowed Range | Description |
| :--- | :---: | :---: | :---: | :--- |
| `Camps.EditTimeoutSeconds` | Integer | `120` | `15 – 600 s` | Idle timeout for active 3D preview/editing sessions before reverting uncommitted placements. |
| `Camps.TravelCooldownSeconds` | Integer | `60` | `15 – 3600 s` | Shared cooldown timer for `.camp go` (return home) and `.camp visit` (visit public camp) actions per character. |

### 5. Game Master (GM) World Builder Controls
| Key | Type | Default | Allowed Range | Description |
| :--- | :---: | :---: | :---: | :--- |
| `Camps.GMSecurityLevel` | Integer | `2` | `1 – 4` | Minimum account security rank required for unrestricted GM World Builder mode (`1` = Observer, `2` = Moderator, `3` = Developer, `4` = Administrator). |

### 6. Geographic & Location Blacklists
| Key | Type | Default | Constraints | Description |
| :--- | :---: | :---: | :---: | :--- |
| `Camps.ForbiddenMaps` | String | `""` | Max 64 IDs | Comma-separated list of native Map IDs where player camp placement is disallowed. Note: Ordinary player camps are already restricted to outdoor maps 0 (Eastern Kingdoms) and 1 (Kalimdor). |
| `Camps.ForbiddenZones` | String | `""` | Max 64 IDs | Comma-separated list of Zone IDs where player camps are forbidden (e.g. major capital cities, battlegrounds, or quest hubs). |
| `Camps.ForbiddenAreas` | String | `""` | Max 64 IDs | Comma-separated list of sub-Area IDs where player camps are forbidden. |

> [!NOTE]
> Each forbidden ID list is limited to 64 entries (maximum 512 bytes). A malformed list will safely disable the module on startup. Restrictions apply to proposed prop coordinates and travel destinations. GM mode bypasses personal camp location restrictions.

### 7. Database Integrity & Storage Engine Policy
| Key | Type | Default | Description |
| :--- | :---: | :---: | :--- |
| `Camps.RequireInnoDB` | Boolean | `0` | Enforces strict InnoDB storage engine on native gameobject tables (`gameobject`, `game_event_gameobject`, `gameobject_battleground`, `camps_camp`, `camps_prop`). When `0` (default), non-InnoDB/MyISAM tables are permitted with a console warning notice. When `1`, startup is halted if any required table is non-InnoDB. |

---

## Addon Setup and Workflows

Copy the folder `addon/TurtleCamps` directly into your client's AddOns directory:  
`<Turtle Client>/Interface/AddOns/TurtleCamps` *(do not copy the root repository folder)*.

Enable it on the character select screen. Its TOC specifies vanilla Interface `11200`. Type `/tc` or `/turtlecamps` in-game to toggle the window (negotiates wire protocol version 1).

### Normal Player Workflow:
1. Choose **Camp** mode.
2. Stand on valid outdoor ground on Map 0 or 1.
3. Click **Claim** to establish your camp center.
4. Search for a prop, creature, or item in the catalogue.
5. Select a row and click **Preview**.
6. Use the 3D directional controls (Shift is coarse, Ctrl is fine, Alt is strafe) to adjust position, elevation, and yaw rotation.
7. Click **Save** to make it persistent, or **Cancel** to discard.
8. The **Owned** tab lists your active props. Nearest/Facing starts an edit immediately.
9. **Go Home** teleports you to your camp center.
10. Toggle **Public** to permit other players to discover and visit your camp via the **Camps** list.
11. **Break** requires two confirmation clicks within 15 seconds to safely pack up and delete camp props.

### Game Master (GM) Workflow:
1. Accounts with security level `>= Camps.GMSecurityLevel` (default: 2 / Moderator, or Developer `SEC_DEVELOPER`) default to **GM** mode.
2. Place props directly on any supported outdoor map without needing to claim an account camp.
3. GM edits are restricted to module-owned decorative spawns within 60 yards (the module never edits arbitrary native world spawns).
4. Toggle between GM and Camp mode at any time.

### Network Protocol:
The AddOn communicates through private self-whisper `.camp` commands and tagged private system replies (`TCAMP/1~...`). There is no public chat broadcast. The AddOn throttles requests to at most one per 0.8 seconds and awaits server acknowledgment.

---

## Commands and Diagnostics

Use the in-game UI normally. Raw diagnostic wire commands (incrementing request ID):

```text
.camp 1~1~HELLO
.camp 1~2~STATUS
.camp 1~3~RELOAD
```

> [!TIP]
> `RELOAD` requires Administrator (`SEC_ADMINISTRATOR`) security and reloads the manager from the **currently loaded** `sConfig` values and database tables; it does not re-read configuration files directly. Use the core's native config reload command to reread files from disk, which automatically triggers the Camps reload hook.

---

## Safety, Limitations and Troubleshooting

- **Safe Catalog Verification**: Only verified generic decorative templates pass admission; overrides cannot enable doors, chests, spell foci, transports, scripted, or quest templates.
- **Collision & Movement**: Preview objects are visible to nearby players. Collision depends on native `GameObjectModel` and server extracted assets. MMAP paths do not dynamically rebuild around decorative props.
- **Geographic Scope**: Personal camps permit Maps 0 and 1 only; GM mode additionally excludes dungeons and battlegrounds.
- **Troubleshooting Checklist**:
  - *No reply*: Verify client AddOn is enabled, check `.camp` permission in `PlayerCommands`, and inspect server console logs.
  - *Disabled on startup*: Check schema version (`camps_schema`), table engines, and coordinate bounds.
  - *Empty catalogue*: Inspect `camps_catalog_override` table; ensure valid templates exist in `gameobject_template` and `creature_template`.
  - *Rejected placement*: Verify distance to camp center (`Camps.Radius`), total placed props (`Camps.PropCap`), combat state, or minimum spacing between neighboring camps (`Camps.MinimumSpacing`).
  - *Break rejected*: Stand centrally so all camp props are loaded in memory before attempting to break.
  - *Database failure*: If a database error occurs, building latches off until realm restart to prevent state corruption. Review read-only diagnostics in `tools/diagnostics.sql`.

---

## Upgrade and Removal

- **Upgrade**: Back up your database, config, and `SavedVariables`. Update the server module and client AddOn together, rebuild `mangosd`, review any new SQL migrations, and restart the server.
- **Removal**: If you wish to remove player scenery before uninstallation, break personal camps and delete GM props while the module is still running. Disabling or removing the module alone leaves placed native spawns in the database intact. Do not drop module tables before accounting for placed spawns.

---

## Credits and License

Original implementation follows Turtle WoW GPL native API patterns. Camp concepts reference WOW Legends; browsing and authoring concepts reference MangosSuperUI; editor state concepts reference MSUIClient. No AGPL server code is copied. See [LICENSE](LICENSE) for details.
