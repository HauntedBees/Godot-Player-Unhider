# Godot 3.4 Player Unhider
In a third-person 3D game, your player might walk behind something! Forget trying to move the camera somewhere else, just make that something transparent!

# Installation
Copy `addons/player_unhider` into your project (final path should be `res://addons/player_unhider`). In the Godot Editor, go to **Project Settings > Plugins** and enable the **Player Unhider** plugin. You can now add an **Unhider** node to a scene.

# Usage
Add an **Unhider** node to your scene and configure it in the **Inspector** as needed. Assign the appropriate **group**s to your player character and scenery, and you're all set.

# Inspector Properties

## Active
Whether or not the unhiding functionality is active. When `false`, this node does nothing.

## Player Group
The **group** that your player character belongs to. Specifically, this should be assigned to the **KinematicBody** or whatever **PhysicsBody** your player character has, so if your player is composed of multiple nodes (such as a **CollisionShape**, **PhysicsBody**, and **MeshInstance**), make sure you apply this group to the **PhysicsBody**.

## Hide Group
The **group** that relevant scenery belongs to. This should be assigned to the **PhysicsBody** Nodes (likely **StaticBody** Nodes for scenery). Leave this blank if you want literally every non-player object in your game to do the thing.

## Player Offset
By default, this code works by casting a from the camera right into the center of your player character. Depending on your character's shape, you may want to offset this a bit in some direction to instead check around the player character's feet or head or something like that. Use this for that. The calculation used is `player.global_position.origin + player_offset`.

## Mesh Relation
Do your game world objects have **MeshInstance** Nodes with **StaticBody** Nodes as their children, or are they **StaticBody** Nodes with **MeshInstance** Nodes as their children? Pick the appropriate option here so the raycast will be able to find the **MeshInstance** from the **StaticBody**. If your stuff has different composition than these two options, you'll probably need to dive into the `unhider.gd` *_get_mesh_from_body* function and tweak it to suit your project.

## Transparency Type
Three different ways for the Unhider to work!
 - **none**: This is the same as setting the **Active** property to `false`. It does nothing.
 - **alpha**: Objects in front of the player will be set to 0.5 opacity.
 - **dots**: Objects in front of the player will fade with a dot effect similar to the ones seen in **Super Mario Odyssey** and **Story of Seasons: Pioneers of Olive Town**.

# License

Copyleft, but, like, whatever. If you've read this far and you're some new indie gamedev or something who really thinks this code will help you but for some reason you're very determined not to open source your game for whatever reason, I think that's weird but realistically don't care. If your game or project makes less than $1,000 or something, you can interpret this as me granting you a license to use this code in your proprietary game (with credit). If your project makes more than that, either release its source under a license compatible with the AGPLv3, take my code out of your project, or send me ten bucks.