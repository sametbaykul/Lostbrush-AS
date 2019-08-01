/*

	------------------------------------------------------------
	- PHYSICS ENGINE(C) 2014 - 2016
	------------------------------------------------------------

	* FULL STATIC
	* INIT : true
	
	v1.0 : 09.06.2014 	: Hareketli görsel nesnelerde çarpışma ve hareket gibi temel fizik kurallarını gerçekleştirmek amacıyla üretildi.
	
	v2.0 : 02.08.2015 	: Box2D Fizik motoru eklenmeye başlandı.
	v2.1 : 28.02.2016 	: Kullanıma hazır ilk sürüm.
	v2.2 : 30.04.2016	: APPLY() metodu üzerindeki bazı hatalar giderildi.
	v2.3 : 30.*4.2016	: GET_PED() metodu ile PED nesnelerine ılaşabilirsiniz.
	
	GELİŞTİRMELER		:	+ CREATE_COMPOUND() Weld parametresi -> Compound parçalarını otomatik olarak cross 'Weld' ile birleştir.
							+ CREATE_COMPOUND() Fiz Parametresi -> Ağırlık merkezini central objede toplamak için diğer nesnelerin ağırlıklarını otomatik olarak sıfırla.
							+ COMPOUND mekanizmalarını test et.
							+ Debugger Desteği: Velocity, Impulse, Force arayüzleri sağla.
							+ APPLY() metodunu test et.
							+ Friction mekanizmasını düzenle.
							+ Hız sınırları eklenmeli. (Ya da çok aşırı dönme turu da olabilir.) Aşırı hızda offset sorunu olduğundan.
							
							+ Compound'lar için özelleştirilmiş PHYISCS_UPDATE() metodları geliştirilebilir.
							+ CREATE_BODY() için BitMap desteği sağla.
							+ Daha fazla ayar ve kontrol için Physics.as sınıfına özel bir pencere desteği sağla. (Single Step veya debugger araçları gibi) (TestBed'den ilham alınabilir)
							+ Warm Starting ekle.
							+ Physics.as penceresine ayrıca b2World, b2Body, b2Joint özelliklerini gösteren bir yapı ekle.
							+ Daha fazla SET() metodu aksiyonu ekle.
							+ Hız, kuvvet vektörleri, çarpışma görselleri gibi daha fazla debugger görseli oluştur.
							+ www.iforce2d.net Physics.as geliştirmeleri için ilham kaynağı olabilir.
							
							AdvancedPhysics Hakkında: (Ayrı bir sınıf olarak)
							
							+ Realistic Simulation Mode (with Processsor.as)
							+ Recording.
							+ Step Next/Step Back Methods.
							+ Expansion/Depression Phenomenon.
							+ Bomb Effects.
							+ Fragmentation.
							+ Joint Fragmentation.
							+ Elastic/Plastic Deformations.

	UYARILAR			:	! Physics.as sınıfı kendine ait bir Map sınıf örneğine ihtiyaç duyar. Bu Map sınıfı örneğinin kullandığı MC'yi başka bir Map sınıfında kullanmanız durumunda hata alırsınız. Map sınıfı static duruma getirildiğinde Physics.as ile olan etkileşimini yeniden gözden geçirmekte fayda var.
							! Physics.as simulasyon zamanında "P_SCALAR" ve "MULTIPLIER" i değiştir ve sonuçları analiz et.
							! Polygon Dynamic Body'lerde hızlı fiziksel etkileşimlerde açısal offset hatası tespit edildi.
							! UPDATE_BODY() metodunu test et. (Polygon Dynamic Body için boyutsal offset sorunu tespit edildi)
							! Canvas Content üzerinde, Component gibi yabancı cisimler 'debugger mod'un düzgün çalışmasını engelleyebilir.
							! update_collision() fonksiyonu ile ilgili, collision_pointlerin posizyonları ile ilgili hatalar mevcut.
	
	by Samet Baykul

*/

package lbl
{
	// Flash Library:
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	// Box2D Library:
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Common.b2Settings;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2World;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2DebugDraw;
	import Box2D.Dynamics.b2ContactListener;
	import Box2D.Dynamics.Joints.*;
	import Box2D.Dynamics.b2FilterData;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Collision.b2AABB;
	import Box2D.Collision.b2Manifold;
	//import Box2D.Collision.b2Segment;
	// External Library:
	import Box2DSeparator.b2Separator;
	// LBL Core:
	import lbl.MathLab;
	import lbl.Utility;
	import lbl.Gensys;
	import lbl.Processor;
	// LBL Control:
	import lbl.InputControl;
	import lbl.Console;
	import lbl.Interaction;
	import lbl.Map;
	

	public class Physics
	{
		
		// ------------------------------------------------------------
		// PROPERTIES :
		// ------------------------------------------------------------
		
		public static var POL:Array = new Array();							// Physics Object List
		public static var COLDOL:Array = new Array();						// Collision Data Object List
		public static var WORLD:b2World;
		public static var MAP:Map;
		public static var CANVAS:MovieClip;
		public static var CONTENT:MovieClip;
		public static var TIMER:Timer;
		public static var P_SCALER:Number;									// Physical Scaler
		public static var MULTIPLIER:Number;								// Dimension Multiplier	
		public static var SCALE:Number;										// Map Scale
		public static var SIMULATING:Boolean;
		
		private static var PED_memory:Array = new Array();					// PED (Physics Engine Data) Memory
		private static var JDO_memory:Array = new Array();					// JDO (Joint Data Object) Memory
		private static var MJO:Object;										// Mouse Joint Object
		private static var COLDO:Object = new Object();						// Collission Data Object
		private static var body_list:Array = new Array();
		private static var body_name_list:Array = new Array();
		private static var all_corners_list:Array = new Array();
		private static var mouse_joint_list:Array = new Array();
		private static var segment_list:Array = new Array();
	
		private static var debug_sprite:Sprite;
		private static var full_mouse_support:Boolean;
		private static var mouse_active:Boolean;
		private static var debug_active:Boolean;
		private static var self_timer:Boolean;
		private static var time_speed:Number;
		private static var simulate_delay:Number;
		private static var iteration_velocity:int = 8;
		private static var iteration_position:int = 3;
		
		// Class Info:
		private static var id:String = "PHY";
		private static var no:int = 003;
		
		public function Physics()
		{
			// Full static class
		}

		// ------------------------------------------------------------
		// METHODS :
		// ------------------------------------------------------------

		// Global Methods:

		public static function INIT(Canvas:MovieClip, Window:MovieClip, Map_Limits:Array = null, Margin:Number = 0, Timer_Link:String = "Self", Full_Mouse_Support:Boolean = false, Debugger_Support:Boolean = false):void
		{
			init_vars();
			init_canvas();
			init_map();
			init_timer();
			init_MJO();
			init_commands();
			
			function init_vars():void
			{
				debug_active = Debugger_Support;
				full_mouse_support = Full_Mouse_Support;
			}
			function init_canvas():void
			{
				CANVAS = Canvas;
				
				if (Boolean(CANVAS.INIT))
				{
					CANVAS.INIT();
				}
				
				CONTENT = CANVAS.Content;
			}
			function init_map():void
			{
				MAP = new Map(CANVAS, Window, Map_Limits, Margin, -1, true, debug_active);
			}
			function init_timer():void
			{
				if (Gensys.TIMEL[Timer_Link])
				{
					TIMER = Gensys.TIMEL[Timer_Link];
				}
				else if (Timer_Link == "Self")
				{
					TIMER = Gensys.NEW_TIMER("Physics_Clock");
				}
				else
				{
					TIMER = Gensys.NEW_TIMER(Timer_Link);
				}
			}
			function init_MJO():void
			{
				SET_MOUSE_SUPPORT(full_mouse_support);
			}
			function init_commands():void
			{
				Console.ADD_COMMAND(id, "phydebug", pedebug, ["Active:Boolean"], "On/Off for debugger mode.");
				Console.ADD_COMMAND(id, "phystart", START, null, "Starts the Physics.");
				Console.ADD_COMMAND(id, "phystop", STOP, null, "Stops the Physics.");
				Console.ADD_COMMAND(id, "phyinfo", peinfo, null, "Overall info about Physics.as");
				Console.ADD_COMMAND(id, "phystep", SINGLE_STEP, null, "Single step for physical simulating.");
				
				function pedebug(Switch:String):void
				{
					if (Switch == "true" || Switch == "on" || Switch == "1")
					{
						Console.PRINT("Physics", "Debugger has been enabled.", 1);
						DEBUG(true);
					}
					else
					{
						Console.PRINT("Physics", "Debugger has been disabled.", 1);
						DEBUG(false);
					}
				}
				function peinfo():void
				{
					STOP();
					
					var World:Object = new Object();
					World.Canvas = CANVAS.name;
					World.Elapsed = String(MathLab.SET_SIGNIFICANT_FIGURE((TIMER.currentCount * TIMER.delay * 0.001), 3)) + " seconds.";
					World.Debugger = debug_active;
					World.Gravity = "(X, Y): (" + WORLD.GetGravity().x + ", " + WORLD.GetGravity().y + ")";
					World.Time_Speed = time_speed;
					World.P_Scaler = P_SCALER;
					World.Multiplier = MULTIPLIER;
					World.Scale = SCALE;
					World.World_Distance = "1[px]\t\t=\t" + Number(SCALE) + "[m]";
					World.World_Area = "1[px2]\t\t=\t" + Number(SCALE * SCALE) + "[m2]";
					World.World_Density = "1[kg/px2]\t\t=\t" + Number(1/MULTIPLIER) + "[kg/m2]";
					World.World_Mass = "1[kg]\t\t=\t" + Number(1/P_SCALER) + "[kg]";
					World.World_Velocity = "1[px/s]\t\t=\t" + Number(SCALE) + "[m/s]";
					World.World_Force = "1[kg.px/s2]\t=\t" + Number(MULTIPLIER) + "[N]";
					World.Iterataion = "Velocity : " + iteration_velocity + ", Position: " + iteration_position;
					World.Number_of_Bodies =  WORLD.GetBodyCount();
					World.Number_of_Contact =  WORLD.GetContactCount();
					World.Number_of_Joints =  WORLD.GetJointCount();
					World.Number_of_Proxy = WORLD.GetProxyCount();
					World.Simulate_Time_Delay = simulate_delay;
					
					Console.DYNAMIC_DATA("World", World);
					
					Console.PRINT("Physics", "Physical World Information: ", 1);
					Console.PRINT_DATA("Physics", "World", World);
					Console.PRINT("Physics", "Information about all 'Physics' objects: ", 1);
					
					for (var i:int = 0; i < POL.length; i ++)
					{
						Console.DYNAMIC_DATA(POL[i].parent.name + "." + POL[i].name + ".PED", POL[i].PED);
								
						if (Boolean(POL[i].PED.is_mother))
						{
							for (var j:int = 0; j < POL[i].PED.children.length; j ++)
							{
								Console.DYNAMIC_DATA(POL[i].parent.name + "." + POL[i].name + "." + POL[i].PED.children[j].name + ".PED", POL[i].PED.children[j].PED);
							}
						}
					}
				}
			}
		}
		public static function CREATE_WORLD(Gravity_Vector_X:Number, Gravity_Vector_Y:Number, Time_Speed:Number = 1, Scale:Number = 30, Multiplier:Number = 1):void
		{
			P_SCALER = Scale;
			MULTIPLIER = Multiplier;
			SCALE = MULTIPLIER / P_SCALER;
			time_speed = Time_Speed;
			
			/*Console.TABLE(12, "P_Scaler:", P_SCALER);
			Console.TABLE(13, "Multiplier:", MULTIPLIER);
			Console.TABLE(14, "Scale:", SCALE);
			Console.TABLE(15, "X Time:", time_speed);*/
			
			set_simulate_delay();
			init_world();
			set_map_scale();
			init_debugger();

			function set_simulate_delay():void
			{
				simulate_delay = (1 / Gensys.FRAME_RATE) * Time_Speed;
				iteration_velocity = iteration_velocity + int(((P_SCALER / 10)-1) * iteration_velocity);
				iteration_position = iteration_position + int(((P_SCALER / 10)-1) * iteration_position);
			}
			function init_world():void
			{
				var contact_listener = new b2ContactListener();

				WORLD = new b2World(new b2Vec2(Gravity_Vector_X, Gravity_Vector_Y),true);
				WORLD.SetContactListener(contact_listener);
			}
			function set_map_scale():void
			{
				MAP.UPDATE_SCALE(SCALE);
			}
			function init_debugger():void
			{
				if (debug_active)
				{
					var debug_draw:b2DebugDraw = new b2DebugDraw();
					debug_sprite = new Sprite();

					CONTENT.addChild(debug_sprite);
					debug_draw.SetSprite(debug_sprite);
					debug_draw.SetDrawScale(P_SCALER);
					debug_draw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit | b2DebugDraw.e_aabbBit | b2DebugDraw.e_centerOfMassBit);
					debug_draw.SetFillAlpha(0.5);
					WORLD.SetDebugDraw(debug_draw);
				}
			}
		}
		public static function SET_TIME_SPEED(Speed:Number = 1):void
		{
			time_speed = Speed;
			simulate_delay = (1 / Gensys.FRAME_RATE) * time_speed;
		}
		public static function GET_TIME_SPEED():Number
		{
			return time_speed;
		}
		public static function START():void
		{
			if (!SIMULATING)
			{
				if (Boolean(Gensys.STAGE))
				{
					SIMULATING = true;
					
					TIMER.addEventListener(TimerEvent.TIMER,update_world,false,0,true);
					
					Console.PRINT("Physics", "Physics Engine has been started...");
				}
				else
				{
					Console.PRINT("Physics","X ERROR > ERROR CODE : 002 > Physics cannot start. Please check the Gensys INIT() Method is used properly before using this function.",3,"");
				}
			}
		}
		public static function STOP():void
		{
			if (SIMULATING)
			{
				Console.PRINT("Physics", "Physics Engine has been stopped.");
			
				SIMULATING = false;
				TIMER.removeEventListener(TimerEvent.TIMER,update_world);
			}
		}
		public static function SINGLE_STEP():void
		{
			STOP();
			
			update_world();
		}
		public static function SET_PERFORMANCE(Iteration_Velocity:Number = 10, Iteration_Position:Number = 10):void
		{
			iteration_velocity = Iteration_Velocity;
			iteration_position = Iteration_Position;
		}
		public static function DEBUG(Switch:Boolean):void
		{
			debug_active = Switch;
			
			if (Switch)
			{
				debug_sprite.visible = true;
			}
			else
			{
				debug_sprite.visible = false;
			}
					
			for each (var mcPE_corners_list in all_corners_list)
			{
				for (var i:int = 0; i < mcPE_corners_list.length; i++)
				{
					mcPE_corners_list[i].visible = Switch;
				}
			}
		}
		
		// Body Methods:
		
		public static function CREATE_BODY(mcPE_List:Array):void
		{
			var POL_prev_length:int = POL.length;
			
			if (check_body_standarts(mcPE_List))
			{
				for (var i:uint = 0; i < mcPE_List.length; i++)
				{
					POL[i + POL_prev_length] = mcPE_List[i];
					body_list[i + POL_prev_length] = create_body(mcPE_List[i]);
					body_name_list[i + POL_prev_length] = mcPE_List[i].name;
				}
			}
			
			function create_body(mcPE:MovieClip):b2Body
			{
				mcPE.PED.fix_list = new Array();
				
				try
				{
					if (Boolean(mcPE.PED.type == "Kinematic"))
					{
						init_kinematic_body(mcPE);
					}
					else
					{
						sync_shape_to_body(mcPE);
					}

					var body:b2Body = WORLD.CreateBody(body_def(mcPE));
					
					attach_fix_to_body(mcPE, mcPE, body);
					
					body_list.push(body);
				}
				catch(e:Error)
				{
					Console.PRINT("Physics","X ERROR > ERROR CODE : 003 > An error occured while creating a new body.",3,"");
					Console.PRINT("Physics","- ERROR DETAIL > " + e.getStackTrace(),2,"");
				}

				return body;
			}
		}
		public static function CREATE_COMPOUND(mcPE_Body:MovieClip, Parts:Array, Assembly:String = "Fix"):void
		{
			switch (Assembly)
			{
				case "Weld":
					create_body_with_weld();
					break;
				default:
					create_body_with_fixture();
					break;
			}
			
			function create_body_with_fixture():void
			{
				var POL_prev_length:int = POL.length;
				
				if (check_body_standarts([mcPE_Body]) && check_body_standarts(Parts))
				{
					POL[POL_prev_length] = mcPE_Body;
					body_list[POL_prev_length] = create_body(mcPE_Body);
					body_name_list[POL_prev_length] = mcPE_Body.name;
				}
				
				function create_body(mcPE:MovieClip):b2Body
				{
					mcPE.PED.fix_list = new Array();
					
					try
					{
						if (Boolean(mcPE.PED.type == "Kinematic"))
						{
							init_kinematic_body(mcPE);
						}
						else
						{
							sync_shape_to_body(mcPE);
						}
						
						var body:b2Body = WORLD.CreateBody(body_def(mcPE));
						
						attach_fix_to_body(mcPE, mcPE, body);
						
						mcPE_Body.PED.is_mother = true;
						mcPE_Body.PED.children = Parts;
						
						for (var i:int = 0; i < Parts.length; i++)
						{
							Parts[i].PED.is_child = true;
							Parts[i].PED.mother = mcPE_Body;
							Parts[i].PED.brothers = Parts;	
								
							if (Boolean(Parts[i].PED.type == "Kinematic"))
							{
								init_kinematic_body(Parts[i]);
							}
							else
							{
								sync_shape_to_body(Parts[i]);
							}
							
							attach_fix_to_body(mcPE, Parts[i], body);
						}
						
						body_list.push(body);
					}
					catch(e:Error)
					{
						Console.PRINT("Physics","X ERROR > ERROR CODE : 004 > An error occured while creating a compound body.", 3, "");
						Console.PRINT("Physics","- ERROR DETAIL > " + e,2,"");
					}
	
					return body;
				}
			}
			function create_body_with_weld():void
			{
				var JDO_weld:Object = new Object();
				var JDO_name:String = new String();
				
				CREATE_BODY([mcPE_Body]);
				CREATE_BODY(Parts);
				
				for (var i:int = 0; i < Parts.length; i++)
				{
					weld_to_body(Parts[i]);
				}
				
				function weld_to_body(Part:MovieClip):void
				{
					JDO_name = "part_" + Part.name + "_weld";
					JDO_weld = Physics.TAKE_JDO(JDO_name, "Weld", [0,0], [mcPE_Body.PED.SYNC.global_init_x - Part.PED.SYNC.global_init_x, Part.PED.SYNC.global_init_y - mcPE_Body.PED.SYNC.global_init_y]);
	
					Physics.UPDATE_JDO(JDO_name, JDO_weld);
					Physics.ADD_JOINT(mcPE_Body, Part, JDO_weld);
				}
			}
		}
		public static function UPDATE_BODY(mcPE_List:Array):void
		{
			if (Utility.TEST_ARRAY_ELEMENTS(POL, mcPE_List))
			{
				for (var i:int = 0; i < mcPE_List.length; i ++)
				{
					mcPE_List[i].parent.rotation = 0;
					
					destroy_old_fix(mcPE_List[i], get_body(mcPE_List[i]))
					create_new_fix(mcPE_List[i], get_body(mcPE_List[i]));
				}
			}
			else
			{
				Console.PRINT("Physics","X ERROR > ERROR CODE : 006 > These mcPE_List is invalid for updating.",3,"");
			}
			
			function destroy_old_fix(mcPE:MovieClip, Body:b2Body):void
			{
				for each(var fix_gorup:* in mcPE_List[i].PED.fix_list)
				{
					if (fix_gorup is Array)
					{
						for each(var fix:b2Fixture in fix_gorup)
						{
							Body.DestroyFixture(fix);
						}
					}
					else
					{
						Body.DestroyFixture(fix_gorup);
					}
				}
			}
			function create_new_fix(mcPE:MovieClip, Body:b2Body):void
			{
				mcPE.PED.fix_list = new Array();
				
				try
				{
					if (Boolean(mcPE.PED.type == "Kinematic"))
					{
						init_kinematic_body(mcPE);
					}
					else
					{
						sync_shape_to_body(mcPE);
					}
					
					attach_fix_to_body(mcPE, mcPE, Body);
					
					if (mcPE.PED.is_mother)
					{
						for (var i:int = 0; i < mcPE.PED.children.length; i++)
						{
							if (Boolean(mcPE.PED.children[i].PED.type == "Kinematic"))
							{
								init_kinematic_body(mcPE.PED.children[i]);
							}
							else
							{
								sync_shape_to_body(mcPE.PED.children[i]);
							}
							
							attach_fix_to_body(mcPE, mcPE.PED.children[i], Body);
						}
					}
				}
				catch(e:Error)
				{
					Console.PRINT("Physics","X ERROR > ERROR CODE : 005 > An error occured while creating a new body while the body is updating.", 3, "");
					Console.PRINT("Physics","- ERROR DETAIL > " + e.getStackTrace(), 2, "");
				}
			}
		}
		public static function SCALE_BODY(mcPE:MovieClip, Parts:Array = null, Width_and_Height:Array = null, Scale:Array = null, Keep_Mass:Boolean = true):void
		{
			if (Utility.TEST_ARRAY_ELEMENTS(POL, [mcPE]))
			{
				if (Boolean(Width_and_Height) || Boolean(Scale))
				{	
					if(!Boolean(Parts))
					{
						update_mc_dim(mcPE);
						
						if (Boolean(mcPE.PED.children))
						{
							Parts = mcPE.PED.children;
						}
					}
					
					if (mcPE.PED.is_mother)
					{
						if (Utility.TEST_ARRAY_ELEMENTS([mcPE], Parts))
						{
							update_mc_dim(mcPE);
						}
						if (Utility.TEST_ARRAY_ELEMENTS(mcPE.PED.children, Parts))
						{
							for (var i:int = 0; i < Parts.length; i++)
							{
								update_mc_dim(Parts[i]);
							}
						}
						else
						{
							Console.PRINT("Physics","- WARNING > There is no any child found on this mcPE", 2, "");
						}
					}
					
					if (!Boolean(Scale))
					{
						var init_w:Number = mcPE.width;
						var init_h:Number = mcPE.height;
						Scale[0] = Width_and_Height[0]/init_w;
						Scale[1] = Width_and_Height[1]/init_h;
					}
					
					STRECH_JOINTS([mcPE], Scale[0], Scale[1]);
					UPDATE_BODY([mcPE]);
				}
				else
				{
					Console.PRINT("Physics","X ERROR > ERROR CODE : 008 > Invalid parameters for scaling.", 3, "");
				}
			}
			else
			{
				Console.PRINT("Physics","X ERROR > ERROR CODE : 007 > These " + mcPE + " is invalid for scaling.", 3, "");
			}
			
			function update_mc_dim(mc:MovieClip):void
			{
				var mass:Number = mc.width * mc.height * mc.PED.density;
				
				Utility.SET_REAL_DIM(mc, Width_and_Height, Scale);
				
				if (Keep_Mass)
				{
					mc.PED.density = mass / (mc.width * mc.height);
				}
			}
		}
		public static function REMOVE_BODY(mcPE_List:Array):void
		{
			if (Utility.TEST_ARRAY_ELEMENTS(POL, mcPE_List))
			{
				for (var i:int = 0; i < mcPE_List.length; i ++)
				{
					var index:int = POL.indexOf(mcPE_List[i]);
					WORLD.DestroyBody(body_list[index]);
					
					destroy_PED(POL[index]);
					all_corners_list[POL[index].name] = null;
					POL[index] = null;
					body_list[index] = null;
					body_name_list[index] = null;
				}
				
				Utility.COMPRESS_ARRAY(all_corners_list);
				Utility.COMPRESS_ARRAY(POL);
				Utility.COMPRESS_ARRAY(body_list);
				Utility.COMPRESS_ARRAY(body_name_list);
			}
			else
			{
				Console.PRINT("Physics","X ERROR > ERROR CODE : 009 > These mcPE_List is invalid for removing.", 3 ,"");
			}
			
			function destroy_PED(mcPE:MovieClip):void
			{
				if (Boolean(mcPE.PED.body_SP))
				{
					CONTENT.removeChild(mcPE.PED.body_SP);
				}
			}
		}
		/*public static function MERGE(A:MovieClip, B:MovieClip):void
		{
			trace(get_body(A));
			trace(get_body(B));
			get_body(A).Merge(get_body(B));
		}*/
		public static function ADD_NEW_PARTS(mcPE_Body:MovieClip, mcPE_List_For_Parts:Array):void
		{
			try
			{
				if (Boolean(get_body(mcPE_Body)))
				{
					if (!Boolean(mcPE_Body.PED.is_mother))
					{
						mcPE_Body.PED.is_mother = true;
						mcPE_Body.PED.children = new Array();
					}
					
					for (var i:int = 0; i < mcPE_List_For_Parts.length; i ++)
					{
						if (!Boolean(mcPE_Body.PED.fix_list[mcPE_List_For_Parts[i].name]))
						{
							if (Boolean(mcPE_Body.PED.children))
							{
								if (Boolean(Utility.TEST_ARRAY_ELEMENTS(mcPE_Body.PED.children, [mcPE_List_For_Parts[i]])))
								{
									sync_shape_to_body(mcPE_List_For_Parts[i], false);
								}
								else
								{
									create_new_fixture(mcPE_List_For_Parts[i]);
								}
							}
							else
							{
								mcPE_Body.PED.children = new Array();
								create_new_fixture(mcPE_List_For_Parts[i]);
							}
							
							attach_fix_to_body(mcPE_Body, mcPE_List_For_Parts[i], get_body(mcPE_Body));
						}
						else
						{
							Console.PRINT("Physics","- WARNING > '" + mcPE_Body.name + "' has already such a fixture '" + mcPE_List_For_Parts[i].name, 2, "");
						}
					}
					for (var j:int = 0; j < mcPE_List_For_Parts.length; j ++)
					{
						mcPE_List_For_Parts[j].PED.brothers = mcPE_Body.PED.children;
					}
				}
				else
				{
					Console.PRINT("Physics","X ERROR > ERROR CODE : 011 > No found such a body '" + mcPE_Body.name + "'.",3,"");
				}
			}
			catch(e:Error)
			{
				Console.PRINT("Physics","X ERROR > ERROR CODE : 010 > An error occured while adding component to body.",3,"");
				Console.PRINT("Physics","- ERROR DETAIL > " + e.getStackTrace(),2,"");
			}
			
			function create_new_fixture(Child_MC:MovieClip):void
			{
				if (check_body_standarts([Child_MC]))
				{
					mcPE_Body.PED.children.push(Child_MC);
					Child_MC.PED.is_child = true;
					Child_MC.PED.mother = mcPE_Body;
					Child_MC.PED.brothers = new Array();
					
					if (Boolean(Child_MC.PED.type == "Kinematic"))
					{
						init_kinematic_body(Child_MC);
					}
					else
					{
						sync_shape_to_body(Child_MC);
					}
				}
			}
		}
		public static function REMOVE_PARTS(mcPE_Body:MovieClip, mcPE_List_For_Parts:Array):void
		{
			if (Boolean(get_body(mcPE_Body)))
			{
				for (var i:int = 0; i < mcPE_List_For_Parts.length; i ++)
				{
					if (Boolean(mcPE_Body.PED.fix_list[mcPE_List_For_Parts[i].name]))
					{
						if (mcPE_Body.PED.fix_list[mcPE_List_For_Parts[i].name] is Array)
						{
							var poygon_fixture_list:Array = mcPE_Body.PED.fix_list[mcPE_List_For_Parts[i].name];
							
							for (var j:int = 0; j < poygon_fixture_list.length; j ++)
							{
								get_body(mcPE_Body).DestroyFixture(poygon_fixture_list[j]);
							}
						}
						else
						{
							get_body(mcPE_Body).DestroyFixture(mcPE_Body.PED.fix_list[mcPE_List_For_Parts[i].name]);
						}
						
						delete mcPE_Body.PED.fix_list[mcPE_List_For_Parts[i].name];
						Console.PRINT("Physics", "'" + mcPE_List_For_Parts[i].name + "' is removed.",1,"");
					}
					else
					{
						Console.PRINT("Physics","X ERROR > ERROR CODE : 013 > No found such a part '" + mcPE_List_For_Parts[i].name + "' on '" + mcPE_Body.name + "'.", 3, "");
					}
				}
			}
			else
			{
				Console.PRINT("Physics","X ERROR > ERROR CODE : 012 > No found such a body '" + mcPE_Body.name + "'.", 3, "");
			}
		}
		
		// Joint Methods:
		
		public static function ADD_JOINT(mcPE_A:MovieClip, mcPE_B:MovieClip, Joint_Data:Object):void
		{
			var joint_standarts:Array = new Array();
			var JDO:Object = new Object();
			
			start_requirements();
			JDO = prepare_JDO(Joint_Data)
			
			if (Boolean(JDO))
			{
				create_joint();
				mcPE_A.PED.joint_list[Joint_Data.name] = JDO;
			}
			
			function start_requirements():void
			{
				// -> Fine Tunning
				joint_standarts["Distance"] = ["name"];
				joint_standarts["Friction"] = ["name"];
				joint_standarts["Revolute"] = ["name"];
				joint_standarts["Prismatic"] = ["name"];
				joint_standarts["Line"] = ["name"];
				joint_standarts["Pulley"] = ["name"];
				joint_standarts["Gear"] = ["name", "jointA", "jointB"];
				joint_standarts["Weld"] = ["name"];
			}
			function prepare_JDO(pre_JDO:Object):Object
			{
				var result:Object = false;
				var post_JDO:Object = new Object();
				
				Processor.RUN_CHAIN([_1_check_bodies, 
								   _2_check_joint_type, 
								   _3_check_joint_type_requirements,
								   _4_update_post_JDO, 
								   _5_check_PED_joint_list, 
								   _6_calculate_position,
								   _7_finish_preparation])
				
				return result;
				
				function _1_check_bodies():Boolean
				{
					if (Boolean(get_body(mcPE_A)) && Boolean(get_body(mcPE_B)))
					{
						post_JDO.mcPE_a = mcPE_A;
						post_JDO.mcPE_b = mcPE_B;
						post_JDO.body_a = get_body(mcPE_A);
						post_JDO.body_b = get_body(mcPE_B);

						return true;
					}
					else
					{
						Console.PRINT("Physics","X ERROR > ERROR CODE : 014 > JDO has no proper body!", 3, "");
						
						return false;
					}
				}
				function _2_check_joint_type():Boolean
				{
					if (Boolean(pre_JDO.type))
					{
						post_JDO.type = pre_JDO.type;
						
						return true;
					}
					else
					{
						Console.PRINT("Physics","X ERROR > ERROR CODE : 015 > JDO has no proper type!", 3, "");
						
						return false;
					}
				}
				function _3_check_joint_type_requirements():Boolean
				{
					if (Boolean(joint_standarts[pre_JDO.type]))
					{
						if (Utility.TEST_OBJECT_STANDART(pre_JDO, joint_standarts[pre_JDO.type]))
						{
							return true;
						}
						else
						{
							Console.PRINT("Physics","X ERROR > ERROR CODE : 017 > JDO has not meet Joint Type Standards. Type: '" + pre_JDO.type + "'. JDO have to theese properties correctly: ",3,"");
							
							for (var i:int; i <  + joint_standarts[pre_JDO.type].length; i++)
							{
								Console.PRINT("Physics", joint_standarts[pre_JDO.type][i], 2, i + ". ");
							}
							
							return false;
						}
					}
					else
					{
						Console.PRINT("Physics","X ERROR > ERROR CODE : 016 > Joint type is wrong! '" + pre_JDO.type + "'.", 3, "");
						
						return false;
					}
				}
				function _4_update_post_JDO():Boolean
				{
					Utility.UPDATE_OBJECT(post_JDO, create_joint_data_object(post_JDO.type), "Overwrite");
					Utility.UPDATE_OBJECT(post_JDO, pre_JDO, "Overwrite");
					add_joint_shape_info_object(post_JDO);
					
					return true;
				}
				function _5_check_PED_joint_list():Boolean
				{
					if (!Boolean(mcPE_A.PED.joint_list))
					{
						mcPE_A.PED.joint_list = new Array();
					}
					
					return true;
				}
				function _6_calculate_position():Boolean
				{
					post_JDO.A_position = [CONVERT(mcPE_A.PED.body_SP.x, "m", "px") + post_JDO.offset_A[0], CONVERT(mcPE_A.PED.body_SP.y, "m", "px") + post_JDO.offset_A[1]];
					post_JDO.B_position = [CONVERT(mcPE_B.PED.body_SP.x, "m", "px") + post_JDO.offset_B[0], CONVERT(mcPE_B.PED.body_SP.y, "m", "px") + post_JDO.offset_B[1]];
				
					return true;
				}
				function _7_finish_preparation():void
				{
					result = post_JDO;
				}
			}
			function add_joint_shape_info_object(jdo:Object):void
			{
				if (Boolean(jdo.shape))
				{
					find_joint_mc_shape();
					set_depth();
					
					if (Boolean(jdo.mc_shape.JOINT_UPDATE))
					{
						jdo.JSI = new Object();// Joint Shape Info
						jdo.JSI.offset_r = 0;
						jdo.JSI.A = new Object();
						jdo.JSI.B = new Object();
						jdo.JSI.C = new Object();
						jdo.JSI.D = new Object();
						jdo.JSI.AB = new Object();
						jdo.JSI.BC = new Object();
						jdo.JSI.CD = new Object();
						
						if (jdo.type == "Pulley")
						{
							jdo.JSI.G1 = new Object();
							jdo.JSI.G2 = new Object();
							jdo.JSI.BG1 = new Object();
							jdo.JSI.G1G2 = new Object();
							jdo.JSI.G2C = new Object();
						}
					}
					else
					{
						Console.PRINT("Physics","X ERROR > ERROR CODE : 018 > Joint shapes must have 'JOINT_UPDATE()' method.", 3, "");
					}
				}
				
				function find_joint_mc_shape():void
				{
					jdo.mc_shape = new jdo.shape as MovieClip;
					jdo.mc_shape.visible = false;
					jdo.mcPE_a.parent.addChild(jdo.mc_shape);
				}
				function set_depth():void
				{	
					if (Boolean(jdo.depth))
					{
						var order_list:Array = new Array();
						var order_is_valid:Boolean = true;
						
						for (var i:int = 0; i < 3; i ++)
						{
							switch(Utility.SPLIT_TEXT(jdo.depth, "_", (i + 1), (i + 1)))
							{
								case "A":
									order_list[i] = jdo.mcPE_a;
									break;
								case "B":
									order_list[i] = jdo.mcPE_b;
									break;
								case "Joint":
									order_list[i] = jdo.mc_shape;
									break;
								default:
									order_is_valid = false;
									Console.PRINT("Physics","X ERROR > ERROR CODE : 019 > JDO.depth properts is wrong!", 3, "");
									break;
							}
						}

						if (order_is_valid)
						{
							Utility.SET_STAGE_DEPTH(order_list);
						}
					}
				}
			}
			function create_joint_data_object(Type:String):Object
			{
				var jdo:Object = new Object();

				jdo.offset_A = [0, 0];
				jdo.anchor_A = [0, 0];
				jdo.offset_B = [0, 0];
				jdo.anchor_B = [0, 0];
				jdo.update = null;
					
				switch (Type)
				{
					case "Distance":
						break;
					case "Revolute":
						jdo.enableMotor = false;
						jdo.maxMotorTorque = 0;
						jdo.enableLimit = false;
						jdo.lowerAngle = 0;
						jdo.upperAngle = 2;
						break;
					case "Friction":
						jdo.maxForce = 0;
						jdo.maxTorque = 0;
						break;
					case "Prismatic":
						jdo.axis = [1, 0];
						jdo.enableMotor = false;
						jdo.maxMotorForce = 0;
						jdo.motorSpeed = 0;
						jdo.enableLimit = false;
						jdo.lowerTranslation = 0;
						jdo.upperTranslation = 0;	
						break;
					case "Line":
						jdo.axis = [0, 1];
						jdo.enableMotor = false;
						jdo.maxMotorForce = 0;
						jdo.motorSpeed = 0;
						jdo.enableLimit = false;
						jdo.lowerTranslation = 0;
						jdo.upperTranslation = 0;	
						break;
					case "Pulley":
						jdo.ground_A = [100,100];
						jdo.ground_B = [400,100];
						jdo.ratio = 1;
						jdo.maxLengthA = 300;
						jdo.maxLengthB = 300;
						break;
					case "Gear":
						jdo.ratio = 1;
						break;
					case "Weld":
						break;
					default:
						Console.PRINT("Physics","X ERROR > ERROR CODE : 015 > Joint type is wrong! '" + Type + "'.", 3, "");
						break;
				}
					
				return jdo;
			}
			function create_joint():void
			{
				var A_position_vec:b2Vec2 = new b2Vec2(CONVERT(JDO.A_position[0], "px", "m"), CONVERT(JDO.A_position[1], "px", "m"));
				var B_position_vec:b2Vec2 = new b2Vec2(CONVERT(JDO.B_position[0], "px", "m"), CONVERT(JDO.B_position[1], "px", "m"));
				var A_anchor_vec:b2Vec2 = new b2Vec2(CONVERT(JDO.anchor_A[0], "px", "m"), CONVERT(JDO.anchor_A[1], "px", "m"));
				var B_anchor_vec:b2Vec2 = new b2Vec2(CONVERT(JDO.anchor_B[0], "px", "m"), CONVERT(JDO.anchor_B[1], "px", "m"));
				
				switch (JDO.type)
				{
					case "Distance":
						create_distance_joint();
						break;
					case "Friction":
						create_friction_joint();
						break;
					case "Revolute":
						create_revolute_joint();
						break;
					case "Prismatic":
						create_prismatic_joint();
						break;
					case "Line":
						create_line_joint();
						break;
					case "Pulley":
						create_pulley_joint();
						break;
					case "Gear":
						create_gear_joint();
						break;
					case "Weld":
						create_weld_joint();
						break;
				}
				
				function create_distance_joint():void
				{
					var new_distance_joint:b2DistanceJoint;
					var new_distance_joint_def:b2DistanceJointDef = new b2DistanceJointDef();
						
					new_distance_joint_def.Initialize(JDO.body_a, JDO.body_b, A_position_vec, B_position_vec);
					new_distance_joint_def.localAnchorA = A_anchor_vec;
					new_distance_joint_def.localAnchorB = B_anchor_vec;
						
					new_distance_joint = WORLD.CreateJoint(new_distance_joint_def) as b2DistanceJoint;
					JDO.joint = new_distance_joint;
				}
				function create_friction_joint():void
				{
					var new_friction_joint:b2FrictionJoint;
					var new_friction_joint_def:b2FrictionJointDef = new b2FrictionJointDef();
						
					new_friction_joint_def.Initialize(JDO.body_a, JDO.body_b, A_position_vec);
					new_friction_joint_def.localAnchorA = A_anchor_vec;
					new_friction_joint_def.localAnchorB = B_anchor_vec;
					new_friction_joint_def.maxForce = JDO.maxForce;
					new_friction_joint_def.maxTorque = JDO.maxTorque;
						
					new_friction_joint = WORLD.CreateJoint(new_friction_joint_def) as b2FrictionJoint;
					JDO.joint = new_friction_joint;
				}
				function create_revolute_joint():void
				{
					var new_revolute_joint:b2RevoluteJoint;
					var new_revolute_joint_def:b2RevoluteJointDef = new b2RevoluteJointDef();
					
					new_revolute_joint_def.Initialize(JDO.body_a, JDO.body_b, A_position_vec);
					new_revolute_joint_def.localAnchorA = A_anchor_vec;
					new_revolute_joint_def.localAnchorB = B_anchor_vec;
					new_revolute_joint_def.enableLimit = JDO.enableLimit;
					new_revolute_joint_def.enableMotor = JDO.enableMotor;
					new_revolute_joint_def.maxMotorTorque = JDO.maxMotorTorque;
					new_revolute_joint_def.lowerAngle = MathLab.DEGREE_TO_RADIAN(JDO.lowerAngle);
					new_revolute_joint_def.upperAngle = MathLab.DEGREE_TO_RADIAN(JDO.upperAngle);

					new_revolute_joint = WORLD.CreateJoint(new_revolute_joint_def) as b2RevoluteJoint;
					JDO.joint = new_revolute_joint;
				}
				function create_prismatic_joint():void
				{
					var new_prismatic_joint:b2PrismaticJoint;
					var new_prismatic_joint_def:b2PrismaticJointDef = new b2PrismaticJointDef();
					var A_axis:b2Vec2 = new b2Vec2(JDO.axis[0], JDO.axis[1]);
						
					new_prismatic_joint_def.Initialize(JDO.body_a, JDO.body_b, A_position_vec, A_axis);
					new_prismatic_joint_def.localAnchorA = A_anchor_vec;
					new_prismatic_joint_def.localAnchorB = B_anchor_vec;
					new_prismatic_joint_def.enableLimit = JDO.enableLimit;
					new_prismatic_joint_def.enableMotor = JDO.enableMotor;
					new_prismatic_joint_def.maxMotorForce = JDO.maxMotorForce;
					new_prismatic_joint_def.motorSpeed = JDO.motorSpeed;
					new_prismatic_joint_def.lowerTranslation = CONVERT(JDO.lowerTranslation, "px", "m");
					new_prismatic_joint_def.upperTranslation = CONVERT(JDO.upperTranslation, "px", "m");
						
					new_prismatic_joint = WORLD.CreateJoint(new_prismatic_joint_def) as b2PrismaticJoint;
					JDO.joint = new_prismatic_joint;
				}
				function create_line_joint():void
				{
					var new_line_joint:b2LineJoint;
					var new_line_joint_def:b2LineJointDef = new b2LineJointDef();
					var A_axis:b2Vec2 = new b2Vec2(JDO.axis[0], JDO.axis[1]);
						
					new_line_joint_def.Initialize(JDO.body_a, JDO.body_b, A_position_vec, A_axis);
					new_line_joint_def.localAnchorA = A_anchor_vec;
					new_line_joint_def.localAnchorB = B_anchor_vec;
					new_line_joint_def.enableLimit = JDO.enableLimit;
					new_line_joint_def.enableMotor = JDO.enableMotor;
					new_line_joint_def.maxMotorForce = JDO.maxMotorForce;
					new_line_joint_def.motorSpeed = JDO.motorSpeed;
					new_line_joint_def.lowerTranslation = CONVERT(JDO.lowerTranslation, "px", "m");
					new_line_joint_def.upperTranslation = CONVERT(JDO.upperTranslation, "px", "m");
						
					new_line_joint = WORLD.CreateJoint(new_line_joint_def) as b2LineJoint;
					JDO.joint = new_line_joint;
				}
				function create_pulley_joint():void
				{
					var new_pulley_joint:b2PulleyJoint;
					var new_pulley_joint_def:b2PulleyJointDef = new b2PulleyJointDef();
					var groundAnchorA_vec:b2Vec2 = new b2Vec2(CONVERT(JDO.ground_A[0], "px", "m"), CONVERT(JDO.ground_A[1], "px", "m")); 
					var groundAnchorB_vec:b2Vec2 = new b2Vec2(CONVERT(JDO.ground_B[0], "px", "m"), CONVERT(JDO.ground_B[1], "px", "m")); 
						 
					new_pulley_joint_def.Initialize(JDO.body_a, JDO.body_b, groundAnchorA_vec, groundAnchorB_vec, A_position_vec, B_position_vec, JDO.ratio);
					new_pulley_joint_def.localAnchorA = A_anchor_vec;
					new_pulley_joint_def.localAnchorB = B_anchor_vec;
					new_pulley_joint_def.maxLengthA = CONVERT(JDO.maxLengthA, "px", "m");
					new_pulley_joint_def.maxLengthB = CONVERT(JDO.maxLengthA, "px", "m");
						 
					new_pulley_joint = WORLD.CreateJoint(new_pulley_joint_def) as b2PulleyJoint;
					JDO.joint = new_pulley_joint;
				}
				function create_gear_joint():void
				{
					if ((JDO.jointA.body_a.GetType() == 0) && ((JDO.jointB.body_a.GetType() == 0)))
					{
						var new_gear_joint:b2GearJoint;
						var new_gear_joint_def:b2GearJointDef = new b2GearJointDef();
						
						new_gear_joint_def.bodyA = JDO.body_a;
						new_gear_joint_def.bodyB = JDO.body_b;
						new_gear_joint_def.joint1 = JDO.jointA.joint;
						new_gear_joint_def.joint2 = JDO.jointB.joint;
						new_gear_joint_def.ratio = JDO.ratio;
						
						new_gear_joint = WORLD.CreateJoint(new_gear_joint_def) as b2GearJoint;
						JDO.joint = new_gear_joint;
					}
					else
					{
						Console.PRINT("Physics","X ERROR > ERROR CODE : 020 > While using Gear Joint, JointA and JointB must be take static body in parameter as mcPE_A", 3, "");
					}
				}
				function create_weld_joint():void
				{
					var new_weld_joint:b2WeldJoint;
					var new_weld_joint_def:b2WeldJointDef = new b2WeldJointDef();
						
					new_weld_joint_def.Initialize(JDO.body_a, JDO.body_b, A_position_vec);
					new_weld_joint_def.localAnchorA = A_anchor_vec;
					new_weld_joint_def.localAnchorB = B_anchor_vec;
						
					new_weld_joint = WORLD.CreateJoint(new_weld_joint_def) as b2WeldJoint;
					JDO.joint = new_weld_joint;
				}
			}
		}
		public static function ADD_MOUSE_JOINT(Apply_List:Array):void
		{
			for (var i:int = 0; i < Apply_List.length; i ++)
			{
				if (get_body(Apply_List[i]))
				{
					mouse_joint_list.push(get_body(Apply_List[i]));
				}
				else
				{
					Console.PRINT("Physics","X ERROR > ERROR CODE : 021 > '" + Apply_List[i].name + "' is cannot find.", 3, "");
				}
			}
		}
		public static function UPDATE_JOINT(mcPE:MovieClip, Joint_Name:String, Joint_Data:Object):void
		{
			UPDATE_JDO(Joint_Data.name, Joint_Data);
			REMOVE_JOINT(mcPE, [Joint_Name], true);
			ADD_JOINT(mcPE, Joint_Data.mcPE_b, Joint_Data);
		}
		public static function STRECH_JOINTS(mcPE_List:Array, Scale_X:Number, Scale_Y:Number):void
		{
			if (Utility.TEST_ARRAY_ELEMENTS(POL, mcPE_List))
			{
				for (var i:int = 0; i < mcPE_List.length; i++)
				{
					if (Boolean(mcPE_List[i].PED.joint_list))
					{
						for each(var JDO:Object in mcPE_List[i].PED.joint_list)
						{
							JDO.anchor_A[0] *= Scale_X;
							JDO.anchor_A[1] *= Scale_Y; 
							JDO.anchor_B[0] *= Scale_X;
							JDO.anchor_B[1] *= Scale_Y;
							JDO.offset_A[0] *= Scale_X;
							JDO.offset_A[1] *= Scale_Y;
							JDO.offset_B[0] *= Scale_X;
							JDO.offset_B[1] *= Scale_Y;
						}
						
						for each(var JDO2:Object in mcPE_List[i].PED.joint_list)
						{
							UPDATE_JOINT(mcPE_List[i], JDO2.name, JDO2);
						}
					}
				}
			}
			else
			{
				Console.PRINT("Physics","X ERROR > ERROR CODE : 022 > Invalid parameters for streching.", 3, "");
			}
		}
		public static function REMOVE_JOINT(mcPE:MovieClip, Joint_Name_List:Array, Destroy_Shape:Boolean = true):void
		{
			if (get_body(mcPE))
			{
				if (Boolean(mcPE.PED.joint_list))
				{
					for (var i:int; i < Joint_Name_List.length; i ++)
					{
						if (Destroy_Shape)
						{
							if (Boolean(mcPE.PED.joint_list[Joint_Name_List[i]].mc_shape))
							{
								mcPE.PED.joint_list[Joint_Name_List[i]].mcPE_a.parent.removeChild(mcPE.PED.joint_list[Joint_Name_List[i]].mc_shape);
							}
						}
						
						WORLD.DestroyJoint(mcPE.PED.joint_list[Joint_Name_List[i]].joint);
						
						delete mcPE.PED.joint_list[Joint_Name_List[i]];
					}
				}
			}
		}
		public static function REMOVE_MOUSE_JOINT(Apply_List:Array):void
		{
			for (var i:int = 0; i < Apply_List.length; i ++)
			{
				if (get_body(Apply_List[i]))
				{
					Utility.REMOVE_SPECIFIC_ELEMENTS(mouse_joint_list, [get_body(Apply_List[i])]);
				}
				else
				{
					Console.PRINT("Physics","X ERROR > ERROR CODE : 023 > '" + Apply_List[i].name + "' is cannot find.", 3, "");
				}
			}
		}

		// Physical Apllications Methods:

		public static function SET_MOUSE_SUPPORT(Active:Boolean, Force:Number = 0):void
		{
			mouse_active = Active;
			
			if (mouse_active)
			{
				if (!Boolean(MJO))
				{
					setup_MJO(Force);
				}
				
				MJO.active = true;
			}
			else
			{
				if (Boolean(MJO))
				{
					MJO.active = false;
				}
			}
		}
		public static function APPLY(mcPE_List:Array, Aplly_What:String, Related_to_Body:Boolean, Vector_Parameters:Array, ... args):void
		{
			var required_point_and_apply_vectors:Boolean = Boolean(Vector_Parameters.length >= 5);
			
			if (Vector_Parameters.length > 0)
			{
				var magnitude:Number = Vector_Parameters[0];
			}
			if (required_point_and_apply_vectors)
			{
				var point_vector:Array = [CONVERT(Vector_Parameters[1], "px", "m"), CONVERT(Vector_Parameters[2], "px", "m")];			
				var apply_vector:Array = [Vector_Parameters[3] * magnitude, Vector_Parameters[4] * magnitude];
			}

			try
			{
				for (var i:int = 0; i < mcPE_List.length; i ++)
				{
					if (required_point_and_apply_vectors)
					{
						if (Related_to_Body)
						{
							if (Related_to_Body)
							{
								apply_vector = MathLab.ADD_ANGLE_TO_VECTOR(apply_vector[0], apply_vector[1], mcPE_List[i].PED.body_SP.rotation);
							}
						}
						
						var point_vector_b2:b2Vec2 = new b2Vec2(point_vector[0], point_vector[1]);
						var apply_vector_b2:b2Vec2 = new b2Vec2(apply_vector[0], apply_vector[1]);
					}
					
					switch (Aplly_What)
					{
						case "Force" :
							apply_force(mcPE_List[i]);
							break;
						case "Torque" :
							apply_torque(mcPE_List[i]);
							break;
						case "Lineer Velocity" :
							apply_lineer_velocity(mcPE_List[i]);
							break;
						case "Angular Velocity" :
							apply_angular_velocity(mcPE_List[i]);
							break;
						case "Impulse" :
							apply_impulse(mcPE_List[i]);
							break;
						case "Angular Impulse" :
							apply_angular_impulse(mcPE_List[i]);
							break;
						case "Friction" :
							apply_friction(mcPE_List[i]);
							break;
					}
				}
			}
			catch(e:Error)
			{
				Console.PRINT("Physics","X ERROR > ERROR CODE : 024 > An error occured while apllying '" + Aplly_What + "' on '" + mcPE_List[i].name + "'.",3,"");
				Console.PRINT("Physics","- ERROR DETAIL > " + e.getStackTrace(),2,"");
			}
			
			function apply_force(mcPE:MovieClip):void
			{
				get_body(mcPE).ApplyForce(apply_vector_b2, get_body(mcPE).GetWorldPoint(point_vector_b2));
			}
			function apply_torque(mcPE:MovieClip):void
			{
				get_body(mcPE).ApplyTorque(magnitude);
			}
			function apply_lineer_velocity(mcPE:MovieClip):void
			{
				get_body(mcPE).SetAwake(true);
				get_body(mcPE).SetLinearVelocity(apply_vector_b2);
			}
			function apply_angular_velocity(mcPE:MovieClip):void
			{
				get_body(mcPE).SetAwake(true);
				get_body(mcPE).SetAngularVelocity(magnitude);
			}
			function apply_impulse(mcPE:MovieClip):void
			{
				get_body(mcPE).ApplyImpulse(apply_vector_b2, get_body(mcPE).GetWorldPoint(point_vector_b2));
			}
			function apply_angular_impulse(mcPE:MovieClip):void
			{
				// !
				
				//get_body(mcPE).ApplyAngularImpulse(magnitude);
			}
			function apply_friction(mcPE:MovieClip):void
			{
				Console.DYNAMIC_DATA("PPI", mcPE.PED);
				
				if (Boolean(mcPE.PED.PPI))
				{
					//magnitude *= mcPE.PED.PPI.mass;
					
					apply_angular_friction();
				}
				
				function apply_angular_friction():void
				{
					//trace("magnitude: " + magnitude + ", ang_speed: " + mcPE.PED.PPI.ang_speed);
					
					if (Math.abs(mcPE.PED.PPI.speed_x) < magnitude)
					{
						get_body(mcPE).SetLinearVelocity(new b2Vec2(0, get_body(mcPE).GetLinearVelocity().y));

						mcPE.PED.PPI.speed_x = 0;
					}
					if (Math.abs(mcPE.PED.PPI.speed_y) < magnitude)
					{
						get_body(mcPE).SetLinearVelocity(new b2Vec2(get_body(mcPE).GetLinearVelocity().x, 0));

						mcPE.PED.PPI.speed_y = 0;
					}
					if (Math.abs(mcPE.PED.PPI.ang_speed) < magnitude)
					{
						get_body(mcPE).SetAngularVelocity(0);

						mcPE.PED.PPI.ang_speed = 0;
					}
					
					/*if (!mcPE.PED.PPI.speed_x && !mcPE.PED.PPI.speed_y && !mcPE.PED.PPI.ang_speed)
					{
						get_body(mcPE).SetAwake(false);
					}*/
					
					if ((Math.abs(int(mcPE.PED.PPI.speed_x)) > 0) && (Math.abs(int(mcPE.PED.PPI.speed_y)) > 0))
					{
						var X:Number = - get_body(mcPE).GetLinearVelocity().x;
						var Y:Number = - get_body(mcPE).GetLinearVelocity().y;
						
						X *= magnitude;
						Y *= magnitude;
						
						get_body(mcPE).ApplyForce(new b2Vec2(X, Y), get_body(mcPE).GetWorldCenter());
					}
					else if (Math.abs(int(mcPE.PED.PPI.speed_x)) > 0)
					{
						if (mcPE.PED.PPI.speed_x > 0)
						{
							magnitude *= -1;
						}
						
						get_body(mcPE).ApplyForce(new b2Vec2(magnitude, 0), get_body(mcPE).GetWorldCenter());
					}
					else if (Math.abs(int(mcPE.PED.PPI.speed_y)) > 0)
					{
						if (mcPE.PED.PPI.speed_y > 0)
						{
							magnitude *= -1;
						}
						
						get_body(mcPE).ApplyForce(new b2Vec2(0, magnitude), get_body(mcPE).GetWorldCenter());
					}
					
					if (Math.abs(int(mcPE.PED.PPI.ang_speed)) > 0)
					{
						if (mcPE.PED.PPI.ang_speed > 0)
						{
							magnitude *= -1;
						}
						
						get_body(mcPE).ApplyTorque(magnitude);
					}
				}
			}
		}
		public static function SET(mcPE:MovieClip, Property:String, Parameter:*):void
		{
			try
			{
				switch (Property)
				{
					case "Active" :
						set_active(mcPE);
						break;
					case "Awake" :
						set_awake(mcPE);
						break;
					case "Visible" :
						set_visible(mcPE);
						break;
					case "Moving" :
						set_moving(mcPE);
						break;
					case "Position" :
						set_position(mcPE);
						break;
					case "Angle" :
						set_angle(mcPE);
						break;
					case "Angular Velocity" :
						set_angular_velocity(mcPE);
						break;
					case "Angular Damping" :
						set_angular_damping(mcPE);
						break;
					case "Filter" :
						set_filter(mcPE);
						break;
					case "Bullet" :
						set_bullet(mcPE);
						break;
					case "Collision" :
						set_filter(mcPE);
						break;
					default:
						Console.PRINT("Physics","X ERROR > ERROR CODE : 026 > There is no such '" + Property + "' property on the adjustable property list", 3, "");
						break;
					}
			}
			catch(e:Error)
			{
				Console.PRINT("Physics","X ERROR > ERROR CODE : 025 > An error occured while set '" + Property + "' on '" + mcPE.name + "'.", 3, "");
				Console.PRINT("Physics","- ERROR DETAIL > " + e.getStackTrace(),2,"");
			}
			
			function set_active(mcPE:MovieClip):void
			{
				if (check_parameter("Boolean"))
				{
					get_body(mcPE).SetActive(Boolean(Parameter));
				}
			}
			function set_awake(mcPE:MovieClip):void
			{
				if (check_parameter("Boolean"))
				{
					get_body(mcPE).SetAwake(Boolean(Parameter));
				}
			}
			function set_visible(mcPE:MovieClip):void
			{
				if (check_parameter("Boolean"))
				{
					get_body(mcPE).SetActive(Boolean(Parameter));
					mcPE.visible = Boolean(Parameter);
				}
			}
			function set_moving(mcPE:MovieClip):void
			{
				if (check_parameter("Boolean"))
				{
					get_body(mcPE).SetAwake(false);
					get_body(mcPE).SetAwake(true);
					get_body(mcPE).SetAwake(Boolean(Parameter));
				}
			}
			function set_position(mcPE:MovieClip):void
			{
				if (Boolean(Parameter is Array))
				{
					if (Parameter.length == 2)
					{
						get_body(mcPE).SetPosition(new b2Vec2(CONVERT(Parameter[0], "px", "m"), CONVERT(Parameter[1], "px", "m")));
					}
					else if (Parameter.length == 3)
					{
						get_body(mcPE).SetPositionAndAngle(new b2Vec2(CONVERT(Parameter[0], "px", "m"), CONVERT(Parameter[1], "px", "m")), MathLab.DEGREE_TO_RADIAN(Parameter[2]));
					}
					else
					{
						trace("hata length must be 2 or 3");
					}
				}
				else
				{
					trace("hata parameter array is needed");
				}
			}
			function set_angle(mcPE:MovieClip):void
			{
				if (check_parameter("Number"))
				{
					get_body(mcPE).SetAngle(MathLab.DEGREE_TO_RADIAN(Parameter));
				}
			}
			function set_angular_velocity(mcPE:MovieClip):void
			{
				if (check_parameter("Number"))
				{
					get_body(mcPE).SetAngularVelocity(MathLab.DEGREE_TO_RADIAN(Parameter));
				}
			}
			function set_angular_damping(mcPE:MovieClip):void
			{
				if (check_parameter("Number"))
				{
					get_body(mcPE).SetAngularDamping(MathLab.DEGREE_TO_RADIAN(Parameter));
				}
			}
			function set_filter(mcPE:MovieClip):void
			{
				if (Boolean(Parameter is Array))
				{
					if (Parameter.length == 3)
					{
						var new_filter:b2FilterData = get_body(mcPE).GetFixtureList().GetFilterData();
						
						new_filter.categoryBits = Parameter[0];
						new_filter.maskBits = Parameter[1];
						new_filter.groupIndex = Parameter[2];
						
						for each(var fix_gorup:* in mcPE.PED.fix_list)
						{
							if (fix_gorup is Array)
							{
								for each(var fix:b2Fixture in fix_gorup)
								{
									fix.SetFilterData(new_filter);
								}
							}
							else
							{
								fix_gorup.SetFilterData(new_filter);
							}
						}
					}
					else
					{
						trace("hata length must be 3");
					}
				}
				else
				{
					trace("hata parameter array is needed");
				}
			}
			function set_bullet(mcPE:MovieClip):void
			{
				if (check_parameter("Boolean"))
				{
					get_body(mcPE).SetBullet(Boolean(Parameter));
					mcPE.PED.bullet = Parameter;
				}
			}
			function set_collision(mcPE:MovieClip):void
			{
				if (check_parameter("Boolean"))
				{
					mcPE.PED.collision = Parameter;
				}
			}
			
			function check_parameter(Which:String):Boolean
			{
				var ok:Boolean = true;
				
				switch (Which)
				{
					case "Boolean":
						if (!Boolean(Parameter is Boolean))
						{
							ok = false;
							trace("parametre hatası");
						}
						break;
					case "Number":
						if (!Boolean(Parameter is Number))
						{
							ok = false;
							trace("parametre hatası");
						}
						break;
				}
				
				return ok;
			}
		}
		public static function CLEAR_FORCES():void
		{
			WORLD.ClearForces();
		}

		// Segment Methods:

		public static function ADD_SEGMENT(Segment_Name:String, Respond:Function = null):void
		{
			var Segment:Object = new Object();
			Segment.name = Segment_Name;
			Segment.ready = false;
			Segment.A = new Array();
			Segment.B = new Array();
			Segment.respond = new Function();
			
			if (Boolean(Respond))
			{
				Segment.respond = Respond;
			}
			
			segment_list[Segment_Name] = Segment;
		}
		public static function UPDATE_SEGMENT(Segment_Name:String, Ready:Boolean, A:Array = null, B:Array = null, Respond:Function = null):void
		{
			if (Boolean(segment_list[Segment_Name]))
			{
				segment_list[Segment_Name].ready = Ready;
					
				if (Boolean(A))
				{
					segment_list[Segment_Name].A = A;
				}
				if (Boolean(B))
				{
					segment_list[Segment_Name].B = B;
				}		
				if (Boolean(Respond))
				{
					segment_list[Segment_Name].respond = Respond;
				}
			}
			else
			{
				Console.PRINT("Physics","X ERROR > ERROR CODE : 027 > No found this segment " + Segment_Name,3,"");
			}
		}
		public static function REMOVE_SEGMENT(Segment_Name_List:Array):void
		{
			Utility.SEARCH_ARRAY_ELEMENTS(segment_list, Segment_Name_List).length = 0;
		}
		public static function REMOVE_ALL_SEGMENTS():void
		{
			segment_list.length = 0;
		}
		
		// Tools:
		
		public static function GET_PED(PO_Name:String):Object
		{
			var result:Object;
			
			for (var i:int = 0; i < POL.length; i ++)
			{
				if (PO_Name == POL[i].name)
				{
					result = POL[i].PED;
				}
			}
			
			return result;
		}
		public static function FIND_MCPE_IN_CANVAS(Point_X:Number, Point_Y:Number, Low_Bound_X:Number, Low_Bound_Y:Number, High_Bound_X:Number, High_Bound_Y:Number, Valid_Types:Array = null, Search_For:Array = null):MovieClip
		{
			if (Boolean(Search_For))
			{
				var search_body_list:Array = new Array();
				
				for (var i:int = 0; i < Search_For.length; i++)
				{
					search_body_list[i] = get_body(Search_For[i]);
				}
			}
			
			var name:String = FIND_BODY_IN_CANVAS(Point_X, Point_Y, Low_Bound_X, Low_Bound_Y, High_Bound_X, High_Bound_Y, Valid_Types, Search_For).GetUserData().name;
			
			if (Boolean(get_mcPE_by_name([name])[0] is MovieClip))
			{
				return get_mcPE_by_name([name])[0];
			}
			else
			{
				return null;
			}
		}
		public static function FIND_BODY_IN_CANVAS(Point_X:Number, Point_Y:Number, Low_Bound_X:Number, Low_Bound_Y:Number, High_Bound_X:Number, High_Bound_Y:Number, Valid_Types:Array = null, Search_For:Array = null):b2Body
		{
			var body:b2Body = null;
			var fixture:b2Fixture;
			var p_vec:b2Vec2 = new b2Vec2(Point_X, Point_Y);
	
			var aabb:b2AABB = new b2AABB();
			aabb.lowerBound.Set(Low_Bound_X, Low_Bound_Y);
			aabb.upperBound.Set(High_Bound_X, High_Bound_Y);
			
			if (!Boolean(Valid_Types))
			{
				Valid_Types = [0,1,2];
			}
			
			WORLD.QueryAABB(get_body_callback, aabb);
			
			return body;

			function get_body_callback(fixture:b2Fixture):Boolean
			{
				var result:Boolean = true;
				
				if (Utility.TEST_ARRAY_ELEMENTS(Valid_Types, [fixture.GetBody().GetType()]))
				{
					if (!Boolean(Search_For) || Utility.TEST_ARRAY_ELEMENTS(Search_For, [fixture.GetBody()]))
					{
						if (fixture.GetShape().TestPoint(fixture.GetBody().GetTransform(), p_vec))
						{
							body = fixture.GetBody();
							
							result = false;
						}
					}
				}
				
				return result;
			}
			
		}
		public static function GET_MOUSE_POINT():Point
		{
			return new Point(CONTENT.mouseX, CONTENT.mouseY);
		}
		public static function TAKE_JDO(JDO_Name:String, Type:String, Anchor_A:Array = null, Anchor_B:Array = null, Depth:String = null, Update_Function:Function = null, Joint_Shape:Object = null):Object
		{
			if (!Boolean(JDO_memory[JDO_Name]))
			{
				var JDO:Object = new Object();
				
				JDO.name = JDO_Name;
				JDO.type = Type;
				JDO.update = Update_Function;
				
				if (Boolean(Depth))
				{
					JDO.depth = Depth;
				}
				else
				{
					JDO.depth = "Joint_B_A";
				}
				
				if (Boolean(Joint_Shape))
				{
					JDO.shape = Joint_Shape;
				}
				
				if (Boolean(Anchor_A))
				{
					JDO.anchor_A = Anchor_A;
				}
				if (Boolean(Anchor_B))
				{
					JDO.anchor_B = Anchor_B;
				}
				
				JDO_memory[JDO_Name] = JDO;
			}
			
			return JDO_memory[JDO_Name];
		}
		public static function TAKE_PED(PED_Name:String, Type:String = null, Spahe:String = null, Active:Boolean = true, Elasticity:Number = 0.2, Friction:Number = 0.5, Density:Number = 1, Category:int = -1, Mask:int = -1, Filter_Index:Number = 0, Collision:Boolean = false):Object
		{
			if (!Boolean(PED_memory[PED_Name]))
			{
				var PED:Object = new Object();
				
				PED.name = PED_Name;
				PED.type = Type;
				PED.shape = Spahe;
				PED.active = Active;
				PED.elasticity = Elasticity;
				PED.friction = Friction;
				PED.density = Density;
				PED.category = Category;
				PED.mask = Mask;
				PED.filter_index = Filter_Index;
				PED.collision = Collision;
				
				PED_memory[PED_Name] = PED;
			}
			
			return PED_memory[PED_Name];
		}
		public static function APPLY_PED(PED_Name:String, MC_Body_List:Array):void
		{
			for (var i:int = 0; i < MC_Body_List.length; i++)
			{
				MC_Body_List[i].PED = new Object();
				MC_Body_List[i].PED = PED_memory[PED_Name];
				MC_Body_List[i].INIT_PHYSICS = new Function();
			}
		}
		public static function UPDATE_JDO(JDO_Name:String, JDO:Object):void
		{
			JDO_memory[JDO_Name] = JDO;
		}
		public static function CONVERT(Value:Number, Input_Unit:String, Output_Unit:String):Number
		{
			if (!Boolean(Input_Unit == Output_Unit))
			{
				switch (Input_Unit)
				{
					case "px":
						return Value / P_SCALER;
						break;
					case "m":
						return Value * P_SCALER;
						break;
					default :
						return NaN;
						break;
				}
			}
			else
			{
				return Value;
			}
		}

		// ------------------------------------------------------------
		// FUNCTIONS :
		// ------------------------------------------------------------
		
		// Event Functions:
		private static function update_world(e:TimerEvent = null):void
		{
			WORLD.Step(simulate_delay, iteration_velocity, iteration_position);

			if (Boolean(MJO))
			{
				if (MJO.active)
				{
					MJO.update();
				}
			}
			
			for (var i:uint = 0; i < POL.length; i++)
			{
				update_joint_info(POL[i]);
				
				if (body_list[i].GetType() == b2Body.b2_dynamicBody)
				{
					if (POL[i].PED.active)
					{	
						sync_body_to_shape(POL[i], body_list[i]);
						POL[i].PHYSICS_UPDATE();
					}
					
					if (Boolean(POL[i].PED.is_mother))
					{
						for (var j:uint = 0; j < POL[i].PED.children.length; j++)
						{
							if (POL[i].PED.children[j].PED.active)
							{
								sync_body_to_shape(POL[i].PED.children[j], body_list[i]);
								POL[i].PED.children[j].PHYSICS_UPDATE();
							}
						}
					}
				} 
				else if (body_list[i].GetType() == b2Body.b2_kinematicBody)
				{
					update_kinematic_body(POL[i], body_list[i]);
				}
			}
			
			if (debug_active)
			{
				WORLD.DrawDebugData();
			}
		}
		public static function update_collision(Type:String, Contact:b2Contact, Old_Manifold:b2Manifold = null, Impulse:b2ContactImpulse = null):void
		{
			start_COLDO();
			
			if (Boolean(COLDO.A.PED.collision))
			{
				handle_collision_feedback(COLDO.A, COLDO.B);
			}
			if (Boolean(COLDO.B.PED.collision))
			{
				handle_collision_feedback(COLDO.B, COLDO.A);
			}

			function start_COLDO():void
			{
				COLDO = null;
				COLDO = new Object();
				COLDO.type = Type;
				COLDO.contact_points = new Array();
				COLDO.manifold_point = new b2Vec2();
				COLDO.A = Contact.GetFixtureA().GetBody().GetUserData().mcPE;
				COLDO.B = Contact.GetFixtureB().GetBody().GetUserData().mcPE;
			}
			function handle_collision_feedback(A:MovieClip, B:MovieClip):void
			{
				switch (Type)
				{
					case "BeginContact":
						begin_contact(A, B);
						break;
					case "EndContact":
						end_contact(A, B);
						break;
					case "PreSolve":
						pre_solve_contact(A, B);
						break;
					case "PostSolve":
						post_solve_contact(A, B);
						break;
				}
			}
			function begin_contact(A:MovieClip, B:MovieClip):void
			{
				if (!Boolean(COLDOL[A.name]))
				{
					COLDOL[A.name] = new Array();
				}
				if (!Boolean(COLDOL[A.name][B.name]))
				{
					COLDOL[A.name][B.name] = new Object();
				}
				
				get_contact_points(COLDOL[A.name][B.name]);
			}
			function end_contact(A:MovieClip, B:MovieClip):void
			{
				if (Boolean(COLDOL[A.name]))
				{
					if (Boolean(COLDOL[A.name][B.name]))
					{
						delete COLDOL[A.name][B.name];
					}
				}
				
				Utility.COMPRESS_ARRAY(COLDOL[A.name]);
			}
			function pre_solve_contact(A:MovieClip, B:MovieClip):void
			{
				if (Boolean(COLDOL[A.name]))
				{
					if (Boolean(COLDOL[A.name][B.name]))
					{
						get_contact_points(COLDOL[A.name][B.name]);
						update_PED_COLDO(COLDOL[A.name][B.name]);
					}
				}
			}
			function post_solve_contact(A:MovieClip, B:MovieClip):void
			{
				if (Boolean(COLDOL[A.name]))
				{
					if (Boolean(COLDOL[A.name][B.name]))
					{
						get_contact_points(COLDOL[A.name][B.name]);
						get_impulse(COLDOL[A.name][B.name]);
						update_PED_COLDO(COLDOL[A.name][B.name]);
					}
				}
			}
			function get_contact_points(PED_COLDO:Object):void
			{
				reset_contact_points();
				get_contact_point_number();
				get_new_contact_points();
				
				function reset_contact_points():void
				{
					for (var i:uint = 0; i < COLDO.contact_points.length; i ++)
					{
						COLDO.contact_points[i] = null;
					}
					
					Utility.COMPRESS_ARRAY(COLDO.contact_points);
				}
				function get_contact_point_number():void
				{
					COLDO.contact_count = Contact.GetManifold().m_pointCount;
				}
				function get_new_contact_points():void
				{
					for (var i:uint = 0; i < COLDO.contact_count; i ++)
					{
						COLDO.manifold_point = Contact.GetManifold().m_points[i].m_localPoint;

						COLDO.contact_points[i] = new Object();
						COLDO.contact_points[i].x = CONVERT(Contact.GetFixtureA().GetBody().GetWorldPoint(COLDO.manifold_point).x, "m", "px");
						COLDO.contact_points[i].y = CONVERT(Contact.GetFixtureA().GetBody().GetWorldPoint(COLDO.manifold_point).y, "m", "px");
  
						//Printmaker.DRAW_CIRCLE(CANVAS, [COLDO.contact_points[i].x, COLDO.contact_points[i].y], 2, COLDO.A.name + "_contact" + COLDO.B.name + "_" + i, false);
					}
				}
			}
			function get_impulse(PED_COLDO:Object):void
			{
				PED_COLDO.impulse = Impulse.normalImpulses;
				PED_COLDO.tangent = Impulse.tangentImpulses;
			}
			function update_PED_COLDO(PED_COLDO:Object):void
			{
				Utility.UPDATE_OBJECT(PED_COLDO, COLDO, "Overwrite");
					
				delete PED_COLDO.A;
				delete PED_COLDO.B;
				delete PED_COLDO.manifold_point;
			}
		}
		
		// Body Creation Functions:
		private static function check_body_standarts(mcPE_List:Array):Boolean
		{
			var current_standarts_mcPE:Array = new Array();
			var current_standarts_PED:Array = new Array();
			var body_standarts:Array = new Array();
			var result_value:int = 1;
			
			start_requirements();
			
			for (var i:uint = 0; i < mcPE_List.length; i++)
			{
				result_value = result_value * int(init_test(mcPE_List[i]));
			}

			return Boolean(result_value);
			
			function start_requirements():void
			{
				// -> Fine Tunning
				body_standarts["Dynamic_mcPE"] = ["PHYSICS_UPDATE"];
				body_standarts["Static_mcPE"] = [];
				body_standarts["Kinematic_mcPE"] = ["INIT_PHYSICS"];
				body_standarts["Dynamic_PED"] = ["shape", "elasticity", "friction", "density", "bullet", "collision"];
				body_standarts["Static_PED"] = ["shape", "elasticity", "friction", "collision"];
				body_standarts["Kinematic_PED"] = ["shape", "elasticity", "friction", "bullet", "collision"];
			}
			function init_test(mcPE:MovieClip):Boolean
			{
				var result:Boolean = false;
				
				Processor.RUN_CHAIN([_1_confirm_MC,
								   _2_confirm_INIT_PHYSICS,
								   _3_confirm_PED, 
								   _4_check_type,
								   _5_check_mcPE,
								   _6_check_PED, 
								   _7_finish_test])
				
				return result;
				
				function _1_confirm_MC():Boolean
				{
					if (Boolean(mcPE is MovieClip))
					{
						return true;
					}
					else
					{
						Console.PRINT("Physics","X ERROR > ERROR CODE : 029 > This object must be a MovieClip! Object is '" + mcPE + "'.",3,"");
						
						return false;
					}
				}
				function _2_confirm_INIT_PHYSICS():Boolean
				{
					if (Boolean(mcPE.INIT_PHYSICS))
					{
						mcPE.INIT_PHYSICS();
						
						return true;
					}
					else
					{
						Console.PRINT("Physics","X ERROR > ERROR CODE : 030 > This object cannot be initiated '" + mcPE.name + "'. INIT_PHYSICS() method is missing.",3,"");
						
						return false;
					}
				}
				function _3_confirm_PED():Boolean
				{
					if (Boolean(mcPE.PED))
					{
						return true;
					}
					else
					{
						Console.PRINT("Physics","X ERROR > ERROR CODE : 031 > '" + mcPE.name + "' must have a 'PED' object.",3,"");
						
						return false;
					}
				}
				function _4_check_type():Boolean
				{
					if (Boolean(mcPE.PED.type))
					{
						switch (mcPE.PED.type)
						{
							case "Dynamic":
								current_standarts_mcPE = body_standarts["Dynamic_mcPE"];
								current_standarts_PED = body_standarts["Dynamic_PED"];
								return true;
								break;
							case "Static":
								current_standarts_mcPE = body_standarts["Static_mcPE"];
								current_standarts_PED = body_standarts["Static_PED"];
								return true;
								break;
							case "Kinematic":
								current_standarts_mcPE = body_standarts["Kinematic_mcPE"];
								current_standarts_PED = body_standarts["Kinematic_PED"];
								return true;
								break;
							default:
								Console.PRINT("Physics","X ERROR > ERROR CODE : 033 > '" + mcPE.name + "' No valid PED type!. Type must be one of these, 'Dynamic','Static','Kinematic'.",3,"");
								return false;
								break;
						}
					}
					else
					{
						Console.PRINT("Physics","X ERROR > ERROR CODE : 032 > '" + mcPE.name + "' No found PED type!. Please check body standarts for Physics.",3,"");
						
						return false;
					}
				}
				function _5_check_mcPE():Boolean
				{
					if (Utility.TEST_OBJECT_STANDART(mcPE, current_standarts_mcPE))
					{
						return true;
					}
					else
					{
						Console.PRINT("Physics", "X ERROR > ERROR CODE : 034 > The object '" + mcPE.name + "' which is associated with Physics.as, does not meet the 'mcPE' requirements.", 3, "");
						Console.PRINT_DATA("Physics", "Requirements for 'mcPE'", current_standarts_mcPE);
						Console.SKIP_LINE();
						
						return false;
					}
				}
				function _6_check_PED():Boolean
				{
					if (Utility.TEST_OBJECT_STANDART(mcPE.PED, current_standarts_PED))
					{
						return true;
					}
					else
					{
						Console.PRINT("Physics", "X ERROR > ERROR CODE : 035 > The object '" + mcPE.name + "' which is associated with Physics.as, does not meet the 'PED' requirements.",3,"");
						Console.PRINT_DATA("Physics", "Requirements for 'PED'", current_standarts_PED);
						Console.SKIP_LINE();
						
						return false;
					}
				}
				function _7_finish_test():void
				{
					result = true;
				}
			}
		}
		private static function body_def(mcPE:MovieClip):b2BodyDef
		{
			var body_def:b2BodyDef = new b2BodyDef();
			
			body_def.userData = new Object();
			body_def.userData.name = mcPE.name;
			body_def.userData.mcPE = mcPE;
			body_def.bullet = mcPE.PED.bullet;
			
			switch (mcPE.PED.type)
			{
				case "Dynamic" :
					body_def.type = b2Body.b2_dynamicBody;
					break;
				case "Kinematic" :
					body_def.type = b2Body.b2_kinematicBody;
					break;
				case "Static" :
					body_def.type = b2Body.b2_staticBody;
					break;
			}
			
			body_def.angle = mcPE.PED.body_SP.rotation;
			body_def.position.Set(mcPE.PED.body_SP.x, mcPE.PED.body_SP.y);

			return body_def;
		}
		private static function attach_fix_to_body(Body_MC:MovieClip, Fixture_MC:MovieClip, Body:b2Body):void
		{
			var body_fixture:b2Fixture = new b2Fixture();
			var fix_def:b2FixtureDef = new b2FixtureDef();
			
			fix_def.restitution = Fixture_MC.PED.elasticity;
			fix_def.friction = Fixture_MC.PED.friction;
			fix_def.density = Fixture_MC.PED.density;
			Body_MC.PED.body = Body;
			
			set_collision_filter_data();

			switch (Fixture_MC.PED.shape)
			{
				case "Circle" :
					create_circle(Fixture_MC);
					break;
				case "Box" :
					create_box(Fixture_MC);
					break;
				case "Polygon" :
					create_polygon(Fixture_MC);
					break;
			}

			function set_collision_filter_data():void
			{
				if (Boolean(Fixture_MC.PED.category))
				{
					fix_def.filter.categoryBits = Fixture_MC.PED.category;
				}
				if (Boolean(Fixture_MC.PED.mask))
				{
					fix_def.filter.maskBits = Fixture_MC.PED.mask;
				}
				if (Boolean(Fixture_MC.PED.filter_index))
				{
					fix_def.filter.groupIndex = uint(Fixture_MC.PED.filter_index);
				}
			}
			function create_circle(mcFix:MovieClip):void
			{
				var shape:b2CircleShape = new b2CircleShape(CONVERT(mcFix.PED.SYNC.global_init_w / 2, "px", "m"));
				
				if (mcFix.PED.is_child)
				{
					shape.SetLocalPosition(new b2Vec2(mcFix.PED.SYNC.body_offset_x, mcFix.PED.SYNC.body_offset_y));
				}
				
				fix_def.shape = shape;
				body_fixture = Body.CreateFixture(fix_def);
				Body_MC.PED.fix_list[Fixture_MC.name] = body_fixture;
			}
			function create_box(mcFix:MovieClip):void
			{
				var shape:b2PolygonShape = new b2PolygonShape();
				
				if (mcFix.PED.is_child)
				{
					shape.SetAsOrientedBox(CONVERT(mcFix.PED.SYNC.global_init_w / 2, "px", "m"), CONVERT(mcFix.PED.SYNC.global_init_h / 2, "px", "m"), new b2Vec2(mcFix.PED.SYNC.body_offset_x, mcFix.PED.SYNC.body_offset_y), mcFix.PED.body_SP.rotation);
				}
				else
				{
					shape.SetAsBox(CONVERT(mcFix.PED.SYNC.global_init_w / 2, "px", "m"), CONVERT(mcFix.PED.SYNC.global_init_h / 2, "px", "m"));
				}
				
				fix_def.shape = shape;
				body_fixture = Body.CreateFixture(fix_def);
				Body_MC.PED.fix_list[Fixture_MC.name] = body_fixture;
			}
			function create_polygon(mcFix:MovieClip):void
			{
				var shape:b2PolygonShape = new b2PolygonShape();
				var shape_vectors:Vector.<b2Vec2> = new Vector.<b2Vec2>();
				var seperator:b2Separator = new b2Separator();
				var corners_list:Array = Utility.GET_SPECIFIC_TYPE_CHILDRENS(mcFix, ["mcPE_corner", "mcPE_Corner"]);
				var X:Number;
				var Y:Number;
				
				all_corners_list[mcFix.name] = corners_list;
				corners_list.sortOn("name");
				calculate_corners_position(mcFix);
				
				try
				{
					Body_MC.PED.fix_list[Fixture_MC.name] = seperator.Separate(Body, fix_def, shape_vectors, P_SCALER);
				}
				catch(e:Error)
				{
					Console.PRINT("Physics","X ERROR > ERROR CODE : 028 > An error occured while polygon shaping.", 3, "");
					Console.PRINT("Physics","- ERROR DETAIL > " + e.getStackTrace(), 2, "");
				}
				
				function calculate_corners_position(mcFix:MovieClip):void
				{
					if (mcFix.PED.is_child)
					{
						for (var i:int = 0; i < corners_list.length; i ++)
						{
							X =(corners_list[i].x * mcFix.PED.SYNC.global_init_scale_x);
							Y =(corners_list[i].y * mcFix.PED.SYNC.global_init_scale_y);

							var central_distance:Number = MathLab.VECTOR_MAGNITUDE(X, Y);
							var central_angle:Number = MathLab.GET_ANGLE_BTW_TWO_VECTORS(1, 0, X, -Y);
							var corners_global_position:Array = Utility.GET_XY_IN_DYNAMIC_ROTATION(central_distance, central_angle - mcFix.PED.SYNC.body_offset_r)

							X = CONVERT(corners_global_position[0], "px", "m") + mcFix.PED.SYNC.body_offset_x;
							Y = CONVERT(corners_global_position[1], "px", "m") + mcFix.PED.SYNC.body_offset_y;

							shape_vectors[i] = new b2Vec2(X, Y);
						}
					}
					else
					{
						for (var j:int = 0; j < corners_list.length; j ++)
						{
							X = CONVERT((corners_list[j].x * mcFix.PED.SYNC.global_init_scale_x), "px", "m");
							Y = CONVERT((corners_list[j].y * mcFix.PED.SYNC.global_init_scale_y), "px", "m");
							
							shape_vectors[j] = new b2Vec2(X, Y);
						}
					}
				}
			}
		}
		private static function init_kinematic_body(mcPE:MovieClip):void
		{
			Utility.GET_REF_PROPS(mcPE, CONTENT);
			
			mcPE.PED.SYNC = new Object();
			mcPE.PED.SYNC.local_init_r = mcPE.rotation;
			mcPE.PED.SYNC.local_init_w = Utility.GET_REAL_DIM(mcPE).init_w;
			mcPE.PED.SYNC.local_init_h = Utility.GET_REAL_DIM(mcPE).init_h;
			
			mcPE.PED.SYNC.global_init_x = Utility.RPO.x;
			mcPE.PED.SYNC.global_init_y = Utility.RPO.y;
			mcPE.PED.SYNC.global_init_w = Utility.RPO.w;
			mcPE.PED.SYNC.global_init_h = Utility.RPO.h;
			mcPE.PED.SYNC.global_init_r = Utility.RPO.r;
			
			create_body_sprite(mcPE);
			
			mcPE.PED.body_SP.x = CONVERT(mcPE.PED.SYNC.global_init_x, "px", "m");
			mcPE.PED.body_SP.y = CONVERT(mcPE.PED.SYNC.global_init_y, "px", "m");
			mcPE.PED.body_SP.rotation = MathLab.DEGREE_TO_RADIAN(mcPE.PED.SYNC.global_init_r);
			
			function create_body_sprite(mcPE:MovieClip):void
			{
				var body_SP:Sprite = new Sprite();
				CONTENT.addChild(body_SP);
				mcPE.PED.body_SP = body_SP;
			}
		}
		
		// Synchronization Functions:
		private static function sync_shape_to_body(mcPE:MovieClip, Reset_SYNC:Boolean = true):void
		{
			if (Reset_SYNC)
			{
				mcPE.PED.SYNC = new Object();
				create_body_sprite(mcPE);
				create_local_to_global_info(mcPE);
				calculate_init_dimension(mcPE);
				calculate_init_position(mcPE);
			}
			
			if (mcPE.PED.is_child)
			{
				calculate_body_reg_distance(mcPE);
				calculate_shape_offset(mcPE);
				mcPE.PED.body_SP.rotation = MathLab.DEGREE_TO_RADIAN(mcPE.PED.SYNC.body_offset_r);
			}
			else
			{
				mcPE.PED.body_SP.rotation = MathLab.DEGREE_TO_RADIAN(mcPE.PED.SYNC.global_init_r);
			}
			
			function create_body_sprite(mcPE:MovieClip):void
			{
				var body_SP:Sprite = new Sprite();
				CONTENT.addChild(body_SP);
				mcPE.PED.body_SP = body_SP;
			}
			function create_local_to_global_info(mcPE:MovieClip):void
			{
				Utility.GET_REF_PROPS(mcPE, CONTENT);
				
				mcPE.PED.SYNC.local_init_r = mcPE.rotation;
				mcPE.PED.SYNC.local_init_w = Utility.RPO.init_w;
				mcPE.PED.SYNC.local_init_h = Utility.RPO.init_h;
				
				mcPE.PED.SYNC.global_init_x = Utility.RPO.x;
				mcPE.PED.SYNC.global_init_y = Utility.RPO.y;
				mcPE.PED.SYNC.global_init_w = Utility.RPO.w;
				mcPE.PED.SYNC.global_init_h = Utility.RPO.h;
				mcPE.PED.SYNC.global_init_r = Utility.RPO.r;
			}
			function calculate_init_dimension(mcPE:MovieClip):void
			{
				mcPE.PED.SYNC.local_init_r = mcPE.rotation;
				mcPE.rotation = 0;
				
				if (Utility.GET_SPECIFIC_TYPE_CHILDRENS(mcPE, ["mcPE_corner", "mcPE_Corner"]).length > 0)
				{
					var corner_offset_w:Number = Utility.GET_SPECIFIC_TYPE_CHILDRENS(mcPE, ["mcPE_corner", "mcPE_Corner"])[0].width / 2;
					var corner_offset_h:Number = Utility.GET_SPECIFIC_TYPE_CHILDRENS(mcPE, ["mcPE_corner", "mcPE_Corner"])[0].height / 2;
					mcPE.PED.SYNC.global_init_scale_x = (mcPE.PED.SYNC.global_init_w / mcPE.width) * mcPE.scaleX;
					mcPE.PED.SYNC.global_init_scale_y = (mcPE.PED.SYNC.global_init_h / mcPE.height) * mcPE.scaleY;
					mcPE.PED.SYNC.global_init_w = (mcPE.width - corner_offset_w) * mcPE.PED.SYNC.global_init_scale_x;
					mcPE.PED.SYNC.global_init_h = (mcPE.height - corner_offset_h) * mcPE.PED.SYNC.global_init_scale_y;
				}
				else
				{
					mcPE.PED.SYNC.global_init_scale_x = mcPE.PED.SYNC.global_init_w / mcPE.width;
					mcPE.PED.SYNC.global_init_scale_y = mcPE.PED.SYNC.global_init_h / mcPE.height;
					mcPE.PED.SYNC.global_init_w = mcPE.width * mcPE.PED.SYNC.global_init_scale_x;
					mcPE.PED.SYNC.global_init_h = mcPE.height * mcPE.PED.SYNC.global_init_scale_y;
				}
				
				mcPE.rotation = mcPE.PED.SYNC.local_init_r;
				mcPE.PED.SYNC.offset_r = mcPE.PED.SYNC.global_init_r - mcPE.PED.SYNC.local_init_r;
			}
			function calculate_init_position(mcPE:MovieClip):void
			{
				mcPE.PED.SYNC.local_pos_x = mcPE.x;
				mcPE.PED.SYNC.local_pos_y = mcPE.y;
				mcPE.PED.body_SP.x = CONVERT(mcPE.PED.SYNC.global_init_x, "px", "m");
				mcPE.PED.body_SP.y = CONVERT(mcPE.PED.SYNC.global_init_y, "px", "m");
			}
			function calculate_body_reg_distance(mcPE:MovieClip):void
			{
				var mother_global_x:Number =  mcPE.PED.mother.PED.SYNC.global_init_x;
				var mother_global_y:Number =  mcPE.PED.mother.PED.SYNC.global_init_y;
				var mother_global_r:Number = mcPE.PED.mother.PED.SYNC.global_init_r;
				var child_global_x:Number = mcPE.PED.SYNC.global_init_x;
				var child_global_y:Number = mcPE.PED.SYNC.global_init_y;
				var child_global_r:Number = mcPE.PED.SYNC.global_init_r;
	
				mcPE.PED.SYNC.body_distance = MathLab.DISTANCE_POINTS(0, 0, child_global_x - mother_global_x, -(child_global_y - mother_global_y));
				mcPE.PED.SYNC.body_angle = MathLab.DEGREE_TO_RADIAN(MathLab.GET_ABS_ANGLE(child_global_x - mother_global_x, -(child_global_y - mother_global_y)) + mother_global_r);
				mcPE.PED.SYNC.body_offset_r = child_global_r - mother_global_r;
				mcPE.PED.SYNC.shape_offset_r = child_global_r - mother_global_r;
				
				var current_body_distances:Array = Utility.GET_XY_IN_DYNAMIC_ROTATION(mcPE.PED.SYNC.body_distance, MathLab.RADIAN_TO_DEGREE(mcPE.PED.SYNC.body_angle));
				mcPE.PED.SYNC.body_offset_x = CONVERT(current_body_distances[0], "px", "m");
				mcPE.PED.SYNC.body_offset_y = CONVERT(current_body_distances[1], "px", "m");		
			}
			function calculate_shape_offset(mcPE:MovieClip):void
			{
				var angle:Number =  MathLab.RADIAN_TO_DEGREE(mcPE.PED.SYNC.body_angle - mcPE.PED.mother.PED.body_SP.rotation);
				var current_shape_distances:Array = Utility.GET_XY_IN_DYNAMIC_ROTATION(mcPE.PED.SYNC.body_distance, angle); 
					
				mcPE.PED.SYNC.shape_offset_x = current_shape_distances[0];
				mcPE.PED.SYNC.shape_offset_y = current_shape_distances[1];
			}
		}
		private static function sync_body_to_shape(mcPE:MovieClip, Body:b2Body):void
		{
			update_location_info(mcPE, Body);
			update_PPI(mcPE);
			update_segments();
			
			function update_location_info(mcPE:MovieClip, Body:b2Body):void
			{
				mcPE.PED.body_SP.x = Body.GetPosition().x;
				mcPE.PED.body_SP.y = Body.GetPosition().y;
				mcPE.PED.body_SP.rotation = Body.GetAngle();
				
				if (mcPE.PED.is_child)
				{
					calculate_shape_offset(mcPE);
					
					mcPE.PED.body_SP.x = mcPE.PED.mother.PED.body_SP.x + mcPE.PED.SYNC.shape_offset_x;
					mcPE.PED.body_SP.y = mcPE.PED.mother.PED.body_SP.y + mcPE.PED.SYNC.shape_offset_y;
					mcPE.PED.body_SP.rotation = mcPE.PED.mother.PED.body_SP.rotation + mcPE.PED.SYNC.shape_offset_r;
				}
				else
				{
					mcPE.PED.body_SP.x = CONVERT(mcPE.PED.body_SP.x, "m", "px");
					mcPE.PED.body_SP.y = CONVERT(mcPE.PED.body_SP.y, "m", "px");
					mcPE.PED.body_SP.rotation = MathLab.RADIAN_TO_DEGREE(mcPE.PED.body_SP.rotation);
				}
				
				Utility.GET_REF_PROPS(mcPE.PED.body_SP, mcPE.parent, [mcPE.PED.SYNC.local_init_w, mcPE.PED.SYNC.local_init_h]);
				mcPE.PED.shape_x = Utility.RPO.x;
				mcPE.PED.shape_y = Utility.RPO.y;
				mcPE.PED.shape_r = mcPE.PED.body_SP.rotation - mcPE.PED.SYNC.offset_r;
				
				
			}
			function update_PPI(mcPE:MovieClip):void
			{
				if (!Boolean(mcPE.PED.PPI))
				{
					mcPE.PED.PPI = new Object();
				}
				
				if (Boolean(mcPE.PED.PPI.ang_speed) || Boolean(mcPE.PED.PPI.speed_x) || Boolean(mcPE.PED.PPI.speed_y))
				{
					mcPE.PED.PPI.ang_speed_f = mcPE.PED.PPI.ang_speed;
					mcPE.PED.PPI.speed_x_f = mcPE.PED.PPI.speed_x;
					mcPE.PED.PPI.speed_y_f = mcPE.PED.PPI.speed_y;
					
				}
				else
				{
					mcPE.PED.PPI.ang_speed_f = 0;
					mcPE.PED.PPI.speed_x_f = 0;
					mcPE.PED.PPI.speed_y_f = 0;
				}
				
				mcPE.PED.PPI.rotation = mcPE.PED.shape_r;
				mcPE.PED.PPI.x = mcPE.PED.shape_x;
				mcPE.PED.PPI.y = mcPE.PED.shape_y;
				mcPE.PED.PPI.angle = MathLab.RADIAN_TO_DEGREE(Body.GetAngle());
				mcPE.PED.PPI.ang_damping = MathLab.RADIAN_TO_DEGREE(Body.GetAngularDamping());
				mcPE.PED.PPI.inertia = Body.GetInertia();
				mcPE.PED.PPI.lin_damping = CONVERT(Body.GetLinearDamping(), "m", "px");
				mcPE.PED.PPI.ang_speed = MathLab.RADIAN_TO_DEGREE(Body.GetAngularVelocity());
				mcPE.PED.PPI.speed_x = CONVERT(Body.GetLinearVelocity().x, "m", "px");
				mcPE.PED.PPI.speed_y = CONVERT(Body.GetLinearVelocity().y, "m", "px");
				mcPE.PED.PPI.speed = MathLab.VECTOR_MAGNITUDE(mcPE.PED.PPI.speed_x, mcPE.PED.PPI.speed_y);
				mcPE.PED.PPI.real_speed = mcPE.PED.PPI.speed * SCALE;
				mcPE.PED.PPI.mass = Body.GetMass();
				mcPE.PED.PPI.real_mass = Body.GetMass()/P_SCALER;
			}
			function update_segments():void
			{
				for (var segment_name:* in segment_list)
				{
					if (segment_list[segment_name].ready)
					{
						WORLD.RayCast(segment_callback, new b2Vec2(CONVERT(segment_list[segment_name].A[0], "px", "m"), CONVERT(segment_list[segment_name].A[1], "px", "m")), new b2Vec2(CONVERT(segment_list[segment_name].B[0], "px", "m"), CONVERT(segment_list[segment_name].B[1], "px", "m")));
					}
				}
				
				function segment_callback(Fix:b2Fixture, Point:b2Vec2, Normal:b2Vec2, Fraction:Number):Number 
				{
					var Feedback:Object = new Object();
					Feedback.x = CONVERT(Point.x, "m", "px");
					Feedback.y = CONVERT(Point.y, "m", "px");
					Feedback.normal_x = CONVERT(Normal.x, "m", "px");
					Feedback.normal_y = CONVERT(Normal.y, "m", "px");
					Feedback.fraction = Fraction;
					Feedback.mcPE = get_mcPE_by_name([Fix.GetBody().GetUserData().name])[0];
					
					segment_list[segment_name].respond(Feedback);
					
					return 1;
				}
			}
			function calculate_shape_offset(mcPE:MovieClip):void
			{
				var angle:Number =  MathLab.RADIAN_TO_DEGREE(mcPE.PED.SYNC.body_angle) - mcPE.PED.mother.PED.body_SP.rotation;
				var current_shape_distances:Array = Utility.GET_XY_IN_DYNAMIC_ROTATION(mcPE.PED.SYNC.body_distance, angle); 
						
				mcPE.PED.SYNC.shape_offset_x = current_shape_distances[0];
				mcPE.PED.SYNC.shape_offset_y = current_shape_distances[1];
			}
		}
		private static function update_kinematic_body(mcPE:MovieClip, Body:b2Body):void
		{
			Utility.GET_REF_PROPS(mcPE, CONTENT, [mcPE.PED.SYNC.local_init_w, mcPE.PED.SYNC.local_init_h]);
				
			mcPE.PED.SYNC.global_init_x = Utility.RPO.x;
			mcPE.PED.SYNC.global_init_y = Utility.RPO.y;
			mcPE.PED.SYNC.global_init_w = Utility.RPO.w;
			mcPE.PED.SYNC.global_init_h = Utility.RPO.h;
			mcPE.PED.SYNC.global_init_r = Utility.RPO.r;

			mcPE.PED.body_SP.x = CONVERT(mcPE.PED.SYNC.global_init_x, "px", "m");
			mcPE.PED.body_SP.y = CONVERT(mcPE.PED.SYNC.global_init_y, "px", "m");
			mcPE.PED.body_SP.rotation = MathLab.DEGREE_TO_RADIAN(mcPE.PED.SYNC.global_init_r);
		
			Body.SetPosition(new b2Vec2(mcPE.PED.body_SP.x, mcPE.PED.body_SP.y));
			Body.SetAngle(mcPE.PED.body_SP.rotation);
		}
		private static function update_joint_info(mcPE:MovieClip):void
		{
			if (Boolean(mcPE.PED.joint_list))
			{
				for (var jdo_name:String in mcPE.PED.joint_list) 
				{
					if (Boolean(mcPE.PED.joint_list[jdo_name].mc_shape))
					{
						get_joint_info(mcPE.PED.joint_list[jdo_name]);
						locate_joint_shape(mcPE.PED.joint_list[jdo_name]);

						if (Boolean(mcPE.PED.joint_list[jdo_name].mc_shape.JOINT_UPDATE))
						{
							update_JSI(mcPE.PED.joint_list[jdo_name]);
							mcPE.PED.joint_list[jdo_name].mc_shape.JOINT_UPDATE(mcPE.PED.joint_list[jdo_name].JSI);
						}
					}
					
					if (mcPE.PED.joint_list[jdo_name].update && mcPE.PED.joint_list[jdo_name].joint)
					{
						update_forces(mcPE.PED.joint_list[jdo_name]);
						mcPE.PED.joint_list[jdo_name].update(mcPE.PED.joint_list[jdo_name]);
					}
				}
			}
			function update_forces(JDO:Object):void
			{
				JDO.force_x = JDO.joint.GetReactionForce(1/simulate_delay ).x;
				JDO.force_y = JDO.joint.GetReactionForce(1/simulate_delay).y;
				JDO.force = MathLab.VECTOR_MAGNITUDE(JDO.force_x, JDO.force_y);
				JDO.torque = JDO.joint.GetReactionTorque(1/simulate_delay);
			}
			function get_joint_info(JDO:Object):void
			{
				JDO.JSI.joint = JDO.joint;
					
				JDO.JSI.A.global_x = CONVERT(JDO.joint.GetBodyA().GetWorldCenter().x, "m", "px");
				JDO.JSI.A.global_y = CONVERT(JDO.joint.GetBodyA().GetWorldCenter().y, "m", "px");

				JDO.JSI.B.global_x = CONVERT(JDO.joint.GetAnchorA().x, "m", "px");
				JDO.JSI.B.global_y = CONVERT(JDO.joint.GetAnchorA().y, "m", "px");
					
				JDO.JSI.C.global_x = CONVERT(JDO.joint.GetAnchorB().x, "m", "px");
				JDO.JSI.C.global_y = CONVERT(JDO.joint.GetAnchorB().y, "m", "px");
					
				JDO.JSI.D.global_x = CONVERT(JDO.joint.GetBodyB().GetWorldCenter().x, "m", "px");
				JDO.JSI.D.global_y = CONVERT(JDO.joint.GetBodyB().GetWorldCenter().y, "m", "px");
					
				if (JDO.type == "Pulley")
				{
					JDO.JSI.G1.global_x = CONVERT(JDO.joint.GetGroundAnchorA().x, "m", "px");
					JDO.JSI.G1.global_y = CONVERT(JDO.joint.GetGroundAnchorA().y, "m", "px");
						
					JDO.JSI.G2.global_x = CONVERT(JDO.joint.GetGroundAnchorB().x, "m", "px");
					JDO.JSI.G2.global_y = CONVERT(JDO.joint.GetGroundAnchorB().y, "m", "px");
				}
			}
			function locate_joint_shape(JDO:Object):void
			{
				Utility.GET_REF_PROPS(CONTENT, JDO.mc_shape.parent);
				JDO.mc_shape.rotation = 0;
				JDO.mc_shape.scaleX = 1;
				JDO.mc_shape.scaleY = 1;
				
				if (JDO.type == "Pulley")
				{
					JDO.mc_shape.x = Utility.RPO.x + JDO.JSI.G1.global_x;
					JDO.mc_shape.y = Utility.RPO.y + JDO.JSI.G1.global_y;
				}
				else
				{
					JDO.mc_shape.x = Utility.RPO.x + JDO.JSI.A.global_x;
					JDO.mc_shape.y = Utility.RPO.y + JDO.JSI.A.global_y;
				}
				
				JDO.mc_shape.visible = true;
			}
			function update_JSI(JDO:Object):void
			{
				if (JDO.type == "Pulley")
				{
					calculate_coordinates(JDO.JSI.G1);
				}
				else
				{
					calculate_coordinates(JDO.JSI.A);
				}
				
				function calculate_coordinates(Reference_Point:Object):void
				{
					update_distance_and_rot(JDO.JSI.A, JDO.JSI.B)
					
					JDO.JSI.A.x = JDO.JSI.A.global_x - Reference_Point.global_x;
					JDO.JSI.A.y = JDO.JSI.A.global_y - Reference_Point.global_y;
					JDO.JSI.A.r = JDO.JSI.rot;
					
					JDO.JSI.AB.x = JDO.JSI.A.global_x - Reference_Point.global_x; 
					JDO.JSI.AB.y = JDO.JSI.A.global_y - Reference_Point.global_y;
					JDO.JSI.AB.r = JDO.JSI.rot;
					JDO.JSI.AB.d = JDO.JSI.distance;
					
					update_distance_and_rot(JDO.JSI.B, JDO.JSI.C)
					
					JDO.JSI.B.x = JDO.JSI.B.global_x - Reference_Point.global_x;
					JDO.JSI.B.y = JDO.JSI.B.global_y - Reference_Point.global_y;
					JDO.JSI.B.r = JDO.JSI.rot;
					
					JDO.JSI.BC.x = JDO.JSI.B.x; 
					JDO.JSI.BC.y = JDO.JSI.B.y;
					JDO.JSI.BC.r = JDO.JSI.rot;
					JDO.JSI.BC.d = JDO.JSI.distance;
					
					update_distance_and_rot(JDO.JSI.C, JDO.JSI.D)
					
					JDO.JSI.C.x = JDO.JSI.C.global_x - Reference_Point.global_x;
					JDO.JSI.C.y = JDO.JSI.C.global_y - Reference_Point.global_y;
					JDO.JSI.C.r = JDO.JSI.rot;
					
					JDO.JSI.CD.x = JDO.JSI.C.x; 
					JDO.JSI.CD.y = JDO.JSI.C.y;
					JDO.JSI.CD.r = JDO.JSI.rot;
					JDO.JSI.CD.d = JDO.JSI.distance;
					
					update_distance_and_rot(JDO.JSI.D, JDO.JSI.C)
					
					JDO.JSI.D.x = JDO.JSI.D.global_x - Reference_Point.global_x;
					JDO.JSI.D.y = JDO.JSI.D.global_y - Reference_Point.global_y;
					JDO.JSI.D.r = JDO.JSI.rot;
					
					if (JDO.type == "Pulley")
					{
						JDO.JSI.G1.x = JDO.JSI.G1.global_x - Reference_Point.global_x;
						JDO.JSI.G1.y = JDO.JSI.G1.global_y - Reference_Point.global_y;
						
						JDO.JSI.G2.x = JDO.JSI.G2.global_x - Reference_Point.global_x;
						JDO.JSI.G2.y = JDO.JSI.G2.global_y - Reference_Point.global_y;
						
						update_distance_and_rot(JDO.JSI.B, JDO.JSI.G1)
						
						JDO.JSI.BG1.x = JDO.JSI.B.x;
						JDO.JSI.BG1.y = JDO.JSI.B.y;
						JDO.JSI.BG1.r = JDO.JSI.rot;
						JDO.JSI.BG1.d = JDO.JSI.distance;
						
						update_distance_and_rot(JDO.JSI.G1, JDO.JSI.G2)
						
						JDO.JSI.G1G2.x = JDO.JSI.G1.x;
						JDO.JSI.G1G2.y = JDO.JSI.G1.y;
						JDO.JSI.G1G2.r = JDO.JSI.rot;
						JDO.JSI.G1G2.d = JDO.JSI.distance;
						
						update_distance_and_rot(JDO.JSI.G2, JDO.JSI.C)
						
						JDO.JSI.G2C.x = JDO.JSI.C.x;
						JDO.JSI.G2C.y = JDO.JSI.C.y;
						JDO.JSI.G2C.r = JDO.JSI.rot - 180;
						JDO.JSI.G2C.d = JDO.JSI.distance;
					}
				}
				function update_distance_and_rot(Point_A:Object, Point_B:Object):void
				{
					JDO.JSI.distance = MathLab.DISTANCE_POINTS(Point_A.global_x, Point_A.global_y, Point_B.global_x, Point_B.global_y);
					JDO.JSI.rot = MathLab.MATH_TO_FLASH_ROTATION(MathLab.GET_ABS_ANGLE(Point_B.global_x - Point_A.global_x, -(Point_B.global_y - Point_A.global_y)));
				}
			}
		}
		
		// Other Functions:
		private static function get_mcPE_by_name(mcPE_Name_List:Array):Array
		{
			var mcPE_list:Array = new Array();
			
			for (var i:int = 0; i < mcPE_Name_List.length; i ++)
			{
				var index:int = body_name_list.indexOf(mcPE_Name_List[i]);
				mcPE_list.push(POL[index]);
			}
			
			return mcPE_list;
		}
		private static function get_body(mcPE:MovieClip):b2Body
		{
			return body_list[POL.indexOf(mcPE)];
		}
		private static function setup_MJO(Force:Number = 0):void
		{
			MJO = new Object();
			
			InputControl.DEFINE("Physics_Mouse_Joint", MAP.MOUSE_AREA, ICC_update_mouse_joint, ["Mouse"]);
			setup_MJO();
				
			function setup_MJO():void
			{	
				var mouse_joint:b2MouseJoint;
				var mouse_pvec:b2Vec2 = new b2Vec2();
				var mouse_joint_def:b2MouseJointDef = new b2MouseJointDef();
					
				MJO.active = false;
				MJO.current_body = null;
				MJO.mouse_joint = mouse_joint;
				MJO.mouse_joint_def = mouse_joint_def;
				MJO.mouse_pvec = mouse_pvec;
				MJO.update = update;
				MJO.force = Force;
					
				function update():void
				{
					if (MJO.mouse_joint)
					{
						var p2:b2Vec2 = new b2Vec2(MJO.physics_x, MJO.physics_y);
									
						MJO.mouse_joint.SetTarget(p2);
					}
				}
			}
			function ICC_update_mouse_joint(Param:Object):void
			{
				if (Param.type == "Mouse")
				{	
					MJO.x = GET_MOUSE_POINT().x;
					MJO.y = GET_MOUSE_POINT().y;
					MJO.physics_x = CONVERT(MJO.x, "px", "m");
					MJO.physics_y = CONVERT(MJO.y, "px", "m");
						
					if (Param.mouseUp || Param.rollOut)
					{
						remove_mouse_joint();
					}
					else if (Param.mouseDown)
					{
						add_mouse_joint();
					}
				}
					
				function add_mouse_joint():void
				{
					if (!MJO.mouse_joint) 
					{
						if (full_mouse_support)
						{
							MJO.current_body = FIND_BODY_IN_CANVAS(MJO.physics_x, MJO.physics_y, MJO.physics_x - 0.001, MJO.physics_y - 0.001, MJO.physics_x + 0.001, MJO.physics_y + 0.001, [2]);
						}
						else
						{
							MJO.current_body = FIND_BODY_IN_CANVAS(MJO.physics_x, MJO.physics_y, MJO.physics_x - 0.001, MJO.physics_y - 0.001, MJO.physics_x + 0.001, MJO.physics_y + 0.001, [2],  mouse_joint_list);
						}
						
						if (Boolean(MJO.current_body))
						{
							MJO.mouse_joint_def.bodyA = WORLD.GetGroundBody();
							MJO.mouse_joint_def.bodyB = MJO.current_body;
							MJO.mouse_joint_def.target.Set(MJO.physics_x, MJO.physics_y);
							MJO.mouse_joint_def.collideConnected = true;
								
							if (MJO.force)
							{
								MJO.mouse_joint_def.maxForce = MJO.force;
							}
							else
							{
								MJO.mouse_joint_def.maxForce = 1000000.0 * MJO.current_body.GetMass();
							}
								
							MJO.mouse_joint = WORLD.CreateJoint(MJO.mouse_joint_def) as b2MouseJoint;
							MJO.current_body.SetAwake(true);
							
							MAP.SET_CONTROL(false);
						}
					}
				}
				function remove_mouse_joint():void
				{
					if (MJO.mouse_joint) 
					{
						WORLD.DestroyJoint(MJO.mouse_joint);
						MJO.mouse_joint = null;
						MJO.current_body = null;
					}
					
					MAP.SET_CONTROL(true);
				}
			}
		}
	}
}