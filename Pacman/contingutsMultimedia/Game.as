/*
Project: Pacman
Authors: Marc Pomar & Laura Cotrina.
Description:
	Main game class, manages game objects, score, sound FX, etc.
*/

package contingutsMultimedia {	
	import flash.display.MovieClip;
	import flash.display.Sprite;

	import flash.geom.Point;
	import contingutsMultimedia.Pacman;
	import contingutsMultimedia.Ghost;
	import contingutsMultimedia.Mapa;
	import contingutsMultimedia.Constants;
	import contingutsMultimedia.Scoreboard;
	import contingutsMultimedia.Soundboard;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import flash.filters.BlurFilter;
	import flash.utils.Timer;
	import flash.events.TimerEvent;


	import com.gskinner.motion.GTween;
	import com.gskinner.motion.easing.*;
	import com.gskinner.motion.plugins.BlurPlugin;

	public class Game extends Sprite{

		private var _mapa:Mapa;
		private var _offset:Point;
		public var pacman:Pacman;
		public var ghosts:Array;
		public var names:Array = [Constants.BLINKY, Constants.INKY, Constants.PINKY, Constants.CLYDE];
		//public var names:Array = [Constants.CLYDE];
		//public var names:Array = new Array();
		public var paused:Boolean;
		public var _muted:Boolean;

		// DEBUG: Path checker 
		private var pcheckArray:Array = new Array();

		// Start position pacman
		var startPositionPacman:Point;

		// Sound objects
		var soundboard:Soundboard;

		// Scoreboard
		public var scoreboard:Scoreboard;

		// Graphics
		var gameOverGraphic:MovieClip;
		var replayButton:MovieClip;


		public function Game(gameMap:String){

			// Initialize blur plugin
			BlurPlugin.install();

			// Initialize ghosts
			ghosts = new Array();

			// Start map instance with map offset
			_offset = new Point(0,25);

			_mapa = new Mapa(gameMap, _offset);
			_mapa.dispatcher.addEventListener("eatPac", eventProcessor);
			_mapa.dispatcher.addEventListener("eatPowerUp", eventProcessor);
			_mapa.dispatcher.addEventListener("pacmanWins", eventProcessor);
			_mapa.dispatcher.addEventListener("mapaLoaded", function(e:Event){
				// When map loaded reset game and spawn characters
				resetGame();
			});
			this.addChild(_mapa.getGraphicsImplement()); // Add map clip and start listeners

			// Setup scoreboard (counts lives and scores)
			scoreboard = new Scoreboard();
			this.addChild(scoreboard);
			scoreboard.addEventListener("toggleMute", toggleMute);
			scoreboard.addEventListener(Event.ADDED_TO_STAGE, function(){
				scoreboard.reset(); // Reset Scoreboard
			});

			// Unmute on start
			_muted = false;

			// Soundboard
			soundboard = new Soundboard();
			soundboard.loadSounds();
			soundboard.playSound("BGS",true);

		}

		public function resetGame(gameOver:Boolean = false){

			trace("---- Reseting characters ----");
			
			// Remove frame listener
			removeEventListener(Event.ENTER_FRAME, frameUpdate);

			// Remove current ghosts & pacman
			if(pacman != null){
				_mapa.getGraphicsImplement().removeChild(pacman);
				pacman = null;
			}
			removeGhosts();
			
			if(gameOver){
				scoreboard.reset();
				_mapa.resetMap();
			}
			// Animate level text and reset game
			scoreboard.showMeTheLevel(function(){
				// Setup new pacman character
				startPositionPacman = new Point(13,23); // Pacman start position
				//startPositionPacman = new Point(1,1); // Pacman start position

				pacman = new Pacman("PacmanClip", _mapa, startPositionPacman);
				_mapa.getGraphicsImplement().addChild(pacman);

				// Create ghosts
				var ghost:Ghost;	
				for(var i:uint; i < names.length; i++){
					var pchecker:Sprite = new Sprite();
					pcheckArray.push(pchecker);
					ghost = new Ghost(names[i], Constants.graficImplementation(names[i]), pacman, _mapa, pchecker);
					ghost.addEventListener("eatGhost", eventProcessor);
					ghost.addEventListener("killPacman", eventProcessor);
					ghosts.push(ghost);
					_mapa.getGraphicsImplement().addChild(ghost);
					_mapa.getGraphicsImplement().addChild(pchecker);
				}

				// Unpause game
				paused = false;

				// Update characters and objects
				addEventListener(Event.ENTER_FRAME, frameUpdate);
			});
		}




		// Updates all objects of game
		public function frameUpdate(e:Event){
			if(!paused){

				// Check ghosts collisions with pacman
				var i:uint;
				for(i=0; i < ghosts.length; i++){
					ghosts[i].checkGameCollisions();
				}

				// Update pacman
				pacman.actuate();

				// Update ghosts
				for(i=0; i < ghosts.length; i++){
					ghosts[i].actuate();
				}

				// Map bright animation
				_mapa.animateSlices();
			}
		}

		// Eat event
		public function eventProcessor(e:Event){
			if(e.type == "eatPac"){
				scoreboard.addScore(10);
				soundboard.playSound(Constants.EVENT_EATPAC);
			}else if (e.type == "eatPowerUp"){
				scoreboard.addScore(50);
				trace("PowerUp!");
				soundboard.playSound(Constants.EVENT_EATPOWERUP);
				for(var i:uint; i < ghosts.length; i++){
					ghosts[i].setFear();
				}
			}else if (e.type == "eatGhost"){
				trace("Eat ghost +200");
				scoreboard.addScore(200);
				paused = true;
				soundboard.playSound(Constants.EVENT_EATGHOST);
				var eatGH:Timer = new Timer(350,1);
				eatGH.addEventListener(TimerEvent.TIMER, function(e:Event){
					paused = false;
				});
				eatGH.start();
			}else if (e.type == "killPacman"){
				trace("Ohh, sorry pacman!");
				soundboard.playSound(Constants.EVENT_PACMANDIES);
				paused = true;
				pacman.diePacman();
				removeGhosts();
				scoreboard.removeLive();
				pacman.addEventListener("pacmanDies", function(e:Event){
					if(scoreboard.hasLives()){
						resetGame();
					}else{
						gameOver();
					}					
				});
			}else if(e.type == "pacmanWins"){
				scoreboard.addLevel();
				resetGame();
				_mapa.resetMap();
			}
		}

		public function removeGhosts(){
			// Remove current ghosts & listeners
			var ghost:Ghost;
			while(ghost = ghosts.pop()){
				ghost.resetGhost(); // Make sure garbage collector removes timers
				ghost.removeEventListener("eatGhost", eventProcessor);
				ghost.removeEventListener("killPacman", eventProcessor);
				_mapa.getGraphicsImplement().removeChild(ghost);
			}
		}

		public function gameOver(){
			trace("GAME OVER");

			// Game over sound
			soundboard.stopAll();
			soundboard.playSound(Constants.EVENT_GAMEOVER);

			// Invisible pacman
			if(pacman){
				pacman.visible = false;
			}

			// Play gameover animation
			gameOverGraphic = new gameOverClip();
			this.addChild(gameOverGraphic);

			// Place in topcenter
			gameOverGraphic.x = (stage.stageWidth/2) - (gameOverGraphic.width/2);
			gameOverGraphic.y = -gameOverGraphic.height;

			// Tween gameover
			var tween:GTween = new GTween(gameOverGraphic,3.5,{y:(stage.stageHeight/2)-(gameOverGraphic.height/2)},
				{ease:Elastic.easeOut,
				onComplete: function(){
					// Add replay button
					replayButton = new replayBT();
					replayButton.x = (stage.stageWidth/2) - (replayButton.width/2);
					replayButton.y = (stage.stageHeight/2) + (gameOverGraphic.height/2) + 60;
					addChild(replayButton);
					replayButton.addEventListener(MouseEvent.CLICK, restartGame);
				}
			});

			// Blur tween for _mapa
			var blur:BlurFilter = new BlurFilter(0, 0, 2);
			_mapa.getGraphicsImplement().filters = new Array(blur);
			var tween2:GTween = new GTween(_mapa.getGraphicsImplement(),1,{blur:25},{ease:Sine.easeIn});

			// Tween for score
			scoreboard.showMeTheScore(new Point(
				(stage.stageWidth/2),
				(stage.stageHeight/2) + (gameOverGraphic.height/2)
			));
		}

		public function restartGame(e:Event){
			trace("RESTARTING GAME...");
			soundboard.playSound("BGS",true);

			// Remove filters;
			_mapa.getGraphicsImplement().filters = new Array();

			// Remove gameover
			removeChild(gameOverGraphic);
			removeChild(replayButton);

			resetGame(true);
		}

		public function toggleMute(e:Event){
			if(_muted){
				_muted = false;
				scoreboard.setMuteBt(false);
				soundboard.setMute(false);
			}else{
				_muted = true;
				scoreboard.setMuteBt(true);
				soundboard.setMute(true);
			}
		}

		// Detects key press
		public function detectKey(event:KeyboardEvent):void{
			if(pacman != null){
				switch (event.keyCode){
					case Keyboard.DOWN :
						pacman.updateMovement(Constants.DOWN);
						break;
					case Keyboard.UP :
						pacman.updateMovement(Constants.UP);
						break;
					case Keyboard.LEFT :
						pacman.updateMovement(Constants.LEFT);
						break;
					case Keyboard.RIGHT :
						pacman.updateMovement(Constants.RIGHT);
						break;
				}
			}
		}
	}
}