/*

	------------------------------------------------------------
	- CURSOR(C) 2015
	------------------------------------------------------------
	
	* FULL STATIC
	* INIT : true
	
	v1.0 : 14.09.2015 : İlk defa Map 2015 sınıfı için üretilmiştir.
	v1.1 : 12.02.2015 : 'id' ve 'no' özellikleri belirlendi.
	
	// ! DİKKAT Yeni Animastor.as Uyumluluk Sorunu
	
	GELİŞTİRMELER:	- Animator.as ile entegrasyonu sağla.
					- Map.as'ta yer alan Cursor.as sınıfına ait kodları transfer et. 
	
	by Samet Baykul
	
*/

package lbl
{
	// Flash Library:
	import flash.display.MovieClip;
	import flash.ui.Mouse;
	// LBL Control:
	import lbl.Animator;
	
	
	public class Cursor
	{
		// ------------------------------------------------------------
		// PROPERTIES :
		// ------------------------------------------------------------
		
		public static var MC_CURSOR:MovieClip;
		public static var ANIM:MovieClip;
		public static var NAME:String;
		public static var TAG:String;
		
		private static var warning_message:Boolean = false;
		
		// Class Info:
		private static var id:String = "CUR";
		private static var no:int = 019;
		
		public function Cursor()
		{
			// Full static class
		}
		
		// ----------------------------------------------------------------
		// METHODS :
		// ----------------------------------------------------------------
		
		public static function INIT(MC_Cursor:MovieClip):void
		{
			init_params();
			init_animator();
			
			function init_params():void
			{
				MC_CURSOR = MC_Cursor;
				MC_CURSOR.mouseEnabled = false;
				MC_CURSOR.mouseChildren = false;
				
				TAG = "Original";
			}
			function init_animator():void
			{
				var ATO_Cursor:Object = new Object();
				ATO_Cursor.Self = "";
				
				Animator.NEW(MC_CURSOR, ATO_Cursor);
				
				ANIM = Animator.GET_ANIM(MC_CURSOR, "Self");
				
				update_info();
			}
		}
		
		public static function SET(ANIM_Name:String, Tag:String = "No", Original_Cursor:int = 0):void
		{
			if (check_cursor_init())
			{
				select_cursor(ANIM_Name);
				animate_cursor();
				update_info(Tag);
			}
			
			function select_cursor(What:String):void
			{
				switch (What)
				{
					case "Auto":
						ANIM_Name = "Default";
						Tag = "Original";
						Mouse.cursor = "auto";
						Original_Cursor = 1;
						break;
					case "Hand":
						ANIM_Name = "Default";
						Tag = "Original";
						Mouse.cursor = "hand";
						Original_Cursor = 1;
						break;
					case "None":
						ANIM_Name = "Default";
						Tag = "Original";
						Original_Cursor = 0;
						break;
				}
			}
			function animate_cursor():void
			{
				Animator.CHANGE_PART(MC_CURSOR, "Self", ANIM_Name);
				
				if (Boolean(Math.abs(Original_Cursor)))
				{
					if (Original_Cursor > 0)
					{
						ORIGINAL(true);
					}
					else
					{
						ORIGINAL(false);
					}
				}
			}
		}
		
		public static function REMOVE(Tag_Name:String):void
		{
			if (Tag_Name == TAG)
			{
				SET("Auto");
			}
		}
		
		public static function SET_POS(X:Number, Y:Number):void
		{
			if (check_cursor_init())
			{
				MC_CURSOR.x = X;
				MC_CURSOR.y = Y;
			}
		}
		
		public static function ORIGINAL(Visible:Boolean = true):void
		{
			if (check_cursor_init())
			{
				if (Visible)
				{
					Mouse.show();
				}
				else
				{
					Mouse.hide();
				}
			}
		}
		
		// ------------------------------------------------------------
		// FUNCTIONS :
		// ------------------------------------------------------------

		private static function check_cursor_init():Boolean
		{
			if (Boolean(MC_CURSOR))
			{
				return true;
			}
			else if (!warning_message)
			{
				warning_message = true;
				
				Console.PRINT("Cursor", "- WARNING > You did not INIT the Cursor.", 2);
				
				return false;
			}
			else
			{
				return false;
			}
		}
		private static function update_info(Tag:String = null):void
		{
			ANIM = Animator.GET_ANIM(MC_CURSOR, "Self");
			
			if (Boolean(Tag))
			{
				TAG = Tag;
			}

			if (Boolean(ANIM))
			{
				NAME = ANIM.name;
			}
			else
			{
				NAME = "None";
			}
		}
	}

}