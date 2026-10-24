# Changelog

## v0.12.0 — 2026-10-24

### Added
- Root, the new boss: a virus made of windows, with one huge eye that follows you and blinks, a crown of cursors and two cursor hands. Its error windows trail behind it like a cloak when it glides.
- Phase 1: Root glides to new spots in the upper half of the room and fires Belt Lash, two arcs of bullets that sweep across each other.
- Phase 2: it also fires Bullet Rain (a ring of 16 after a loading spinner) and teleports every 6 s: its windows close one by one, the eye shuts, the main window closes, and it opens again somewhere else, the eye opening last. It fires Bullet Rain right after.
- Phase 3: the five error windows fly off and fight on their own. Each keeps its distance, flashes its title bar before an aimed teal shot, teleports by itself, bursts into pixels when destroyed and comes back 6 s later. Only the main window hurts Root now; it teleports every 3.5 s, fires a ring after each teleport and an aimed burst in between.
- Root roars for 1.5 s between phases, and can't be hit while it roars, splits or teleports: bullets pass through.
- When Root dies its windows close one by one, the error windows vanish and it drops the code.
- The Boss Chamber is a dark station hall with a hazard ring on the floor, two broken lights, a wall screen and four red-lit pylons in its corners.

### Removed
- The Ammo Wraith.

## v0.11.0 — 2026-10-24

### Changed
- Fight, chest, start and exit rooms are now one of four station rooms, picked at random: a Control room, a Server hall, a Lab or a Storage room, each with its own floor, walls and objects. Corridors look like the room they lead from.
- The Labyrinth is a dark maze room and the Enemy Arena a hall with pillars and hazard stripes around the code chest. The Boss Chamber keeps its old look.
- North walls are tall wall faces with lamps, screens, vents and signs; other walls show their tops; inner walls and pillars have a short face.
- Crates are now room objects of the same size (server racks, tanks, desks, shelves, crate stacks). They still block movement and bullets exactly as before.
- Every room has a dark tint and coloured lights: warm lamps, glowing tanks and consoles, cold strip lights, and a broken light that slowly drifts between two colours and dims softly. The tint fades when you walk into another room.
- The Enemy Arena has a red alarm light slowly sweeping the hall; the Labyrinth has a few red emergency lights on its inner walls and keeps its darkness around you.
- Floors have random tile variants, grates, oil stains, debris, papers, cables and glowing puddles, and hazard stripes in front of doors.
- Bullets stay bright in dark rooms.

## v0.10.0 — 2026-10-23

### Changed
- Officer Kin are now Watchers: dome cameras on wheels with a siren. The lens sweeps while they patrol, and they stare and light up while they chase you.
- Rocket Kin are now Rams: heavy robots with a striped dozer blade. The visor flares while they shake before a charge.
- Wing Kin are now Trojans: flying pyramids with one eye and dangling cables, bobbing over their shadow. The eye opens wide half a second before the 3-bullet spread.
- Shade Kin are now Glitches: one-eyed ghost files, half see-through, floating smoothly over their shadow instead of flickering.
- Every 3–6 s a Glitch either twitches or teleports: it tears apart, is gone for a moment and appears again 50–90 px from you, with sparks at both places. It can't hurt you or be hit while teleporting.
- These four enemies leave their dying frame behind, fading out, when they die.

## v0.9.0 — 2026-10-23

### Changed
- New guns in the hand: the Pop Pistol, Brass Revolver, Scattershot, Fuse Launcher and Gold Detonator each have their approved sprite, held by the grip with bullets and the flash at the muzzle. Guns on the floor use the same sprites.
- The secret code is now a key: it floats up and down above a small shadow, in a soft golden glow, with a glint now and then.
- Gun chests are weapon cases: a red strip and padlock while locked, a gently pulsing teal strip and a green tick when ready. Opening, the lid lifts, teal light spills out and the chest's gun rises, then drops in front of it.
- The code chest is a vault in chains: at the unlock wave the chains break and fall and the padlock drops; opening, golden light shines out and the key rises, then drops in front of it.
- The Enemy Arena's two gun chests stay locked until the code chest unlocks.

### Removed
- Gun chests no longer change colour with the gun's rarity.

## v0.8.0 — 2026-10-23

### Changed
- The hero is now Telly, a walking TV: idle with blinking and a little breathing dip, walking front and back (the body sinks onto its legs on every step), and his screen is his face.
- Aiming down or level shows his front, aiming up shows his back; aiming left mirrors him.
- He holds the gun in one hand at the corner of the box on the aiming side: under the screen in front view, up by the ear (with the gun behind him) in back view. The gun turns around its grip and is never upside down.
- Shooting: the gun and the hand jump back 3 px, the muzzle kicks up, a 2-frame flash, and he shouts on his screen. Bullets come out of the muzzle.
- Reloading: the muzzle tips up and back down while a loading bar fills on his screen over the gun's reload time.
- Getting hit: a white flash, then X eyes. Dying: static, a dark screen, then he falls over; the end screen waits a little longer so you see it.
- The dodge roll shows only the TV tumbling head over heels with a small hop, no spinning; the timing, distance and invulnerability are the same.
- The Pop Pistol has a new drawing in the hand.

### Removed
- The second hand that sat on the gun.

## v0.7.0 — 2026-10-23

### Added
- A new password menu: an ASCII art television in green phosphor with a soft glow, faint scanlines, a slow sweeping band and a rare flicker. It boots up row by row out of noise, and a few characters shimmer all the time.
- Typing pops each digit into one of 4 code cells, with a blinking cursor and a burst of shimmer. Backspace erases; Enter or the TRY CODE button tries the code.
- A wrong code turns the cells and the button red, shakes the button and makes the TV shimmer harder, then clears the cells. The right code shows "ACCESS GRANTED" and goes straight into a round.
- The main menu is the same TV, with the title and PLAY and QUIT buttons; the chosen button lights up, and Up, Down and Enter work too.
- The TV fills the screen.
- The pause menu is an ASCII art panel in the same green phosphor (without the TV): it boots up and shimmers, with RESUME, RESTART ROUND and MENU; Up, Down and Enter choose, Esc resumes.

### Changed
- The right password now starts a round at once; the main menu is only reached from the Menu buttons.

## v0.6.0 — 2026-10-23

### Added
- The Ammo Wraith, the boss: 250 hit points in three phases. Belt Lash (two sweeping arcs of bullets), then Bullet Rain (rings of 16 bullets), then everything 1.3 times faster plus Fade (it teleports away and fires a ring). It stops and roars between phases. A health bar shows at the bottom of the screen.
- Beating the boss opens the door to an exit room; stepping on the exit wins the round.
- Tab shows a map of the rooms you have seen, the corridors between them and where you are.

### Changed
- Every round is one of three map types, picked at random: the Enemy Arena (a floor of rooms ending in the wave arena), the Labyrinth (one big dark maze again, with a 60–90 s shortest walk) or the Boss Chamber (a floor of rooms ending in the boss).
- Boss rounds have no timer: you only lose by dying.
- You always start in a room with one way out.
- Wing Kin no longer fly over walls, so they can't hover where your bullets can't reach them.
- The timer is 5:00 for the arena and the maze. To fit, the arena's code chest opens at wave 4, which is now the last wave, and floors have 5–6 rooms.
- The smoke bomb sends out a wave to the edge of the screen and shakes it, so you can see it work.
- Breaking free from handcuffs throws the officer back; he goes back to his patrol instead of catching you again.
- The Mash E prompt counts down the presses still needed.
- Movement is smooth on high refresh rate screens, and enemies plan their paths less often, so the game runs lighter.

### Fixed
- The arena no longer sends waves forever.
- An officer could handcuff you again the moment his stun ended if you stood still.

## v0.5.0 — 2026-10-23

### Added
- Every round is now a floor of 6–8 rooms joined by corridors, like Enter the Gungeon, with no loading between rooms. The last room is the objective: the Boss Chamber, the Labyrinth or the Enemy Arena, picked at random.
- Fight rooms: walking in closes the doors and enemies appear; the doors open once every enemy is dead. Deeper rooms send harder enemies.
- Chest rooms at dead ends, each with a gun chest.
- Gun chests are coloured by the rarity of the gun inside: bone C, teal B, brass A, red S.
- The Enemy Arena and the Boss Chamber are generated fresh every round too: mirrored crates and barrels in the arena (the code chest still stands at one of its four spots), four mirrored pillars in the boss room.

### Changed
- The Labyrinth is smaller (the shortest walk to the code takes 40–60 s) and the arena's code chest opens at wave 5, so a whole floor still fits the time target.
- `--map=boss|maze|arena` now picks the floor's objective room.
- The Labyrinth's darkness covers only the maze; the rest of the floor is lit.
- Guns and items lying on the floor are drawn small (the gun's in-hand drawing, half-size items); the HUD keeps the big drawings.
- The Boss Chamber placeholder is the spec's 30×20 tiles.

### Fixed
- Your bullets and enemy bullets no longer fly through walls.

## v0.4.0 — 2026-10-23

### Added
- The Labyrinth: a new maze every round with 2-tile corridors, the start in a corner and the code in the farthest spot. The shortest walk to the code takes 60–90 s (checked over 50 mazes).
- Darkness in the Labyrinth: you see only about 140 px around you.
- Officer Kin patrol the corridors and chase you for up to 4 s when you step into their view. If one touches you, you are handcuffed: mash E 10 times to break free with a knife slash. No heart is lost, the officer is stunned for 3 s, and officers can't catch you again for 3 s.
- Shade Kin drift slowly through walls, half see-through and flickering. Touching one costs a heart.
- A Wing Kin, a gun chest in one dead end and an hourglass in another: the hourglass adds 30 s to the timer, once per round.
- The run log counts how often you were handcuffed.

## v0.3.0 — 2026-10-23

### Added
- The game opens on a password screen; a wrong password shakes the field and clears it. It is asked once per launch.
- The Enemy Arena in full: a 48×32 hall with crates for cover, red barrels and two gun chests.
- Waves: a new wave every 30 s, or at once when fewer than 3 enemies are left; never more than 12 at a time. Enemies appear at the edges with a short red ring, never right next to you.
- The code chest stands at one of four spots and is chained shut until wave 7 starts; the HUD shows "Chest locked: wave X/7", then "Chest open!" as the chains fall off. Hold E for 2 s to open it; getting hit cancels it.
- Red barrels explode when shot: 8 damage to enemies, one heart off you, and nearby barrels go off one after another.
- Rocket Kin: wanders, shakes with a red aim line, then dashes until it hits something and is stunned. Touching it costs a heart.
- Wing Kin: flies over walls, keeps its distance, and fires a spread of 3 teal bullets.
- F also shoots, for Mac trackpads.
- A third floor tile with a chipped corner.
- The F3 overlay shows the arena wave.

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
