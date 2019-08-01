/*

	------------------------------------------------------------
	- MAP(C) 2015 - 2016
	------------------------------------------------------------
	
	* DYNAMIC
	* INIT : Constructor
	
	v1.0 : 10.09.2015 	: İlk defa Physics 2015 sınıfı için üretilmiştir. Daha önce buna benzer bir algoritma CityMaker 2010'da kullanıldı.
	v1.1 : 12.02.2016 	: 'id' ve 'no' özellikleri belirlendi.
	v1.2 : 25.02.2016 	: - DEFINE_CONTROL() metodu kontrolleri 'check' edildi ve bazı hatalar giderildi. 
						- 'Cursor_Support' ile Cursor animasyon desteği opsiyonel duruma getirildi.
						- 'Moving_Keys' kontrolü ile ilgili 'Focus' hatası giderildi.
	
	GELİŞTİRMELER		: 	- İsim güncelle. (-> Camera)
							- Temel değişkenlerde isim değişikliği yap. World ve Win anlam karmaşasına sebep oluyor.
							- Static duruma getir.
							- Animator.as desteği ekle.
							- Map bağlantılarını gözden geçir.
							- Map kullanım prosedürünü sadeleştir.
							- TOOL: Movement_Sensor için Zoom kontrol desteği ekle.
							- TOOL: Mini Map.
							- TOOL: Moving_Keys Accelerator.
							- TOOL: Map Scale Adjustment Bar.
							- CONTROL: Smooth Transition Zomming.
							- Paralel Maps. (Map Bridge)
							- Length Unit fonksiyonları genel kullanım için paylaşılabilir.
							- Map sınıfına SET_ROTATION() ve GET_ROTATITON() metodları eklenebilir.
							- Compass arayüzü eklenebilir.
							- Physics.as ile olan etkileşimini gözden geçir.
							- 
							
	UYARILAR			:	! Map.Content üzerinde Mouse olayları, MOUSE_AREA objesi tarafından bloke ediliyor.
							// ! DİKKAT Yeni Animastor.as Uyumluluk Sorunu
		
	by Samet Baykul
	
*/

package  lbl
{
	// Flash Library:
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	// LBL Core:
	import lbl.MathLab;
	import lbl.Utility;
	import lbl.Processor;
	// LBL Control:
	import lbl.InputControl;
	import lbl.Console;
	import lbl.Cursor;
	
	
	public class Map
	{		
		// ------------------------------------------------------------
		// PROPERTIES :
		// ------------------------------------------------------------
		
		public var MAP:MovieClip;
		public var WIN:MovieClip;
		public var MOUSE_AREA:MovieClip;
		public var RECT:Rectangle;
		public var LIMITS:Object;
		public var START_VALUES:Object;
		public var CONTROL_AVTIVE:Boolean;
		public var SCALE_FACTOR:Number;
		
		private var tools:Object = new Object();
		private var debug:Boolean;
		
		private const au:Number = 149597870691;
		private const ld:Number = 173 * au;
		private const ly:Number = 9460730472580800;
		
		// Class Info:
		private static var id:String = "MAP";
		private static var no:int = 018;
		
		public function Map(Map:MovieClip, Window:MovieClip, Limits:Array = null, Margin:Number = 0, Scale_Factor:Number = -1, Cache_As_Bitmap:Boolean = true, Debugger_Mode:Boolean = false)
		{
			init_vars();
			init_MAP();
			init_limits();
			init_boundary();
			init_WIN();
			init_mouse_area();
			init_scale();
			init_toolset();
			init_start_values();
			init_commands();
			
			function init_vars():void
			{
				MAP = Map;	
				WIN = Window;
				MOUSE_AREA = WIN.Mouse_Area;
				RECT = new Rectangle();
				LIMITS = new Object();
				
				debug = Debugger_Mode;
			}
			function init_MAP():void
			{
				MAP.cacheAsBitmap = Cache_As_Bitmap;
			}
			function init_limits():void
			{
				if (Boolean(Limits))
				{
					SET_LIMITS(Limits[0], Limits[1], Limits[2], Limits[3], Limits[4], Limits[5]);
				}
				else
				{
					SET_LIMITS(NaN, NaN, NaN, NaN, NaN, NaN);
				}
			}
			function init_boundary():void
			{
				var pos_x:Number = LIMITS.init_L_X + Margin;
				var pos_y:Number = LIMITS.init_L_Y + Margin;
				var dim_w:Number = MAP.width + LIMITS.init_H_X - LIMITS.init_L_X - (Margin * 2);
				var dim_h:Number = MAP.height + LIMITS.init_H_Y  - LIMITS.init_L_Y - (Margin * 2);
				
				aplly(WIN.Boundary);
				aplly(MOUSE_AREA);

				function aplly(MC:MovieClip):void
				{
					WIN.removeChild(MC);
					MAP.addChild(MC);
				
					MC.x = pos_x;
					MC.y = pos_y;
					MC.width = dim_w;
					MC.height = dim_h;
				}
			}
			function init_WIN():void
			{
				MAP.mask = WIN.Mask;
				WIN.mouseEnabled = false;
				WIN.mouseChildren = false;

				Utility.GET_REF_PROPS(WIN, MAP, [WIN.width, WIN.height]);
				SET_FRAME_DIM(Utility.RPO.w, Utility.RPO.h);
				SET_FRAME_POS(Utility.RPO.x, Utility.RPO.y);
			}
			function init_mouse_area():void
			{
				MOUSE_AREA = WIN.Mouse_Area;

				if (debug)
				{
					MOUSE_AREA.alpha = 0;
				}
				else
				{
					MOUSE_AREA.alpha = 0;
				}
			}
			function init_scale():void
			{
				UPDATE_SCALE(Scale_Factor);
			}
			function init_toolset():void
			{
				WIN.Zoom.visible = false;
				WIN.Map_Scale.visible = false;
				WIN.Movement_Sensor.visible = false;
			}
			function init_start_values():void
			{
				START_VALUES = new Object();
				
				START_VALUES.pos_x = RECT.x;
				START_VALUES.pos_y = RECT.y;
				START_VALUES.zoom = 1;
			}
			function init_commands():void
			{
				//
			}
		}
		
		// ----------------------------------------------------------------
		// METHODS :
		// ----------------------------------------------------------------
		
		public function RESET(Pos_X:Number = NaN, Pos_Y:Number = NaN, Zoom_Scale:Number = NaN):void
		{
			if (Boolean(Pos_X) && (Pos_X !== 0))
			{
				START_VALUES.pos_x = Pos_X;
			}
			if (Boolean(Pos_Y) && (Pos_Y !== 0))
			{
				START_VALUES.pos_y = Pos_Y;
			}
			if (Boolean(Zoom_Scale) && (Zoom_Scale !== 0))
			{
				START_VALUES.zoom = Zoom_Scale;
			}
			
			ZOOM(START_VALUES.zoom, GET_SCREEN_MID_POINT());
			SET_FRAME_POS(START_VALUES.pos_x, NaN);
			SET_FRAME_POS(NaN, START_VALUES.pos_y);
		}
		
		public function SET_LIMITS(Lowest_X:Number = NaN, Highest_X:Number = NaN, Lowest_Y:Number = NaN, Highest_Y:Number = NaN, Lowest_Zoom:Number = NaN, Highest_Zoom:Number = NaN):void
		{
			check_infinity();
			check_comparisons();
			
			LIMITS.init_L_X = Lowest_X;
			LIMITS.init_H_X = Highest_X;
			LIMITS.init_L_Y = Lowest_Y;
			LIMITS.init_H_Y = Highest_Y;
			LIMITS.init_L_ZOOM = Lowest_Zoom;
			LIMITS.init_H_ZOOM = Highest_Zoom;
			
			LIMITS.L_X = Lowest_X;
			LIMITS.H_X = Highest_X;
			LIMITS.L_Y = Lowest_Y;
			LIMITS.H_Y = Highest_Y;
			LIMITS.L_ZOOM = Lowest_Zoom;
			LIMITS.H_ZOOM = Highest_Zoom;
			
			function check_infinity():void
			{
				if (!Boolean(Lowest_X) && (Lowest_X !== 0))
				{
					Lowest_X = MathLab.EXTREME_VALUE(false);
				}
				if (!Boolean(Highest_X) && (Highest_X !== 0))
				{
					Highest_X = MathLab.EXTREME_VALUE();
				}
				if (!Boolean(Lowest_Y) && (Lowest_Y !== 0))
				{
					Lowest_Y = MathLab.EXTREME_VALUE(false);
				}
				if (!Boolean(Highest_Y) && (Highest_Y !== 0))
				{
					Highest_Y = MathLab.EXTREME_VALUE();
				}
				if (!Boolean(Lowest_Zoom) && (Lowest_Zoom !== 0))
				{
					Lowest_Zoom = 1 / Math.min(MAP.width, MAP.height);
				}
				if (!Boolean(Highest_Zoom) && (Highest_Zoom !== 0))
				{
					Highest_Zoom = Math.min(MAP.width, MAP.height);
				}
			}
			function check_comparisons():void
			{
				if (Lowest_X > Highest_X)
				{
					Console.PRINT("Map","X ERROR > ERROR CODE : xxxx > Highest_X must be greater than Lowest_X.",3,"");
				}
				if (Lowest_Y > Highest_Y)
				{
					Console.PRINT("Map","X ERROR > ERROR CODE : xxxx > Lowest_Y must be greater than Highest_Y.",3,"");
				}
				if (Lowest_Zoom > Highest_Zoom)
				{
					Console.PRINT("Map","X ERROR > ERROR CODE : xxxx > Lowest_Zoom must be greater than Highest_Zoom.",3,"");
				}
				if (Lowest_Zoom < 0)
				{
					Console.PRINT("Map","X ERROR > ERROR CODE : xxxx > Lowest_Zoom must be greater than Zero.",3,"");
				}
			}
		}
		
		public function SET_FRAME_POS(Pos_X:Number = NaN, Pos_Y:Number = NaN):void
		{
			var target_X:Number;
			var target_Y:Number;
			
			check_params();
			handle_dim();
			update_frame_RECT();

			MAP.scrollRect = RECT;

			function check_params():void
			{
				if (!Boolean(Pos_X) && (Pos_X !== 0))
				{
					Pos_X = RECT.x;
				}
				if (!Boolean(Pos_Y) && (Pos_Y !== 0))
				{
					Pos_Y = RECT.y;
				}
			}
			function handle_dim():void
			{
				if ((Pos_X >= LIMITS.L_X) && (Pos_X <= LIMITS.H_X))
				{
					target_X = Pos_X;
				}
				else
				{
					if (Pos_X < LIMITS.L_X)
					{
						target_X = LIMITS.L_X;
					}
					if (Pos_X > LIMITS.H_X)
					{
						target_X = LIMITS.H_X;
					}
				}
					
				if ((Pos_Y >= LIMITS.L_Y) && (Pos_Y <= LIMITS.H_Y))
				{
					target_Y = Pos_Y;
				}
				else
				{
					if (Pos_Y < LIMITS.L_Y)
					{
						target_Y = LIMITS.L_Y;
					}
					if (Pos_Y > LIMITS.H_Y)
					{
						target_Y = LIMITS.H_Y;
					}
				}
			}
			function update_frame_RECT():void
			{
				RECT.x = target_X;
				RECT.y = target_Y;
			}
		}
		
		public function SET_FRAME_DIM(Dim_W:Number = NaN, Dim_H:Number = NaN):void
		{
			check_params();
			
			RECT.width = Dim_W;
			RECT.height = Dim_H;
			MAP.scrollRect = RECT;
			
			function check_params():void
			{
				if (!Boolean(Dim_W) && (Dim_W !== 0))
				{
					Dim_W = RECT.width;
				}
				if (!Boolean(Dim_H) && (Dim_H !== 0))
				{
					Dim_H = RECT.height;
				}
			}
		}
		
		public function ZOOM(Scale:Number, Focus_Point:Point):void
		{
			if (Scale > 0 && Scale <= LIMITS.H_ZOOM && Scale >= LIMITS.L_ZOOM)
			{
				var scale_rate:Number;
				var map_focus:Point = Focus_Point;
				var win_focus:Point = GET_POINT(map_focus, "Rect", "Map");
				
				update_dim();
				update_bounds();
				update_pos();
			}
			if (Utility.TEST_OBJECT_STANDART(tools, ["Map_Scale"]))
			{
				update_map_scale();
			}
			if (Utility.TEST_OBJECT_STANDART(tools, ["Zoom"]))
			{
				WIN.Zoom.visible = true;
				
				WIN.Zoom.value.text = "X " + MathLab.SET_SIGNIFICANT_FIGURE(GET_SCALE(), 6 - MathLab.FIND_DIGIT_NUMBER(GET_SCALE()));
			}
			
			function update_dim():void
			{
				scale_rate = MAP.scaleX / Scale;
				
				MAP.scaleX = Scale;
				MAP.scaleY = Scale;
				SET_FRAME_DIM(RECT.width * scale_rate, RECT.height * scale_rate);
			}
			function update_bounds():void
			{
				reset_boundary();
					
				if (Scale > 1)
				{
					LIMITS.L_X = LIMITS.init_L_X;
					LIMITS.L_Y = LIMITS.init_L_Y;
					LIMITS.H_X = LIMITS.init_H_X + Scale * RECT.width - RECT.width;
					LIMITS.H_Y = LIMITS.init_H_Y + Scale * RECT.height - RECT.height;
				}
				else
				{
					LIMITS.H_X = LIMITS.init_H_X - (RECT.width - (Scale * RECT.width));
					LIMITS.H_Y = LIMITS.init_H_Y - (RECT.height - (Scale * RECT.height));
					
					if (LIMITS.H_X < LIMITS.init_L_X)
					{
						LIMITS.L_X = -(RECT.width - (Scale * RECT.width)) / 2;
						LIMITS.H_X = -(RECT.width - (Scale * RECT.width)) / 2;
					}
					if (LIMITS.H_Y < LIMITS.init_L_Y)
					{
						LIMITS.L_Y = -(RECT.height - (Scale * RECT.height)) / 2;
						LIMITS.H_Y = -(RECT.height - (Scale * RECT.height)) / 2;
					}
				}
			}
			function update_pos():void
			{
				var offset_x:Number = (win_focus.x / WIN.width) * RECT.width;
				var offset_y:Number = (win_focus.y / WIN.height) * RECT.height;
				
				SET_FRAME_POS(map_focus.x - offset_x, map_focus.y - offset_y);
			}
			function reset_boundary():void
			{
				LIMITS.L_X = LIMITS.init_L_X;
				LIMITS.L_Y = LIMITS.init_L_Y;
				LIMITS.H_X = LIMITS.init_H_X;
				LIMITS.H_Y = LIMITS.init_H_Y;
			}
		}
		
		public function SET_CONTROL(Active:Boolean):void
		{
			CONTROL_AVTIVE = Active;
			
			if (!Active)
			{
				if (Boolean(Cursor.MC_CURSOR))
				{
					Cursor.SET("Auto");
				}
			}
		}
		
		public function UPDATE_SCALE(Scale_Factor:Number):void
		{
			SCALE_FACTOR = Scale_Factor;
			
			if (Utility.TEST_OBJECT_STANDART(tools, ["Map_Scale"]))
			{
				if (SCALE_FACTOR < 0)
				{
					WIN.Map_Scale.visible = false;
				}
				else
				{
					update_map_scale();
				}
			}
		}
		
		// -> Fine Tunning:
		public function DEFINE_CONTROL(Type:String, Cursor_Support:Boolean = false, Params:Array = null):void
		{
			if (check_cursor_availability())
			{
				SET_CONTROL(true);
			
				switch (Type)
				{
					case "Reset_Click":
						init_reset_click();
						break;
					case "Moving_Keys":
						init_moving_keys();
						break;
					case "Rotating_Keys":
						init_rotating_keys();
						break;
					case "Moving_Hand":
						init_moving_hand();
						break;
					case "Moving_Circle":
						init_moving_circle();
						break;
					case "Zoom_Keys":
						init_zoom_keys();
						break;
					case "Zoom_Scroll":
						init_zoom_scroll();
						break;
					case "Auto_Screen_Cleaner":
						init_auto_screen_cleaner();
						break;
					default:
						trace("warning: Type was not found <- DEFINE_CONTROL()");
						break;
				}
			}

			function check_cursor_availability():Boolean
			{
				var ok:Boolean = true;
				
				if (Cursor_Support)
				{
					if (!Boolean(Cursor.MC_CURSOR))
					{
						trace("error: cursor error!!!");
						
						ok = false;
					}
				}
				
				return ok;
			}
			function init_reset_click():void
			{
				InputControl.DEFINE("Map_Reset_Click", MOUSE_AREA, ICC_reset_click, ["Mouse"]);
				MOUSE_AREA.doubleClickEnabled = true;

				function ICC_reset_click(Param:Object):void
				{		
					if (Param.type == "Mouse" && CONTROL_AVTIVE && Param.target)
					{
						if (Param.target == MOUSE_AREA)
						{
							/*if (Param.doubleClick)
							{
								// ! DİKKAT Yeni Animastor.as Uyumluluk Sorunu
								
								if (Animator.TEST_ANIM(Cursor.MC_CURSOR))
								{
									CONTROL_AVTIVE = false;
									
									if (Cursor_Support)
									{
										Cursor.SET_POS(get_frame_mid_poimt().x, get_frame_mid_poimt().y);
										Cursor.SET("Reset", "Reset");
										//Animator.ANIMATE_SPECIAL(Cursor.MC_CURSOR, "Self", 500, 3, 
										//Cursor.ANI.ANIMATE("Reset", "Time", null, 500, 3, RC_reset);
									}
								}
								
								RESET();
							}*/
						}
					}
				}
				function RC_reset():void
				{
					CONTROL_AVTIVE = true;
					
					if (Cursor_Support)
					{
						Cursor.REMOVE("Reset");
					}
				}
			}
			function init_moving_keys():void
			{
				var multiplier:Number = 10;
				var current_multiplier:Number = multiplier;
				
				order_params();
				
				InputControl.DEFINE("Map_Moving_Keys", MOUSE_AREA, ICC_navigate_map, ["Keyboard"]);

				function ICC_navigate_map(Param:Object):void
				{
					if (true)
					{
						if (Param.type == "Keyboard" && !Boolean(Gensys.STAGE.focus))
						{
							if (Param[Params[1][0]] && CONTROL_AVTIVE)
							{
								update_current_multiplier();
								SET_FRAME_POS(RECT.x - current_multiplier, NaN);
							}
							if (Param[Params[1][1]] && CONTROL_AVTIVE)
							{
								update_current_multiplier();
								SET_FRAME_POS(RECT.x + current_multiplier, NaN);
							}
							if (Param[Params[1][2]] && CONTROL_AVTIVE)
							{
								update_current_multiplier();
								SET_FRAME_POS(NaN, RECT.y - current_multiplier);
							}
							if (Param[Params[1][3]] && CONTROL_AVTIVE)
							{
								update_current_multiplier();
								SET_FRAME_POS(NaN, RECT.y + current_multiplier);
							}
						}
					}
				}
				function update_current_multiplier():void
				{
					current_multiplier = multiplier * (RECT.width / WIN.width);
				}
				function order_params():void
				{
					if (Boolean(Params))
					{
						if (Boolean(Params[0] is Number))
						{
							multiplier = Params[0];
						}
						else
						{
							Console.PRINT("Map","- WARNING > DEFINE_CONTROL() Param[0] ('multiplier') must be Number.", 2, "");
						}
						if (Boolean(Params[1]))
						{
							if (!Boolean(Params[1] is Array))
							{
								Console.PRINT("Map","- WARNING > DEFINE_CONTROL() Param[1] ('key_codes') must be an Array.", 2, "");
							}
						}
					}
					else
					{
						Params = new Array();
						Params[0] = 10;
						Params[1] = ["A","D","W","S"]
					}
				}
			}
			// -> Eksik kısımlar var
			function init_rotating_keys():void
			{
				var multiplier:Number = 10;
				
				InputControl.DEFINE("Map_Rotating_Keys", MOUSE_AREA, ICC_navigate_map, ["Keyboard"]);
				
				order_params();
				
				function ICC_navigate_map(Param:Object):void
				{				
					if (Param.type == "Keyboard")
					{
						if (Param.Q && CONTROL_AVTIVE)
						{
							//ROTATE(GET_ROTATION() - multiplier);
						}
						if (Param.E && CONTROL_AVTIVE)
						{
							//ROTATE(GET_ROTATION() + multiplier);
						}
					}
				}
				function order_params():void
				{
					if (Boolean(Params))
					{
						if (Boolean(Params[0] is Number))
						{
							multiplier = Params[0];
						}
						else
						{
							Console.PRINT("Map","- WARNING > DEFINE_CONTROL() Param[0] ('multiplier') must be Number.", 2, "");
						}
					}
				}
			}
			function init_moving_hand():void
			{
				var activity:Boolean = false;
				var init_X:Number = 0;
				var init_Y:Number = 0;
				var difference_X:Number = 0;
				var difference_Y:Number = 0;
				
				InputControl.DEFINE("Map_Moving_Hand", MOUSE_AREA, ICC_navigate_map, ["Mouse"]);

				function ICC_navigate_map(Param:Object):void
				{		
					if (Param.type == "Mouse" && Param.target)
					{
						if (Param.target == MOUSE_AREA)
						{
							if (Param.mouseUp || Param.rollOut || !CONTROL_AVTIVE)
							{
								terminate_moving();
							}
							else if (Param.mouseDown && CONTROL_AVTIVE)
							{
								activity = true;
								init_X = Param.x;
								init_Y = Param.y;
								
								if (Cursor_Support)
								{
									Cursor.SET("Hand");
								}
							}
							else if (Param.mouseMove && CONTROL_AVTIVE)
							{
								if (activity)
								{
									update_navigator(Param.x, Param.y);
									Param.update();
								}
							}
						}
					}
					if (Param.target != MOUSE_AREA)
					{
						terminate_moving();
					}
				}
				function terminate_moving():void
				{
					activity = false;
								
					if (Cursor_Support)
					{
						Cursor.REMOVE("Original");
					}
				}
				function update_navigator(X:Number, Y:Number):void
				{
					difference_X = X - init_X;
					difference_Y = Y - init_Y;
					
					SET_FRAME_POS(RECT.x - difference_X, RECT.y - difference_Y);
				}
			}
			function init_moving_circle():void
			{
				if (check_req())
				{
					var activity:Boolean = false;
					var difference_X:Number = 0;
					var difference_Y:Number = 0;
					var angle:Number = 0;
					var multiplier:Number = 0.03;
					var dist_pow:int = 2;
					var dist_resist_c:Number = 0.2;
	
					InputControl.DEFINE("Map_Moving_Circle", MOUSE_AREA, ICC_navigate_map, ["Mouse"]);
					
					order_params();
				}
				
				function check_req():Boolean
				{
					var ok:Boolean = false;
					
					if (Boolean(Cursor.MC_CURSOR))
					{
						if (Boolean(InputControl.ICOL["Map_Moving_Hand"]))
						{
							trace("'Moving_Circle' -> ile 'Moving_Hand' çakışması tespit edildi. Lütfen yalnızca birini kullanın");
						}
						else if (!Boolean(Cursor_Support))
						{
							trace("'Moving_Circle' icon_supportu açmak zorundasınız.");
						}
						else
						{
							ok = true;
						}
					}
					else
					{
						trace("'Moving_Circle' -> bu control için cursora ihtiyaç var.");
					}
					
					return ok;
				}
				function ICC_navigate_map(Param:Object):void
				{
					if (Param.type == "Mouse" && Param.target == MOUSE_AREA)
					{
						if (Param.mouseUp || Param.rollOut || !CONTROL_AVTIVE)
						{
							terminate_moving();
						}
						else if (Param.mouseDown && CONTROL_AVTIVE && !activity)
						{
							if (Cursor.TAG == "Original")
							{
								activity = true;
								
								Cursor.SET_POS(MOUSE_AREA.x, MOUSE_AREA.y);
								Cursor.SET("Moving_Circle", "Map_Moving_Circle", -1);
								
								difference_X = 0;
								difference_Y = 0;
								
								Cursor.ANIM.circle.x = Utility.CHANGE_COORD(new Point(Param.x, Param.y), MOUSE_AREA, Cursor.MC_CURSOR).x;
								Cursor.ANIM.circle.y = Utility.CHANGE_COORD(new Point(Param.x, Param.y), MOUSE_AREA, Cursor.MC_CURSOR).y;
								Cursor.ANIM.arrow.x = Cursor.ANIM.circle.x;
								Cursor.ANIM.arrow.y = Cursor.ANIM.circle.y;
							}
						}
						else if (Param.mouseMove && CONTROL_AVTIVE && activity)
						{
							update_navigator(Param.x, Param.y);
						}
					}
					else
					{
						terminate_moving();
					}
					
					if (activity)
					{
						if (Math.abs(difference_X) > 0)
						{
							SET_FRAME_POS(RECT.x + (multiplier * Math.pow(difference_X, dist_pow) / (difference_X * dist_resist_c)), NaN);
							Param.update();
						}
						if (Math.abs(difference_Y) > 0)
						{
							SET_FRAME_POS(NaN, RECT.y + (multiplier * Math.pow(difference_Y, dist_pow) / (difference_Y * dist_resist_c)));
							Param.update();
						}
					}
				}
				function update_navigator(X:Number, Y:Number):void
				{
					X = Utility.CHANGE_COORD(new Point(X, Y), MOUSE_AREA, Cursor.MC_CURSOR).x;
					Y = Utility.CHANGE_COORD(new Point(X, Y), MOUSE_AREA, Cursor.MC_CURSOR).y;
					difference_X = X - Cursor.ANIM.circle.x;
					difference_Y = Y - Cursor.ANIM.circle.y;
					angle = MathLab.MATH_TO_FLASH_ROTATION(MathLab.GET_ABS_ANGLE(difference_X, -difference_Y));
					
					Cursor.ANIM.arrow.x = X;
					Cursor.ANIM.arrow.y = Y;
					Cursor.ANIM.circle.rotation = angle;
					Cursor.ANIM.arrow.rotation = angle;
					
					check_navigator_limits();
				}
				function check_navigator_limits():void
				{
					if (Math.abs(difference_X) < Cursor.ANIM.circle.width)
					{
						difference_X = 0;
					}
					else
					{
						difference_X -= MathLab.GET_SIGN(difference_X) * Cursor.ANIM.circle.width;
					}
						
					if (Math.abs(difference_Y) < Cursor.ANIM.circle.height)
					{
						difference_Y = 0;
					}
					else
					{
						difference_Y -= MathLab.GET_SIGN(difference_Y) * Cursor.ANIM.circle.height;
					}
				}
				function terminate_moving():void
				{
					activity = false;
							
					Cursor.REMOVE("Map_Moving_Circle");
				}
				function order_params():void
				{
					if (Boolean(Params))
					{
						if (Boolean(Params[0] is Number))
						{
							multiplier = Params[0];
						}
						else
						{
							Console.PRINT("Map","- WARNING > DEFINE_CONTROL() Param[0] ('multiplier') must be Number.", 2, "");
						}
						if (Boolean(Params[1] is int))
						{
							dist_pow = Params[1];
						}
						else
						{
							Console.PRINT("Map","- WARNING > DEFINE_CONTROL() Param[1] ('distance_power') must be Number.", 2, "");
						}
						if (Boolean(Params[2] is Number))
						{
							dist_resist_c = Params[2];
						}
						else
						{
							Console.PRINT("Map","- WARNING > DEFINE_CONTROL() Param[2] ('distant_resistance_coefficient') must be Number.", 2, "");
						}
					}
				}
			}
			function init_zoom_keys():void
			{
				var multiplier:Number = 0.1;
				var current_multiplier:Number = multiplier;
				
				InputControl.DEFINE("Map_Zoom_Keys", MOUSE_AREA, ICC_zoom, ["Keyboard"]);
				
				order_params();

				function ICC_zoom(Param:Object):void
				{
					if (Param.type == "Keyboard" && !Boolean(Gensys.STAGE.focus))
					{
						if ((!Param.NumpadAdd && !Param.NumpadSubstract) || !CONTROL_AVTIVE)
						{
							if (Cursor_Support)
							{
								Cursor.REMOVE("Map_Zoom_Keys");
							}
						}
						if (Param.NumpadAdd && CONTROL_AVTIVE)
						{
							if (Cursor_Support)
							{
								Cursor.SET_POS(get_frame_mid_poimt().x, get_frame_mid_poimt().y);
								Cursor.SET("Zooming_In", "Map_Zoom_Keys", 1);
							}
							
							update_current_multiplier();
							ZOOM(GET_SCALE() + current_multiplier, GET_SCREEN_MID_POINT());
						}
						if (Param.NumpadSubstract && CONTROL_AVTIVE)
						{
							if (Cursor_Support)
							{
								Cursor.SET_POS(get_frame_mid_poimt().x, get_frame_mid_poimt().y);
								Cursor.SET("Zooming_Out", "Map_Zoom_Keys", 1);
							}

							update_current_multiplier();
							ZOOM(GET_SCALE() - current_multiplier, GET_SCREEN_MID_POINT());
						}
					}
				}
				function update_current_multiplier():void
				{
					current_multiplier = GET_SCALE() * multiplier;
				}
				function order_params():void
				{
					if (Boolean(Params))
					{
						if (Boolean(Params[0] is Number))
						{
							multiplier = Params[0];
						}
						else
						{
							Console.PRINT("Map","- WARNING > DEFINE_CONTROL() Param[0] ('multiplier') must be Number.", 2, "");
						}
					}
				}
			}
			function init_zoom_scroll():void
			{
				var multiplier:Number = 0.05;
				var current_multiplier:Number = multiplier;
				var focus_point:Point = GET_SCREEN_MID_POINT();
				
				InputControl.DEFINE("Map_Zoom_Scroll", MOUSE_AREA, ICC_zoom, ["Mouse"]);
				
				order_params();
				
				function ICC_zoom(Param:Object):void
				{
					update_table();
					
					if (Param.type == "Mouse" && Param.target == MOUSE_AREA)
					{
						if (!Param.mouseWheel || !CONTROL_AVTIVE) 
						{
							terminate_cursor_anim();
						}
						else if (Param.mouseWheel && CONTROL_AVTIVE)
						{
							if (Cursor_Support)
							{
								if (Cursor.TAG == "Original" || Cursor.TAG == "Map_Zoom_Scroll")
								{
									Cursor.SET_POS(get_mouse_point_on_win().x, get_mouse_point_on_win().y);
	
									if (Param.delta > 0)
									{
										Processor.ABORT("Cursor", ["Map_Zoom_Scroll"]);
										Cursor.SET("Zooming_In", "Map_Zoom_Scroll", -1);
									}
									else if (Param.delta < 0)
									{
										Processor.ABORT("Cursor", ["Map_Zoom_Scroll"]);
										Cursor.SET("Zooming_Out", "Map_Zoom_Scroll", -1);
									}
								}
							}
							
							update_current_multiplier();
							update_focus_point(Param);
							ZOOM(GET_SCALE() + current_multiplier * Param.delta, get_mouse_point_on_map());
						}
					}
					else
					{
						terminate_cursor_anim();
					}
				}
				function update_current_multiplier():void
				{
					current_multiplier = GET_SCALE() * multiplier;
				}
				function update_focus_point(Param:Object):void
				{
					focus_point = new Point(Param.x, Param.y);
				}
				function terminate_cursor_anim():void
				{
					if (Cursor.TAG == "Map_Zoom_Scroll")
					{
						Processor.ADD(reset_cursor, 1, "Cursor", ["Map_Zoom_Scroll"], 150);
					}
				}
				function reset_cursor():void
				{
					Cursor.REMOVE("Map_Zoom_Scroll");
				}
				function order_params():void
				{
					if (Boolean(Params))
					{
						if (Boolean(Params[0] is Number))
						{
							multiplier = Params[0];
						}
						else
						{
							Console.PRINT("Map","- WARNING > DEFINE_CONTROL() Param[0] ('multiplier') must be Number.", 2, "");
						}
					}
				}
			}
			function init_auto_screen_cleaner():void
			{
				InputControl.DEFINE("Auto_Screen_Cleaner", MOUSE_AREA, ICC_clean_screen, ["Mouse"]);
				
				function ICC_clean_screen(Param:Object):void
				{
					if (Param.type == "Mouse")
					{
						if (Param.mouseMove)
						{
							if (Utility.TEST_OBJECT_STANDART(tools, ["Map_Scale"]))
							{
								if (get_mouse_point_on_win().x < WIN.Map_Scale.x + WIN.Map_Scale.width && get_mouse_point_on_win().y > WIN.Map_Scale.y)
								{
									WIN.Map_Scale.visible = false;
								}	
							}
							if (Utility.TEST_OBJECT_STANDART(tools, ["Zoom"]))
							{
								if (get_mouse_point_on_win().x > WIN.Zoom.x && get_mouse_point_on_win().y > WIN.Zoom.y)
								{
									WIN.Zoom.visible = false;
								}	
							}
						}
					}
				}
			}
		}
		
		public function REMOVE_CONTROL(Types:Array):void
		{
			InputControl.BREAK_LINKS(Types);
		}
		
		public function ADD_TOOL(Tool_Name:String, Params:Array = null):void
		{
			if (Boolean(WIN[Tool_Name]))
			{
				if (Boolean(WIN[Tool_Name].INIT))
				{
					WIN[Tool_Name].INIT(Params);
				}
				
				if (Tool_Name == "Movement_Sensor")
				{
					InputControl.DEFINE("Movement_Sensor", WIN.Movement_Sensor, ICC_check_movement_sensor, ["Frame"]);
				}
				
				tools[Tool_Name] = Params;
			}
			else
			{
				Console.PRINT("Map", "- WARNING > '" + Tool_Name + "' is not found on Map Tool Set.", 2, "");
			}
			
			function ICC_check_movement_sensor(Param:Object):void
			{
				var map_pos:Point = new Point(tools["Movement_Sensor"][0].x, tools["Movement_Sensor"][0].y);
				map_pos = Utility.CHANGE_COORD(map_pos, tools["Movement_Sensor"][0].parent, MAP);

				var win_pos:Point = Utility.CHANGE_COORD(map_pos, MAP, WIN);
				
				if (win_pos.x < WIN.Movement_Sensor.x)
				{
					SET_FRAME_POS(map_pos.x + (WIN.Movement_Sensor.width/GET_SCALE() - RECT.width)/2, NaN);
				}
				if (win_pos.x > WIN.Movement_Sensor.x + WIN.Movement_Sensor.width)
				{
					SET_FRAME_POS(map_pos.x - (WIN.Movement_Sensor.width/GET_SCALE() + RECT.width)/2, NaN);
				}
				if (win_pos.y < WIN.Movement_Sensor.y)
				{
					SET_FRAME_POS(NaN, map_pos.y + (WIN.Movement_Sensor.height/GET_SCALE() - RECT.height)/2);
				}
				if (win_pos.y > WIN.Movement_Sensor.y + WIN.Movement_Sensor.height)
				{
					SET_FRAME_POS(NaN, map_pos.y - (WIN.Movement_Sensor.height/GET_SCALE() + RECT.height)/2);
				}
			}
		}
		
		public function REMOVE_TOOL(Tool_Names:Array):void
		{
			for (var i:int; i < Tool_Names.length; i ++)
			{
				if (Tool_Names[i] == "Movement_Sensor")
				{
					InputControl.BREAK_LINKS(["Movement_Sensor"]);
				}
				
				if (Boolean(WIN[Tool_Names[i]]))
				{
					delete tools[Tool_Names[i]];
					
					WIN[Tool_Names[i]].visible = false;
				}
			}
		}
		
		public function GET_MAP_POS():Point
		{
			return new Point(RECT.x, RECT.y);
		}
		
		public function GET_SCALE():Number
		{
			return Math.min(MAP.scaleX, MAP.scaleY);
		}
		
		public function GET_SCREEN_MID_POINT():Point
		{
			return new Point(RECT.x + RECT.width/2, RECT.y + RECT.height/2);
		}
		
		public function GET_POINT(Position:Point, From:String, To:String):Point
		{
			if (!Boolean(From == To))
			{
				if (From == "Rect" && To == "Map")
				{
					return convert_rect_to_map(Position);
				}
				else if (From == "Map" && To == "Rect")
				{
					return convert_map_to_rect(Position)
				}
				else
				{
					Console.PRINT("Map","X ERROR > ERROR CODE : xxxx > Invalid parameters. You can select only 'Win' and 'Map'.",3,"");
					return null;
				}
			}
			else
			{
				return Position;
			}
			
			function convert_rect_to_map(Rect_Point:Point):Point
			{
				return new Point((Rect_Point.x - RECT.x) * GET_SCALE(), (Rect_Point.y - RECT.y) * GET_SCALE());
			}
			function convert_map_to_rect(Map_Point:Point):Point
			{
				return new Point((Map_Point.x / GET_SCALE()) + RECT.x , (Map_Point.y / GET_SCALE()) + RECT.y);
			}
		}
		
		// ------------------------------------------------------------
		// FUNCTIONS :
		// ------------------------------------------------------------

		private function get_mouse_point_on_map():Point
		{
			return new Point(MAP.mouseX, MAP.mouseY);
		}
		private function get_mouse_point_on_win():Point
		{
			return new Point(WIN.mouseX, WIN.mouseY);
		}
		private function get_frame_mid_poimt():Point
		{
			return new Point(WIN.x + WIN.width/2, WIN.y + WIN.height/2);
		}
		private function update_map_scale():void
		{	
			var current_scale_factor:Number = SCALE_FACTOR * GET_SCALE();
			var min_unit_length:Number = WIN.Map_Scale.min_unit_length;
			var maj_unit_length:Number = WIN.Map_Scale.maj_unit_length;

			if (current_scale_factor > 0)
			{
				var maj_digit:int = calculate_digits((maj_unit_length * 4)/current_scale_factor);
				var min_digit:int = calculate_digits((min_unit_length * 1)/current_scale_factor);
	
				for (var i:int = 1; i <= 4; i ++)
				{
					var maj_value:Number = MathLab.SET_SIGNIFICANT_FIGURE((maj_unit_length * i * find_multiplier(maj_digit))/current_scale_factor,2);
				
					WIN.Map_Scale["maj_"+i].text = maj_value + find_unit(maj_digit);
				}

				for (var j:int = 1; j <= 3; j ++)
				{
					var min_value:Number = MathLab.SET_SIGNIFICANT_FIGURE((min_unit_length * j * find_multiplier(min_digit))/current_scale_factor,2)
					
					WIN.Map_Scale["min_"+j].text = min_value + find_unit(min_digit);
				}
				
				if (maj_value == 0)
				{
					WIN.Map_Scale.visible = false;
				}
				else
				{
					WIN.Map_Scale.visible = true;
				}
			}
		}
		private function find_unit(Deger:int):String
		{
			var unit:String;
			
			switch(Deger)
			{
				case -1:
					unit = " cm";
					break;
				case -2:
					unit = " mm";
					break;
				case -3:
					unit = " µm";
					break;
				case -4:
					unit = " nm";
					break;
				case 1:
					unit = " m";
					break;
				case 2:
					unit = " km";
					break;
				case 3:
					unit = " Mm";
					break;
				case 4:
					unit = " Mkm";
					break;
				case 5:
					unit = " AU";
					break;
				case 6:
					unit = " Light Day";
					break;
				case 7:
					unit = " Light Year";
					break;
			}
			
			return unit;
		}
		private function find_multiplier(Deger:int):Number
		{
			var multiplier:Number;
			
			switch(Deger)
			{
				case -1:
					multiplier = 100;
					break;
				case -2:
					multiplier = 1000;
					break;
				case -3:
					multiplier = 1000000;
					break;
				case -4:
					multiplier = 1000000000;
					break;
				case 1:
					multiplier = 1;
					break;
				case 2:
					multiplier = (1/1000);
					break;
				case 3:
					multiplier = (1/1000000);
					break;
				case 4:
					multiplier = (1/1000000000);
					break;
				case 5:
					multiplier = (1/au);
					break;
				case 6:
					multiplier = (1/ld);
					break;
				case 7:
					multiplier = (1/ly);
					break;
			}
			
			return multiplier;
		}
		private function calculate_digits(Deger:Number):int
		{
			var digit_number:uint;
			var tag:int;
			
			if (Deger >= 1)
			{
				digit_number = MathLab.FIND_DIGIT_NUMBER(Deger);
				
				if (digit_number <= 3)
				{
					tag = 1;
				}
				else if (digit_number <= 6)
				{
					tag = 2;
				}
				else if (digit_number <= 9)
				{
					tag = 3;
				}
				else if (digit_number <= 12)
				{
					tag = 4;
				}
				else if (Deger/au <= 100)
				{
					tag = 5;
				}
				else if (Deger/ld <= 365)
				{
					tag = 6;
				}
				else
				{
					tag = 7;
				}
			}
			else if (Deger < 1)
			{
				if (Deger >= 0.01)
				{
					tag = -1;
				}
				else if (Deger >= 0.001)
				{
					tag = -2;
				}
				else if (Deger >= 0.000001)
				{
					tag = -3;
				}
				else if (Deger >= 0.0000000001)
				{
					tag = -4;
				}
			}
			
			return tag;
		}
		private function update_table():void
		{
			/*Console.TABLE(1, "Mouse:", "", true);
			Console.TABLE(2, "Map X:", get_mouse_point_on_map().x);
			Console.TABLE(3, "Map Y:", get_mouse_point_on_map().y);
			Console.TABLE(4, "Win X:", get_mouse_point_on_win().x);
			Console.TABLE(5, "Win Y:", get_mouse_point_on_win().y);
			
			Console.TABLE(6, "RECT:", "", true);
			Console.TABLE(7, "RECT X:", RECT.x);
			Console.TABLE(8, "RECT Y:", RECT.y);
			Console.TABLE(9, "RECT W:", RECT.width);
			Console.TABLE(10, "RECT H:", RECT.height);
		
			Console.TABLE(26, "Control:", CONTROL_AVTIVE);*/
		}
	}
}