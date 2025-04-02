![Gaea](https://raw.githubusercontent.com/gaea-godot/gaea-docs/a81f21c78766012a823992dd1ac8feecd17f62a6/docs/logo.svg)

# 🌍 Gaea

[![](https://img.shields.io/badge/Docs-%239dbd4b?style=for-the-badge&logo=https%3A%2F%2Ffonts.googleapis.com%2Fcss2%3Ffamily%3DMaterial%2BSymbols%2BOutlined%3Aopsz%2Cwght%2CFILL%2CGRAD%4048%2C400%2C1%2C0&logoColor=white
)](https://gaea-godot.github.io/gaea-docs/#/) [![](https://img.shields.io/badge/-Gamedev%20Graveyard-5865f2?style=for-the-badge&logo=discord&labelColor=white)](https://discord.gg/V7UsX54V49)
> Join the **Gamedev Graveyard** discord server to get notified about Gaea and hang out with other devs.


Gaea 1.X is an **add-on for Godot 4.3***, designed to empower your project with advanced **procedural generation** capabilities.

*For 4.2, use v1.1.3 or lower. For 4.0-4.1, use v0.6.2 or lower.

> **NOTE:** This version is more stable than [v2.0](https://github.com/BenjaTK/gaea/tree/2.0) for now, but it might fall behind in the future.

### What's in a Name?

**Gaea**, in Greek mythology, is the personification of Earth - a nod towards the terrain and world generation capabilities this addon brings to your game development toolkit. Plus, we think it sounds pretty cool.

# 💫 Key Features

## Generators
Our collection of generators, including Cellular, Heightmap, and Walker, allow for dynamic and unique world creation. Whether you're looking to create intricate cave systems or sprawling landscapes, Gaea's got you covered.

![generators showcase](https://github.com/gaea-godot/gaea-docs/blob/main/docs/1.X/assets/generators-showcase.png?raw=true)

## Modifiers
Further fine-tune your procedurally generated worlds with our set of modifiers. Add layers of complexity and fine-tune the details to create environments that truly come alive.

## Renderers
`GaeaRenderers` are nodes that take the generator's data to **render** the generation. They can be used for drawing in a TileMap, a GridMap, a mesh, a texture, or whatever you can code.

## Chunk loading
Gaea comes with a `ChunkLoader` node that can generate an area around an `actor`, allowing both for infinite worlds and to optimize big worlds. 

# Videos
#### A great tutorial for beginners:
[![How to Create Procedural Generation in Godot 4](https://github.com/gaea-godot/gaea-docs/blob/main/docs/1.X/assets/devworm-thumbnail.jpg?raw=true)](https://youtu.be/oB1xsCcO9wI "How to Create Procedural Generation in Godot 4")
[![10+2 AWESOME ADDONS for GODOT 4 by MrElipteach](https://github.com/gaea-godot/gaea-docs/blob/main/docs/1.X/assets/mrelipteach-thumbnail.jpg?raw=true)](https://youtu.be/-FQNPCB7e3s?t=144&si=myv2OsGoLa7jiUfi "10+2 AWESOME ADDONS for GODOT 4 by MrElipteach")

# 🔧 Installation Steps

1. **Download the project files.**
2. Move the `gaea` folder into your `/addons` folder within your Godot project.
3. Enable the addon through the project settings, and let your world-building journey begin!
