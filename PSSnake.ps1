# Copyright (C) 2019 Syphirint
# This program is free software: you can redistribute it and/or modify it under the terms of the
# GNU General Public License as published by the Free Software Foundation, version 3.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along with this program.
# If not, see <https://www.gnu.org/licenses/>.

######################################################################################################################

# Some ideas taken from the game by CAKEbuilder found in # https://github.com/CAKEbuilder/Snake/blob/master/snake.ps1
# Haven't tried to run CAKEbuilder's script, so probably is much better than mine.
# This was an exercise for me to build the "simplest form(TM)" of the snake game.
# None of this code shows best code practices, or even good code practices.
# This code does not use any naming convention, or even a "just by seeing the variable name, I understand what is does".
# I tried to implement the game with an event that would trigger the game loop by using a timer (and not comparing the time), but the event would fail every time.

#############################################################################################################################
# Do not use this code in production.																						#
# Do not use this code if you do not understand it.																			#
# Run this code in the console (either Command Prompt or Powershell Console) and not in the ISE. Otherwise will not work.	#
#############################################################################################################################

# Let's get this done.

# Remove the console cursor (the blinky thing that you see in the console when you launch it normally).
# Some say it mitigates the console flashing so must be true
[console]::CursorVisible = $false;

# Get console dimentions, so it can function in all sizes of consoles
$console_width=$Host.UI.RawUI.BufferSize.Width;
$console_height=$Host.UI.RawUI.WindowSize.Height;

# Create the piece de resistance, the snake. Well, atleast something that represents it: a list.
$snake = New-object System.Collections.ArrayList
# Create a timer to keep with time for game loop execution.
$timer=New-Object system.diagnostics.stopwatch
$timer.Start(); # Start the game loop timer.

# Now that the list (snake) is created, one needs to populate it with pieces.
# Maybe there is a better way to do this. Guess we'll never know.
$number_body_parts = 3;
for($i=0;$i-lt$number_body_parts;$i++){
    $piece=@{};												# Create an generic array (that is defnitely not the correct name).
    $piece["x"]=@([math]::round($console_width/2-$i));		# Create and populate the x-coordenate.
    $piece["y"]=@([math]::round($console_height/2));		# Create and populate the y-coordenate.
    $null=$snake.Add($piece);								# Add the now created body piece to the end of the list.
}

# Define variables the necessary variables
$direction=$curdirection='right';	# Defines the initial movement direction.
[int[]]$food=1,1;						# Creates a food object just for precaution.
$interval=80;						# Sets the speed of the snake. (Bigger number, slower snake).
$timer_e=0;							# Variable to store the time between game loop executions.

# ***********************************
# Description:	Writes a string of characters on the console, starting on the specified coordinates
# Inputs:		$String	- The string that the user wishes to print out
#				$x		- x-coordenate on console (in number of characters, not pixels)
#				$y		- y-coordenate on console (in number of characters, not pixels)
# Outputs:		None
# ***********************************
function Write-Buffer ([string] $String, [int] $x = 0, [int] $y = 0) {
	[console]::setcursorposition($x,$y)
	Write-Host $String -NoNewline
}

# ***********************************
# Description:	Draws the playing area in an unchanged "cmd" console (black console, not the powershell console in blue)
# Inputs:		None
# Outputs:		None
# ***********************************
function Board {
	Clear-Host							# Removes everything from the console.
	
	# Draws the top section of the playing area using an extended ASCII character.
	for($i=0;$i-lt$console_width;$i++){
		Write-Buffer -String '▄' -x $i -y 0;
	}
	# Draws both side section of the playing area using an extended ASCII character.
	for($i=1;$i-lt($console_height-1);$i++){
		Write-Buffer -String '█' -x 0 -y $i;
		Write-Buffer -String '█' -x ($console_width-1) -y $i;
	}
	# Draws the bottom section of the playing area using an extended ASCII character.
	for($i=0;$i-lt$console_width;$i++){
		Write-Buffer -String '▀' -x $i -y ($console_height-1);
	}
	
	[console]::setcursorposition(0,0);	# Places the invisible cursor in position 0,0.
										# This prevents the console to create one more line and scroll down.
}

# ***********************************
# Description:	Draws a food piece in the playing area
# Inputs:		None
# Outputs:		None
# ***********************************
function Food {
	$x=Get-Random -Minimum 1 -Maximum ($console_width-2);	# Get a pseudo-randomized x-coordenate.
	$y=Get-Random -Minimum 1 -Maximum ($console_height-2);	# Get a pseudo-randomized x-coordenate.
	Write-Buffer -String '■' -x $x -y $y;					# Draw the food in the obtained position.
	$food[0]=$x;$food[1]=$y;								# Creation of the food piece (analogously to a snake body piece).
}

# ***********************************
# Description:	Draws the initial screen of the game
# Inputs:		None
# Outputs:		None
# ***********************************
function HelloScreen {
	Clear-Host;																														# Removes everything from the console.
	Board;																															# Draws the playing area.
	Write-Buffer -String 'Press Any Key To Start' -x ([math]::round($console_width/2)-11) -y ([math]::round($console_height/2));	# Prints the initial statement.
	$keytostart=[console]::readkey("noecho").Key;																					# Wait for the user to press a button to start the game.
	Write-Buffer -String '						' -x ([math]::round($console_width/2)-11) -y ([math]::round($console_height/2));	# Deletes the previously shown string by overwriting it with spaces.
}

# ***********************************
# Description:	Draws the final screen of the game
# Inputs:		None
# Outputs:		None
# ***********************************
function GameOverScreen {
	Write-Buffer -String 'Game Over' -x ([math]::round($console_width/2)-5) -y ([math]::round($console_height/2)-3);				# Prints Game Over on the console center.
	Write-Buffer -String 'Press R to Restart' -x ([math]::round($console_width/2)-9) -y ([math]::round($console_height/2)-1);		# Prints instructions to restart.
	Write-Buffer -String 'Press Esc to Quit' -x ([math]::round($console_width/2)-9) -y ([math]::round($console_height/2));			# Prints instructions to quit.
	$keytofinish=[console]::readkey("noecho").Key;																					# Awaites for user input.

	# Verifies what was the pressed key.
	switch($keytofinish){
		R{
			# Redefine the variables again to reset everything.
			$snake = New-object System.Collections.ArrayList
			for($i=0;$i-lt$number_body_parts;$i++){
                $piece=@{};												# Create an generic array (that is defnitely not the correct name).
                $piece["x"]=@([math]::round($console_width/2-$i));		# Create and populate the x-coordenate.
                $piece["y"]=@([math]::round($console_height/2));		# Create and populate the y-coordenate.
                $null=$snake.Add($piece);								# Add the now created body piece to the end of the list.
            }
			$direction=$curdirection='right';
			
			HelloScreen;	# Start the game again.
			Food;			# Draws food again.
			# Print the snake again.
			foreach ($coord in $snake) {
				Write-Buffer -String '■' -x (([int[]]$coord.x)[0]) -y ([int[]]$coord.y)[0];	# Draw the body piece at the obtained coordinates.
			}
			Run-Main;		# Runs the game loop again, restarting the game again.
		}
		Escape{
			Clear-Host;		# Removes everything from the console.
			$timer.Stop();	# Stops the game loop timer.
			exit;			# Stops the game.
		}
		default{
			GameOverScreen;	# Jesus! Is this thing recursive?!? Best of luck in your future endevours and controling the beast.
		}
	}
}

# ***********************************
# Description:	Checks if the snake is eating its own body
# Inputs:		None
# Outputs:		boolean
# ***********************************
function EatingOwnBody {
	$size=$snake.Count;												# Gets the snake size (number of body pieces).
	$headx=(([int[]]($snake[0].x))[0]);								# Gets the snake's head x-coordenate as integer.
	$heady=(([int[]]($snake[0].y))[0]);								# Gets the snake's head y-coordenate as integer.
	
	for ($i=1;$i-lt$size;$i++) {									# Goes through the body pieces looking for a colision
		if((([int[]]($snake[$i].x))[0]-eq$headx) -and (([int[]]($snake[$i].y))[0]-eq$heady)){
			return $true;											# If there is a colision, returns boolean true. And you thought that I didn't know that functions return things. 
		}
	}
}

# ***********************************
# Description:	Does the snake's behaviour. Atleast some part of it
# Inputs:		$dir	- desired direction for the snake (default value is 'right')
# Outputs:		None
# ***********************************
function Snake ([string] $dir='right') {	
	# Decides where to set the "new head" of the snake according to the desired direction
	switch($dir){
		up{
			# Create a piece and decrease 1 from the head's y-coordenate.
			$piece=@{}; $piece["x"]=@(([int[]]($snake[0].x))[0]);$piece["y"]=@(([int[]]($snake[0].y))[0]-1);
		}
		down{
			# Create a piece and add 1 from the head's y-coordenate.
			$piece=@{}; $piece["x"]=@(([int[]]($snake[0].x))[0]);$piece["y"]=@(([int[]]($snake[0].y))[0]+1);
		}
		left{
			# Create a piece and decrease 1 from the head's x-coordenate.
			$piece=@{}; $piece["x"]=@(([int[]]($snake[0].x))[0]-1);$piece["y"]=@(([int[]]($snake[0].y))[0]);
		}
		right{
			# Create a piece and add 1 from the head's x-coordenate.
			$piece=@{}; $piece["x"]=@(([int[]]($snake[0].x))[0]+1);$piece["y"]=@(([int[]]($snake[0].y))[0]);
		}
	}
	$snake.Insert(0,$piece); # Prepend the new head in the list.
	
	$itiseatingherself=EatingOwnBody;		# Check if the snake is hungerly eating herself.
    $headx=(([int[]]($snake[0].x))[0]);		# Gets the snake's head x-coordenate as integer.
	$heady=(([int[]]($snake[0].y))[0]);		# Gets the snake's head y-coordenate as integer.
	
	# Checks if the head is in collision with the walls. Stay inside your enclosure snake!
	if((($headx -lt 1) -or ($headx -gt ($console_width-2))) -or (($heady -lt 1) -or ($heady -gt ($console_height-2))) -or $itiseatingherself){
		# Game Over, buuuhhhhhhhhh
		GameOverScreen;		# Shows the finishing screen. Sad.
	} else {
		# As the head did not eat any of snakes elements nor hit a wall, print its head.
		Write-Buffer -String '■' -x $headx -y $heady; # Print the snake's head.
		# Now that we know that the snake is still in her enclosure, we need to make sure if she is eating.
		if(($headx-eq$food[0]) -and ($heady-eq$food[1])){
			# Seems she is eating good.
			Food;	# Give her more food so she can grow strong.
		} else {
			# This is the clever bit, if the snake is not eating, then its staying the same size. Disclaimer: I said clever, but it miles from being well implemented.
			# Remember that we added a new piece (new head) not so long ago.
			# If the snake is a piece longer, then its time to loose one piece to stay the same size.
            $tail=$snake.Count-1;																		# Get the last element of the snake.
			Write-Buffer -String ' ' -x (([int[]]$snake[$tail].x)[0]) -y (([int[]]$snake[$tail].y)[0]);	# Overwrite the last piece with a space character.
			$snake.RemoveAt($tail);																		# Remove the last piece from the list.
		}
	}
}

# ***********************************
# Description:	Main game loop.
# Inputs:		None
# Outputs:		None
# ***********************************
function Run-Main {
	while(1-eq1){											# Infinite loop, duhh.
		# If the necessary time has elapsed, then the game can execute another game loop.
		if($timer.ElapsedMilliseconds-$timer_e -gt $interval){
			if([console]::keyavailable){					# Check if there are keypresses saved in the keyboard's buffer.
				$key=[console]::readkey("noecho").Key;		# If so, read what key it was. This only takes onlly 1 key presse as FIFO.
				switch($key){								# Decides what Key is was.
					UpArrow{								# If the pressed key was Up Arrow we need to check if that is a valid direction.
						if($curdirection-ne'down'){			# If currect direction is Down, the snake cannot go up without going to the sides first.
							$curdirection=$direction='up';	# If the direction is valid, the direction can be changed. The currect direction is the same as the desired direction.
						}
					}
					DownArrow{								# Repeat for other directions.
						if($curdirection-ne'up'){
							$curdirection=$direction='down';
						}
					}
					LeftArrow{
						if($curdirection-ne'right'){
							$curdirection=$direction='left';
						}
					}
					RightArrow{
						if($curdirection-ne'left'){
							$curdirection=$direction='right';
						}
					}
					Escape{									# If the user presses Esc.
						Clear-Host;							# Removes everything from the console.
						$timer.Stop();						# Stop the game loop timer.
						exit;								# The game terminates.
					}
					P{										# When the user presses P.
						Write-Buffer -String 'Press Any Key to Continue' -x ([math]::round($console_width/2-13)) -y ([math]::round($console_height/2));	# Prints the message how to continue.
						$pause=[console]::readkey("noecho").Key;																						# Awaites for user input.
						Write-Buffer -String '						   ' -x ([math]::round($console_width/2-13)) -y ([math]::round($console_height/2));	# Deletes the previous message by overwriting it with spaces.
					}
				}
			}
			$timer_e=$timer.ElapsedMilliseconds;			# Save current time for next comparison.
			Snake -dir $direction;							# Do your thing snake!
		}
		sleep -Milliseconds 1;								# Sleep for 1 ms in order to not overload the processor.
	}
}

# The following code only executes once to start the loop.
HelloScreen;	# Start the game again.
Food;			# Draws food again.
# Print the snake.
foreach ($coord in $snake) {
	Write-Buffer -String '■' -x (([int[]]$coord.x)[0]) -y ([int[]]$coord.y)[0];	# Draw the body piece at the obtained coordinates.
}
Run-Main;		# Runs the game loop again, restarting the game again.