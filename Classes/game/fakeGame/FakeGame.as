/******************
 * Header Comments
 * @author Michael Yee
 * @date 3/14/14
 * @etc....
 */

package stmath.game.fakeGame
{

	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.*;
	import flash.net.SharedObject;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	public class FakeGame extends Sprite
	{
		private var myOtherNumber:Number;
		private var myNumber:Number:
		private var myNumber2:Number;
		private var a:Number;
		private var b:Number;
		private var c:Number;
		private var d:Number;
		private var e:Number;
		
		private var _accuracyBox:*;
		private var _speedBox:*;
		private var _newFluencyBox:*;
		private var _autoAccelerateBox:*;
		
		private var b:*;
		
		private var _txtFmt:*;
		
		private var _garbageCan:Array = [];
		
		// Constructor 
		public function FakeGame() 
		{		
			
		}
		
		override public function getArenaHeight():Number
		{
			return 640;
		}
		
		override public function getBackgroundColor():uint
		{
			return 0x0066FF;
		}
		
		/////////////////////////////////////////////////
		///////     BEGIN TESTING PARTS        //////////
		/////////////////////////////////////////////////
		
		
		public function buildTestPuzzleDefList( levelIndex:int, levelName:String ):XMLList
		{
			var testDefs_Level0:XMLList = 
			<>
				
			</>
			return testDefs_Level0;
		}
		
		public function getTestLevelCount():int {
			return 1;
		}
		
		override public function getTestPuzzleFactory( isInQAMode:Boolean ):*
		{
			return this;
		}
		
		
		///////////////////////////////////////////////
		///////     END TESTING PARTS        //////////
		///////////////////////////////////////////////
		
		
		public function initGame():void
		{
			
			_txtFmt = new TextFormat();
			_txtFmt.size = 18;
			_txtFmt.font = "Tahoma";
			_txtFmt.align = "center";
			_txtFmt.leading = 0;
			_txtFmt.color = 0x000000;
			
			var def:XML = <def nums="448,289" op="-" fillIn="1" notation="long" introAnimation="1"/>;
			constructGame(def);
		}
		
	
		public function constructGame( puzDef:XML ):void
		{
			
			try
			{
				var curLevKey:* = getLevelInfoObject().getCurricDefPointer().getFileRefKey();
				var resLookupDictionary:* = getLevelInfoObject().getCurricDef().getOption( "objNavResLookup" ,null);
				var filePath:String = RegExp(/(level\/[^\)]+)\)/).exec(resLookupDictionary[curLevKey])[1];
				trace(filePath);
				var so:* = SharedObject.getLocal("EditTimeAssets/EditTimePRF", "/");
				var prefs:* = so.data.prefs;
				prefs.testLevelDefs = [filePath];
				so.data.prefs = prefs;
				so.flush();
				trace("Fake Game Constructing: " + curLevKey);
			}
			catch (e:Error)
			{
				trace("EditTimePrefs NOT changed");
			}
			
			
			try {
				initArena();
				
				var loadingGameTxt:* = this.getChildByName("loadingGameTxt");
				if(!loadingGameTxt) {
					var titleTxtFmt:* = new TextFormat();
					titleTxtFmt.size = 42;
					titleTxtFmt.color = 0x000000;
					titleTxtFmt.font = getFontNameForKey("TahomaBold");
					titleTxtFmt.align = "center";
				
					loadingGameTxt = createTextField("Loading Game",titleTxtFmt);
					loadingGameTxt.name = "loadingGameTxt";
					loadingGameTxt.x = 320 - (loadingGameTxt.width/2);
					loadingGameTxt.y = 50;
					this.addChild(loadingGameTxt);
				}
				
				
				var spinner:* = this.getChildByName("spinner");
				if(!spinner) {
					spinner = new LoadingIndicator(this);
					spinner.name = "spinner";
					spinner.x = 320;
					spinner.y = loadingGameTxt.y + loadingGameTxt.height + 35;
					this.addChild(spinner);
				}
				spinner.animate();
				
				
				var customDatPanel:* = this.getChildByName("customDatPanel");
				if(!customDatPanel) {
					customDatPanel = new Sprite();
					customDatPanel.name  = "inputPanel";
					
					_accuracyBox = createInputLabel("accuracy:","1");
					_speedBox = createInputLabel("speed:","-1");
					_newFluencyBox = createInputLabel("newFluencyLevel:","1");
					_autoAccelerateBox = createCheckBoxLabel("autoAccelerate:");
					
					var maxWidth:* = Math.max(_newFluencyBox.width,Math.max(_accuracyBox.width,_speedBox.width));
					_accuracyBox.x =  maxWidth - _accuracyBox.width;
					_accuracyBox.y = 0;
					customDatPanel.addChild(_accuracyBox);
					
					_speedBox.x = _accuracyBox.x + _accuracyBox.width - _speedBox.width;
					_speedBox.y = _accuracyBox.y + _accuracyBox.height + 2;
					customDatPanel.addChild(_speedBox);
					
					_newFluencyBox.x = _accuracyBox.x + _accuracyBox.width - _newFluencyBox.width;
					_newFluencyBox.y = _speedBox.y + _speedBox.height + 2;
					customDatPanel.addChild(_newFluencyBox);
					
					_autoAccelerateBox.x = _accuracyBox.x + _accuracyBox.width - _autoAccelerateBox.width;
					_autoAccelerateBox.y = _newFluencyBox.y + _newFluencyBox.height + 4;
					customDatPanel.addChild(_autoAccelerateBox);
					
					var customDatButt:* = createButton("Custom\nData",0xFFFFFF,150,75);
					customDatButt.name = "customDatButt";
					customDatButt.x = customDatPanel.width + 10;
					customDatButt.y = 0;
					customDatPanel.addChild(customDatButt);
					
					customDatPanel.x = 320 - (customDatPanel.width/2);
					customDatPanel.y = 50;
					this.addChild(customDatPanel);
				}
				customDatPanel.mouseEnabled = false;
				customDatPanel.mouseChildren = false;
				customDatPanel.visible = false;
				
				
				/////				
				var debugPanel:* = this.getChildByName("debugPanel");
				if(!debugPanel) {
					debugPanel = new Sprite();
					debugPanel.name = "debugPanel";
					this.addChild(debugPanel);
					
					//////
					var panelTitleTxtFmt:* = new TextFormat();
					panelTitleTxtFmt.size = 24;
					panelTitleTxtFmt.font = getFontNameForKey("Tahoma");
					panelTitleTxtFmt.color = 0xFFFFFF; //0x000000;
					panelTitleTxtFmt.align = "center";
				
					var titleTxt:* = createTextField("Debug Utils:",panelTitleTxtFmt);
					titleTxt.name = "titleTxt";
					titleTxt.x = -titleTxt.width/2;
					titleTxt.y = 5;
					debugPanel.addChild(titleTxt);
					
					//////
					var gamePassPanel:* = new Sprite();
					gamePassPanel.name = "gamePassPanel";
					
					var abortButt:* = createButton1("ABORT");
					abortButt.name = "abortButt";
					abortButt.x = 0;
					gamePassPanel.addChild(abortButt);
				
					var passButt:* = createButton1("PASS");
					passButt.name = "passButt";
					passButt.x = abortButt.x + abortButt.width + 10;
					gamePassPanel.addChild(passButt);
					
					var failButt:* = createButton1("FAIL");
					failButt.name = "failButt";
					failButt.x = passButt.x + passButt.width + 10;
					gamePassPanel.addChild(failButt);
					
					gamePassPanel.visible = true;
					gamePassPanel.x = -gamePassPanel.width/2;
					gamePassPanel.y = titleTxt.y + titleTxt.height + 10;
					debugPanel.addChild(gamePassPanel);
					
					//////
					var probeTitleTxt:* = createTextField("Probes:",panelTitleTxtFmt);
					probeTitleTxt.name = "probeTitleTxt";
					probeTitleTxt.x = -probeTitleTxt.width/2;
					probeTitleTxt.y = gamePassPanel.y + gamePassPanel.height + 10;
					debugPanel.addChild(probeTitleTxt);
					
					//////
					var probePanel:* = new Sprite();
					probePanel.name = "probePanel";
						
					var factProbeButt:* = createButton1("Fact",140);
					factProbeButt.name = "addFactProbeButt";
					factProbeButt.x = 0;
					probePanel.addChild(factProbeButt);
						
					var readNumProbeButt:* = createButton1("Read Num",140);
					readNumProbeButt.name = "readNumProbeButt";
					readNumProbeButt.x = 10 + factProbeButt.x + factProbeButt.width;
					probePanel.addChild(readNumProbeButt);
						
					var writeNumProbeButt:* = createButton1("Write Num",140);
					writeNumProbeButt.name = "writeNumProbeButt";
					writeNumProbeButt.x = 10 + readNumProbeButt.x + readNumProbeButt.width;
					probePanel.addChild(writeNumProbeButt);
						
					probePanel.x = -probePanel.width/2;
					probePanel.y = probeTitleTxt.y + probeTitleTxt.height + 5;
					debugPanel.addChild(probePanel);
					
					
					/////
					debugPanel.graphics.lineStyle(2,0x000000);
					debugPanel.graphics.beginFill(0x000000,.5);
					debugPanel.graphics.drawRoundRect((-debugPanel.width/2)-20,0,debugPanel.width+40,debugPanel.height+15,15);
					debugPanel.graphics.endFill();
					debugPanel.scaleX = .6;
					debugPanel.scaleY = .6;
					debugPanel.x = 320;
					debugPanel.y = 448 - 25 - debugPanel.height;
				}
				this.addChild(debugPanel);
				
				var dot:* = new Sprite();
				dot.name = "dot";
				var dotg:Graphics = dot.graphics;
				dotg.beginFill(0);
				dotg.drawCircle(0,0,20);
				dot.x = 200+Math.random()*5;
				dot.y = 200+Math.random()*5;
				
				dot.addEventListener(MouseEvent.MOUSE_DOWN, dotDown);
				
				this.addChild(dot);
				
				_garbageCan.push(dot);
				
				
				var cross:* = new Sprite();
				cross.name = "cross";
				var crossG:Graphics = cross.graphics;
				crossG.beginFill(0);
				crossG.drawRect(-2,-10,4,20);
				crossG.drawRect(-10,-2,20,4);
				
				
				this.addChild(cross);
				
				_garbageCan.push(cross);
				
				finishedConstructing(true);
			}
			catch(error:Error) {
				finishedConstructing(error);
			}
			
		}
		
		private function dotDown(evt:*):void
		{
			var dot:* = evt.target;
			var listenerSprite:* = new Sprite();
			listenerSprite.name = listenerSprite;
			listenerSprite.alpha = 0;
			listenerSprite.graphics.beginFill(0x000000,1);
			listenerSprite.graphics.drawRect(0,0,640,448);
			listenerSprite.graphics.endFill();
			this.addChild(listenerSprite);
				
			listenerSprite.addEventListener(MouseEvent.MOUSE_UP, dotUp);
			listenerSprite.addEventListener(MouseEvent.MOUSE_MOVE, dotMove);
			_garbageCan.push(listenerSprite);
		}
		
		private function dotUp(evt:*):void
		{
			dotMove(evt);
			var listenerSprite:Sprite = evt.target;
			listenerSprite.removeEventListener(MouseEvent.MOUSE_UP, dotUp);
			listenerSprite.removeEventListener(MouseEvent.MOUSE_MOVE, dotMove);
			this.removeChild(listenerSprite);
		}
		
		private function dotMove(evt:MouseEvent):void
		{
			var dot:* = this.getChildByName("dot");
			dot.x = evt.localX;
			dot.y = evt.localY;
		}
		
		private function initArena():void {			
			
		}
		
		override public function startArena():void
		{
			setMouseBlocking(false);
			
			moveCrossDown();
		}
		
		private function moveCrossDown():void
		{
			var cross:* = this.getChildByName("cross");
			if(cross)
			{
				tweenThenCall( cross, ["x","y"], 0, [640,448], null, 3, moveCrossBack );
			}
		}
		
		private function moveCrossBack():void
		{
			var cross:* = this.getChildByName("cross");
			if(cross)
			{
				tweenThenCall( cross, ["x","y"], [640,448], 0 , null, 3, moveCrossDown );
			}
		}
		
		
		/***
		* Function: cleanUpArena
		* Parameters: none
		* Description:
		*
		***/
		public override function cleanUpArena():void {
			for(var i:int=0; i<_garbageCan.length; i++) {
				if(_garbageCan[i].parent) {
					_garbageCan[i].parent.removeChild(_garbageCan[i]);
				}
			}
			_garbageCan.splice(0,_garbageCan.length);
		}
		
		
		
		/////////////////////////
		//
		// HANDLERS
		//
		////////////////////////
		
		private function checkBoxClicked(e:MouseEvent):void {
			var checkBox:* = e.target as Sprite;
			var checker = checkBox.getChildByName("checker");
			checker.visible = !checker.visible;
		}
		
		private function buttRolledOver(e:MouseEvent):void {
			var butt:* = e.target as Sprite;
			butt.getChildByName("over").visible = true;
			butt.getChildByName("out").visible = false;
		}
		
		private function buttRolledOut(e:MouseEvent):void {
			var butt:* = e.target as Sprite;
			butt.getChildByName("over").visible = false;
			butt.getChildByName("out").visible = true;
		}
		
		private function buttSelected(e:MouseEvent):void {
			var isProbe:Boolean = (e.target.name.split("Probe").length>1);
			if(isProbe) {
				if(e.target.name == "addFactProbeButt") {
					generateBasicFactProbe(true,true);
				}
				else if(e.target.name == "readNumProbeButt") {
					generateReadingWholeNumberProbe(true,true);
				}
				else if(e.target.name == "writeNumProbeButt") {
					generateWritingWholeNumberProbe(true,true);
				}
			}
			else {
				buttRolledOut(e);
				
				var i:uint;
				var sceneDescription:*;
				if(e.target.name == "abortButt") {
					abortEntireArena( new Error("ABORT") ); 
					return;
				}
				else if(e.target.name =="passButt") {
					for(i=0; i<8; i++) generateRandomProbe(true);
					//sceneDescription = '<desc sceneType="gameUpdateSelection" accuracy="1" speed="1" newFluencyStage="1" autoAcceleration="0"/>';
				}
				else if(e.target.name == "failButt") {
					for(i=0; i<8; i++) generateRandomProbe(false);
					
					/*
					var randomAccuracy = Math.random();
					while(randomAccuracy == 1) randomAccuracy = Math.random();
					var randomSpeed = Math.random();
					sceneDescription = '<desc sceneType="gameUpdateSelection" accuracy="'+randomAccuracy+'" speed="'+randomSpeed+'" newFluencyStage="1" autoAcceleration="0"/>';
					*/
				}
				else if(e.target.name == "customDatButt") {
					var accuracyInput:* = TextField(_accuracyBox.getChildByName("inputBox")).text;
					var speedInput:* = TextField(_speedBox.getChildByName("inputBox")).text;
					var newFluencyInput:* = TextField(_newFluencyBox.getChildByName("inputBox")).text;
					var autoAcceleration:* = (Sprite(_autoAccelerateBox.getChildByName("checkBox")).getChildByName("checker").visible)?1:0;
					sceneDescription = '<desc sceneType="gameUpdateSelection" accuracy="'+accuracyInput+'" speed="'+speedInput+'" newFluencyStage="'+newFluencyInput+'" autoAcceleration="'+autoAcceleration+'"/>';
				}
				//trace(sceneDescription);
				
				
				puzzleOver(true);
				
			}
		}
		
		/////////////////////////////////////////////////////
		//-------Arena-Specific Methods--------------------//
		////////////////////////////////////////////////////
		
		private function generateReactionTime(correct:Boolean,rand:Boolean=false):* {
			var reactionTime:* = Math.random();
			if(rand) {
				if(reactionTime < 0.1) return 1000;
				else if(reactionTime < 0.5) return (Math.random()*2000);
				else return 2000;
			}
			else {
				if(correct) return 2000;
				else {
					while(reactionTime==1) reactionTime=Math.random();
					return reactionTime*2000;
				}
			}
		}
		
		private function generateAccuracy(correct:Boolean,rand:Boolean=false):* {
			var accuracy:* = Math.random();
			if(rand) {
				if(accuracy < 0.1) return 0;
				else if(accuracy < 0.5) return Math.random();
				else return 1;
			}
			else {
				if(correct) return 1;
				else {
					while(accuracy==1) accuracy = Math.random();
					return accuracy;
				}
			}
		}
		
		private function generateRandomProbe(correct:Boolean,rand:Boolean=false):void {
			var probeType:* = Math.random();
			if(probeType<=0.33) generateBasicFactProbe(correct,rand);
			else if(probeType<=.66) generateReadingWholeNumberProbe(correct,rand);
			else generateWritingWholeNumberProbe(correct,rand);
		}
		
		
		private function generateBasicFactProbe(correct:Boolean,rand:Boolean=false):void {
			var diffFactor:* = 1;
			var reactionTime:* = generateReactionTime(correct,rand);
			var accuracy:* = generateAccuracy(correct,rand);
			
			var num0:* = Math.round(Math.random()*9);
			var num1:* = Math.round(Math.random()*9);
			var op:* = "*";
			trace("generating basic fact probe: " + num0 + " " + op + " " + num1 + " accuracy: " + accuracy + " reactionTime: " + reactionTime);
			addBasicFactProbe(num0,num1,op,accuracy,reactionTime,diffFactor);
		}
		
		private function generateReadingWholeNumberProbe(correct:Boolean,rand:Boolean=false):void {
			var diffFactor:* = 1;
			var reactionTime:* = generateReactionTime(correct,rand);
			var accuracy:* = generateAccuracy(correct,rand);
			
			var num:* = Math.round(Math.random()*10);
			trace("generating reading num probe: " + num + " accuracy: " + accuracy + " reactionTime: " + reactionTime);
			addReadingWholeNumberProbe( num, accuracy, reactionTime, diffFactor);
		}
		
		private function generateWritingWholeNumberProbe(correct:Boolean,rand:Boolean=false):void {
			var diffFactor:* = 1;
			var reactionTime:* = generateReactionTime(correct,rand);
			var accuracy:* = generateAccuracy(correct,rand);
			
			var num:* = Math.round(Math.random()*10);
			trace("generating writing num probe: " + num + " accuracy: " + accuracy + " reactionTime: " + reactionTime);
			addWritingWholeNumberProbe( num, accuracy, reactionTime, diffFactor);
		}

		
		///////////
		//
		// UTILS
		//
		///////////
		private function createInputLabel(labelName,defaultInput:String=""):* {
			var inputLabel:* = new Sprite();
			var label:* = createTextField(labelName,_txtFmt);
			inputLabel.addChild(label);
			
			_txtFmt.color = 0x000000;
			var box:* = createInputBox(_txtFmt,defaultInput);
			box.name = "inputBox";
			box.x = inputLabel.width;
			inputLabel.addChild(box);
			
			_txtFmt.color = 0xFFFFFF;
			return inputLabel;
		}
		
		private function createCheckBoxLabel(labelName):* {
			var checkBoxLabel:* = new Sprite();
			var label:* = createTextField(labelName,_txtFmt);
			checkBoxLabel.addChild(label);
			
			var box:* = createCheckBox();
			box.name = "checkBox";
			box.x = checkBoxLabel.width;
			
			var maxHeight:* = Math.max(checkBoxLabel.height,box.height);
			checkBoxLabel.y = (checkBoxLabel.height - maxHeight)/2;
			box.y = (box.height - maxHeight)/2;
			checkBoxLabel.addChild(box);
			return checkBoxLabel;
		}
		
		private function createTextField(txt:String,txtFmt:TextFormat):* {
			var txtField:* = new TextField();
			txtField.selectable = false;
			txtField.defaultTextFormat = txtFmt;
			txtField.embedFonts = true;
			txtField.text = txt;
			txtField.width = txtField.textWidth + 4;
			txtField.height = txtField.textHeight + (2*txtField.numLines) + 2;	
			return txtField;
		}
		
		private function createInputBox(txtFmt:TextFormat,defaultInput:String=""):* {
			var inputBox:* = createTextField("$$$$$$$$$$",txtFmt);
			inputBox.type = TextFieldType.INPUT;
			inputBox.selectable = true;
			inputBox.text = defaultInput;
			inputBox.border = true;
			inputBox.background = true;
			return inputBox;
		}
		
		private function createCheckBox(dim:Number=25):* {
			var checkBox:* = new Sprite();
			checkBox.buttonMode = true;
			checkBox.mouseChildren = false;
			
			var outline:* = new Shape();
			outline.name = "outline";
			outline.graphics.lineStyle(1);
			outline.graphics.beginFill(0xFFFFFF);
			outline.graphics.drawRect(0,0,dim,dim);
			outline.visible = true;
			
			var checker:* = new Shape();
			checker.name = "checker";
			checker.graphics.lineStyle(2);
			checker.graphics.moveTo(0,0);
			checker.graphics.lineTo(dim,dim);
			checker.graphics.moveTo(dim,0);
			checker.graphics.lineTo(0,dim);
			checker.visible = false;
			
			checkBox.addChild(outline);
			checkBox.addChild(checker);
			checkBox.addEventListener(MouseEvent.CLICK,checkBoxClicked);
			return checkBox;
		}
		
		private function createButton(buttonLabel:String,color:uint,w:Number=100,h:Number=50):* {
			var butt:* = new Sprite();
			butt.buttonMode = true;
			butt.mouseChildren = false;
			butt.graphics.lineStyle(2,0);
			butt.graphics.beginFill(color);
			butt.graphics.drawRoundRect(0,0,w,h,10);
			butt.graphics.endFill();
			
			var buttTxt:* = new TextFormat();
			buttTxt.size = 24;
			buttTxt.align = "center";
			buttTxt.color = 0;
			var buttLabel:* = createTextField(buttonLabel,buttTxt);
			buttLabel.x = (w-buttLabel.width)/2;
			buttLabel.y = (h-buttLabel.height)/2;
			butt.addChild(buttLabel);
			
			butt.addEventListener(MouseEvent.CLICK,buttSelected);
			return butt;
		}
		
		
		private function createButton1(txt:String,buttW:Number=100,buttH:Number=30):* {
			var butt:* = new Sprite();
			butt.buttonMode = true;
			butt.mouseChildren = false;
			butt.tabEnabled = false;
			
			var gradientBox:* = new Matrix();
			gradientBox.createGradientBox(buttW,buttH,Math.PI/2,-buttW/2,-buttH/2);
			var out:* = new Shape();
			out.name = "out";
			out.graphics.lineStyle(1,0x000000,0.5);
			out.graphics.beginGradientFill(GradientType.LINEAR,[0xFFFFFF,0xD5D5D5],[1,1],[128,255],gradientBox);
			out.graphics.drawRoundRect(0,0,buttW,buttH,10);
			out.graphics.endFill();
			
			var over:* = new Shape();
			over.name = "over";
			over.graphics.lineStyle(3.5,0x0066FF,1);
			over.graphics.beginGradientFill(GradientType.LINEAR,[0xFFFFFF,0xD5D5D5],[1,1],[128,255],gradientBox);
			over.graphics.drawRoundRect(0,0,buttW,buttH,10);
			over.graphics.endFill();
			
			_txtFmt.size = 24;
			_txtFmt.color = 0x000000;
			var buttTxt:* = createTextField(txt,_txtFmt);
			buttTxt.x = (buttW/2) - (buttTxt.width/2);
			buttTxt.y = (buttH/2) - (buttTxt.height/2);
			
			out.visible = true;
			over.visible = false;
			
			butt.addChild(out);
			butt.addChild(over);
			butt.addChild(buttTxt);
			
			butt.addEventListener(MouseEvent.ROLL_OVER,buttRolledOver);
			butt.addEventListener(MouseEvent.ROLL_OUT,buttRolledOut);
			butt.addEventListener(MouseEvent.CLICK,buttSelected);
			
			return butt;
		}
		
	}
}