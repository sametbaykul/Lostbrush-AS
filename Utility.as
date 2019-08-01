/*

	------------------------------------------------------------
	- UTILITY(C) 2014 - 2016
	------------------------------------------------------------
	
	* FULL STATIC
	* INIT : false
	
	v1.0 : 14.09.2014 : Harici fonksiyonlar için tasarlandı.
	
	v1.1 : 03.02.2015 : JOIN_OBJECTS() ve UPDATE_OBJECT() metodları eklendi. (by Muhtar)
	v1.2 : 04.02.2015 : TEST_OBJECT_STANDART() metodu eklendi. UPDATE_OBJECT() metodu için "Overwrite" parametresi eklendi.
	v1.3 : 04.02.2015 : GET_OBJECT_TREE() metoduna "Filter" parametresi eklendi.
	v1.4 : 07.02.2015 : SET_STAGE_DEEPTH() metodundaki hatalar giderildi.
	v1.5 : 07.02.2015 : SEARCH_ARRAY_ELEMENTS_BY_VALUE() metodu geliştirildi.
	
	v2.0 : 08.02.2015 : IGIL (Instance Group Interaction List) RBM'den Utility'e kazandırıldı. Bununla birlikte yeni bir algoritma için fikir edinildi.
	v2.1 : 09.02.2015 : SEARCH_TEXT() metodu eklendi.
	v2.2 : 10.02.2015 : SEARCH_ARRAY_ELEMENTS() ve TEST_ARRAY_ELEMENTS() metodları eklendi. Bir dizinin içerisinde bir elementin olup olmadığını anlama ihtiyacından dolayı yaratıldı.
	v2.3 : 10.02.2015 : UPDATE_OBJECT() metoduna yeni davranış parametreleri eklendi. TEST_OBJECT_STANDART() negatif sonuç hatası çözümlendi.
	v2.4 : 20.02.2015 : Artık SOME_REGEXP() metodu ile bir metinde birden fazla desen için Array.some() benzeri bir tarama testi gerçekleştirebilirsiniz.
	v2.5 : 01.03.2015 : CLEAR_OBJECT() metodu eklendi.
	v2.6 : 07.03.2015 : Array.splice gibi metodları daha güvenli bir şekilde kullanmak amacıyla CLONE() metodu eklendi.
	v2.7 : 12.03.2015 : TEST_OBJECT_BY_VALUE() metodu eklendi (by Muhtar)
	v2.8 : 15.05.2015 : CLEAR_OBJECT() ve JOIN_OBJECTS() metodları yeniden düzenlendi. SEARCH_ARRAY_ELEMENTS() ve SEARCH_ARRAY_ELEMENTS_BY_VALUE() metodlarındaki hatalar giderildi.
	v2.9 : 27.07.2015 : UPDATE_OBJECT() "update" parametresinde ciddi bir hata giderildi.

	v3.0 : 05.08.2015 : CENTRE_DISPLAY_OBJECT() metodu SlideShowEssential(2013)'den devralındı. Bir nesnenin konumunu başka bir nesneye göre ortalar ve çıkan sonucu "int" olarak döndürür. Bu değer ortalanmak istenilen nesnenin "x" veya "y" özelliğine atılır.("en_yada_boy" parametresi: "true" olduğunda ene göre, "false" olduğunda boya göre ortalama alır.)
	v3.1 : 06.08.2015 : Physics() sınıfında kullanılmak üzere GET_CENTER(), ve GET_XY_IN_DYNAMIC_ROTATION() metodları geliştirildi.
	v3.2 : 10.08.2015 : GET_SPECIFIC_CHILDRENS() metodu ile, adı olmayan mc'leri bile belirli desenlere göre kolayca bulabilirsiniz. 
	v3.3 : 16.08.2015 : GET_REF_PROPS() metodu ile bir MC'nin bütün özelliklerini belirli bir referansa göre alın.
	v3.4 : 18.08.2015 : COMPRESS_ARRAY() bir array deki null değerlerini atarak bu arrayi yoğunlaştırır.
	v3.5 : 18.08.2015 : TEST_ARRAY_ELEMENTS() metodundaki önemli bir hata düzeltildi. Ayrıca SOME_ARRAY_ELEMENTS() adında yeni bir metod daha geliştirildi.
	v3.6 : 19.08.2015 : GET_OBJECT_TREE() metodunun 'Filter' parametresindeki bir hata düzeltildi. Ayrıca GET_ARRAY_TREE() metodu da dahil bu metodlara, daha okunabilir sonuçlar vermesi için alfabetik düzenleme getirildi.
	v3.7 : 25.08.2015 : REMOVE_SPECIFIC_ELEMENTS() metodu ile bir listedeki belirli ögeleri siler ve listeyi sıkıştırır. USE_SPECIFIC_ELEMENTS() metodu bir listedeki belirli elementleri kullanarak bildirilen bir fonksiyonu çağırır.
	v3.8 : 31.08.2015 : GET_REF_PROPS() metodu için Recourse Optimization güncellemesi yapıldı ve Utility sınıfına ilk kez 'RPO' adında bir genel object atandı.
	v3.9 : 09.09.2015 : GET_REF_PROPS() çok kritik bir hata giderildi. Sonuçta RPO'ya 'point' özelliği eklendi.
	
	v4.0 : 09.09.2015 : SET_REAL_DIM() ve GET_REAL_DIM() metodları ile bir görsel ögenin rotasuyonuna bağlı olarak değişen boyutlarından bağımsız şekilde gerçek bpyutlar üzerinde çalışmanızı sağlar.
	v4.1 : 11.09.2015 : CHANGE_COORD() metodu ile bir noktanın farklı koordinatlardaki iz düşümlerini kolayca bulabilirsiniz.
	v4.2 : 16.09.2015 : GET_OBJECT_LENGTH() metodu ile Array.length özelliği gibi nesnelerin öge sayılarını alabilirsiniz.
	v4.3 : 18.09.2015 : SET_STAGE_DEPTH() metodu güncellendi.
	v4.4 : 04.02.2016 : FIND_LONGEST_ITEM_IN_TEXT() metodu eklendi. Bir stringler listesindeki en uzun (karakter sayısı olarak) itemi döndürür.
	v4.5 : 05.02.2016 : GET_OBJECT_TREE() ve GET_ARRAY_TREE() metodları, Console.as v3.0'ın geliştirilmesi ile beraber kaldırıldı.
	v4.6 : 11.02.2016 : FIND_LONGEST_ITEM_IN_TEXT() metodundaki bir hata giderildi.
	v4.7 : 12.02.2016 : 'id' ve 'no' özellikleri belirlendi.
	v4.8 : 13.02.2016 : SORT_ARRAY() metodu ile ilişkilendirilmiş dizilerde, anahtara göre sıralama yapın. Ayrıca 'Value' parametresini de kullanarak ek bir özelliğe göre daha sıralama yaptırmanız mümkün.
	v4.9 : 16.02.2016 : Utility metodları kategorize edildi.
	
	v5.0 : 20.03.2016 : GET_FAMILY() metodu ile bir görüntü nesnesinin soy ağacını alın. TEST_FAMILY() metodu ile bir görsel nesnesinin ailesi içinde bir veya daha fazla görsel nesnenin varlığını test edin. FIND_IN_FAMILY() metodu ile bir ailede belirli bir nesneyi arayın.
	v5.1 : 22.03.2016 : ADD_ARRAY() metodu eklendi. Sınırsız sayıda dizinin elemanlarını uç uca tek bir dizide birleştirmek için kullanılır.
	
	v6.0 : 29.04.2016 : 
		Eklenen yeni özellikler:
			1. FIND_PATH()				: Herhangi bir nesne içerisinde aranan bir nesne veya özelliğin veriyolunu bir liste içinde döndürür. Eğer bir özellik veya nesne birden fazla defa eşleşirse bu liste içerisinde sıralanır.
			2. FIND_OBJECT_FROM_PATH()	: Bir nesne üzerinde belirli bir veriyolu üzerinden eşleşilen nesneyi döndürür.
			2. COMPLETE_PATH()			: Eksik bir veriyolu girildiğinde, bu veriyoluna uygun olarak karşılık gelebilecek bütün potansiyel veriyollarını almanızı sağlar.
			4. UPDATE_OBJECT_FROM_PATH(): Bir veriyolu üzerinden bir nesne üzerindeki bir özelliği değiştirebilirsiniz.
			5. SMART_PATH_FINDER()		: Verilen parametrelere göre bir veya daha fazla veriyolunu kolayca bulmanızı sağlar.
			6. SMART_OBJECT_FINDER()	: Verilen parametrelere göre bir veya daha fazla nesneyi kolayca bulmanızı sağlar.
			7. FIND_CHILD()				: Bir görsel nesne üzerinde olduğu düşünülen bir çocuk nesneye ulaşmak için kullanılır. Arama işlemi için çocuk nesnenin kendisi ya da adı gereklidir.
			8. CHECK_KEY_CONFLICT()		: Bir nesne üzerinde belirli özellik ya da anahtarların birden fazla defa kullanılıp kullanılmadığı sonucunu bir feedback nesnesi ile beraber döndürür.
			9. SEARCH_OBJECT()			: Bir nesne üzerinde bir özellik veya değer ile örtüşen nesnelerin çıktısını bir liste olarak döndürür.
		   10. CHECK_ARRAY_REPETATION()	: Bir dizi üzerinde herhangi bir elemanın birden fazla defa kullanılıp kullanılmadığı sonucunu Boolean olarak döndürür.
		   11. STOP_ALL_CHILDREN()		: Bir görsel nesne üzerinde yer alan bütün alt görsel nesnelerinin zaman çizelgesi akışını durdurur.
		   12. ARRAY_TO_STRING()		: Bir diziyi dizeye dönüştürür.
		   13. STRING_TO_ARRAY()		: Bir diziyi dizeye dönüştürür.
		   14. TEST_FAMILY_VISIBILITY()	: Bir görsel nesnenin ebeveynlerinden en az biri görünmez olduğunda false, hepsi görünür olduğunda ise true döndürür.
		   15. GET_SPECIFIC_CHILDRENS()	metodunun adı GET_SPECIFIC_TYPE_CHILDRENS() olarak değiştirirdi.
		   16. SEARCH_TEXT() metodundaki bir hata giderildi.

	GELİŞTİRMELER		:	+ TEST_ARRAY_ELEMENTS() metodunu hızlandır. 
							+ SOME_ARRAY_ELEMENTS() metodunu associated array'lerde test et. 
							+ Metod işlevselliklerini ve isimlerini gözden geçir.
							- Console.TABULATE() filter mekanizmasını gözden geçir. Bu filter mekanizmasını Utility'e aktar.
	
	by Samet Baykul
	
*/

package lbl
{
	// Flash Library:
	import flash.display.Stage;
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.utils.*;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	// LBL Core:	
	import lbl.Access;
	// LBL Control:
	import lbl.Console;
	
	
	public class Utility
	{
		// ------------------------------------------------------------
		// PROPERTIES :
		// ------------------------------------------------------------
		
		public static var RPO:Object = new Object(); // Reference Property Object -> GET_REF_PROPS();
		
		// Class Info:
		private static var id:String = "UTI";
		private static var no:int = 010;
		
		public function Utility():void
		{
			// Full static class
		}
		
		// Text Methods:
		
		public static function SEARCH_TEXT(Text:String, Pattern:String):Boolean
		{
			var result:int = Text.indexOf(Pattern);
			
			if (result > -1)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		public static function SOME_REGEXP(Text:String, Regexp_List:Array):Boolean
		{
			var result:Boolean = false;
					
			for (var i:uint = 0; i < Regexp_List.length; i++)
			{
				var pattern:RegExp = new RegExp(Regexp_List[i])
						
				if (pattern.test(Text))
				{
					result = true;
				}
			}
					
			return result;
		}
		public static function FIND_LONGEST_ITEM_IN_TEXT(Item_List:Array):String
		{
			var longest_item:String = "";
			
			for (var i:uint = 0; i < Item_List.length; i++)
			{
				if (String(Item_List[i]).length > String(longest_item).length)
				{
					longest_item = Item_List[i];
				}
			}
			
			return longest_item;
		}
		public static function CHANGE_CHAR(Text:String, Remove_Part:String, Replace:String):String
		{
			var split_text:Array = Text.split(Remove_Part);
			var modified_text:String = "";
			
			for (var i:uint = 0; i < split_text.length; i ++)
			{
				if (i != 0)
				{
					modified_text +=  Replace;
				}
				
				modified_text +=  String(split_text[i]);
			}
			
			return modified_text;
		}
		public static function SPLIT_TEXT(Text:String, Split_Mark:String, Get_Parts_Start:uint, Get_Parts_End:uint = 0x7fffffff):String
		{
			var split_text:Array = Text.split(Split_Mark);
			var modified_text:String = "";
			var last_part_index:uint = Math.min(split_text.length,Get_Parts_End);
			
			for (var i:uint = Get_Parts_Start; i <= last_part_index; i ++)
			{
				if (i != Get_Parts_Start)
				{
					modified_text +=  Split_Mark;
				}
				
				modified_text +=  String(split_text[i - 1]);
			}

			return modified_text;
		}
		public static function ARRAY_TO_STRING(Target_Array:Array, Split_Mark:String = ", "):String
		{
			var txt:String = "";
			
			for (var i:int = 0; i < Target_Array.length; i ++)
			{
				txt += String(Target_Array[i]);
				
				if (i < Target_Array.length - 1)
				{
					txt += Split_Mark;
				}
			}
			
			return txt;
		}
		public static function STRING_TO_ARRAY(Text:String, Split_Mark:String = ", "):Array
		{
			return Text.split(Split_Mark);
		}
		
		// Array Methods:
		
		public static function ADD_ARRAY(...args):Array
		{
			var merged_array:Array = new Array();
			
			for (var i:int = 0; i < args.length; i ++)
			{
				if (args[i] is Array)
				{
					for each(var obj:* in args[i])
					{
						merged_array.push(obj);
					}
				}
				else
				{
					merged_array.push(args[i]);
				}
			}
			
			return merged_array;
		}
		public static function SOME_ARRAY_ELEMENTS(Source_Array:Array, Elements:Array):Boolean
		{
			var result:Boolean = Source_Array.some(is_exist_in_Elements);

			function is_exist_in_Elements(element:*, index:int, arr:Array):Boolean 
			{
				var is_exist:Boolean = false;
				
            	for (var key:String in Elements)
				{
					if (Elements[key] == element)
					{
						is_exist = true;
					}
				}
				
				return is_exist;
        	}
			
			return result;
		}
		public static function TEST_ARRAY_ELEMENTS(Source_Array:Array, Elements:Array):Boolean
		{
			var result:int = 1;
		
			for (var i:uint = 0; i < Elements.length; i++)
			{
				try 
				{
					result *= int(SOME_ARRAY_ELEMENTS(Source_Array, [Elements[i]]));
				}
				catch (e:Error)
				{
					result = 0;
				}
			}
			
			return Boolean(result);
		}
		public static function SEARCH_ARRAY_ELEMENTS(Source_Array:Array, Elements:Array):Array
		{
			var result:Array = new Array();	
			
			for each(var key_sa:* in Source_Array)
			{
				for each(var key_e:* in Elements)
				{
					if (key_sa == key_e)
					{
						result.push(key_sa);
					}
				}
			}
			
			return result;
		}
		public static function SEARCH_ARRAY_ELEMENTS_BY_VALUE(Source_Array:Array , Value:String, Case_Sensivity:Boolean = true):Array
		{
			var result:Array = new Array();

			for (var i:uint = 0; i < Source_Array.length; i++)
			{
				if (Source_Array[i] is String)
				{
					if (Case_Sensivity)
					{
						if (Source_Array[i].search(Value) == 0)
						{
							result.push(Source_Array[i]);
						}
					}
					else
					{
						var insensitive_element:String = Source_Array[i].toLowerCase();
						var insensitive_value:String = Value.toLowerCase();
						
						if (insensitive_element.search(insensitive_value) == 0)
						{
							result.push(Source_Array[i]);
						}
					}
				}
			}
			
			return result;
		}
		public static function CHECK_ARRAY_REPETATION(Source_Array:Array):Boolean
		{
			var result:Boolean = false;
			var key_list:Array = new Array();
			
			for each(var element:* in Source_Array)
			{
				if (!result)
				{
					if (!Boolean(SOME_ARRAY_ELEMENTS(key_list, [element])))
					{
						key_list.push(element);
					}
					else
					{
						result = true;
						
						break;
					}
				}
			}

			return result;
		}
		public static function SORT_ARRAY(Source_Array:Array, Value:String = null):void
		{
			var keys:Array = new Array();
			var values:Array = new Array();
			var index:int = 0;
			
			gather_info();
			sort();
			deal_index();
			delete_vars();
			
			function gather_info():void
			{
				for (var key:String in Source_Array)
				{
					keys.push(key);
					
					if (!(TEST_ARRAY_ELEMENTS(values, [Source_Array[key][Value]])) && (Boolean(Value)))
					{
						values.push(Source_Array[key][Value]);
					}
				}
			}
			function deal_index():void
			{
				if (Boolean(Value))
				{
					for (var i:int = 0; i < values.length; i ++)
					{					
						for (var j:int = 0; j < keys.length; j ++)
						{
							if (Source_Array[keys[j]][Value] == values[i])
							{
								Source_Array[keys[j]].index = index;
								
								index++;
							}
						}
					}
				}
				else
				{
					for (var k:int = 0; k < keys.length; k ++)
					{
						Source_Array[keys[j]].index = k;
					}
				}
			}
			function sort():void
			{
				keys.sort();
				values.sort();
			}
			function delete_vars():void
			{
				keys = null;
				values = null;
			}
		}
		public static function USE_SPECIFIC_ELEMENTS(Source_Array:Array, Elements:Array, Use_For:Function):void
		{
			for (var key_sa:* in Source_Array)
			{
				for (var key_e:* in Elements)
				{
					if (Source_Array[key_sa] == Elements[key_e])
					{
						Use_For(Source_Array[key_sa]);
					}
				}
			}
		}
		public static function REMOVE_SPECIFIC_ELEMENTS(Source_Array:Array, Elements:Array):int
		{
			var result:int = 0;	
			
			for (var key_sa:* in Source_Array)
			{
				for (var key_e:* in Elements)
				{
					if (Source_Array[key_sa] == Elements[key_e])
					{
						delete Source_Array[key_sa];
						
						result ++;
					}
				}
			}

			return result;
		}
		public static function COMPRESS_ARRAY(Source_Array:Array):int
		{
			var compressed_array:Array = new Array();
			var number_of_compressed_item:int = 0;
			var i:uint = 0;
			
			while (i < Source_Array.length)
			{
				if ((Source_Array[i] == null) || (Source_Array[i] == undefined))
				{
					Source_Array.splice(i, 1);
					number_of_compressed_item ++;
					i = 0;
				}
				else
				{
					i ++;
				}
			}
			
			return number_of_compressed_item;
		}
		
		// Object Methods:

		public static function TEST_OBJECT_STANDART(Target_Object:Object, Key_List:Array):Boolean
		{
			var ok:Boolean = true;
		
			for (var i:uint = 0; i < Key_List.length; i++)
			{
				try 
				{
					if (!Boolean(Target_Object.hasOwnProperty(Key_List[i])))
					{
						ok = false;
					}
				}
				catch (e:Error)
				{
					ok = false;
				}
			}
			
			return ok;
		}
		public static function TEST_OBJECT_BY_VALUE(Target_Object:Object, Search_Property_Array:Array, Search_Value_Array:Array):Boolean
		{
			var return_value:Boolean = false;
			var count:uint = 0;
			
			if(Search_Property_Array.length == Search_Value_Array.length)
			{
				if(TEST_OBJECT_STANDART(Target_Object, Search_Property_Array))
				{
					for(var i:uint = 0; i<Search_Property_Array.length; i++)
					{
						if(Target_Object[Search_Property_Array[i]] == Search_Value_Array[i])
						{
							count ++;
						}
					}
					
					if(count == Search_Property_Array.length)
					{
						return_value = true;
					}
				}
			}
			else
			{
				Console.PRINT("Utility","X ERROR > ERROR CODE: 0034 > Input Arrays must be in same length in the method TEST_OBJECT_BY_VALUE()",3,"");
			}
			return return_value;
		}
		public static function SEARCH_OBJECT(Source_Object:Object, Values_List:Array):Array
		{
			var result:Array = new Array();
			
			if (CHECK_ARRAY_REPETATION(Values_List))
			{
				trace("HATA: Values_List all elements must be unique!");
			}
			else
			{
				var paths:Array = new Array();
				
				for (var i:int = 0; i < Values_List.length; i ++)
				{
					result[String(Values_List[i])] = new Array();
					
					paths = FIND_PATH(Source_Object, Values_List[i]);
					
					for (var j:int = 0; j < paths.length; j ++)
					{
						result[String(Values_List[i])].push(FIND_OBJECT_FROM_PATH(Source_Object , paths[j]));
					}
				}
			}

			return result;
		}
		public static function UPDATE_OBJECT(Target_Object:Object , New_Object:Object, Method:String = "New"):Object
		{
			switch (Method)
			{
				case "Overwrite":
					for (var key_1:* in New_Object)
					{
						Target_Object[key_1] = New_Object[key_1];
					}
					break;
				case "New":
					for (var key_2:* in New_Object)
					{
						if(!TEST_OBJECT_STANDART(Target_Object, [key_2]))
						{
							Target_Object[key_2] = New_Object[key_2];
						}
					}
					break;
				case "Update":
					for (var key_3:* in Target_Object)
					{
						if(TEST_OBJECT_STANDART(New_Object, [key_3]))
						{
							Target_Object[key_3] = New_Object[key_3];
						}
					}
					break;
				default :
					trace("Hata. Bu metod listede yok");
					
					return null;
					break;
			}
			
			return Target_Object;
		}
		public static function JOIN_OBJECTS(Object_List:Array):Object
		{
			var return_object:Object = new Object();
			var key_array:Array = new Array();

			for (var i : int = 0; i < Object_List.length; i++)
			{
				search_object_elements(Object_List[i]);
			}
			
			return return_object;
			
			function search_object_elements(Target_Object:Object):void
			{
				for (var key:* in Target_Object)
				{
					if (TEST_ARRAY_ELEMENTS([key],key_array))
					{
						var error_message:String = "- WARNING > Utility.JOIN_OBJECTS(): Her iki objede de '" + key + "' özelliği aynı ve biri diğerinin üzerine yazıldı. Verileriniz kaybolabilir.";
						trace(error_message);
						Console.PRINT("Utility", error_message, 2, "");
					}
					
					return_object[key] = Target_Object[key];
					key_array.push(key);
				}
			}
		}
		public static function CHECK_KEY_CONFLICT(Target:Object):Object
		{
			var keys_and_objs:Array = new Array();
			var CONO:Object = new Object();
			
			check_next_layer(Target);
			
			update_CONO();
			
			return CONO;
			
			function check_next_layer(obj:Object):void
			{
				for (var key:String in obj)
				{
					keys_and_objs[obj[key]] = FIND_PATH(Target, obj[key]);
					
					if (GET_OBJECT_LENGTH(obj[key]))
					{
						check_next_layer(obj[key]);
					}
				}
			}
			function update_CONO():void
			{
				for (var key:String in keys_and_objs)
				{
					if (keys_and_objs[key].length > 1)
					{
						CONO[key] = new Object();
						CONO[key].count = keys_and_objs[key].length;
						
						for (var i:int = 0; i < keys_and_objs[key].length; i ++)
						{
							CONO[key]["key_" + int(i + 1)] = keys_and_objs[key][i];
						}
					}
				}
			}
		}
		public static function GET_OBJECT_LENGTH(Target:Object):int
		{
			var result:int=0;
			
			for (var Key:* in Target) 
			{
				result ++;
			}
			
			return result;
		}
		public static function CLONE(Target:Object):*
		{
			var new_ba:ByteArray = new ByteArray();
			
			new_ba.writeObject(Target); 
			new_ba.position = 0; 
			
			return(new_ba.readObject()); 
		}
		public static function CLEAR_OBJECT(Target_Object:Object, Key_List:Array = null):void
		{
			for (var key:* in Target_Object)
			{
				var clear_ok:Boolean = false;
				
				if (Key_List.length)
				{
					if (Key_List[0] == "All")
					{
						clear_ok = true;
					}
					else
					{
						clear_ok = Utility.SOME_REGEXP(key,[Key_List]);
					}
				}
				
				if (clear_ok)
				{
					Target_Object[key] = null;
				}
			}
		}
		
		// Path Methods:
		
		public static function FIND_PATH(Mother_Object:Object, Target_Object:Object, Include_Object_Values:Boolean = false):Array
		{
			var paths:Array = new Array();
			var path:String = "";
			
			init_find_path();
			
			return paths;
			
			function init_find_path():void
			{
				if (Target_Object is String)
				{
					if (!SEARCH_TEXT(String(Target_Object), "."))
					{
						get_path_next(Mother_Object, path);
					}
					else
					{
						paths = COMPLETE_PATH(Mother_Object, String(Target_Object), true);
					}
				}
				else
				{
					get_path_next(Mother_Object, path);
				}
			}
			function get_path_next(obj:Object, parent_path:String):void
			{
				if (obj is MovieClip)
				{
					layer_as_MC();
				}
				else
				{
					layer_as_object();
				}
				
				function layer_as_MC():void
				{
					for (var i:int = 0; i < obj.numChildren; i ++)
					{
						if (obj.getChildAt(i) is MovieClip)
						{
							if ((obj.getChildAt(i) === Target_Object) || (obj.getChildAt(i).name === Target_Object))
							{
								update_path(parent_path, obj.getChildAt(i).name);
									
								paths.push(path);
							}
							
							if (obj.getChildAt(i).numChildren)
							{
								update_path(parent_path, obj.getChildAt(i).name);
								
								get_path_next(obj[obj.getChildAt(i).name], path);
							}
						}
					}
				}
				function layer_as_object():void
				{
					for (var key:String in obj)
					{
						if ((key === Target_Object) || (obj[key] === Target_Object))
						{
							update_path(parent_path, key);
								
							paths.push(path);
						}
						
						if (GET_OBJECT_LENGTH(obj[key]))
						{
							update_path(parent_path, key);
							
							get_path_next(obj[key], path);
						}
					}
				}
			}
			function update_path(old_path:String, new_obj_key:String):void
			{
				path = old_path;
								
				if (Boolean(path))
				{
					path += ".";
				}
							
				path += new_obj_key;
			}
		}
		public static function FIND_OBJECT_FROM_PATH(Target_Object:Object, Path:String = null):*
		{
			var final_obj:Object;
			var path_array:Array = STRING_TO_ARRAY(Path, ".");
			var depth:uint = 0;
			
			if (Path)
			{
				search_object(Target_Object);
			}
			else
			{
				final_obj = Target_Object;
			}
			
			return final_obj;
			
			function search_object(Layer:Object):void
			{
				depth ++;
				
				if (depth < path_array.length)
				{
					if (Boolean(Layer[path_array[depth - 1]]))
					{
						search_object(Layer[path_array[depth - 1]]);
					}
					else
					{
						final_obj = null;
					}
				}
				else
				{
					if (Boolean(Layer[path_array[depth - 1]]))
					{
						final_obj = Layer[path_array[depth - 1]];
					}
					else
					{
						final_obj = null;
					}
				}
			}
		}
		public static function COMPLETE_PATH(Mother_Object:*, Short_Path:String, Keep_Integrity:Boolean = false):Array
		{
			var paths:Array = new Array();
			
			init_complete_path();

			return paths;
			
			function init_complete_path():void
			{
				if (SEARCH_TEXT(Short_Path, "."))
				{
					find_next(Short_Path);
				
					if (Keep_Integrity)
					{
						integrity_filter()
					}
				}
				else
				{
					paths = FIND_PATH(Mother_Object, Short_Path);
				}
			}
			function find_next(Next_Path:String, Root_Path:String = ""):void
			{
				var new_path:String = SPLIT_TEXT(Next_Path, ".", 2);
				var root:String = SPLIT_TEXT(Next_Path, ".", 1, 1);
				
				var TOPL:Array = new Array();
				var TOL:Array = new Array();
				
				update_TOPL();
				
				//
				/*Console.PRINT("Utility", "-----", 3);
				Console.PRINT_DATA("Utility", "Root_Path", Root_Path);
				Console.PRINT_DATA("Utility", "Next_Path", Next_Path);
				Console.PRINT_DATA("Utility", "root", root);
				Console.PRINT_DATA("Utility", "new_path", new_path);
				Console.PRINT_DATA("Utility", "TOPL", TOPL);
				Console.PRINT("Utility", "--", 2);*/
				//
				
				check_path_accuracy();
				
				function update_TOPL():void
				{
					TOPL = FIND_PATH(FIND_OBJECT_FROM_PATH(Mother_Object, Root_Path), root);
					
					if (Root_Path)
					{
						for (var i:int = 0; i < TOPL.length; i ++)
						{
							TOPL[i] = Root_Path + "." + TOPL[i] ;
						}
					}
				}
				function check_path_accuracy():void
				{
					if (TOPL.length)
					{
						for (var i:int = 0; i < TOPL.length; i ++)
						{
							TOL[i] = FIND_OBJECT_FROM_PATH(Mother_Object, TOPL[i]);
							
							if (Boolean(TOL[i]))
							{
								if (!Boolean(new_path))
								{
									if (!SOME_ARRAY_ELEMENTS(paths, [TOPL[i]]))
									{
										//
										//Console.PRINT("Utility", "ADDED '" + TOPL[i] + "'", 2);
										//
										
										paths.push(TOPL[i]);
									}
								}
								else if (GET_OBJECT_LENGTH(TOL[i]))
								{
									find_next(new_path, TOPL[i]);
								}
							}
						}
					}
				}
			}
			function integrity_filter():void
			{
				for (var i:int = 0; i < paths.length; i ++)
				{
					if (!SEARCH_TEXT(paths[i], Short_Path))
					{
						delete paths[i];
					}
				}
				
				COMPRESS_ARRAY(paths);
			}
		}
		public static function UPDATE_OBJECT_FROM_PATH(Target_Object:Object, Path:String = null, New_Value:* = null):Boolean
		{
			var final_obj:Object;
			var path_array:Array = STRING_TO_ARRAY(Path, ".");
			var depth:uint = 0;
			
			if (Path)
			{
				search_object(Target_Object);
			}
			else
			{
				final_obj = New_Value;
			}
			
			return final_obj;
			
			function search_object(Layer:Object):void
			{
				depth ++;
				
				if (depth < path_array.length)
				{
					if (Boolean(Layer[path_array[depth - 1]]))
					{
						search_object(Layer[path_array[depth - 1]]);
					}
					else
					{
						final_obj = null;
					}
				}
				else
				{
					if (TEST_OBJECT_STANDART(Layer, [path_array[depth - 1]]))
					{
						Layer[path_array[depth - 1]] = New_Value;
						
						final_obj = Layer[path_array[depth - 1]];
					}
					else
					{
						final_obj = null;
					}
				}
			}
		}
		public static function SMART_PATH_FINDER(Mother_Object:*, Short_Path_or_Full_Path_or_Object:*, Include_Object_Values:Boolean = false, Keep_Integrity:Boolean = false, Shortest_Path:Boolean = false):Array
		{
			var paths:Array = new Array();
			
			init_smart_path_finder();
			
			if (Shortest_Path)
			{
				find_shortest_path();
			}

			return paths;
			
			function init_smart_path_finder():void
			{
				if (Short_Path_or_Full_Path_or_Object is String)
				{
					if (!SEARCH_TEXT(String(Short_Path_or_Full_Path_or_Object), "."))
					{
						paths = FIND_PATH(Mother_Object, String(Short_Path_or_Full_Path_or_Object), Include_Object_Values);
						
						
					}
					else
					{
						paths = COMPLETE_PATH(Mother_Object, String(Short_Path_or_Full_Path_or_Object), Keep_Integrity);
					}
				}
				else
				{
					paths = FIND_PATH(Mother_Object, String(Short_Path_or_Full_Path_or_Object), Include_Object_Values);
				}
			}
			function find_shortest_path():void
			{
				var path_texts:Array = new Array();
				var shortest_path_depth:int = 0;
				
				for (var i:int = 0; i < paths.length; i ++)
				{
					path_texts[i] = STRING_TO_ARRAY(paths[i], ".").length;
					
					if (!shortest_path_depth)
					{
						shortest_path_depth = path_texts[i];
					}
					else if (shortest_path_depth > path_texts[i])
					{
						shortest_path_depth = path_texts[i];
					}
				}
				
				for (var j:int = 0; j < paths.length; j ++)
				{
					if (path_texts[j] > shortest_path_depth)
					{
						paths[j] = null;
					}
				}
				
				COMPRESS_ARRAY(paths);
			}
		}
		public static function SMART_OBJECT_FINDER(Mother_Object:*, Short_Path_or_Full_Path_or_Object:*, Include_Object_Values:Boolean = false, Keep_Integrity:Boolean = false, Shortest_Path:Boolean = false):Array
		{
			var paths:Array = new Array();
			var objects:Array = new Array();
			
			init_smart_path_finder();
			find_objects_from_paths();
			
			return objects;
			
			function init_smart_path_finder():void
			{
				paths = SMART_PATH_FINDER(Mother_Object, Short_Path_or_Full_Path_or_Object, Include_Object_Values, Keep_Integrity, Shortest_Path);
			}
			function find_objects_from_paths():void
			{
				for (var i:int = 0; i < paths.length; i ++)
				{
					objects[paths[i]] = FIND_OBJECT_FROM_PATH(Mother_Object, paths[i]);
				}
			}
		}

		// DisplayObjects Methods:
		
		public static function CHECK_NAME_CONFLICT(Mother_MC:MovieClip):Object
		{
			var keys_and_objs:Array = new Array();
			var CONO:Object = new Object();
			
			check_next_layer(Mother_MC);
			
			Console.DYNAMIC_DATA("keys_and_objs", keys_and_objs);
			
			update_CONO();
			
			return CONO;
			
			function check_next_layer(MC:MovieClip):void
			{				
				for (var i:int = 0; i < MC.numChildren; i ++)
				{
					if (MC.getChildAt(i) is MovieClip)
					{
						keys_and_objs[MC.getChildAt(i).name] = FIND_PATH(Mother_MC, MC.getChildAt(i).name);
						
						if (MovieClip(MC.getChildAt(i)).numChildren)
						{
							check_next_layer(MC.getChildAt(i));
						}
					}
				}
			}
			function update_CONO():void
			{
				for (var key:String in keys_and_objs)
				{
					if (keys_and_objs[key].length > 1)
					{
						CONO[key] = new Object();
						CONO[key].count = keys_and_objs[key].length;
						
						for (var i:int = 0; i < keys_and_objs[key].length; i ++)
						{
							CONO[key]["key_" + int(i + 1)] = keys_and_objs[key][i];
						}
					}
				}
			}
		}
		public static function GET_ALL_CHILDREN(Mother_MC:MovieClip, Filter:Array = null):Array
		{
			var children_mc_list:Array = new Array();
			
			search_children(Mother_MC);

			function search_children(Target_MC:MovieClip):void
			{
				var pass_filter:Boolean = false;

				for (var i:uint = 0; i < Target_MC.numChildren; i++)
				{
					if (Filter)
					{
						pass_filter = Filter.some(test_for_filter);
					}
					else
					{
						pass_filter = true;
					}

					if (pass_filter)
					{
						children_mc_list[Target_MC.getChildAt(i).name] = Target_MC.getChildAt(i);

						if (Target_MC.getChildAt(i) is MovieClip)
						{
							search_children(Target_MC.getChildAt(i));
						}
					}
				}

				function test_for_filter(element:*, index:int, arr:Array):Boolean
				{
					return !(element == Target_MC.getChildAt(i).name);
				}
			}

			return children_mc_list;
		}
		public static function GET_SPECIFIC_TYPE_CHILDRENS(Mother_MC:MovieClip, AS_Linkage_Patterns:Array):Array
		{
			var all_children:Array;
			var mc_specific_list:Array = new Array();
			
			all_children = Utility.GET_ALL_CHILDREN(Mother_MC);
			
			for each (var specific_object:* in all_children)
			{
				if (Boolean(SOME_REGEXP(getQualifiedClassName(specific_object), AS_Linkage_Patterns)))
				{
					mc_specific_list.push(specific_object);
				}
			}
			
			return mc_specific_list;	
		}
		public static function FIND_CHILD(Mother_MC:MovieClip, Child_Name_or_Itself:Object):MovieClip
		{
			var child:MovieClip;
			
			search_children(Mother_MC);
			
			return child;
			
			function search_children(Mother:MovieClip):void
			{
				for (var i:uint = 0; i < Mother.numChildren; i++)
				{
					if (Mother.getChildAt(i) is MovieClip)
					{
						if (Mother.getChildAt(i).name == Child_Name_or_Itself || Mother.getChildAt(i) == Child_Name_or_Itself)
						{
							child = MovieClip(Mother.getChildAt(i));
							
							break;
						}
						else
						{
							search_children(Mother.getChildAt(i));
						}
					}
				}
			}
		}
		public static function GET_FAMILY(DO:DisplayObject):Array
		{
			var family:Array = new Array();
			
			family[0] = DO;
			
			get_mother(DO);
			
			return family;
			
			function get_mother(Child_DO:DisplayObject):void
			{
				if (Boolean(Child_DO.parent))
				{
					family.push(Child_DO.parent);
					get_mother(Child_DO.parent);
				}
			}
		}
		public static function TEST_FAMILY(Family_DO:DisplayObject, Check_DO_List:Array):Boolean
		{
			return SOME_ARRAY_ELEMENTS(GET_FAMILY(Family_DO), Check_DO_List);
		}
		public static function FIND_IN_FAMILY(Family_DO:DisplayObject, Check_DO_List:Array):DisplayObject
		{
			var result:DisplayObject = null;
			
			GET_FAMILY(Family_DO).some(is_exist_in_family);

			function is_exist_in_family(element:*, index:int, arr:Array):Boolean 
			{
				var is_exist:Boolean = false;
				
            	for (var key:String in Check_DO_List)
				{
					if (Check_DO_List[key] == element)
					{
						is_exist = true;
						result = element;
					}
				}
				
				return is_exist;
        	}
			
			return result;
		}
		public static function TEST_FAMILY_VISIBILITY(DO:DisplayObject):Boolean
		{
			var result:Boolean = true;
			var family_list:Array = GET_FAMILY(DO);
			var temp:Array = new Array();
			
			REMOVE_SPECIFIC_ELEMENTS(family_list, [DO]);
			
			COMPRESS_ARRAY(family_list);
		
			for (var parent_name:String in family_list)
			{
				if (family_list[parent_name] is MovieClip)
				{
					if (!Boolean(family_list[parent_name].visible))
					{
						result = false;
					}
				}
			}

			return result;
		}
		public static function STOP_ALL_CHILDREN(Target_MC:MovieClip):void
		{
			search_children(Target_MC);
			
			function search_children(MC:MovieClip):void
			{
				for (var i:uint = 0; i < MC.numChildren; i++)
				{
					if (MC.getChildAt(i) is MovieClip)
					{
						MovieClip(MC.getChildAt(i)).stop();
						
						search_children(MC.getChildAt(i));
					}
				}
			}
		}
		public static function CHANGE_COORD(Domain_Point:Point, Domain_DO:DisplayObject, Target_DO:DisplayObject = null):Point
		{
			Domain_Point = Domain_DO.localToGlobal(Domain_Point);
			
			if (Boolean(Target_DO))
			{
				Domain_Point = Target_DO.globalToLocal(Domain_Point);
			}
			
			return Domain_Point;
		}
		public static function GET_REAL_DIM(DO:DisplayObject):Object
		{
			var dim:Object = new Object();
			var rect:Rectangle = DO.getBounds(DO);
 			dim.w = rect.width * DO.scaleX;
 			dim.h = rect.height * DO.scaleY;
			
			return dim;
		}
		public static function SET_REAL_DIM(DO:DisplayObject, Width_and_Height:Array = null, Scale:Array = null):void
		{
			if (Boolean(Width_and_Height) || Boolean(Scale))
			{	
				var temp_r:Number = DO.rotation;
				
				DO.rotation = 0;
				
				if (Boolean(Width_and_Height))
				{
					DO.width = Width_and_Height[0];
					DO.height = Width_and_Height[1];
				}
				if (Boolean(Scale))
				{
					DO.width = DO.width * Scale[0];
					DO.height = DO.height * Scale[1];
				}
				
				DO.rotation = temp_r;
			}
			else
			{
				Console.PRINT("Utility","X ERROR > ERROR CODE : xxxx > Invalid parameters for setting real dimension of a display object.",3,"");
			}
		}
		public static function SET_STAGE_DEPTH(Stage_Objects:Array, Front_or_Back:Boolean = true):void
		{
			var mother:Stage = Stage_Objects[0].parent;
			var initial_index:int = 0;

			Stage_Objects.reverse();
			
			if (Front_or_Back)
			{
				initial_index = mother.numChildren - Stage_Objects.length;
			}

			for (var i:int = 0; i < Stage_Objects.length; i++)
			{
				mother.setChildIndex(Stage_Objects[i], initial_index + i);
			}
		}
		
		// Advanced DisplayObjects Methods:
		
		public static function GET_REF_PROPS(Child_DO:DisplayObject, Reference_DO:DisplayObject = null, Child_Initial_Dim:Array = null):void
		{
			RPO.point = new Point(Child_DO.x, Child_DO.y);
			
			RPO.x = Child_DO.parent.localToGlobal(RPO.point).x;
			RPO.y = Child_DO.parent.localToGlobal(RPO.point).y;
			RPO.r = Child_DO.rotation;
			RPO.sx = 1;
			RPO.sy = 1;
			
			find_initial_dim();
			find_parent(Child_DO);

			RPO.w = RPO.w * RPO.sx;
			RPO.h = RPO.h * RPO.sy;
			
			if (Boolean(Reference_DO))
			{
				RPO.point = new Point(RPO.x, RPO.y);
				
				RPO.x = Reference_DO.globalToLocal(RPO.point).x;
				RPO.y = Reference_DO.globalToLocal(RPO.point).y;
				RPO.w = RPO.w / Reference_DO.scaleX;
				RPO.h = RPO.h / Reference_DO.scaleY;
				RPO.r = RPO.r - Reference_DO.rotation;
			}
			
			function find_initial_dim():void
			{
				if (Boolean(Child_Initial_Dim))
				{
					RPO.w = Child_Initial_Dim[0];
					RPO.h = Child_Initial_Dim[1];
				}
				else
				{
					RPO.w = GET_REAL_DIM(Child_DO).w;
					RPO.h = GET_REAL_DIM(Child_DO).h;
					RPO.init_w = RPO.w;
					RPO.init_h = RPO.h;
				}
			}
			function find_parent(DO:DisplayObject):void
			{
				if (Boolean(DO.parent))
				{
					if (DO.parent is DisplayObject)
					{
						RPO.sx = RPO.sx * DO.parent.scaleX;
						RPO.sy = RPO.sy * DO.parent.scaleY;
						RPO.r = RPO.r + DO.parent.rotation;
							
						find_parent(DO.parent);
					}
				}
			}
		}
		public static function CENTRE_DISPLAY_OBJECT(DO_1:DisplayObject, DO_2:DisplayObject, Align_for_H_or_W:Boolean):int
		{
			var sonuc:int;
			
			if (Align_for_H_or_W)
			{
				var boy_fark:int = DO_2.height - DO_1.height;
				
				if ((boy_fark > 0))
				{
					sonuc = boy_fark / 2;
				}
			}
			else
			{
				var en_fark:int = DO_2.width - DO_1.width;
				
				if ((en_fark > 0))
				{
					sonuc = en_fark / 2;
				}
			}
			
			return sonuc;
		}
		public static function GET_CENTER(Width:Number, Height:Number, Rotation:Number, Regist_X:Number, Regist_Y:Number):Array
		{
			var Regist_X:Number = - Regist_X;
			var Regist_Y:Number = Height + Regist_Y;
			var loc_center_x:Number = Width / 2;
			var loc_center_y:Number = Height / 2;
			var r:Number = Math.abs(MathLab.DISTANCE_POINTS(Width / 2, Height / 2, Regist_X, Regist_Y));
			var central_angle:Number = MathLab.GET_ANGLE_BTW_TWO_VECTORS_IN_COORDINATES(0, 0, Regist_X, Regist_Y, Regist_X + Width, Regist_Y, Regist_X, Regist_Y, loc_center_x, loc_center_y) - Rotation;
			
			var offset_x:Number = Math.cos(MathLab.DEGREE_TO_RADIAN(central_angle)) * r;
			var offset_y:Number = -Math.sin(MathLab.DEGREE_TO_RADIAN(central_angle)) * r;
			
			return [offset_x, offset_y]
		}
		public static function GET_XY_IN_DYNAMIC_ROTATION(Distance:Number, Angle:Number):Array
		{
			var distance_x:Number = Math.cos(MathLab.DEGREE_TO_RADIAN(Angle)) * Distance;
			var distance_y:Number = - Math.sin(MathLab.DEGREE_TO_RADIAN(Angle)) * Distance;
			
			return [distance_x, distance_y]
		}

	}
}