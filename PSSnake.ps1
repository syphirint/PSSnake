# Copyright (C) 2019 Syphirint
# This program is free software: you can redistribute it and/or modify it under the terms of the
# GNU General Public License as published by the Free Software Foundation, version 3.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along with this program.
#If not, see <https://www.gnu.org/licenses/>.

######################################################################################################################

# Some ideas taken from the game by CAKEbuilder found in # https://github.com/CAKEbuilder/Snake/blob/master/snake.ps1
# Haven't tried to run CAKEbuilder's script, so probably is much better than mine.
# This was an exercise for me to build the "simplest form(TM)" of the snake game.
# None of this code shows best code practices, or even good code practices.
# This code does not use any naming convention, or even a "just by seeing the variable name, I understand what is does".
# I tried to implement the game with an event that would trigger the game loop by using a timer (and not comparing the time), but the event would fail every time.

#########################################################################################################
# Do not use this code in production.																	#
# Do not use this code if you do not understand it.														#
# If you are brave enough, run this code in the console and not in the ISE. Otherwise will not work.	#
#########################################################################################################

# Let's get this done.

# Remove the console cursor (the blinky thing that you see in the console when you launch it normally).
# Some say it mitigates the console flashing so must be true
[console]::CursorVisible = $false;
# Create the piece de resistance, the snake. Well, atleast something that represents it: a list.
$snake = New-object System.Collections.ArrayList

# Now that the list (snake) is created, one needs to populate it with pieces.
# Maybe there is a better way to do this. Guess we'll never know.
$piece=@{};				# Create an generic array (that is defnitely not the correct name).
$piece["x"]=@(39);		# Create and populate the x-coordenate.
$piece["y"]=@(12);		# Create and populate the y-coordenate.
$a=$snake.Add($piece);	# Add the now created body piece to the end of the list.
# Repeat the above until your hearth desires.
$piece=@{}; $piece["x"]=@(38);$piece["y"]=@(12);
$a=$snake.Add($piece);
$piece=@{}; $piece["x"]=@(37);$piece["y"]=@(12);
$a=$snake.Add($piece);

# Define variables the necessary variables
$direction=$curdirection='right';	# Defines the initial movement direction.
$food=@{};							# Creates a food object just for precaution.
$interval=50;						# Sets the speed of the snake (indirectly). It is the sleep time between movement.
									# Not that it helps, as the snake slows down when it gets big.
									# Poor programming or difficulty in updating the console (I would bet on the firts one).

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
	for($i=0;$i-lt80;$i++){
		Write-Buffer -String '▄' -x $i -y 0;
	}
	# Draws both side section of the playing area using an extended ASCII character.
	for($i=1;$i-lt24;$i++){
		Write-Buffer -String '█' -x 0 -y $i;
		Write-Buffer -String '█' -x 79 -y $i;
	}
	# Draws the bottom section of the playing area using an extended ASCII character.
	for($i=0;$i-lt80;$i++){
		Write-Buffer -String '▀' -x $i -y 24;
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
	$x=Get-Random -Minimum 1 -Maximum 78;				# Get a pseudo-randomized x-coordenate.
	$y=Get-Random -Minimum 1 -Maximum 23;				# Get a pseudo-randomized x-coordenate.
	Write-Buffer -String '■' -x $x -y $y;				# Draw the food in the obtained position.
	$food["x"]=@($x);$food["y"]=@($y);					# Creation of the food piece (analogously to a snake body piece).
	
	# Write on console the coordinates of the food piece.
	[console]::setcursorposition(30,24);				# Set the invisible cursor to the desired position.
	Write-Host 'FOOD' $food.x ',' $food.y -NoNewline;	# Print the desired information.
}

# ***********************************
# Description:	Draws the initial screen of the game
# Inputs:		None
# Outputs:		None
# ***********************************
function HelloScreen {
	Clear-Host;													# Removes everything from the console.
	Board;														# Draws the playing area.
	Write-Buffer -String 'To Start Press Any Key' -x 28 -y 11;	# Prints the initial statement.
	$keytostart=[console]::readkey("noecho").Key;				# Wait for the user to press a button to start the game.
	Write-Buffer -String '                      ' -x 28 -y 11;	# Deletes the previously shown string by overwriting it with spaces.
}

# ***********************************
# Description:	Draws the final screen of the game
# Inputs:		None
# Outputs:		None
# ***********************************
function GameOverScreen {
	Write-Buffer -String 'Game Over' -x 32 -y 10;				# Prints Game Over on the console center.
	Write-Buffer -String 'Press R to Restart' -x 28 -y 12;		# Prints instructions to restart.
	Write-Buffer -String 'Press Esc to Quit' -x 28 -y 13;		# Prints instructions to quit.
	$keytofinish=[console]::readkey("noecho").Key;				# Awaites for user input.
	
	# Verifies what was the pressed key.
	switch($keytofinish){
		R{
			# Redefine the variables again to reset everything.
			$snake = New-object System.Collections.ArrayList
			$piece=@{}; $piece["x"]=@(39);$piece["y"]=@(12);
			$a=$snake.Add($piece);
			$piece=@{}; $piece["x"]=@(38);$piece["y"]=@(12);
			$a=$snake.Add($piece);
			$piece=@{}; $piece["x"]=@(37);$piece["y"]=@(12);
			$a=$snake.Add($piece);
			$piece=@{}; $piece["x"]=@(36);$piece["y"]=@(12);
			$a=$snake.Add($piece);
			$piece=@{}; $piece["x"]=@(35);$piece["y"]=@(12);
			$a=$snake.Add($piece);
			$piece=@{}; $piece["x"]=@(34);$piece["y"]=@(12);
			$a=$snake.Add($piece);
			#$timer=New-Object -TypeName Timers.Timer;
			$direction='right';
			$curdirection='right';
			$food=@{};
			
			HelloScreen;	# Start the game again.
			Food;			# Draws food again.
			Run-Main;		# Runs the game loop again, restarting the game again.
		}
		Escape{
			Clear-Host;		# Removes everything from the console.
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
	$headx=($snake[0].x | Select-Object -ExcludeProperty Value);	# Gets the snake's head x-coordenate as integer.
	$heady=($snake[0].y | Select-Object -ExcludeProperty Value);	# Gets the snake's head y-coordenate as integer.
	
	for ($i=1;$i-lt$size;$i++) {									# Goes through the body pieces looking for a colision
		if((($snake[$i].x | Select-Object -ExcludeProperty Value)-eq$headx) -and (($snake[$i].y | Select-Object -ExcludeProperty Value)-eq$heady)){
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
	[console]::setcursorposition(3,0)				# Set the cursor to the desired position.
	Write-Host 'SCORE: ' $snake.Count -NoNewline	# Prints the current score, a.k.a. number of body parts.
	
	# Decides where to set the "new head" of the snake according to the desired direction
	switch($dir){
		up{
			# Create a piece and decrease 1 from the head's y-coordenate.
			$piece=@{}; $piece["x"]=@(($snake[0].x | Select-Object -ExcludeProperty Value));$piece["y"]=@(($snake[0].y | Select-Object -ExcludeProperty Value)-1);
		}
		down{
			# Create a piece and add 1 from the head's y-coordenate.
			$piece=@{}; $piece["x"]=@(($snake[0].x | Select-Object -ExcludeProperty Value));$piece["y"]=@(($snake[0].y | Select-Object -ExcludeProperty Value)+1);
		}
		left{
			# Create a piece and decrease 1 from the head's x-coordenate.
			$piece=@{}; $piece["x"]=@(($snake[0].x | Select-Object -ExcludeProperty Value)-1);$piece["y"]=@(($snake[0].y | Select-Object -ExcludeProperty Value));
		}
		right{
			# Create a piece and add 1 from the head's x-coordenate.
			$piece=@{}; $piece["x"]=@(($snake[0].x | Select-Object -ExcludeProperty Value)+1);$piece["y"]=@(($snake[0].y | Select-Object -ExcludeProperty Value));
		}
	}
	
	# Now comes the tricky bit.
	# I could have used a linked list of some form or maybe I'm not using this list in the correct form, but here is goes.
	$snake.Reverse();		# Invert the order of the body pieces. Now the tail is the head and the head is the tail.
	$a=$snake.Add($piece);	# Add the freshly created piece at the end of the list.
	$snake.Reverse();		# Invert the order of the body pieces again. Now there is a new head, going where we want to.
	
	[console]::setcursorposition(3,24)							# Set the cursor to the desired position.
	Write-Host 'HEAD' $snake[0].x ',' $snake[0].y -NoNewline	# Print the current position of snake's head.
	
	$itiseatingherself=EatingOwnBody;	# Check if the snake is hungerly eating herself.
	
	# Checks if the head is in collision with the walls. Stay inside your enclosure snake!
	if(((($snake[0].x | Select-Object -ExcludeProperty Value) -lt 1) -or (($snake[0].x | Select-Object -ExcludeProperty Value) -gt 78)) -or ((($snake[0].y | Select-Object -ExcludeProperty Value) -lt 1) -or (($snake[0].y | Select-Object -ExcludeProperty Value) -gt 23)) -or $itiseatingherself){
		# Game Over, buuuhhhhhhhhh
		GameOverScreen;		# Shows the finishing screen. Sad.
	} else {
		# Now that we know that the snake is still in her enclosure, we need to make sure if she is eating.
		if((($snake[0].x | Select-Object -ExcludeProperty Value)-eq($food.x | Select-Object -ExcludeProperty Value)) -and (($snake[0].y | Select-Object -ExcludeProperty Value)-eq($food.y | Select-Object -ExcludeProperty Value))){
			# Seems she is eating good.
			Food;	# Give her more food so she can grow strong.
		} else {
			# This is the clever bit, if the snake is not eating, then its staying the same size. Disclaimer: I said clever, but it miles from being well implemented.
			# Remember that we added a new piece (new head) not so long ago.
			# If the snake is a piece longer, then its time to loose one piece to stay the same size.
			[int]$tempx=$snake[$snake.Count-1].x | Select-Object -ExcludeProperty Value;	# Get the last piece x-coordenate.
			[int]$tempy=$snake[$snake.Count-1].y | Select-Object -ExcludeProperty Value;	# Get the last piece y-coordenate.
			Write-Buffer -String ' ' -x $tempx -y $tempy;									# Overwrite the last piece with a space character.
			$snake.RemoveAt($snake.Count-1);												# Remove the last piece from the list.
		}
	}
	
	# Finaly we can print the snake.
	foreach ($coord in $snake) {
		[int]$tempx=$coord.x | Select-Object -ExcludeProperty Value;	# Get the last piece x-coordenate.
		[int]$tempy=$coord.y | Select-Object -ExcludeProperty Value;	# Get the last piece y-coordenate.
		Write-Buffer -String '■' -x $tempx -y $tempy;					# Draw the body piece at the obtained coordinates.
	}
}

# ***********************************
# Description:	Main game loop.
# Inputs:		None
# Outputs:		None
# ***********************************
function Run-Main {
	while(1-eq1){									# Infinite loop, duhh.
		if([console]::keyavailable){				# Check if there are keypresses saved in the keyboard's buffer.
			$key=[console]::readkey("noecho").Key;	# If so, read what key it was. This only takes onlly 1 key presse as FIFO.
			switch($key){							# Decides what Key is was.
				UpArrow{							# If the pressed key was Up Arrow we need to check if that is a valid direction.
					if($curdirection-ne'down'){		# If currect direction is Down, the snake cannot go up without going to the sides first.
						$direction='up';			# If the direction is valid, the direction can be changed.
						$curdirection=$direction;	# Now the currect direction is the same as the desired direction.
					}
				}
				DownArrow{							# Repeat for other directions.
					if($curdirection-ne'up'){
						$direction='down';
						$curdirection=$direction;
					}
				}
				LeftArrow{
					if($curdirection-ne'right'){
						$direction='left';
						$curdirection=$direction;
					}
				}
				RightArrow{
					if($curdirection-ne'left'){
						$direction='right';
						$curdirection=$direction;
					}
				}
				Escape{								# If the user presses Esc.
					Clear-Host;						# Removes everything from the console.
					exit;							# The game terminates.
				}
				P{									# When the user presses P.
					Write-Buffer -String 'Press Any Key to Continue' -x 26 -y 11;	# Prints the message how to continue.
					$pause=[console]::readkey("noecho").Key;						# Awaites for user input.
					Write-Buffer -String '                         ' -x 26 -y 11;	# Deletes the previous message by overwriting it with spaces.
				}
			}
		}
		Snake -dir $direction;			# Do your thing snake!
		sleep -Milliseconds $interval;	# Wait the initially defined time (in milliseconds) until next game cycle.
	}
}

# The following code only executes once to start the loop.
HelloScreen;	# Start the game again.
Food;			# Draws food again.
Run-Main;		# Runs the game loop again, restarting the game again.