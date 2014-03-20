﻿/*Project: PacmanAuthors: Marc Pomar & Laura Cotrina.Description:	Ghost implementation for Inky, Blinky, Pinky and Clyde.*/package contingutsMultimedia{	import flash.geom.Point;	import flash.display.MovieClip;	import flash.display.Sprite;	import flash.utils.getDefinitionByName;	import contingutsMultimedia.Actor;	import contingutsMultimedia.Node;	import contingutsMultimedia.AStar;	import contingutsMultimedia.Constants;	import contingutsMultimedia.Mapa;	import flash.utils.Timer;    import flash.events.TimerEvent;    import flash.events.Event;	// Ghost player :-)	public class Ghost extends Actor {		// Variables		private var _status:String;		private var _lastPosition:Point;		// Path deployment		public var _star:AStar;		private var _path:Array;		// Timer for normal/fight		private var _timer:Timer;		// Timer for ghost fear mode		private var _fearTimer:Timer;		// Timer for jail		private var _jailTimer:Timer;		private var _inJail:Boolean;		// PUSH		public var _pushedDirection:Point;		// Pacman clip		private var _pacman:Actor;		private var _pushedStatus:String;		// Ghost graphics		var _ghostFearGraphic:MovieClip;		var _ghostNormalGraphic:MovieClip;		var _ghostEyesGraphic:MovieClip;		// DEBUG		private var _pathcheck:Sprite; // Debug variable path checker		private static const DEBUG_GHOST:Boolean = false;		// Constructor		public function Ghost(ghostName:String, ghostGraphicsClip:String, pacman:Actor,m:Mapa, pathcheck:Sprite){			// AStar finder			_star = new AStar(m, this);			_pacman = pacman;			_pathcheck = pathcheck;			_inJail = false;			// Path is empty array			_path = new Array();			_pushedStatus = null;			// Initialize ghost graphics			var definedImplementation:Class = getDefinitionByName(ghostGraphicsClip) as Class;      		_ghostNormalGraphic = new definedImplementation();			_ghostFearGraphic = new fantasmica_malo();			_ghostEyesGraphic = new fantasmica_ojos();      		// Scale ghost      		var scale:Number =  m.getTileSize() * 1.3 / _ghostNormalGraphic.width;      		_ghostNormalGraphic.scaleX = _ghostNormalGraphic.scaleY = scale;      		_ghostFearGraphic.scaleX = _ghostFearGraphic.scaleY = scale;      		_ghostEyesGraphic.scaleX = _ghostEyesGraphic.scaleY = scale;			var startPosition:Point = m.getJailPosition();			//var startPosition = new Point(15,15);			_lastPosition = new Point(startPosition.x, startPosition.y);			super(_ghostNormalGraphic, m, Constants.GHOST_SPEED, startPosition, ghostName);			resetGhost();		}		// Reset ghost behaviour		public function resetGhost(){			_path = new Array();			_inJail = false;			_pushedDirection = null;			// Normal ghost			setGraphicsImplement(_ghostNormalGraphic);			// Initial status			this.initializeGhostName(_name);			// Reset timer			if(_timer != null){				_timer.stop();			}			_timer = null;			this.updateTimers(null);			if(_pathcheck){				while (_pathcheck.numChildren > 0) {								_pathcheck.removeChildAt(0);				}			}		}		public function initializeGhostName(ghostName:String){			_name = ghostName;						// Set initial status			switch(_name){				case Constants.BLINKY:					_status = Constants.FIGHT;				break;				case Constants.INKY:					_status = Constants.FIGHT;				break;				case Constants.PINKY:					_status = Constants.NORMAL;				break;				case Constants.CLYDE:					_status = Constants.NORMAL;				break;				default:					_status = Constants.NORMAL;				break;			}		}		// Act ghost		public function actuate(){			// Updates ghost behaviour depending on state			this.updateGhostBehaviour();			// Checks jail timer and releases ghost			this.checkJail();			// Update actor			this.actorUpdate();			// Print path on screen			if(_path && DEBUG_GHOST){				// Clear graphics object				while (_pathcheck.numChildren > 0) {								_pathcheck.removeChildAt(0);				}				for(var i:uint; i < _path.length; i++){					var pathPoint:Sprite = new Sprite();					var pp:Point = map.tileToPixel(_path[i].getX(),_path[i].getY());					pathPoint.graphics.lineStyle(1);					pathPoint.graphics.beginFill(Constants.ghostColor(_name));					pathPoint.graphics.drawCircle(pp.x,pp.y,map.getTileSize()/6);					_pathcheck.addChild(pathPoint);				}			}		}		public function checkGameCollisions(){			// Check collision with pacman and dispatches events on collision			var t:Point = this.getCoordinates();			var p:Point = _pacman.getCoordinates();			if(Math.abs(p.x - t.x) < map.getTileSize() && Math.abs(p.y - t.y) < map.getTileSize()){				if(_status == Constants.GHOST_FEAR){					setGraphicsImplement(_ghostEyesGraphic);					dispatchEvent(new Event("eatGhost"));					debugGhost("Pacman eats");					_status = Constants.GO_INSIDE_JAIL;					_path = null;				}else if(_status == Constants.FIGHT || _status == Constants.NORMAL){					dispatchEvent(new Event("killPacman"));				}			}		}		override public function getNextMoveDirection(){			// Update ghost moveDirection based on next direction and current position			if(_pushedDirection != null){				if(this.setMoveDirection(_pushedDirection)){					//trace("Updated!!");					moveEyes(_pushedDirection); // Update ghost eyes					_pushedDirection = null;				}			}		}				override public function overflowTile(lastPos:Point){			if(_path){				if(_path.length > 0){					// Next node step					_pushedDirection = parseNode(_path.shift(),_position);					_lastPosition = lastPos;				}			}		}		public function parseNode(n:Node,lastPos:Point):Point{			if(n.getY() < lastPos.y){				return Constants.UP;			}else if(n.getY() > lastPos.y){				return Constants.DOWN;			}else if(n.getX() > lastPos.x){				return Constants.RIGHT;			}else if(n.getX() < lastPos.x){				return Constants.LEFT;			}			trace("Error parsing node!");			return new Point(0,0);		}		// Moves Ghost eyes to current moving direction		public function moveEyes(moveDirection){			if(moveDirection.equals(Constants.UP)){				_graphicsImplement.ojos.gotoAndStop(2);			}else if(moveDirection.equals(Constants.DOWN)){				_graphicsImplement.ojos.gotoAndStop(1);			}else if(moveDirection.equals(Constants.LEFT)){				_graphicsImplement.ojos.gotoAndStop(3);			}else{				_graphicsImplement.ojos.gotoAndStop(4);			}		}		public function setupPathTo(p:Point, ignoreNew:Boolean=false){			//trace("Setup path ->" + this.getPosition());			if(needNewPath() || ignoreNew){				_path = _star.findPath(this.getPosition(), p);				if(_path != null){					_path.shift();					_pushedDirection = parseNode(_path.shift(),_position);				}			}		}		// Updates ghost path		public function updateGhostBehaviour(){			// get pushed status			if(_pushedStatus != null){				_status = _pushedStatus;				_pushedStatus = null;			}			var rnd:Point;			switch(_status){				case Constants.NORMAL:					setSpeed(Constants.GHOST_SPEED);					this.setupPathTo(map.getRandomPoint(_position));					setGraphicsImplement(_ghostNormalGraphic);					break;				case Constants.GHOST_FEAR:					setSpeed(Constants.GHOST_SPEED);					this.setupPathTo(map.getRandomPoint(_position));					setGraphicsImplement(_ghostFearGraphic);					break;				case Constants.FIGHT:					this.setupPathTo(_pacman.getPosition(),true);					break;				case Constants.GO_INSIDE_JAIL:					this.setSpeed(Constants.GHOST_SPEED * 2);					this.setupPathTo(map.getJailPosition());					setGraphicsImplement(_ghostEyesGraphic);					break;			}		}		public function updateTimers(e:Event){			if (_timer == null){				_timer = new Timer(1000);				_timer.addEventListener("timer", updateTimers);			}			if(_status == Constants.FIGHT){				// Random timing mode depending on ghost				switch(_name){					case Constants.BLINKY:						_timer.delay = 3000;					break;					case Constants.INKY:						_timer.delay = 4000;					break;					case Constants.PINKY:						_timer.delay = 6000;					break;					case Constants.CLYDE:						_timer.delay = 4000;					break;					default:						_timer.delay = 6000;					break;				}				_pushedStatus = Constants.NORMAL;				debugGhost("Goes Random");			}else if(_status == Constants.NORMAL){				// Normal timing mode depending on ghost				switch(_name){					case Constants.BLINKY:						_timer.delay = 16000;					break;					case Constants.INKY:						_timer.delay = 6000;					break;					case Constants.PINKY:						_timer.delay = 7000;					break;					case Constants.CLYDE:						_timer.delay = 8000;					break;					default:						_timer.delay = 10000;					break;				}				_pushedStatus = Constants.NORMAL;				debugGhost("Goes Fight");			}			_timer.reset();			_timer.start();		}		// Checks if we need to update path		public function needNewPath(){			if(_path == null) return true;			if(_path.length == 0) return true;			return false;		}		// Checks if current actor can be moved to position p		override public function canMoveThru(p:Point){						//trace("GHOST CHECK" + p);			// Check wall			var tile:String = map.getTileAtPoint(p.x, p.y).getType();			if(tile == Constants.WALL){				return false;			}			// If p is equal to last position, we cannot move to this point			// This causes a ghost to cannot reverse direction			/*if(p.equals(_lastPosition) && _status != Constants.GO_INSIDE_JAIL){				return false;			}*/			return true;		}		public function checkJail(){			// Check if ghost is currently inside the jail					if(_status == Constants.GO_INSIDE_JAIL && map.getTileAtPoint(_position.x, _position.y).getType() == Constants.JAIL && !_inJail){				debugGhost("Jail timer starts!");				_inJail = true;				_jailTimer = new Timer(Constants.JAIL_TIME, 1);				_jailTimer.addEventListener("timer", function(){					_status = Constants.NORMAL;					debugGhost("Bye Jail!");				});				_jailTimer.start();			}else if (map.getTileAtPoint(_position.x, _position.y).getType() != Constants.JAIL){				_inJail = false;			}		}		public function setFear(){			// Reset timer if ghost is on fear and another fear event is called			if(_status == Constants.GHOST_FEAR){				_fearTimer.reset();			}			// If not in jail, go to fear mode and start timer			if(_status != Constants.GO_INSIDE_JAIL){				debugGhost("Fear ON!");				_status = Constants.GHOST_FEAR;				_timer.stop();				_fearTimer = new Timer(Constants.FEAR_TIME, 1);				_fearTimer.addEventListener("timer", function(){					if(_status == Constants.GHOST_FEAR){						_status = Constants.NORMAL;						debugGhost("Fear off :-( ");						_timer.start();					}				});				_fearTimer.start();			}		}		public function debugGhost(s:String){			trace("Ghost ["+_name+"] s["+_status+"] -> "+ s);		}	}}