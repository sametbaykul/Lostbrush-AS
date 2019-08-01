/*

	------------------------------------------------------------
	- ACCESS(C) 2015
	------------------------------------------------------------
	
	* FULL STATIC
	* INIT : false
	
	v1.0 : 08.02.2015 : "PBL", "AMCL" ve "IGIL" algoritmalarını "Utility" sınıfından devralarak daha uygulanabilir ve sade bir boyut kazandırmıştır.
	
	v2.0 : 20.02.2015 :
		Eklenen yeni özellikler:
		1. ADD_TO_AMCL() metodu ile oluşturuldu.
		2. ADD_TO_AMCL() metoduna "Key_Filter" parametresi ile "Object_Filter" dışında, bir desen ile uyumlu nesnelerin filtrelenmesi sağlandı.
		3. "Type_Filter" ile "Shape" ve "StaticText" sınıflarına ait nesnelerin filtrelenmesi sağlanarak veri deposundan %38 tasarruf sağlandı. Ayrıca bu filtreleme Developer tarafından rahatlıkla değiştirilebilmesi için parametre olarak atandı.
		4. AMCL'ye dahil edilmek istenmeyen, aynı Mother MC'ye ait ve isim çakışması olan nesneler için OMCL filtresi geliştirildi. Bu filtre veri deposundan %44 tasarruf sağladı.
		5. İsim çakışması olan nesneleri developera bildirmek amacıyla OMCL nesnesi, OMCL filtrelemeye takılan nesnelerin saklıcak şekilde tasarlandı. Bu nesne Console'da "access OMCL" ile rahatlıkla erişilebilir.
		6. İsim çakışmalarını önlemek amacıyla yapılan bu sistem için Console command bölümüne parametre özelliği eklendi.
	v2.1 : 28.02.2015 : FOR_EACH_AMCL() ve GET_AMCL_PART() metodları eklendi.
	v2.2 : 16.05.2015 : OMCL veri hataları çözüldü.
	v2.3 : 12.02.2016 : 'id' ve 'no' özellikleri belirlendi.
	
	by Samet Baykul

*/

package lbl
{
	// Flash Library:
	import flash.display.Stage;
	import flash.display.MovieClip;
	import flash.utils.getQualifiedClassName;
	// LBL Core:
	import lbl.Utility;
	// LBL Control:
	import lbl.Console;


	public class Access
	{
		public static var PBL:Array = new Array();
		public static var AMCL:Array = new Array();
		public static var OMCL:Array = new Array();
		public static var IGIL:Array = new Array();
		public static var EIML:Array = new Array();

		// Class Info:
		private static var id:String = "ACC";
		private static var no:int = 013;
		
		public function Access():void
		{
			// Full static class
		}

		public static function CREATE_PB(Class_Name:String):Object
		{
			if (! Boolean(PBL[Class_Name]))
			{
				PBL[Class_Name] = new Object();
			}

			PBL[Class_Name]["ADD"] = add_prop;

			return PBL[Class_Name];

			function add_prop(Prop_Name:String,Prop:*):void
			{
				PBL[Class_Name][Prop_Name] = Prop;
			}
		}
		
		public static function ADD_TO_AMCL(MC:MovieClip, Object_Filter:Array = null, Key_Filter = "???", Type_Filter:Array = null):void
		{
			if (! Boolean(AMCL[MC.name]))
			{
				AMCL[MC.name] = new Array();
				OMCL[MC.name] = new Array();
			}
			
			if (! Type_Filter)
			{
				Type_Filter = ["Shape", "StaticText"];
			}

			AMCL[MC.name] = get_all_children(MC, Object_Filter, Key_Filter, Type_Filter);
			
			function get_all_children(Mother_MC:MovieClip, Object_Filter:Array, Key_Filter:String, Type_Filter:Array):Array
			{
				var children_mc_list:Array = new Array ;

				var Total_Item:int = 0;
				var Overwrited_Item:int = 0;
				var Filtered_Item:int = 0;

				search_children(Mother_MC);
				update_OMCL();

				function search_children(Target_MC:MovieClip):void
				{
					var pass_object_filter:Boolean = true;
					var pass_OMCL:Boolean = true;
					var pass_key_filter:Boolean = true;
					var pass_type_filter:Boolean = true;

					for (var i:uint = 0; i < Target_MC.numChildren; i++)
					{
						pass_object_filter = !Boolean(Object_Filter.some(test_for_filter));
						pass_OMCL = !Boolean(OMCL[MC.name].some(test_for_filter));
						pass_key_filter = ! Utility.SOME_REGEXP(Target_MC.getChildAt(i).name,[Key_Filter]);
						pass_type_filter = ! Utility.SOME_REGEXP(flash.utils.getQualifiedClassName(Target_MC.getChildAt(i)),Type_Filter);
						
						// -> Filtre denetleme:
						//trace("Result:\t" + String(int(Boolean(pass_object_filter && pass_OMCL && pass_key_filter && pass_type_filter))) + " |" + pass_object_filter + "/" + pass_OMCL + "/" + pass_key_filter + "/" + pass_type_filter + "\t: " + Target_MC.getChildAt(i).name);

						if (pass_object_filter && pass_OMCL && pass_key_filter && pass_type_filter)
						{
							Total_Item++;

							if (! Boolean(children_mc_list[Target_MC.getChildAt(i).name]))
							{
								children_mc_list[Target_MC.getChildAt(i).name] = Target_MC.getChildAt(i);
							}
							else
							{
								Overwrited_Item++;
								OMCL[MC.name].push(String(Target_MC.getChildAt(i).name));
							}

							if (Target_MC.getChildAt(i) is MovieClip)
							{
								search_children(Target_MC.getChildAt(i));
							}
						}
						else
						{
							Filtered_Item++;
						}
					}

					function test_for_filter(element: * ,index:int,arr:Array):Boolean
					{
						return Boolean(element == Target_MC.getChildAt(i).name);
					}
				}
				function update_OMCL():void
				{
					var success:Number;
				
					if (OMCL["Result"])
					{
						var already_overwrited_item:int = int(Utility.SPLIT_TEXT(OMCL["Overwrited Item"], ": ", 2));
						var already_filtered_item:int = int(Utility.SPLIT_TEXT(OMCL["Filtered Item"], ": ", 2));
						var already_total_accessible_item:int = int(Utility.SPLIT_TEXT(OMCL["Total Accessible Item"], ": ", 2));
						
						var current_oi:int = Overwrited_Item + already_overwrited_item;
						var current_fi:int = Filtered_Item + already_filtered_item;
						var current_tai:int = Total_Item + already_total_accessible_item;
						
						success = ((current_fi + current_oi) *100)/(current_tai + current_fi + current_oi);
						
						OMCL["Overwrited Item"] = String("Overwrited Item: " + int(current_oi));
						OMCL["Filtered Item"] = String("Filtered Item: " + int(current_fi));
						OMCL["Total Accessible Item"] = String("Total Accessible Item: " + int(current_tai));
					}
					else
					{
						success = ((Filtered_Item + Overwrited_Item) *100)/(Total_Item + Filtered_Item + Overwrited_Item);
						OMCL["Overwrited Item"] = String("Overwrited Item: " + Overwrited_Item);
						OMCL["Filtered Item"] = String("Filtered Item: " + Filtered_Item);
						OMCL["Total Accessible Item"] = String("Total Accessible Item: " + Total_Item);
					}
					
					OMCL["Result"] = String("%" + MathLab.SET_SIGNIFICANT_FIGURE(success,1) + " items have been filtered.");
				}
				
				return children_mc_list;
			}
		}
		
		public static function FOR_EACH_AMCL(AMCL_Lists:Array, Search_For:String, Do_It_What:Function):void
		{
			for (var i:uint = 0; i < AMCL_Lists.length; i++)
			{
				if (Boolean(AMCL[AMCL_Lists[i]]))
				{
					for (var key:* in AMCL[AMCL_Lists[i]])
					{
						if (Utility.SEARCH_TEXT(key, Search_For))
						{
							var type:String = Search_For;
							
							Do_It_What(AMCL[AMCL_Lists[i]][key], type);
						}
					}
				}
				else
				{
					Console.PRINT("Access", "X ERROR > ERROR CODE: 0035 > " + AMCL_Lists[i] + " is no found on AMCL System™", 3, "");
				}
			}
		}
		
		public static function GET_AMCL_PART(AMCL_Lists:Array, Search_For:String):Array
		{
			var result:Array = new Array();
			
			for (var i:uint = 0; i < AMCL_Lists.length; i++)
			{
				if (Boolean(AMCL[AMCL_Lists[i]]))
				{
					for (var key:* in AMCL[AMCL_Lists[i]])
					{
						if (Utility.SEARCH_TEXT(key, Search_For))
						{									
							result.push(AMCL[AMCL_Lists[i]][key]);
						}
					}
				}
				else
				{
					Console.PRINT("Access", "X ERROR > ERROR CODE: 0036 > " + AMCL_Lists[i] + " is no found on AMCL System™", 3, "");
				}
			}
			
			return result;
		}

		public static function ADD_TO_IGIL(IGIL_Name:String="Global", Group_Name:String="Main", Instance:Object=null):int
		{
			if (! Boolean(IGIL[IGIL_Name]))
			{
				IGIL[IGIL_Name] = new Array();
			}

			var new_group_is_possible:Boolean = IGIL[IGIL_Name].every(search_same_goup);

			if (new_group_is_possible)
			{
				IGIL[IGIL_Name].push(Group_Name);
				IGIL[IGIL_Name][Group_Name] = [Instance];
			}
			else
			{
				var temp_array:Array = IGIL[IGIL_Name][Group_Name];
				temp_array.push(Instance);
				IGIL[IGIL_Name][Group_Name] = temp_array;
			}

			return IGIL[IGIL_Name][Group_Name].indexOf(Instance);

			function search_same_goup(element: *,index:int,arr:Array):Boolean
			{
				if ((element == Group_Name))
				{
					return false;
				}
				else
				{
					return true;
				}
			}
		}
		
		// Console için yazılmış bir private fonksiyon.
		public static function GET_ACCESS_INFO(param:Array):void
		{
			//Console.PRINT("Access", Console.GET_OBJECT_TREE(Access[param[0]], String(param[0])), 1, "");
		}
	}
}