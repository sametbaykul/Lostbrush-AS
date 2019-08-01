/*

	------------------------------------------------------------
	- LOCAL STORAGE (C) 2014 
	------------------------------------------------------------
	
	* FULL STATIC
	* INIT : true
	
	v1.0 : 05.06.2014 : Storage Data
	
	v2.0 : 05.02.2015 : İsmi 'LocalStorage' olarak değiştirildi. Sınıf tümüyle yeniden yapılandırıldı ve genel hatalar düzeltildi.
	v2.1 : 09.02.2015 : PRINT() metodu güncellendi ve ADD_DATA() metoduna "Update_Storage" parametresi eklendi.
	v2.2 : 10.02.2015 : FORMAT() metodunda "Property" parametre hatası giderildi.
	
	v3.0 : 11.02.2015 : 
		Eklenen yeni özellikler:
		1. ADD_DATA() metodu "Utility" sınıfının yeni UPDATE_OBJECT() ve TEST_OBJECT_STANDART() metodlarıyla yeninden yapılandırılarak daha sezgisel ve tutarlı bir sınıf yaratıldı. 
		2. ADD_DATA() metoduna How parametresi eklenerek veri girişlerinde kontrol arttırıldı.
		3. ADD_DATA() metoduna "Array_Support" parametresi eklendi. Bu parametre ile farklı kanallardan aynı veri bankasına çağrılan metodlarla veri bir dizi şeklinde büyütülebilecek.
	
	V4.0 : 20.02.2015 : Storage'dan güvenli bir şekilde veri çekmeyi sağlayan GET_DATA() metodu eklendi. Bu metodun avantajları şöyle sıralanabilir:
		Eklenen yeni özellikler:
		1. "Storage" a ait bir "Property", daha "Storage" başlatılmadan önce çağrılmak istendiğinde "GET_DATA()" metodu başlatma işlemini otomatik olarak yapar.
		2. Eğer bir "Storage" tanımlanmamışsa "GET_DATA()" metodu otomatik olarak yeni bir "Storage" tanımlar.
		3. Eğer "Storage" içerisinde ulaşılmak istenilen "Property" yoksa, "GET_DATA()" metodu sizi bu konuda uyarır.
		4. Ulaşılmak istenilen özelliğe erişilirken herhangi bir nedenden dolayı bir hata olursa, "GET_DATA()" metodu program akışına zarar vermeden sizi hata ayrıntılarıyla birlikte uyarır  ve "null" değerini döndürür.
		5. Artık "DATA" dizisi yerine "GET_DATA()" metodunun kullanılması tavsiye edilir.
		6. TEST_PROP() ve TEST_VALUE() metodları için: TEST_PROP() metodunun kullanılması artık tavsiye edilmez ve yakın bir gelecekte kaldırılabilir. TEST_VALUE() metodu ise kullanılabilir ve halen daha oldukça faydalı bir metoddur.
	v4.1 : 26.02.2015 : FORMAT() metodunda güvenlik güncellemesi yapıldı. Ayrıca ADD_DATA() metoduna Boolean veri türü eklendi.
	v4.2 : 01.03.2015 : TEST_PROP() ve TEST_VALUE() metodları artık ilgili STORAGE başlatılmasına gerek kalmadan çalıştırılabilir. Ayrıca bir STORAGE'ın ilgili özellikleri hariç bütün özelliklerini silmek için CLEAR_STORAGE() metodu oluşturuldu. 
	v4.3 : 12.02.2015 : 'id' ve 'no' özellikleri belirlendi.
	
	by Samet Baykul

*/

package lbl
{
	// Flash Library:
	import flash.net.SharedObject;
	// LBL Core:
	import lbl.Utility;
	// LBL Control:
	import lbl.Console;

	public class LocalStorage
	{
		public static var DATA:Array = new Array();
		public static var SO_LIST:Array = new Array();

		private static var storage_location:String;
		
		// Class Info:
		private static var id:String = "LOC";
		private static var no:int = 002;

		public function LocalStorage():void
		{
			// Full static class
		}

		// ----------------------------------------------------------------
		// METHODS:
		// ----------------------------------------------------------------

		public static function START(Storage_List:Array):void
		{
			try
			{
				for (var i = 0; i < Storage_List.length; i++)
				{
					var SO:SharedObject = SharedObject.getLocal(Storage_List[i]);
					DATA[Storage_List[i]] = new Object();
					SO_LIST[Storage_List[i]] = SO;
				}
				
				UPDATE_CLIENT_DATA();
			}
			catch(e:Error)
			{
				Console.PRINT("LocalStorage", "X ERROR > ERROR CODE: 0029 > Coludn not connect the local storage in your machine. ", 3, "");
				Console.PRINT("LocalStorage", "- ERROR DETAILS > " + e, 2, "");
			}
		}

		public static function UPDATE_CLIENT_DATA():void
		{
			try
			{
				for (var key:* in SO_LIST)
				{
					DATA[key] = SO_LIST[key].data;
				}
			}
			catch(e:Error)
			{
				Console.PRINT("LocalStorage", "X ERROR > ERROR CODE: 0030 > Colud not get data from the local storage. ", 3, "");
				Console.PRINT("LocalStorage", "- ERROR DETAILS > " + e, 2, "");
			}
		}

		public static function UPDATE_STORAGE():void
		{
			try
			{
				for (var key:* in DATA)
				{
					Utility.UPDATE_OBJECT(SO_LIST[key].data, DATA[key]);
					SO_LIST[key].flush();
				}
			}
			catch(e:Error)
			{
				Console.PRINT("LocalStorage", "X ERROR > ERROR CODE: 0031 > Colud not update the local storage. ", 3, "");
				Console.PRINT("LocalStorage", "- ERROR DETAILS > " + e, 2, "");
			}
		}
	
		public static function GET_DATA(Storage_Name:String, Property:String):Object
		{
			var result:Object;
			var start_again:Boolean = false;
			
			get_data();
			
			function get_data():void
			{
				if (DATA[Storage_Name])
				{
					if (DATA[Storage_Name][Property])
					{
						try
						{
							result = DATA[Storage_Name][Property];
						}
						catch(e:Error)
						{
							Console.PRINT("LocalStorage", "X ERROR >  ERROR CODE: 0032 > Attempt to reach '" + Storage_Name + "." + Property + "' object returns an error.", 3, "");
							Console.PRINT("LocalStorage", "- ERROR DETAILS: " + e, 2, "");
							result = null;
						}
					}
					else
					{
						Console.PRINT("LocalStorage", "- WARNING > The property which name is '" + Property + "', is not exist in " + Storage_Name + ".", 2, "");
						result = null;
					}
				}
				else
				{
					if (!start_again)
					{
						START([Storage_Name]);
						start_again = true;
						get_data();
					}
					else
					{
						Console.PRINT("LocalStorage", "- WARNING > The storage which name is '" + Storage_Name + "', is not exist in LocalStorage DATA.", 2, "");
						result = null;
					}
				}
			}
			
			return result;
		}
		
		public static function ADD_DATA(Storage_Name:String, Property:String, Value:*, Update_Storage:Boolean = true, How:String = "Overwrite", Array_Support:Boolean = false):void
		{
			if (!Utility.TEST_ARRAY_ELEMENTS(DATA, [Storage_Name]))
			{
				START([Storage_Name]);
			}
			
			if (!Utility.TEST_OBJECT_STANDART(DATA[Storage_Name], [Property]))
			{
				if (Array_Support)
				{
					DATA[Storage_Name][Property] = new Array();
				}
				else
				{
					DATA[Storage_Name][Property] = new Object();
				}
			}
			
			if (Value is String || Value is int || Value is uint || Value is Number || Value is Boolean)
			{
				if (Array_Support)
				{
					DATA[Storage_Name][Property].push(Value);
				}
				else
				{
					DATA[Storage_Name][Property] = Value;
				}
			}
			else
			{	
				Utility.UPDATE_OBJECT(DATA[Storage_Name][Property], Value, How);
			}
			
			if (Update_Storage)
			{
				UPDATE_STORAGE();
			}
		}

		public static function TEST_PROP(Storage_Name:String, Property:String):Boolean
		{
			var key_list:Array = new Array();
			
			if (!Boolean(DATA[Storage_Name]))
			{
				START([Storage_Name]);
			}
			
			for (var key:* in DATA[Storage_Name])
			{
				key_list.push(key);
			}

			return key_list.some(test_for_element);

			function test_for_element(element:*, index:int, arr:Array):Boolean
			{
				return (element == Property);
			}
		}

		public static function TEST_VALUE(Storage_Name:String, Property:String,  Value:*):Boolean
		{
			if (!Boolean(DATA[Storage_Name]))
			{
				START([Storage_Name]);
			}
			
			if (!Boolean(DATA[Storage_Name][Property]))
			{
				return false;
			}
			else
			{
				var prop:* = DATA[Storage_Name][Property];

				if (prop is String || prop is int || prop is uint || prop is Number)
				{
					return (prop == Value);
				}
				else
				{
					return DATA[Storage_Name][Property].some(test_for_element);
				}
			}
			function test_for_element(element:*, index:int, arr:Array):Boolean
			{
				return (element == Value);
			}
		}
		
		public static function FORMAT(Storage_Name:String):void
		{
			if (Storage_Name == "Full")
			{
				for (var so_key:* in SO_LIST)
				{
					SO_LIST[so_key].clear();
				}
				for (var data_key:* in DATA)
				{
					DATA[data_key] = null;
				}
			}
			else
			{
				if (SO_LIST[Storage_Name])
				{
					SO_LIST[Storage_Name].clear();
					DATA[Storage_Name] = null;
				}
			}
		}
		
		// -> Test edilmeli.
		public static function CLEAR_STORAGE(Storage_Name:String, Update_Storage:Boolean = true, Key_Array:Array = null):void
		{
			if (!Utility.TEST_ARRAY_ELEMENTS(DATA, [Storage_Name]))
			{
				START([Storage_Name]);
			}
			
			try
			{
				Utility.CLEAR_OBJECT(DATA[Storage_Name], Key_Array);
			
				if (Update_Storage)
				{
					UPDATE_STORAGE();
				}
			}
			catch(e:Error)
			{
				Console.PRINT("LocalStorage", "X ERROR >  ERROR CODE: 0033 > Colud not clear '" + Storage_Name + "' data from LocalStorage.", 3, "");
				Console.PRINT("LocalStorage", "- ERROR DETAILS: " + e, 2, "");
			}
		}
		
		public static function PRINT(Storage_Name:String = "All", Prop_Name:String = null):void
		{
			if (Storage_Name == "All")
			{
				for (var key_1:* in SO_LIST)
				{
					Console.PRINT("LocalStorage", Utility.GET_OBJECT_TREE(SO_LIST[key_1].data, "SO_LIST." + key_1), 1, "");
				}
			
				Console.PRINT("LocalStorage", Utility.GET_OBJECT_TREE(DATA, "DATA"), 1, "");
			}
			else if (Prop_Name == null)
			{
				Console.PRINT("LocalStorage", Utility.GET_OBJECT_TREE(SO_LIST[Storage_Name].data, "SO_LIST." + Storage_Name + ".data"), 1, "");
				Console.PRINT("LocalStorage", Utility.GET_OBJECT_TREE(DATA[Storage_Name], "DATA." + Storage_Name), 1, "");
			}
			else
			{
				Console.PRINT("LocalStorage", Utility.GET_OBJECT_TREE(SO_LIST[Storage_Name].data.Prop_Name, "SO_LIST." + Storage_Name + ".data." + Prop_Name), 1, "");
				Console.PRINT("LocalStorage", Utility.GET_OBJECT_TREE(DATA[Storage_Name][Prop_Name], "DATA." + Storage_Name + ".Prop"), 1, "");
			}
		}
	}
}