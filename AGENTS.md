# GDScript Language Reference for Code Generation

GDScript is a high-level, object-oriented, imperative, and gradually typed programming language built for the Godot game engine. It uses indentation-based syntax similar to Python but is entirely independent from Python. Key differences from Python are called out throughout this document.
When creating nodes, use the gli MCP, since it offers deterministic tools to check the quality of the code.


## Very Important, NEVER Forget
Be concise when talking and writing code.
Every additional line of code is a liability, so don't overengineer stuff.
Methods should have a documentation line that explains what the method does

## Example Script

```gdscript
class_name MyClass
extends Node

enum State { IDLE, HIT }

const MAX_HEALTH: int = 100
var health: int = MAX_HEALTH
var position: Vector2 = Vector2.ZERO

class Stats:
    var health: int = 0

    func _init(initial_health: int) -> void:
        health = initial_health

func _ready() -> void:
    print("Ready")

func take_damage(amount: int) -> void:
    health = max(health - amount, 0)
    if health == 0:
        print("Defeated")
```
## Literals

- Integers: decimal, hexadecimal (`0x...`), or binary (`0b...`); floats use decimal notation. `_` separators are allowed.
- Booleans are `true`/`false`; the empty value is `null`.
- Strings support single/double quotes, triple quotes, and raw strings (`r"..."`).
- `&"name"` is a `StringName`; `^"Node/Path"` is a `NodePath`.
- `$Path` is shorthand for `get_node("Path")`; `%Name` accesses a scene-unique node.


## Annotations

Annotations begin with `@`.

- Do not combine `@onready` and `@export` on one variable.
- `@export` exposes a typed value in the inspector:
  ```gdscript
  @export var speed: float = 200.0
  @export_range(0, 100) var health: int = 100
  @export_file("*.txt") var file_path: String = ""
  ```
- Useful variants include `@export_group`, `@export_enum`, `@export_flags`, `@export_storage`, and `@tool`.
- Inspector-set exported values are unavailable in `_init()`; use `_ready()` or a setter.
- Use `Curve` for designer-tunable value relationships and `sample_baked()` at runtime. Do not use `Curve2D`/`Curve3D` for value mapping.


## Signals

Signals are messages emitted by objects that other objects can listen to. They are the primary decoupling mechanism in Godot (the Observer pattern). Use signals to keep code flexible and avoid tight references between nodes.

### Declaring Signals

```gdscript
signal health_depleted
signal health_changed(old_value, new_value)
```

Argument names in the declaration are for documentation purposes; they appear in the editor's Signals dock.

### Emitting Signals

```gdscript
func take_damage(amount: int) -> void:
    var old_health = health
    health -= amount
    health_changed.emit(old_health, health)
    if health <= 0:
        health_depleted.emit()
```

### Connecting Signals in Code (Preferred Method)

Always use the `Signal.connect()` method with callable references (not string-based `Object.connect()`):

```gdscript
func _ready() -> void:
    # Preferred: direct signal reference + callable
    $Button.pressed.connect(_on_button_pressed)

    # With bound parameters
    var player = get_node("Player")
    player.hit.connect(_on_player_hit.bind("sword", 100))

func _on_button_pressed() -> void:
    print("Button pressed!")

# Bound arguments come after emitted arguments
func _on_player_hit(hit_by: String, level: int, weapon: String, damage: int) -> void:
    print("%s hit by %s" % [weapon, hit_by])
```

**Parameter order when binding:** emitted arguments come first, then bound arguments.

### Disconnecting Signals

```gdscript
if player.hit.is_connected(_on_player_hit):
    player.hit.disconnect(_on_player_hit)
```

### Signal Connection Flags

```gdscript
signal.connect(callable, CONNECT_ONE_SHOT)   # Auto-disconnect after first emission
signal.connect(callable, CONNECT_DEFERRED)   # Call on next idle frame
```

### The Signal Type

Signals are first-class values:
```gdscript
var my_signal: Signal = $Button.pressed
my_signal.connect(_on_pressed)
my_signal.has_connections()  # true/false
my_signal.get_name()         # StringName
my_signal.get_object()       # The emitting object
```



## Initialization Order

Member variables are initialized in this order — this is critical to understand:

1. Variables get their **type default** (`null` for objects, `0` for `int`, `false` for `bool`, etc.).
2. **Specified values** are assigned top-to-bottom in script order.
   - Variables with `@onready` are deferred to step 5.
3. `_init()` is called.
4. **Exported values** from the scene/resource file are assigned.
5. `@onready` variables are initialized (Node-derived classes only).
6. `_ready()` is called (Node-derived classes only).

This means: `@export` values override script defaults (step 4 after step 2), and `@onready` values override everything (step 5 after step 4) — which is why combining `@export` and `@onready` on the same variable is forbidden.



## Casting

Use `as` to cast values; object casts return `null` on failure, while built-in conversions may raise an error.

## Classes

### Class Names and Inheritance

Always give classes a name using `class_name`. Keep `class_name` and `extends` on separate lines:

```gdscript
class_name Character
extends CharacterBody2D
```

This registers the class globally — it can be used anywhere without `load()` or `preload()`:

```gdscript
var player = Character.new()
```

Add an `@icon` annotation only if explicitly requested:
```gdscript
@icon("res://icons/character.svg")
class_name Character
extends CharacterBody2D
```

If no `extends` is specified, the class implicitly inherits `RefCounted`.


### Inner Classes

Define classes inside a script using `class`. Use inner classes when manipulating structured data instead of dictionaries — they provide named fields, type safety, and better readability:

```gdscript
class DamageEvent:
    var source: Node
    var amount: int
    var type: String

    func _init(p_source: Node, p_amount: int, p_type: String) -> void:
        source = p_source
        amount = p_amount
        type = p_type

# Usage
var event = DamageEvent.new(self, 25, "fire")
print(event.amount)  # Much clearer than event["amount"]
```

Prefer inner classes over dictionaries for structured data. Use dictionaries only for truly dynamic key-value data.


## Properties (Setters and Getters)

Setters and getters are always called (even from within the class), unlike Godot 3's `setget`.

**Inline style** — use when the logic is simple:

```gdscript
var health: int = 100:
    get:
        return health
    set(value):
        health = clampi(value, 0, max_health)
        health_changed.emit(health)
```

**Separate function style** — use when the logic is complex. Put it on the line after the variable, not inline:

```gdscript
var health: int = 100:
    get = get_health, set = set_health

func get_health() -> int:
    return health

func set_health(value: int) -> void:
    health = clampi(value, 0, max_health)
    health_changed.emit(health)
```

### When Setters/Getters Are NOT Called

- **Initialization:** the initial value is written directly, bypassing the setter. This includes `@onready` initialization.
- **Self-reference inside own setter/getter:** using the variable's own name inside its setter/getter accesses the backing value directly (no infinite recursion):

```gdscript
signal changed(new_value)
var warns_when_changed = "some value":
    get:
        return warns_when_changed      # Direct access, no recursion
    set(value):
        changed.emit(value)
        warns_when_changed = value     # Direct access, no recursion
```

**This is critical for `@tool` scripts:** when a tool script loads, exported values are assigned but the setter is not called during initialization. If your tool script relies on side effects in a setter (like updating visuals), you may need to manually trigger the update in `_ready()`.

**Warning:** the no-recursion exception only applies to the setter/getter function itself, NOT to other functions called from within it:

```gdscript
var my_prop:
    set(value):
        set_my_prop(value)  # This calls the function below

func set_my_prop(value):
    my_prop = value  # INFINITE RECURSION — this triggers the setter again
```


## Tool Mode (`@tool`)

Add `@tool` at the top of a script to run it inside the editor. Use `Engine.is_editor_hint()` to separate editor code from game code:

```gdscript
@tool
extends Sprite2D

@export var speed: float = 1.0:
    set(new_speed):
        speed = new_speed
        rotation = 0

func _process(delta: float) -> void:
    if Engine.is_editor_hint():
        rotation += PI * delta * speed  # Runs in editor
    else:
        rotation -= PI * delta * speed  # Runs in game
```

**Critical rules for `@tool` scripts:**
- Any GDScript that a tool script references must also be `@tool` (except for static methods, constants, and enums).
- Extending a `@tool` script does NOT automatically make the child `@tool`.
- Be cautious with `queue_free()` and `free()` — freeing the script's own node can crash the editor.
- When setters rely on side effects (updating visuals, notifying children), remember that the setter is NOT called during initialization. Handle this in `_ready()`.

### Configuration Warnings

In `@tool` scripts, implement `_get_configuration_warnings()` to show yellow warning icons in the Scene dock when a node is misconfigured. **By default, always implement configuration warnings** when a node has required properties, dependencies, or constraints that could be set up incorrectly. Warn when something is missing, has an invalid value, or would cause runtime errors:

```gdscript
@export var title: String = "":
    set(p_title):
        if p_title != title:
            title = p_title
            update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
    var warnings: PackedStringArray = []
    if title == "":
        warnings.append("Please set 'title' to a non-empty value.")
    return warnings
```

### Resource Change Notifications

To react to changes on an exported resource's properties in the editor, connect to the resource's `changed` signal:

```gdscript
@export var resource: MyResource:
    set(new_resource):
        if resource != null:
            resource.changed.disconnect(_on_resource_changed)
        resource = new_resource
        if resource != null:
            resource.changed.connect(_on_resource_changed)

func _on_resource_changed() -> void:
    # React to property changes on the resource
    queue_redraw()
```

The resource class must also be `@tool` and emit `changed` from its setters:

```gdscript
@tool
class_name MyResource
extends Resource

@export var property: int = 1:
    set(value):
        property = value
        changed.emit()
```
## Format Strings

```gdscript
# % operator with placeholders
var text = "Player %s has %d HP" % [name, health]

# Common specifiers: %s (string), %d (decimal int), %f (float), %x (hex)
# Padding: %10d (pad to 10 chars), %010d (pad with zeros)
# Precision: %.2f (2 decimal places)

# String.format() method
var text = "Hello {name}, level {level}".format({"name": "Hero", "level": 5})
var text = "Values: {0}, {1}".format([42, "test"])
```

## Custom Drawing (`_draw`)

Any node inheriting from `CanvasItem` (which includes `Node2D` and `Control`) can override `_draw()` to render custom shapes. Drawing is primarily used for **debugging and visualization** — showing collision areas, velocity arrows, detection ranges, paths, AI states, etc.

### How It Works

Override `_draw()` on a `CanvasItem`; it is cached until `queue_redraw()` is called, and uses local coordinates.

```gdscript
func _draw() -> void:
    draw_circle(Vector2.ZERO, 50.0, Color.RED)
```

Common methods: `draw_line`, `draw_polyline`, `draw_circle`, `draw_arc`, `draw_rect`, `draw_polygon`, `draw_string`, `draw_texture`, and `draw_set_transform`.
Debug draws should always be togglable via an `@export` variable. This is the standard pattern:

To show debug draws in the editor (for level design visualization), combine `@tool` with drawing:
This is useful for visualizing detection ranges, spawn areas, trigger zones, and other spatial properties directly in the editor viewport.

## Editor Plugins (`EditorPlugin`)

A `@tool` script lets a node *run* its own code in the editor (e.g. drawing itself via `_draw()`), but it only sees its own instance. An **editor plugin** (`extends EditorPlugin`) is more expressive: it operates on the editor itself, so it can inspect and mutate *other* nodes in the edited scene, capture raw viewport input, drive the undo/redo history, and draw overlays on top of the 2D/3D viewport. Use a plugin when you need the editor to *interact with* scene objects (select, move, connect, generate them) rather than have a single node merely draw a visualization of itself.

A plugin lives under `res://addons/<plugin_name>/` and needs two files: a `plugin.cfg` descriptor and a `@tool extends EditorPlugin` script referenced by it. Enable it in **Project Settings → Plugins**.

```
# addons/my_plugin/plugin.cfg
[plugin]
name="My Plugin"
description="What it does."
author=""
version="1.0"
script="plugin.gd"
```

### Typical Workflow

A plugin that manipulates 2D viewport objects generally implements these `EditorPlugin` overrides:

- **`_handles(object: Object) -> bool`** — called with the currently selected object. Return `true` to make the editor route viewport input to your plugin. This is where you gate *when* the plugin is active. You don't have to inspect `object`: you can check the edited scene as a whole (e.g. "does this scene contain any node I care about?") so the plugin isn't tied to what is currently selected.
- **`_edit(object: Object) -> void`** — called when the editor hands your plugin an object to edit (the current selection). Implement this when your tool operates *on the selected node*. **Omit it** when you want to act on objects regardless of selection — leaving it out is what frees the plugin from the current-selection constraint.
- **`_forward_canvas_gui_input(event: InputEvent) -> bool`** — receives mouse/keyboard events in the 2D viewport while `_handles()` is true. Return `true` to **consume** the event (preventing the editor's own box-select, node-drag, and pan) and `false` to let it pass through. This is the core of click/drag interaction. (`_forward_3d_gui_input` is the 3D equivalent.)
- **`_forward_canvas_draw_over_viewport(overlay: Control) -> void`** — draw overlays (handles, outlines, guides) on top of the viewport. Call `update_overlays()` to request a redraw.

Mutate scene nodes through `get_undo_redo()` rather than assigning properties directly. This makes edits undoable and marks the scene dirty so Godot prompts to save. Merge continuous edits (like a drag) into one history entry with `UndoRedo.MERGE_ENDS`.

Access the edited scene with `EditorInterface.get_edited_scene_root()` and the selection with `EditorInterface.get_selection()`.

## How to Test
For complex cases, or when debugging with a user, you can create a sample scene, instantiate what you need, and then look at eventual logs and errors on the godot command that you will use to run the scene / script.

Sometimes you will be asked to do interactived testing: you will put some meaningful logs, open the scene with godot, ask the user to perform some operations, and then you will read the logs to undrstand what's happening.
