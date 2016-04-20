# Space-Invaders-Game-in-MIPS-Assembly-Programming-Language

Download the the MIPS Simulator form Simulator Directory given in the source.


Phase 1: 
make alieans of 4 rows of 11 aliens and use the timer. Already finished this phase. (Will send you the code of first phase.use that code. proffesor has given that code.)

Phase 2: 
Laser cannon should be able to move left and right using the arrow keys on the keyboard. Maximum speed (motion period) should be controlled by a timer.
When the space bar is pressed, the Cannon should "fire" a laser pulse (extended ASCII code 0179) that moves up the screen one line every 17 milliseconds.
The cannon may not fire again until the pulse hits something or goes off the screen.
If the laser pulse encounters an Alien, it should "explode" and disappear on the following frame.
Each time an Alien is destroyed, the interval between alien moves should shorten. 44 aliens * 17msec = 0.748 seconds, 


Phase 3: Bombing.
Aliens should drop bombs assuming that the laser cannon is moving at its maximum rate.
In other words if the cannon is moving. predict which alien should drop a bomb so that it will hit the cannon.
If the cannon is stationary. Drop bombs from the alien immediately above the cannon. 
Bombs should emit from the lowest alien in the column, and should appears to drop from the third character (towards the back of the motion.
Bombs should fall at a constant speed.
bombs that make contact with the cannon, should kill the cannon.

Phase 4: 
Shields, Add some shields that the cannon can hide behind.
Each bomb hit from above (or cannon shot from below) should change the density of the bricks,
using 0219, 0178, 0177, 0176, and finally a space, to allow the shields to take a number of hits before failing.
Contact with an alien will destroy the touched character of the shield.


Phase 5: 
Add an alien "mothership that periodically flies across the top of the screen. Speed should be lower than max  cannon speed to allow the cannon to catch up, overtake and get off a laser shot. Laser shots should destroy it.
Add score keeping if you can. scores need not display until the game is over, or between waves of aliens,
This is the final project turn in.


Final
