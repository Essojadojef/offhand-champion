# offhand-champion

Offhand Champion is a platform fighter based around item combinations. 

This game was made with the latest stable version of the Godot Engine.
To play or modify it you need to have downloaded Godot Engine 2.1 for your
platform.
Add the game to the engine's project manager (press "Scan" and select the game
folder), then select the game from the list and press "Run".

## Gameplay

The focus of this game is PvP fighting in a freestyle manner.
Players can wield two weapons (and an utility item) at the same time.
Each weapon can perform a variety of attack using only the button they're
assigned to and the directional input (stick or WASD keys).

Opponents can be defeated by reducing their health to zero or by launching them
offscreen. Comboing an opponent will result in them being launched further and
further after every hit of the string.
This multiplier will cap at twice the default launch distance and will reset
after the opponent's stun runs out (0.5 seconds after the last hit received).

The game supports joypad and keyboard controls.
Press any button on the device of your choice to join the fight.
Your character will leave the game after loosing 3 lives.

The controls are explained more below this simplified table.
Action | Joypad | Keyboard
------ | ------ | --------
Move | Left Stick | WASD
Jump/Dodge | Left Bumper | Space
Use weapons | A/B (+ Left Stick) | J/I (+ WASD)
Use item | X | O
Throw weapon/item | Right Bumper + A/B/X | P + J/I/O

#### Basic controls

Tilt the left stick horizontally (A/D on keyboard) to move.
Press the left bumper (space on kb) to jump while on the ground and to dodge
while in midair.
Both on ground and in midair you can change the direction you're facing by
attacking while inputting that direction.

Your character can wield two weapons and you can choose which one to use by
pressing either A or B (J or I on kb).
Pressing a button that has no weapon assigned to it will make your character
perform an attack from their default moveset. If there is a weapon nearby, your
character will pick it up and attack with it instead.

There are also items you can use during combat. Press X (O on kb) to use an item
or to pick up one nearby.

#### Advanced controls

While in midair you can change your horizontal momentum by moving left and
right.
You can high-jump by jumping while holding the left stick up (W on kb) or dodge
from the ground by jumping while holding the left stick down (S on kb).

Each weapon has its own moveset and will perform different attacks depending on
various factors, one of them being the directional input.
The directional input is controlled by the position of the left stick (WASD on
kb) and can be set to 9 position (neutral, up, down, left, right and diagonals).
It also changes the direction of your dodges.

Some attacks can be performed by inputting a direction and an attack at the same
time.
Some attacks can also be charged by holding the attack button and aimed pressing
up or down.

If you want to throw away a weapon or an item you can do so by pressing right
bumper (P on kb) and the button the weapon or item is assigned to.

#### Other mechanics

Before joining the game you can choose one weapon to give to your character.



Weapons and items will periodically spawn on the stage.
When an item is about to spawn an icon and a timer will appear at the top of the
screen.
During this time you can hit the bells to change where the item will spawn.

## Future development

I'm sharing this project on Github because I don't want to work on it all by
myself. I would like to add more content to this game (weapons, items,
mechanics and more).

If you want to propose a change or an addition feel free to open an issue.
If you would like to help you can discuss on an issue or contribute with some
code.

Note: The assets inside the combomancy folder come from an old project of mine
and will probably be removed at some point.

#### Licenses

All the code is under the GNU GPLv3 license. You can read the license inside COPYING.

All the assets are under the CC-BY-4.0 license. You can read the license here:
https://creativecommons.org/licenses/by/4.0/.
