# Angry Birds - CS50 Game Development

An Angry Birds-inspired physics game developed in Lua using LÖVE2D and Box 2D.

## Features

## Alien Split Ability

Implemented a special projectile ability inspired by the blue bird from Angry Birds.

### Split Mechanic

- Press **Space** while the alien is in flight
- The current alien splits into three independent aliens
- Each alien continues its own physical simulation

Once all three aliens stop moving:

- The level resets
- A new alien becomes available

This mechanic allows players to cover a larger impact area and create more complex destruction patterns.

## Material System

Implemented four different obstacle materials, each with unique durability and collision behavior.

| Material | Hits Required |
|----------|--------------:|
| Glass | 1 |
| Wood | 2 |
| Stone | 3 |
| Metal | 4 |

Each material also requires a different minimum collision velocity before damage is registered, making stronger materials significantly harder to destroy.

### Glass Behavior

Glass includes an additional mechanic:

- It immediately breaks when it hits the ground

This gives glass distinct physical behavior compared to the other materials.

## Progressive Damage States

Obstacles visually reflect the amount of damage they have taken.

### Wood

Wood uses two sprite variants:

- Normal
- Cracked

### Stone and Metal

Stone and metal use three sprite variants:

- Normal
- Chipped
- Cracked

As obstacles receive damage, their appearance changes to provide visual feedback before eventually breaking.

## Physics Joints

Implemented multiple Box2D joint types to create more dynamic structures.

### Revolute Joint

Used to create a swinging pendulum obstacle.

This demonstrates rotational constraints and realistic swinging physics.

### Weld Joint

Used to permanently attach bodies together.

Applications include:

- Anchoring the first ground obstacles to prevent unwanted movement after impacts
- Attaching the pendulum weight to its supporting structure

These joints improve structural stability while allowing other objects to behave dynamically.

## Technologies

- Lua
- LÖVE2D
- Box2D Physics

## Code Implemented

Main classes:
 - AlienLaunchMarker
 - Obstacle
 - Level
 - Dependencies
 - constants