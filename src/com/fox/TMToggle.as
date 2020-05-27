/*
* ...
* @author fox
*/
import com.GameInterface.DistributedValue;
import com.GameInterface.Input;
import com.Utils.Archive;
import com.Utils.GlobalSignal;
import com.fox.Utils.Common;
import flash.geom.Point;
import mx.utils.Delegate;
 
class com.fox.TMToggle
{
	public var m_SwfRoot:MovieClip;
	static var dvalTargetMode:DistributedValue;
	public var mouselistener:Object;
	public var buttonClip:MovieClip;
	public var pos:Point;
	public var scale:Number;
	
	public static function main(swfRoot:MovieClip):Void
	{
		var s_app = new TMToggle(swfRoot);
		swfRoot.onLoad = function(){s_app.Load()};
		swfRoot.onUnload = function(){s_app.Unload()};
		swfRoot.OnModuleActivated = function(config){s_app.Activate(config)};
		swfRoot.OnModuleDeactivated = function(){return s_app.Deactivate()};
	}

	public function TMToggle(root) {
		m_SwfRoot = root;
		dvalTargetMode = DistributedValue.Create("InvertSimpleGroundTarget");
		mouselistener = new Object();
		mouselistener.onMouseWheel = Delegate.create(this, scaleIcon);
	}
	
	public function Load(){
		GlobalSignal.SignalSetGUIEditMode.Connect(GuiEditMode, this);
		dvalTargetMode.SignalChanged.Connect(ColorIcon, this);
		Input.RegisterHotkey(_global.Enums.InputCommand.e_InputCommand_Action_Attack_Stance, "com.fox.TMToggle.ToggleMode", _global.Enums.Hotkey.eHotkeyUp, 0);
	}
	static function ToggleMode(){
		if (Key.isDown(Key.SHIFT)){ //control doesnt work
			dvalTargetMode.SetValue(!dvalTargetMode.GetValue());
		}
		
	}
	
	public function Unload(){
		dvalTargetMode.SignalChanged.Disconnect(ColorIcon, this);
		GlobalSignal.SignalSetGUIEditMode.Disconnect(GuiEditMode, this);
	}
	public function Activate(config: Archive):Void
	{
		pos = config.FindEntry("pos", new Point(200, 200));
		scale = config.FindEntry("scale", 50);
		if (!buttonClip) DrawButton();
	}
	
	public function scaleIcon(delta){
		if (Mouse.getTopMostEntity() != buttonClip) return;
		if (delta < 0){
			scale -= 5;
			if (scale < 20) scale = 20;
			buttonClip._xscale = buttonClip._yscale = scale;
			var pos2:Point = Common.getOnScreen(buttonClip);
			buttonClip._x = pos2.x;
			buttonClip._y = pos2.y;
			pos = pos2;
		}else{
			scale += 5;
			if (scale > 200) scale = 200;
			buttonClip._xscale = buttonClip._yscale = scale;
			var pos2:Point = Common.getOnScreen(buttonClip);
			buttonClip._x = pos2.x;
			buttonClip._y = pos2.y;
			pos = pos2;
		}
	}

	
	public function Deactivate():Archive
	{
		var arch:Archive = new Archive();
		arch.AddEntry("pos", pos);
		arch.AddEntry("scale", scale);
		return arch;
	}
	
	public function DrawButton(){
		if (!_root.abilitybar){
			setTimeout(Delegate.create(this, DrawButton), 500);
			return
		}
		buttonClip = m_SwfRoot.attachMovie("crosshair", "TargetModeButton", m_SwfRoot.getNextHighestDepth());
		buttonClip._xscale = buttonClip._yscale = scale;
		buttonClip.BG._alpha = 75;
		buttonClip._x = pos.x;
		buttonClip._y = pos.y;
		var pos2:Point = Common.getOnScreen(buttonClip);
		buttonClip._x = pos2.x;
		buttonClip._y = pos2.y;
		pos = pos2;
		ColorIcon();
		GuiEditMode(false);
	}
	
	public function startDrag(){
		buttonClip.startDrag();
	}
	
	public function stopdrag(){
		buttonClip.stopDrag();
		var pos2:Point = Common.getOnScreen(buttonClip);
		buttonClip._x = pos2.x;
		buttonClip._y = pos2.y;
		pos = pos2;
	}
	
	private function ChangeMode(){
		dvalTargetMode.SetValue(!dvalTargetMode.GetValue());
		ColorIcon();
	}
	
	private function ColorIcon(){
		if (!dvalTargetMode.GetValue()){
			//Colors.ApplyColor(buttonClip.crosshair, 0x068E28);
			buttonClip.crosshair._yscale = 50;
			buttonClip.crosshair._xscale = 100;
			buttonClip.crosshair._y = buttonClip.crosshair._height;
			buttonClip.crosshair._x = 0;
		}else{
			//Colors.ApplyColor(buttonClip.crosshair, 0xF00000);
			buttonClip.crosshair._yscale = 100;
			buttonClip.crosshair._xscale = 50;
			buttonClip.crosshair._x = buttonClip.crosshair._width;
			buttonClip.crosshair._y = 0;
		}
	}
	
	public function GuiEditMode(state){
		if (!state){
			buttonClip.onRelease = buttonClip.onReleaseOutside = undefined;
			buttonClip.onPress = Delegate.create(this, ChangeMode);
			Mouse.removeListener(mouselistener);
		}else{
			buttonClip.onPress = Delegate.create(this, startDrag);
			buttonClip.onRelease = buttonClip.onReleaseOutside = Delegate.create(this, stopdrag);
			Mouse.addListener(mouselistener);
		}
	}
}