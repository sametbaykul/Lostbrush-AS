/*

	------------------------------------------------------------
	- WINDOWS(C) 2016
	------------------------------------------------------------
	
	* FULL STATIC
	* INIT : true
	
	v1.0 : 12.08.2015 : Temel pencere olaylarını yönetir.
	v1.1 : 12.02.2015 : 'id' ve 'no' özellikleri belirlendi.
	
	// -> DİKKAT Yeni Animastor.as Uyumluluk Sorunu

	by Samet Baykul

*/

package lbl
{
	// Flash Library:
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.display.Stage;
	//import flash.events.Event;
	//import flash.events.TimerEvent;
	//import flash.utils.Timer;
	// LBL Core:
	import lbl.Utility;
	import lbl.Gensys;
	// LBL Control:
	import lbl.InputControl;
	import lbl.Console;
	import lbl.Interaction;
	import lbl.Animator;

	public class Windows
	{

		// ------------------------------------------------------------
		// PROPERTIES :
		// ------------------------------------------------------------
		
		public static var WINOL:Array;									// Windows Object List
		
		public static var HANIL:Array = new Array();					// Head ANI List
		
		private static var win_depth:Array = new Array();
		
		//public static var ACTIVE:Boolean;
		//public static var SELECTED:DisplayObject;
		
		// Class Info:
		private static var id:String = "WIN";
		private static var no:int = 022;
		
		public function Windows()
		{
			// Full static class
		}
		
		// ------------------------------------------------------------
		// METHODS :
		// ------------------------------------------------------------
		
		public static function INIT(Supports:Array):void
		{
			init_vars();
			init_actions();
			
			function init_vars():void
			{
				WINOL = new Array();
			}
		}
		
		public static function ADD(Target:Stage, Win_Name:String, Template_Name:Object, Position_X:Number, Position_Y:Number, Support_List:Array = null):void
		{
			var WINO:Object = new Object();
			var Win:MovieClip = new Template_Name as MovieClip;
			
			set_WINO();
			set_win_template();
			set_interactions();

			Console.DYNAMIC_DATA("WINOL", WINOL);

			function set_WINO():void
			{
				WINO.stage = Target;
				WINO.name = Win_Name;
				WINO.template = Template_Name;
				WINO.pos_x = Position_X;
				WINO.pos_y = Position_Y;
				WINO.supports = ["Win"]
				WINO.supports = Utility.ADD_ARRAY(WINO.supports, Support_List);
				
				WINO.selected = false;
				WINO.impulse = false;
				
				WINO.drag = false;
				WINO.head = false;
				WINO.selectable = false;
				WINO.scale = false;
				
				WINOL[WINO.name] = WINO;
			}
			function set_win_template():void
			{
				Win.name = WINO.name;
				Win.x = WINO.pos_x;
				Win.y = WINO.pos_y;
				
				// SELECTABLE_AREA (Must)
				if (Boolean(Win.selectable_area))
				{
					Win.selectable_area.alpha = 0;
					WINO.selectable = Win.selectable_area;
				}
				// DRAG_DROP
				if (Boolean(Win.head_drag_drop))
				{
					Win.head_drag_drop.alpha = 0;
					WINO.drag = Win.head_drag_drop;
				}
				// HEAD
				if (Boolean(Win.mcA_head))
				{
					// check MCA
					if (true)
					{
						reset_heads();
						
						WINO.selected = true;
						
						// -> DİKKAT Yeni Animastor.as Uyumluluk Sorunu
						
						//WINO.head = new Animator(Win.mcA_head, "Gray", "Gensys");
						
						update_heads();
					}
					else
					{
						trace("Hata!. HEAD must be a MCA")
					}
				}
				// SCALE_AREA
				if (Boolean(Win.scale_area))
				{
					Win.scale_area.alpha = 0;
					WINO.scale = Win.scale_area;
				}
				
				Target.addChild(Win);
				win_depth.push(Win);
				WINO.object = Win;
			}
			function set_interactions():void
			{
				if (WINO.selectable)
				{
					Interaction.ADD_GROUP("Windows_Selectable", [WINO.name], [WINO.object], [WINO.object], WINO.supports);
				}
				if (WINO.drag)
				{
					Interaction.ADD_GROUP("Windows_Drag", [WINO.name], [WINO.object], [WINO.drag], WINO.supports);
				}
				if (WINO.scale)
				{
					Interaction.ADD_GROUP("Windows_Scale", [WINO.name], [WINO.object], [WINO.scale], WINO.supports);
				}
			}
		}
		
		public static function IMPULSE(Win_Name:String):void
		{
			WINOL[Win_Name].impulse = true;
			
			update_heads();
		}
		
		// ------------------------------------------------------------
		// FUNCTIONS :
		// ------------------------------------------------------------
		
		private static function init_actions():void
		{
			Interaction.ADD_ACTION("Windows_Selection", win_selection_control, "Mouse", ["Windows_Selectable"], ["Win"]);
			Interaction.ADD_ACTION("Windows_Dragging", win_dragging_control, "Mouse", ["Windows_Drag"], ["Win"]);
			
			function win_selection_control(Feedback:Object)
			{
				update_head_animation(Feedback);
				set_win_depth(Feedback);
				
				Console.DYNAMIC_DATA("Windows_Selection", Feedback);
				Console.DYNAMIC_DATA("WINOL", WINOL);
				
				function update_head_animation(Feedback:Object):void
				{
					reset_heads();
					
					for each(var win_selected:MovieClip in Feedback.selected)
					{
						WINOL[win_selected.name].selected = true;
					}
					
					update_heads();
				}
				function set_win_depth(Feedback:Object):void
				{
					if (Feedback.last_selected)
					{
						Utility.REMOVE_SPECIFIC_ELEMENTS(win_depth, Feedback.selected);
						Utility.COMPRESS_ARRAY(win_depth);
					
						for (var i:int = 0; i < Feedback.selected.length; i ++)
						{
							win_depth[i] = Feedback.selected[i];
						}
						
						Utility.SET_STAGE_DEPTH(win_depth);
					}
				}
			}
			function win_dragging_control(Feedback:Object)
			{
				Feedback.drag_drop();
				
				for each(var win_selected:MovieClip in Feedback.selected)
				{
					WINOL[win_selected.name].pos_x = WINOL[win_selected.name].object.x;
					WINOL[win_selected.name].pos_y = WINOL[win_selected.name].object.y;
				}
				
				Console.DYNAMIC_DATA("Drag", Feedback);
			}
		}
		private static function reset_heads():void
		{
			for each (var WINO:Object in WINOL)
			{
				WINO.selected = false;
			}
		}
		private static function update_heads():void
		{
			for each (var WINO:Object in WINOL)
			{
				if (WINO.head)
				{
					if (WINO.selected)
					{
						WINO.head.ANIMATE("Blue");
						WINO.impulse = false;
					}
					else if (WINO.impulse)
					{
						WINO.head.ANIMATE("Impulse", "Endless");
					}
					else
					{
						WINO.head.ANIMATE("Gray");
					}
				}
			}
		}
	}
}