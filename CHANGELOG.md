# Changelog

## v0.2.2 — 2026-10-23

### Added
- The game can be built for Windows (a single .exe) and macOS (one app for Apple Silicon and Intel Macs).

## v0.2.1 — 2026-10-19

### Added
- Enemies drop a smoke bomb 3 % of the time; you can carry at most 2.
- Enemies stand idle until they see you or you come within 160 px.

### Changed
- Guns in the hand are small (10–16 px long) and drawn in the game palette; the big drawings are now only icons in the HUD and on the floor.
- The Gold Detonator's sparkles stay upright instead of turning with the gun.
- Characters, walls and chests are drawn in depth order: whatever stands lower on screen is in front.
- Every explosion follows one rule: it hurts enemies and you, except the Gold Detonator, which never hurts you. Walls block explosions.
- Fuse Kin blasts now also hurt other enemies.

### Removed
- The floor tile with shell casings drawn on it, which looked like real casings.

## v0.2.0 — 2026-10-19

### Added
- Main menu with Play and Quit. Play starts a round on one of the three maps at random.
- A 10:00 round timer at the top of the screen; it turns red and pulses in the last minute and stops while paused.
- Win by picking up the secret code; lose when the timer hits 0:00 or the last heart is gone.
- Win screen with "ESCAPED!", the round's random 4-digit code and the time used; lose screen with "BOOM" and the reason. Both offer Play again (new random map) and Menu.
- Pause menu on Esc: Resume, Restart round, Menu.
- Hearts: enemy bullets and blasts cost one heart, followed by 1 s of blinking invulnerability. The dodge roll lets bullets pass through.
- All five guns: Pop Pistol, Brass Revolver, Scattershot (6 pellets), Fuse Launcher (rockets that can hurt you) and Gold Detonator (exploding bullets). Carry the pistol plus two more and switch with the mouse wheel or 1–3.
- Gun chests: hold E for half a second to open; they drop a C, B, A or S gun (50/30/15/5 %). Press E on a gun to take it.
- Grunt Kin, who keep their distance and shoot, and Fuse Kin, who run at you and explode.
- Dead enemies sometimes drop an ammo box (refills half the reserve) or a heart.
- Smoke bomb on Q clears every enemy bullet on screen.
- Placeholder rooms for the Boss Chamber, Labyrinth and Enemy Arena, with the map name shown at the start.
- `--map=boss|maze|arena` on the command line goes straight to that map.
- F3 shows a debug overlay: FPS, map, time left, player position and enemy count.
- Every finished round is written to runs.csv for playtest tuning.

### Removed
- The Part A test room; the placeholder maps replace it.

## v0.1.0 — 2026-10-19

### Added
- A test room with walls and pillars to run around in, with pixel-crisp graphics at 640×360.
- The hero: walks with WASD at 110 px/s, faces the mouse, and holds the Pop Pistol in a floating hand that aims at the cursor.
- The Pop Pistol: hold the left mouse button to fire 4 shots a second; 8-round magazine, infinite reserve, 1 s reload, automatic reload when empty, R to reload early.
- Dodge roll on Space or right mouse button: about 70 px in 0.45 s, untouchable for the first 0.35 s, 0.6 s cooldown.
- Game feel: walk bob and footstep squash, roll spin with dust puffs, muzzle flash, 2 px recoil kick, bullet impact sparks, and shell casings that bounce and stay on the floor.
- HUD with hearts, the current gun, ammo as magazine / reserve, and the smoke bomb count.
- The camera follows the player smoothly and stays inside the room.
