/*

	------------------------------------------------------------
	- INTERACTION(C) 2016
	------------------------------------------------------------
	
	* FULL STATIC
	* INIT : true
	
	v1.0 : 28.02.2016 : Nesneler arasındaki etkileşimleri gerçekleştirir.
	
	v2.0 : 20.03.2016 : 
		Eklenen yeni özellikler:
		1. Link 'Mouse' için kritik bir hata giderildi. ADD_GROUP() metodu yenilendi.
		2. ACTO Feedback gönderme mekanizması yenilendi. Artık yalnızca feedback üzerinde gerçekten bir değişiklik olduğunda gönderme işlemi gerçekleştirilecek. 
		3. Yeni ACTO Feedback mekanizması projeye göre ciddi performans artışı sağlayabilir. Ayrıca Animator.as gibi sınıflarla daha güvenli çalışmayı sağlıyor.
		4. ADD_GROUP() metoduna 'Object_Action_Areas' parametresi eklendi. Böylece kendisi yerine farklı bir nesnenin etkileşimlerini dinleyebilir. 
		(Örnek: Bir nesnenin sürükle-bırak etkileşimine girmesini istediğinizi düşünün. Fakat bu etkileşimin bu nesnenin sadece belirli bir bölgesi ile sınırlandırmak istediğinizde bu parametreyi kullanabilirsiniz.)
		5. ADD_GROUP() metodu için 'Link' parametresi kaldırıldı.
		6. Methodlar gruplandırıldı.
		7. Physics.as ile çalışılmadığı durumlarda compile time'ı azaltmak için pratik bir yöntem geliştirildi.
	
	v2.1 : 23.04.2016 : TIMER yapısı güncellendi.
	
	UYARILAR			:	! ADD_GROUP() metodu ile tanıttığınız nesneler eğer Link parametresinde 'Physics' içeriyorsa, bu nesnelerin bu metod çağrılmadan önce Physics.as tarafından fizik nesnelerine dönüştürülmüş olmaları beklenir.
							! 'Fine_Hit' Link'i için 'Action_Area' parametresini 'null' değerinde bırakmalısınız. Çünkü henüz desteklenmiyor.
	
	by Samet Baykul

*/

package lbl
{
	// Flash Library:
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.Timer;
	// LBL Core:
	import lbl.Utility;
	import lbl.Gensys;
	import lbl.Processor;
	// LBL Control:
	import lbl.Console;
	

	public class Interaction
	{

		// ------------------------------------------------------------
		// PROPERTIES :
		// ------------------------------------------------------------
		
		public static var INTOL:Array;									// Interaction Objects List
		public static var ACTOL:Array;									// Action Objects List
		public static var TIMER:Timer;
		public static var ACTIVE:Boolean;
		
		//-> Fine Tunning
		private static var available_links:Array = ["Constant", "Mouse", "Hit", "Fine_Hit", "Physics"];
		private static var physics:Class;
		//private static var physics:Class = Physics;
		
		private static var active_links:Array;
		private static var self_timer:Boolean;
		
		
		// Class Info:
		private static var id:String = "INT";
		private static var no:int = 021;
		
		// Temporarily:
		private static var info:Object = new Object();
		
		public function Interaction()
		{
			// Full static class
		}
		
		// ------------------------------------------------------------
		// METHODS :
		// ------------------------------------------------------------
		
		// General Methods:
		
		public static function INIT(Timer_Link:String = "Global"):void
		{
			init_starting_vars();
			init_timer();
			init_command_support();
			
			function init_starting_vars():void
			{
				INTOL = new Array();
				ACTOL = new Array();
				ACTIVE = false;
				
				active_links = new Array();
			}
			function init_timer():void
			{
				if (Gensys.TIMEL[Timer_Link])
				{
					TIMER = Gensys.TIMEL[Timer_Link];
				}
				else if (Timer_Link == "Self")
				{
					TIMER = Gensys.NEW_TIMER("Interaction_Clock");
				}
				else
				{
					TIMER = Gensys.NEW_TIMER(Timer_Link);
				}
			}
			function init_command_support():void
			{
				Console.ADD_COMMAND(id, "intinfo", intinfo, null, "Overall info about Interaction.as");
				Console.ADD_COMMAND(id, "intol", intol, null, "INTOL: Interaction Objects List.");
				Console.ADD_COMMAND(id, "actol", actol, null, "ACTOL: Action Objects List.");
				
				function intinfo():void
				{
					var info_matrix:Array = new Array();
					
					info_matrix[0] = ["ACTIVE", ACTIVE, "Read Only", ""];
					info_matrix[1] = ["active_links", active_links, "Private", ""];
					info_matrix[2] = ["self_timer", self_timer, "Private", ""];
					
					Console.PRINT_CLASS_INFO(id, info_matrix);
				}
				function intol():void
				{
					Console.DYNAMIC_DATA("INTOL", INTOL);
				}
				function actol():void
				{
					Console.PRINT_DATA(id, "ACTOL", ACTOL);
				}
			}	
		}
		public static function START(Actions_Support:Array = null):void
		{
			if (Boolean(Actions_Support))
			{
				if (Utility.TEST_ARRAY_ELEMENTS(available_links, Actions_Support))
				{
					active_links = Actions_Support;
					ACTIVE = true;
				}
				else
				{
					trace("hata. START parametreleri yanlış");
					ACTIVE = false;
				}
			}
			else
			{
				active_links = available_links;
				ACTIVE = true;
			}
			
			update_ACTOL();
		
		}
		public static function STOP():void
		{
			ACTIVE = false;
			
			update_ACTOL();
		}
		public static function SET_LINKS(Actions_Support:Array):void
		{
			if (Utility.TEST_ARRAY_ELEMENTS(available_links, Actions_Support))
			{
				active_links = Actions_Support;
				
				update_ACTOL();
			}
			else
			{
				trace("hata. SET_LINKS parametreleri yanlış");
			}
		}
		public static function UPDATE():void
		{
			update_ACTOL();
		}
		
		// Group Methods:
		
		public static function ADD_GROUP(Group_Name:String, Object_Names:Array, Objects:Array, Object_Action_Areas:Array = null, Labels:Array = null):void
		{
			Processor.RUN_CHAIN([_1_test_objects_length,
								 _2_lengths_equality,
								 _3_test_action_areas,
								 _4_unique_tes_for_INTO],
								 init_add_group);
								 
								 
			function _1_test_objects_length():Boolean
			{
				return Boolean(Object_Names.length > 0)
			}
			function _2_lengths_equality():Boolean
			{
				return Boolean(Objects.length == Object_Names.length)
			}
			function _3_test_action_areas():Boolean
			{
				if (!Boolean(Object_Action_Areas))
				{
					Object_Action_Areas = new Array();
					
					for (var i:int = 0; i < Objects.length; i ++)
					{
						Object_Action_Areas[i] = Objects[i];
					}
					
					return true;
				}
				else
				{
					if (Objects.length == Object_Action_Areas.length)
					{
						return true;
					}
					else
					{
						return false;
					}
				}
			}
			function _4_unique_tes_for_INTO():Boolean
			{
				var ok:Boolean = true;
				
				for (var i:int = 0; i < Objects.length; i ++)
				{
					for each(var INTO:Object in INTOL[Group_Name])
					{
						if (Utility.TEST_ARRAY_ELEMENTS([Object_Names[i]], [INTO.name]))
						{
							ok = false;
						}
					}
				}
				
				return ok;
			}

			function init_add_group():void
			{
				for (var i:int = 0; i < Objects.length; i ++)
				{
					if (!Boolean(Labels))
					{
						Labels = ["General"];
					}
						
					create_INTO(Group_Name, Object_Names[i], Objects[i], Object_Action_Areas[i], Labels);
					update_ACTOL();
				} 
			}
		}
		public static function UPDATE_GROUP(Group_Name:String, Labels:Array = null):void
		{
			if (Boolean[INTOL[Group_Name]])
			{
				for each (var INTO:Object in INTOL[Group_Name])
				{
					update_INTO(INTO, INTOL[Group_Name].action_object, Labels);
					update_ACTOL();
				}
			}
			else
			{
				trace("uyarı. böyle bir grup bulunamadı.");
			}
		}
		public static function UPDATE_OBJECT(Target_Object:Object, Only_These_Groups:Array = null, Object_Action_Areas:Object = null, Labels:Array = null, New_Group_Name:String = null):void
		{
			var Group_Name:String;

			for (var i:int = 0; i < Only_These_Groups.length; i ++)
			{
				Group_Name = Only_These_Groups[i];

				if (Boolean(INTOL[Group_Name]))
				{
					for each(var INTO:Object in INTOL[Group_Name])
					{
						if (INTO.object == Target_Object)
						{
							// *
							
							if (New_Group_Name)
							{
								if (!Boolean(INTOL[New_Group_Name]))
								{
									INTOL[New_Group_Name] = new Array();
								}
								
								INTOL[New_Group_Name].push(Target_Object);
								Target_Object = null;
								Utility.COMPRESS_ARRAY(INTOL[Group_Name]);
								
								update_ACTOL();
							}
							else
							{
								update_INTO(INTO, Object_Action_Areas, Labels);
								
								update_ACTOL();
							}
						}
					}
				}
				else
				{
					trace("uyarı. böyle bir grup bulunamadı.");
				}
			}
		}
		public static function UPDATE_OBJECT_BY_NAME(Object_Name:String, Only_These_Groups:Array = null, Object_Action_Areas:Object = null, Labels:Array = null, New_Group_Name:String = null):void
		{
			var Group_Name:String;
			
			for (var i:int = 0; i < Only_These_Groups.length; i ++)
			{
				Group_Name = Only_These_Groups[i]
				
				if (Boolean[INTOL[Group_Name]])
				{
					for (var INTO_name:String in INTOL[Group_Name])
					{
						if (INTO_name == Object_Name)
						{
							if (New_Group_Name)
							{
								if (!Boolean(INTOL[New_Group_Name]))
								{
									INTOL[New_Group_Name] = new Array();
								}
								
								INTOL[New_Group_Name].push(INTOL[Group_Name][INTO_name]);
								INTOL[Group_Name][INTO_name] = null;
								Utility.COMPRESS_ARRAY(INTOL[Group_Name]);
								
								update_ACTOL();
							}
							else
							{
								update_INTO(INTOL[Group_Name][INTO_name], Object_Action_Areas, Labels);
								
								update_ACTOL();
							}
						}
					}
				}
				else
				{
					trace("uyarı. böyle bir grup bulunamadı.");
				}
			}
		}
		public static function DELETE_GROUPS(Groups:Array):int
		{
			var deleted_number:int = 0;
			
			for (var i:int = 0; i < Groups.length; i ++)
			{
				if (Boolean(INTOL[Groups[i]]))
				{
					delete INTOL[Groups[i]];
				}
			}
			
			if (deleted_number == 0)
			{
				trace("uyarı. silinecek bir grup bulunamadı.");
			}
			
			Utility.COMPRESS_ARRAY(INTOL);
			
			return deleted_number;
		}
		public static function DELETE_OBJECTS(Object_Names:Array, In_Only_Group:String = null):int
		{
			var deleted_number:int = 0;
			
			if (Boolean(In_Only_Group))
			{
				if (Boolean[INTOL[In_Only_Group]])
				{
					delete_objects_in_group(In_Only_Group)
				}
				else
				{
					trace("uyarı. böyle bir grup bulunamadı.");
				}
			}
			else
			{
				for (var Gorup_Name:String in INTOL)
				{
					delete_objects_in_group(Gorup_Name)
				}
			}

			if (deleted_number == 0)
			{
				trace("uyarı. silinecek obje bulunamadı.");
			}
			
			return deleted_number;
			
			function delete_objects_in_group(Group:String):void
			{
				for (var i:int; i < INTOL[Group].length; i ++)
				{
					if (Utility.TEST_ARRAY_ELEMENTS(Object_Names, [INTOL[Group][i].name]))
					{
						delete INTOL[Group][i];
						deleted_number ++;
					}
				}
					
				Utility.COMPRESS_ARRAY(INTOL[Group]);
					
				if (INTOL[Group].length == 0)
				{
					delete INTOL[Group];
					deleted_number ++;
						
					Utility.COMPRESS_ARRAY(INTOL);
				}
			}
		}
		
		// Action Methods
		
		public static function ADD_ACTION(Action_Name:String, Action_Function:Function, Link:String, Groups:Array, Requirements:Array, Filters:Array = null):void
		{
			if (!Boolean(ACTOL[Action_Name]))
			{
				if (test_available_links([Link]))
				{
					var ACTO:Object = new Object();
				
					ACTO.name = Action_Name;
					ACTO.link = Link;
					ACTO.active = false;
					ACTO.groups = Groups;
					ACTO.require = Requirements;
					ACTO.action = Action_Function;
					ACTO.filter = Filters;
					ACTO.data = new Object();
					
					ACTO.INTO_list = new Array();
					ACTO.potentials_KEY = new Array();
					ACTO.potentials_IND = new Array();
					ACTO.potential_labels = new Array();

					add_props_related_link();
					
					ACTOL[Action_Name] = ACTO;
					update_ACTOL();
				}
				else
				{
					trace("uyarı. Hatalı link adı.");
				}
			}
			else
			{
				trace("uyarı. bu ACTO daha önce kullanılmış.");
			}
			
			function add_props_related_link():void
			{
				switch (ACTO.link)
				{
					case "Mouse":
						add_mouse_delta();
						add_mouse_selected_items();
						add_mouse_init_pos();
						add_auto_drag_drop_func();
						break;
					case "Hit":
						add_collision_data();
						add_set_collision_func();
						break;
					case "Fine_Hit":
						add_collision_data();
						add_set_collision_func();
						add_bitmap_transform();
						break;
					case "Physics":
						add_collision_data();
						add_set_collision_func();
						add_set_physical_collision_func();
						add_physics_data();
						break;
				}
			}
			
			function add_mouse_delta():void
			{
				ACTO.mouse_delta = new Object();
				ACTO.mouse_delta.delta = new Object();
				ACTO.mouse_delta.point_A = new Object();
				ACTO.mouse_delta.point_B = new Object();

				ACTO.mouse_delta.active = false;
				ACTO.mouse_delta.delta.x = 0;
				ACTO.mouse_delta.delta.y = 0;
				ACTO.mouse_delta.point_A.x = 0;
				ACTO.mouse_delta.point_A.y = 0;
				ACTO.mouse_delta.point_B.x = 0;
				ACTO.mouse_delta.point_B.y = 0;
			}
			function add_mouse_selected_items():void
			{
				ACTO.multi_selection = false;
				ACTO.selected = new Array();
				ACTO.last_selected = null;
				ACTO.mouse_target = new Object();
				ACTO.INTO_target = new Object();
			}
			function add_mouse_init_pos():void
			{
				ACTO.init_pos = new Array();
			}
			function add_auto_drag_drop_func():void
			{
				ACTO.drag_drop = drag_drop;
					
				function drag_drop():void
				{
					if (ACTO.mouse_delta.active)
					{
						for (var key:String in ACTO.init_pos)
						{
							ACTO.potentials_KEY[key].x = ACTO.init_pos[key][0] + ACTO.mouse_delta.delta.x;
							ACTO.potentials_KEY[key].y = ACTO.init_pos[key][1] + ACTO.mouse_delta.delta.y;
						}
					}
				}
			}
			function add_collision_data():void
			{
				ACTO.collisions = new Array();
				ACTO.hit_target = new Object();
			}
			function add_set_collision_func():void
			{
				ACTO.reset_collisions = reset_collisions;
					
				function reset_collisions():void
				{
					for (var i:int; i < ACTO.potentials_IND.length; i++)
					{
						ACTO.collisions[ACTO.potentials_IND[i].name] = new Array();
					}
				}
			}
			function add_set_physical_collision_func():void
			{
				ACTO.reset_physical_collisions = reset_physical_collisions;
					
				function reset_physical_collisions():void
				{
					for (var i:int; i < ACTO.potentials_IND.length; i++)
					{
						ACTO.physics_collisions[ACTO.potentials_IND[i].name] = new Array();
					}
				}
			}
			function add_bitmap_transform():void
			{
				ACTO.bitmap_transform_list = new Array();
				ACTO.bitmap_transform_list.update = update;
					
				function update():void
				{
					for (var key:String in ACTO.potentials_KEY)
					{
						var bitmap_transform:Object = new Object();
						bitmap_transform.rect;
						bitmap_transform.offset;
						bitmap_transform.bitmap_data;
						bitmap_transform.location;
	
						ACTO.bitmap_transform_list[key] = bitmap_transform;
					}
				}
			}
			function add_physics_data():void
			{
				ACTO.physics_collisions = new Array();
			}
		}
		public static function UPDATE_ACTION(Action_Name:String, Action_Function:Function = null, Link:String = null, Requirements:Array = null, Filters:Array = null):void
		{
			if (Boolean(ACTOL[Action_Name]))
			{
				if (Boolean(Link))
				{
					if (test_available_links([Link]))
					{
						ACTOL[Action_Name].link = Link;				
					}
					else
					{
						trace("uyarı. Hatalı link adı.");
					}
				}
				
				if (Boolean(Action_Function))
				{
					ACTOL[Action_Name].action = Action_Function;
				}
				if (Boolean(Filters))
				{
					ACTOL[Action_Name].filter = Filters;
				}
				
				create_ACTO_requirements(ACTOL[Action_Name], Requirements);
				
				update_ACTOL();
			}
			else
			{
				trace("uyarı. böyle bir ACTO bulunamadı.");
			}
		}
		public static function DELETE_ACTIONS(Actions:Array):int
		{
			var deleted_number:int = 0;
			
			for (var i:int = 0; i < Actions.length; i ++)
			{
				if (Boolean(ACTOL[Actions[i]]))
				{
					delete ACTOL[Actions[i]];
				}
			}
			
			if (deleted_number == 0)
			{
				trace("uyarı. silinecek bir action bulunamadı.");
			}
			
			Utility.COMPRESS_ARRAY(ACTOL);
			
			return deleted_number;
		}
		
		// ------------------------------------------------------------
		// FUNCTIONS :
		// ------------------------------------------------------------
		
		private static function update_ACTOL():void
		{
			for each (var ACTO:Object in ACTOL)
			{
				reset_ACTO_objects(ACTO);
				set_active(ACTO)
				set_potentials(ACTO);
				set_potential_labels(ACTO);
				set_links(ACTO);
			}
			
			function reset_ACTO_objects(Current_ACTO:Object):void
			{
				Current_ACTO.potentials_KEY = null;
				Current_ACTO.potentials_KEY = new Array();
				
				Current_ACTO.INTO_list = null;
				Current_ACTO.INTO_list = new Array();
				
				Current_ACTO.potentials_IND = null;
				Current_ACTO.potentials_IND = new Array();
				
				Current_ACTO.action_area_list = null;
				Current_ACTO.action_area_list = new Array();
			}
			function set_active(Current_ACTO:Object):void
			{
				if (Utility.TEST_ARRAY_ELEMENTS(active_links, [Current_ACTO.link]))
				{
					Current_ACTO.active = true
				}
				else
				{
					Current_ACTO.active = false
				}
			}
			function set_potentials(Current_ACTO:Object):void
			{
				for (var group_name:String in INTOL)
				{
					if (Utility.TEST_ARRAY_ELEMENTS(Current_ACTO.groups, [group_name]))
					{
						for each (var INTO:Object in INTOL[group_name])
						{						
							if (Utility.TEST_ARRAY_ELEMENTS(INTO.labels, Current_ACTO.require))
							{
								if (Boolean(Current_ACTO.filter))
								{
									if (!Utility.TEST_ARRAY_ELEMENTS(INTO.labels, Current_ACTO.require))
									{
										add_new_potentials(INTO);
									}
								}
								else
								{
									add_new_potentials(INTO);
								}
							}
						}
					}
				}
				
				function add_new_potentials(INTO:Object):void
				{
					Current_ACTO.potentials_KEY[INTO.name] = INTO.object;
					Current_ACTO.potentials_IND.push(INTO.object);
					Current_ACTO.INTO_list[INTO.name] = INTO;
					Current_ACTO.action_area_list.push(INTO.action_object);

					if (Boolean(Current_ACTO.set_collisions))
					{
						Current_ACTO.set_collisions();
					}
				}
			}
			function set_potential_labels(Current_ACTO:Object):void
			{
				ACTO.potential_labels = null;
				ACTO.potential_labels = new Array();
				
				for (var key:String in ACTO.potentials_KEY)
				{
					ACTO.potential_labels[key] = new Array();
					
					for (var i:int = 0; i < ACTO.INTO_list[key].labels.length; i ++)
					{
						if (!Utility.TEST_ARRAY_ELEMENTS(ACTO.require, [ACTO.INTO_list[key].labels[i]]))
						{
							ACTO.potential_labels[key].push(ACTO.INTO_list[key].labels[i]);
						}
					}
				}
			}
			function set_links(Current_ACTO:Object):void
			{
				switch (Current_ACTO.link)
				{
					case "Mouse":
						set_mouse_contol(Current_ACTO);
						break;
					case "Hit":
						set_hit_contol();
						break;
					case "Fine_Hit":
						set_fine_hit_contol();
						break;
					case "Physics":
						set_physics_contol();
						break;
				}
				
				function set_mouse_contol():void
				{
					for each (var potential_object:Object in Current_ACTO.potentials_KEY)
					{
						if (Current_ACTO.active)
						{
							define_IC(potential_object);
						}
						else
						{
							break_IC(potential_object);
						}
					}
					
					function define_IC(Target:DisplayObject):void
					{
						InputControl.DEFINE("ACTO-" + Current_ACTO.name + "-" + Target.name, Target, update_mouse_control, ["Mouse"]);
					}
					function break_IC(Target:DisplayObject):void
					{
						if (Boolean(InputControl.ICOL["ACTO-" + Current_ACTO.name + "-" + Target.name]))
						{
							InputControl.BREAK_LINKS(["ACTO-" + Current_ACTO.name + "-" + Target.name]);
						}
					}
					function update_mouse_control():void
					{
						if (Boolean(InputControl.MICO.target))
						{
							update_selection();
							update_drag_drop();
						}
					}
					function update_selection():void
					{
						if (InputControl.MICO.mouseDown)
						{
							if (Boolean(InputControl.MICO.target))
							{
								update_targets();
							}
							if (Boolean(ACTO.mouse_target))
							{
								if (ACTO.multi_selection)
								{
									if (Utility.TEST_ARRAY_ELEMENTS(Current_ACTO.selected, [ACTO.INTO_target]))
									{
										Utility.REMOVE_SPECIFIC_ELEMENTS(Current_ACTO.selected, [ACTO.INTO_target]);
										Utility.COMPRESS_ARRAY(Current_ACTO.selected);
									}
					
									Current_ACTO.selected.push(ACTO.INTO_target);
								}
								else
								{
									Current_ACTO.selected = new Array();
									Current_ACTO.selected[0] = ACTO.INTO_target;
								}
									
								Current_ACTO.last_selected = ACTO.INTO_target;
							}
							else
							{
								Current_ACTO.last_selected = null;
								Current_ACTO.selected = new Array();
								Current_ACTO.init_pos = new Array();
								Current_ACTO.mouse_delta.active = false;
							}
							if (Current_ACTO.drag_drop)
							{
								Current_ACTO.init_pos = new Array();
									
								for each(var obj:DisplayObject in Current_ACTO.selected)
								{
									 Current_ACTO.init_pos[obj.name] = [obj.x, obj.y];
								}
							}
							
							send_feedback_ACTO(Current_ACTO);
						}
					}
					function update_drag_drop():void
					{
						if (InputControl.MICO.mouseDown && !Current_ACTO.mouse_delta.active)
						{
							Current_ACTO.mouse_delta.point_A.x = InputControl.MICO.global_x;
							Current_ACTO.mouse_delta.point_A.y = InputControl.MICO.global_y;
							Current_ACTO.mouse_delta.active = true;
							
							send_feedback_ACTO(Current_ACTO);
						}
						if (InputControl.MICO.mouseUp && Current_ACTO.mouse_delta.active)
						{
							Current_ACTO.mouse_delta.active = false;
							
							send_feedback_ACTO(Current_ACTO);
						}
						if (Current_ACTO.mouse_delta.active)
						{
							Current_ACTO.mouse_delta.point_B.x = InputControl.MICO.global_x;
							Current_ACTO.mouse_delta.point_B.y = InputControl.MICO.global_y;
							Current_ACTO.mouse_delta.delta.x = Current_ACTO.mouse_delta.point_B.x - Current_ACTO.mouse_delta.point_A.x;
							Current_ACTO.mouse_delta.delta.y = Current_ACTO.mouse_delta.point_B.y - Current_ACTO.mouse_delta.point_A.y;
							
							send_feedback_ACTO(Current_ACTO);
						}
					}
					function update_targets():void
					{
						ACTO.mouse_target = null;	
						ACTO.INTO_target = null;
						
						ACTO.mouse_target = Utility.FIND_IN_FAMILY(InputControl.MICO.target, Current_ACTO.action_area_list);
						
						if (Boolean(ACTO.mouse_target))
						{
							ACTO.INTO_target = Utility.FIND_IN_FAMILY(ACTO.mouse_target, Current_ACTO.potentials_IND);
						}
					}
				}
				function set_hit_contol():void
				{
					if (ACTO.active)
					{
						define_IC();
					}
					else
					{
						break_IC();
					}
					
					function define_IC():void
					{
						InputControl.DEFINE("ACTO-" + Current_ACTO.name + "-hit_control", Current_ACTO, update_hit_control, ["Frame"]);
					}
					function break_IC():void
					{
						if (Boolean(InputControl.ICOL["ACTO-" + Current_ACTO.name + "-hit_control"]))
						{
							InputControl.BREAK_LINKS(["ACTO-" + Current_ACTO.name + "-hit_control"]);
						}
					}
					function update_hit_control():void
					{
						Current_ACTO.reset_collisions();
						
						for (var i:int = 0; i < (Current_ACTO.action_area_list.length - 1); i ++)
						{
							for (var j:int = (i+1); j < Current_ACTO.action_area_list.length; j ++)
							{
								if (Current_ACTO.action_area_list[i].hitTestObject(Current_ACTO.action_area_list[j]))
								{
									Current_ACTO.collisions[Current_ACTO.potentials_IND[i].name].push(Current_ACTO.potentials_IND[j]);
									Current_ACTO.collisions[Current_ACTO.potentials_IND[j].name].push(Current_ACTO.potentials_IND[i]);
								}
							}
						}
						
						send_feedback_ACTO(Current_ACTO);
					}
				}
				function set_fine_hit_contol():void
				{
					if (ACTO.active)
					{
						define_IC();
					}
					else
					{
						break_IC();
					}
					
					Current_ACTO.bitmap_transform_list.update();
					
					var btm_info:Object = new Object();
					
					function define_IC():void
					{
						InputControl.DEFINE("ACTO-" + Current_ACTO.name + "-fine_hit_control", Current_ACTO, update_fine_hit_control, ["Frame"]);
					}
					function break_IC():void
					{
						if (Boolean(InputControl.ICOL["ACTO-" + Current_ACTO.name + "-fine_hit_control"]))
						{
							InputControl.BREAK_LINKS(["ACTO-" + Current_ACTO.name + "-fine_hit_control"]);
						}
					}
					function update_fine_hit_control():void
					{
						Current_ACTO.reset_collisions();
	
						for (var key:String in Current_ACTO.potentials_KEY)
						{
							Current_ACTO.bitmap_transform_list[key].rect = Current_ACTO.potentials_KEY[key].getBounds(Gensys.STAGE);
							Current_ACTO.bitmap_transform_list[key].offset = Current_ACTO.potentials_KEY[key].transform.matrix;
							Current_ACTO.bitmap_transform_list[key].offset.tx = Current_ACTO.potentials_KEY[key].x - Current_ACTO.bitmap_transform_list[key].rect.x;
							Current_ACTO.bitmap_transform_list[key].offset.ty = Current_ACTO.potentials_KEY[key].y - Current_ACTO.bitmap_transform_list[key].rect.y;
							Current_ACTO.bitmap_transform_list[key].bitmap_data = new BitmapData(Current_ACTO.bitmap_transform_list[key].rect.width, Current_ACTO.bitmap_transform_list[key].rect.height, true, 0);
							Current_ACTO.bitmap_transform_list[key].bitmap_data.draw(Current_ACTO.potentials_KEY[key], Current_ACTO.bitmap_transform_list[key].offset);
							Current_ACTO.bitmap_transform_list[key].location = new Point(Current_ACTO.bitmap_transform_list[key].rect.x, Current_ACTO.bitmap_transform_list[key].rect.y);
						}
						for (var i:int = 0; i < (Current_ACTO.potentials_IND.length - 1); i ++)
						{
							for (var j:int = (i+1); j < Current_ACTO.potentials_IND.length; j ++)
							{
								if (Current_ACTO.bitmap_transform_list[Current_ACTO.potentials_IND[i].name].bitmap_data.hitTest(Current_ACTO.bitmap_transform_list[Current_ACTO.potentials_IND[i].name].location, 255, Current_ACTO.bitmap_transform_list[Current_ACTO.potentials_IND[j].name].bitmap_data, Current_ACTO.bitmap_transform_list[Current_ACTO.potentials_IND[j].name].location, 255))
								{
									Current_ACTO.collisions[Current_ACTO.potentials_IND[i].name].push(Current_ACTO.potentials_IND[j]);
									Current_ACTO.collisions[Current_ACTO.potentials_IND[j].name].push(Current_ACTO.potentials_IND[i]);
								}
							}
						}
						for (var key_2:String in Current_ACTO.potentials_KEY)
						{
							Current_ACTO.bitmap_transform_list[key_2].bitmap_data.dispose();
						}
						
						send_feedback_ACTO(Current_ACTO);
					}
				}
				function set_physics_contol():void
				{
					if (ACTO.active && physics)
					{
						define_IC();
					}
					else
					{
						break_IC();
					}
					
					function define_IC():void
					{
						InputControl.DEFINE("ACTO-" + Current_ACTO.name + "-physics_control", Current_ACTO, update_physics_control, ["Frame"]);
					}
					function break_IC():void
					{
						if (Boolean(InputControl.ICOL["ACTO-" + Current_ACTO.name + "-physics_control"]))
						{
							InputControl.BREAK_LINKS(["ACTO-" + Current_ACTO.name + "-physics_control"]);
						}
					}
					function update_physics_control():void
					{
						Current_ACTO.reset_collisions();
						Current_ACTO.reset_physical_collisions();
						
						for (var i:int = 0; i < (Current_ACTO.action_area_list.length); i ++)
						{
							if (Boolean(physics.COLDOL[Current_ACTO.action_area_list[i].name]))
							{
								for (var j:int = 0; j < Current_ACTO.potentials_IND.length; j ++)
								{
									if (Boolean(physics.COLDOL[Current_ACTO.action_area_list[i].name][Current_ACTO.action_area_list[j].name]))
									{
										Current_ACTO.collisions[Current_ACTO.potentials_IND[i].name].push(Current_ACTO.potentials_IND[j]);
										Current_ACTO.collisions[Current_ACTO.potentials_IND[j].name].push(Current_ACTO.potentials_IND[i]);
											
										Current_ACTO.physics_collisions[Current_ACTO.potentials_IND[i].name][Current_ACTO.potentials_IND[j].name] = physics.COLDOL[Current_ACTO.action_area_list[i].name][Current_ACTO.action_area_list[j].name];
									}
								}
							}
						}
						
						send_feedback_ACTO(Current_ACTO);
					}
				}
			}
			function send_feedback_ACTO(Current_ACTO:Object):void
			{
				if (ACTIVE && Current_ACTO.active)
				{
					Current_ACTO.action(Current_ACTO);
				}
			}
		}
		private static function create_INTO(Group_Name:String, Target_Name:String, Target:Object, Target_Action_Object:Object, Labels:Array):void
		{
			if (true)
			{
				var INTO:Object = new Object();
				
				INTO.name = Target_Name;
				INTO.group = Group_Name;
				INTO.object = Target;
				INTO.action_object = Target_Action_Object;
				INTO.labels = Labels;

				add_to_INTOL();
			}
			else
			{
				trace("NEW_GROUP, test_links error");
			}
				
			function add_to_INTOL():void
			{
				if (!Boolean(INTOL[Group_Name]))
				{
					INTOL[Group_Name] = new Array();
				}
					
				INTOL[Group_Name].push(INTO);
			}
		}
		private static function update_INTO(INTO:Object, Target_Action_Object:Object = null, Labels:Array = null):void
		{
			if (Boolean(Target_Action_Object))
			{
				INTO.action_object = Target_Action_Object;
			}
			if (Boolean(Labels))
			{
				INTO.labels = Labels;
			}
		}
		private static function test_available_links(Links:Array):Boolean
		{
			if (Utility.TEST_ARRAY_ELEMENTS(available_links, [Links]))
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		private static function create_ACTO_requirements(ACTO:Object, Requirements:Array = null):void
		{
			if (!Boolean(ACTO.require))
			{
				ACTO.require = new Array();
			}

			ACTO.require = [ACTO.link];

			if (Boolean(Requirements))
			{
				for (var i:int = 0; i < Requirements.length; i ++)
				{
					ACTO.require.push(Requirements[i]);
				}
			}
		}
	}
}