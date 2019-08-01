/*

	------------------------------------------------------------
	- INPUT CONTROL(C) 2015 - 2016
	------------------------------------------------------------
	
	* FULL STATIC
	* INIT : true
	
	v1.0 : 29.07.2015 : Klavye ve fare gibi kullanıcı giriş aygıtlarının işlevselliğini düzenlemek amacıyla oluşturuldu.	
	v1.1 : 12.08.2015 : Fare desteği eklendi. Bazı önemli hatalar düzeltidli. Daha esnek olmasını sağlayacak yeni özellikler eklendi.
	v1.2 : 26.08.2015 : InputControl ile çalışan nesnelerde artık IC() şartı aranmıcak. Onun yerine bir callback function parametresi istenecek. Bu şekilde daha esnek bir yapıya sahip oldu.
	v1.3 : 03.09.2015 : DEFINE() ve update_control() fonksiyonlarında, bu sınıfın birden fazla nesne tarafından ortak kullanılmasını engelleyen bütün hatalar giderildi.
	v1.4 : 10.09.2015 : MICO nesnesine yeni olay dinleyicileri eklendi ve küçük bir hata giderildi.
	v1.5 : 12.09.2015 : MICO için 'update' metodu eklendi. Bu metod Flash ekranını yeniden render almaya zorlayarak, Mouse etkileşimli animasyonlarınızın daha kesintisiz olmasını sağlar.
	
	v2.0 : 14.09.2015 : 
	Eklenen yeni özellikler:
		 1. Sınıf yapısı değiştirildi. DEFINE() metodunda artık her türlü object için bir IC desteği var. Bu bağlantılar artık 'Link_Name' ler ile sağlanıyor. Gerekli durumlarda bu bağlantılara doğrudan erişim artık mümkün.
		 2. SET_LINKS_ACTIVE() metodu ile runtime'da, bir bağlantıyı duraklatmanız veya yeniden çalıştırmanız mümkün.
		 3. BREAK_LINKS() metodu ile daha önceden tanımlanmış bir bağlantı kesmenizi sağlar. Bu bağlantının sahip olduğu aktif bir olay dinleyici nesne varsa, bu nesne diğer bağlantılar tarafından kullanılabilir olacağından dolayı kaldırılmaz. Eğer bu nesneyi kaldırmak istiyorsanız, BREAK_MOUSE_LISTENERS() metodunu kullanın.
		 4. BREAK_MOUSE_LISTENERS() metodu ile Mouse olaylarını dinleyen bir nesnenin bu olayları dinlemesini sonlandırabilirsiniz.
		 5. STOP() güncellendi. InputControl sınıfının çalışmasını tamamen durdurmak için bu metodu kullanın. Bu metod artık sadece çekirdek dinleyicileri kaldırmakla kalmayıp, aynı zamanda bütün ICO bağlantılarını da temizler.
		 6. RESET() metodu, bütün tanımlı ICO nesnelerini ve onlara bağlı olay dinleyicilerini siler. Ancak çekirdek dinleyiciler ve geçerli donanım hizmetleri devam eder.
		 7. CONFIG_INPUTS() metodu ile donanım girdilerini çaprazlayabilirsiniz.
		 8. RESET_CONFIG_INPUTS() metodu, girdi donaımlarındaki olay dinleyicilerini orginal durumuna geri döndürür.
		 9. Yeni eklenen 'key_codes' nesnesi ve 'mouse_codes' listesi sayesinde bu iki donanım için yeni girdi eylemleri eklemek artık çok kolay. Sadece olay isimlerini yazarak tanıtmanız yeterli. Arka planda yapılması gereken, dinleyicilerin başlatılması, düzenlenmesi ve sonlandırılması gibi işlemler InputControl fonksiyonları tarafından yapılacaktır.
		11. mouse_listener_object_list ile bir mouse dinleyici nesneye gereksiz yere daha fazla olay dinleyicisi atanması engellendi.
		12. Ayrıca bütün bu geliştirmelere ve eklenen daha fazla açıklamalara rağmen, sınıf boyutunda yalnızca 1KB'lik bir değişiklik oldu. InputContol artık çok daha kolay geliştirilebilir, esnek, güçlü ve kararlı bir AS3 sınıfı.
	v2.1 : 17.09.2015 : "Frame" adında yeni bir kontrol yöntemi eklendi. Parametre olarak gönderilen nesne adı FICO.
	v2.2 : 11.02.2016 : mouse_control() sınıfındaki bir hata düzeltildi.
	v2.3 : 12.02.2016 : 'id' ve 'no' özellikleri belirlendi.
	v2.4 : 16.02.2016 : Mouse sahne dinleyicisi eklendi.
	v2.5 : 19.02.2016 : DEFINE() metodundaki bir hata giderildi. Bu şekilde artık "Keyboard" ve "Frame" için "domain" objesinin tür dayatması ortadan kalmış oldu.
	v2.6 : 23.04.2016 : TIMER yapısı güncellendi.
	
	// NOT: Daha fazla etkileşim ve aygıt ekle.
	// Hata denetimlerini kontrol et.
	
	by Samet Baykul

*/

package lbl
{	
	// Flash Library:
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.utils.Timer;
	import flash.ui.Keyboard;
	// LBL Core:
	import lbl.Utility;
	import lbl.Gensys;
	// LBL Control:
	import lbl.Console;
	
	
	public class InputControl
	{

		// ------------------------------------------------------------
		// PROPERTIES :
		// ------------------------------------------------------------
		
		public static var TIMER:Timer;
		public static var ICOL:Array;							// Input Control Objects List
		public static var HW_LIST:Array;						// Donanım desteği listesi 
		public static var KICO:Object;							// Keyboard Input Control Object
		public static var MICO:Object;							// Mouse Input Control Object
		public static var FICO:Object;							// Frame Input Control Object
		public static var ACTIVE:Boolean;

		private static var chw_list:Array;						// Geçerli donanım desteği listesi
		private static var mouse_listener_object_list:Array;
		private static var keyboard_inputs:Object;
		private static var self_timer:Boolean;	
			
		private static var key_codes:Object;
		private static var mouse_codes:Array;
		
		// Class Info:
		private static var id:String = "INC";
		private static var no:int = 016;
		
		public function InputControl()
		{
			// Full static class
		}
		
		// ------------------------------------------------------------
		// METHODS :
		// ------------------------------------------------------------
		
		public static function INIT(Timer_Link:String = "Self"):void
		{
			init_starting_vars();
			init_timer();
			init_key_codes();
			init_mouse_codes();
			init_KICO();
			init_MICO();
			init_FICO();
			init_commands();

			function init_starting_vars():void
			{
				ICOL = new Array();
				HW_LIST = new Array();	
				chw_list = new Array();
				mouse_listener_object_list = new Array();
			}
			function init_timer():void
			{
				if (Gensys.TIMEL[Timer_Link])
				{
					TIMER = Gensys.TIMEL[Timer_Link];
				}
				else if (Timer_Link == "Self")
				{
					TIMER = Gensys.NEW_TIMER("InputControl_Clock");
				}
				else
				{
					TIMER = Gensys.NEW_TIMER(Timer_Link);
				}
			}
			// -> Define more events.
			function init_key_codes():void
			{
				key_codes = new Object();
				keyboard_inputs = new Object();
				
				// Function Keys :
				key_codes.Backspace = 8;
				key_codes.Enter = 13;
				key_codes.Shift = 16;
				key_codes.Control = 17;
				key_codes.Spacebar = 32;
				
				// Arrow Keys :
				key_codes.LeftArrow = 37;
				key_codes.UpArrow = 38;
				key_codes.RightArrow = 39;
				key_codes.DownArrow = 40;
				
				// Char Keys :
				key_codes.A = 65;
				key_codes.D = 68;
				key_codes.E = 69;
				key_codes.F = 70;
				key_codes.Q = 81;
				key_codes.S = 83;
				key_codes.W = 87;

				// Numpad Keys :
				key_codes.NumpadAdd = 107;
				key_codes.NumpadSubstract = 109;
			
				reset_keyboard_inputs();
			}
			// -> Define more events.
			function init_mouse_codes():void
			{
				mouse_codes = new Array();
				
				mouse_codes.push("click");
				mouse_codes.push("doubleClick");
				mouse_codes.push("mouseDown");
				mouse_codes.push("mouseMove");
				mouse_codes.push("mouseOut");
				mouse_codes.push("mouseOver");
				mouse_codes.push("mouseUp");
				mouse_codes.push("rightClick");
				mouse_codes.push("rightMouseDown");
				mouse_codes.push("rightMouseUp");
				mouse_codes.push("rollOut");
				mouse_codes.push("rollOver");
				mouse_codes.push("mouseWheel");
			}
			function init_KICO():void
			{
				KICO = new Object();
				KICO = Utility.CLONE(key_codes);
				
				for (var key:String in KICO)
				{
					KICO[key] = false;
				}
				
				KICO.type = "Keyboard";
			}
			function init_MICO():void
			{
				MICO = new Object();
				MICO.type = "Mouse";
				
				reset_MICO();
			}
			function init_FICO():void
			{
				FICO = new Object();
				FICO.type = "Frame";
			}
			function init_commands():void
			{
				Console.ADD_COMMAND(id, "icinfo", icinfo);
				
				function icinfo():void
				{
					Console.PRINT("InputControl", "InputContol info:", 1, "");
					Console.SKIP_LINE();
					Console.PRINT_DATA("InputControl", "ICOL", ICOL);
					Console.SKIP_LINE();
				}
			}
		}
		
		public static function DEFINE(Link_Name:String, Domain_Object:Object, Input_Control_Callback:Function, Input_Support:Array):void
		{
			var ICO:Object = new Object();
			
			check_params();
			init_ICO();
			check_mouse_support();
			update_ICOL();
			
			function check_params():void
			{
				if (Utility.TEST_ARRAY_ELEMENTS(Input_Support, ["Mouse"]) && !Boolean(Domain_Object is DisplayObject))
				{
					if (Domain_Object is DisplayObject)
					{
						Console.PRINT("InputControl", "X ERROR > ERROR CODE : XXXX > The object '" + ICO.name + "' is not a DipslayObject which can react with mouse events" , 3, "");
					}
				}
			}
			function init_ICO():void
			{
				ICO.name = Link_Name;
				ICO.domain = Domain_Object;
				ICO.ICC = Input_Control_Callback;
				ICO.IS = Input_Support;
				ICO.active = true;
			}
			function check_mouse_support():void
			{
				if (Utility.TEST_ARRAY_ELEMENTS(Input_Support, ["Mouse"]))
				{
					if (Utility.TEST_ARRAY_ELEMENTS(HW_LIST, ["Mouse"]))
					{
						add_mouse_listeners(ICO.domain);
					}
					else
					{
						Console.PRINT("InputControl", "- WARNING > The object '" + ICO.name + "' is not supported by HW Support List." , 2, "");
					}
				}
			}
			function update_ICOL():void
			{
				ICOL.sort();
				ICOL[Link_Name] = ICO;
			}
		}
		
		public static function SET_LINKS_ACTIVE(Link_List:Array, Active:Boolean = true):void
		{
			for (var i:int = 0; i < Link_List.length; i ++)
			{
				if (Boolean(ICOL[Link_List[i]]))
				{
					ICOL[Link_List[i]].active = Active;
				}
				else
				{
					Console.PRINT("InputControl", "- WARNING > '" + Link_List[i] + "' is not found on ICOL.", 2, "");
				}
			}
		}
		
		public static function BREAK_LINKS(Link_List:Array):void
		{
			for (var i:int = 0; i < Link_List.length; i ++)
			{
				if (Boolean(ICOL[Link_List[i]]))
				{
					delete ICOL[Link_List[i]];
					
					ICOL.sort();
				}
				else
				{
					Console.PRINT("InputControl", "- WARNING > '" + Link_List[i] + "' is not found on ICOL.", 2, "");
				}
			}
		}
		
		public static function BREAK_MOUSE_LISTENERS(Listener_Object_List:Array):void
		{
			for (var i:int = 0; i < Listener_Object_List.length; i ++)
			{
				if (Utility.TEST_ARRAY_ELEMENTS(mouse_listener_object_list, [Listener_Object_List[i]]))
				{
					clear_mouse_listeners(Listener_Object_List[i]);
				}
				else
				{
					Console.PRINT("InputControl", "- WARNING > '" + Listener_Object_List[i] + "' is not found on mouse_listener_object_list.", 2, "");
				}
			}
		}
		
		public static function START(Input_Support:Array):void
		{
			HW_LIST = Input_Support;
			chw_list = HW_LIST;
			ACTIVE = true;
			
			if (Boolean(Gensys.STAGE))
			{
				TIMER.addEventListener(TimerEvent.TIMER, update_control);
				
				if (Utility.TEST_ARRAY_ELEMENTS(HW_LIST, ["Keyboard"]))
				{
					Gensys.STAGE.addEventListener(KeyboardEvent.KEY_DOWN,keyboard_control);
					Gensys.STAGE.addEventListener(KeyboardEvent.KEY_UP,keyboard_control);
				}
				if (Utility.TEST_ARRAY_ELEMENTS(HW_LIST, ["Mouse"]))
				{
					for (var i:int; i < mouse_codes.length; i ++)
					{
						Gensys.STAGE.addEventListener(mouse_codes[i], mouse_control);
					}
				}
			}
			else
			{
				Console.PRINT("InputControl", "X ERROR > ERROR CODE : 0058 > InputControl cannot start. Please check the Gensys INIT() Method is used properly before using this function.", 3, "");
			}
		}
		
		public static function STOP():void
		{
			HW_LIST = [];
			
			TIMER.removeEventListener(TimerEvent.TIMER, update_control);
			Gensys.STAGE.removeEventListener(KeyboardEvent.KEY_DOWN,keyboard_control);
			Gensys.STAGE.removeEventListener(KeyboardEvent.KEY_UP,keyboard_control);
			
			for each (var ICO:Object in ICOL)
			{
				if (Utility.TEST_ARRAY_ELEMENTS(ICO.IS, ["Mouse"]))
				{
					clear_mouse_listeners(ICO.domain);
				}
			}
			for (var i:int; i < mouse_codes.length; i ++)
			{
				Gensys.STAGE.removeEventListener(mouse_codes[i], mouse_control);
			}
			
			RESET();
		}
		
		public static function RESET():void
		{
			var counter:int = 0;
			
			SET_ACTIVE(false);
			
			for (var key:String in ICOL)
			{
				delete ICOL[key];
				counter ++;
			}
			
			mouse_listener_object_list = null;
			
			Console.PRINT("InputControl", "- INFO > " + counter + " ICO has been deleted on ICOL", 1, "");
		}
		
		public static function SET_ACTIVE(Activity:Boolean):void
		{
			ACTIVE = Activity; 
			
			if (ACTIVE)
			{
				chw_list = HW_LIST;
			}
			else
			{
				chw_list = [];
			}
		}
		
		public static function SET_HW(New_Input_Support_List:Array):void
		{
			STOP();
			HW_LIST = New_Input_Support_List;
			START(HW_LIST);
			SET_ACTIVE(ACTIVE);
		}
		
		public static function CONFIG_INPUTS(Hardware:String, Real_Event_List:Array, New_Event_List:Array):void
		{
			switch (Hardware)
			{
				case "Keyboard":
					config_keyboard_inputs();
					break;
			}
			
			function config_keyboard_inputs():void
			{
				if (Real_Event_List.length == New_Event_List.length)
				{
					for (var i:int = 0; i < Real_Event_List.length; i ++)
					{
						if (Boolean(keyboard_inputs[Real_Event_List[i]]) && Boolean(key_codes[New_Event_List[i]]))
						{
							keyboard_inputs[Real_Event_List[i]] = key_codes[New_Event_List[i]]
						}
						else
						{
							throw_parameter_error(Real_Event_List[i], New_Event_List[i]);
						}
					}
				}
				else
				{
					throw_parameter_error();
				}
			}
			function throw_parameter_error(Invalid_Pair_1:String = null, Invalid_Pair_2:String = null):void
			{
				Console.PRINT("InputControl", "- WARNING > Parameters are invalid." , 2, "");
				
				if (Boolean(Invalid_Pair_1) && Boolean(Invalid_Pair_2))
				{
					Console.PRINT("InputControl", "- WARNING DETAILS > Invalid Pair is '" + Invalid_Pair_1 + "', '" + Invalid_Pair_2 + "'." , 2, "");
				}
			}
		}
		
		public static function RESET_CONFIG_INPUTS():void
		{
			keyboard_inputs = key_codes;
		}
		
		// ------------------------------------------------------------
		// FUNCTIONS :
		// ------------------------------------------------------------
		
		private static function update_control(e:TimerEvent):void
		{
			for each (var ICO:Object in ICOL)
			{
				try
				{
					if (ICO.active)
					{
						if (Utility.TEST_ARRAY_ELEMENTS(ICO.IS, ["Keyboard"]) && Utility.TEST_ARRAY_ELEMENTS(chw_list, ["Keyboard"]))
						{
							ICO.ICC(KICO);
						}
						if (Utility.TEST_ARRAY_ELEMENTS(ICO.IS, ["Mouse"]) && Utility.TEST_ARRAY_ELEMENTS(chw_list, ["Mouse"]))
						{
							ICO.ICC(MICO);
						}
						if (Utility.TEST_ARRAY_ELEMENTS(ICO.IS, ["Frame"]) && Utility.TEST_ARRAY_ELEMENTS(chw_list, ["Frame"]))
						{
							ICO.ICC(FICO);
						}
					}
				}
				catch(e:Error)
				{
					Console.PRINT("InputControl", "X ERROR > ERROR CODE : XXXX > The object '" + ICO.name + "' which has an corrupted update method. Please check it.", 3, "");
					Console.PRINT("InputControl", "- ERROR DETAILS > " + e.getStackTrace(), 2, "");
				}
			}
			
			reset_MICO();
		}
		private static function add_mouse_listeners(Mouse_Object:DisplayObject):void
		{
			if (!Utility.TEST_ARRAY_ELEMENTS(mouse_listener_object_list, [Mouse_Object]))
			{
				for (var i:int; i < mouse_codes.length; i ++)
				{
					Mouse_Object.addEventListener(mouse_codes[i], mouse_control);
				}
				
				mouse_listener_object_list.push(Mouse_Object);
			}
		}
		private static function clear_mouse_listeners(Mouse_Object:DisplayObject):void
		{
			if (Utility.TEST_ARRAY_ELEMENTS(mouse_listener_object_list, [Mouse_Object]))
			{
				for (var i:int; i < mouse_codes.length; i ++)
				{
					Mouse_Object.removeEventListener(mouse_codes[i], mouse_control);
				}
				
				Utility.REMOVE_SPECIFIC_ELEMENTS(mouse_listener_object_list, [Mouse_Object]);
			}
		}
		private static function reset_MICO():void
		{
			for (var i:int; i < mouse_codes.length; i ++)
			{
				MICO[mouse_codes[i]] = false;
			}
		}
		private static function mouse_control(e:MouseEvent):void
		{
			MICO.x = e.localX;
			MICO.y = e.localY;
			MICO.global_x = e.stageX;
			MICO.global_y = e.stageY;
			MICO.update = e.updateAfterEvent;
			
			/*if (!Boolean(MICO.target))
			{
				// v2.1 sürümünde bu vardı. sebebi bilinmiyor.
				
				MICO.target = e.target;
			}*/
			MICO.target = e.target;
			
			for (var i:int; i < mouse_codes.length; i ++)
			{
				if (e.type == mouse_codes[i])
				{
					MICO[mouse_codes[i]] = true;
						
					if (e.type == "mouseWheel")
					{
						MICO.delta = e.delta;
					}
				}
			}
		}
		private static function keyboard_control(e:KeyboardEvent):void
		{
			if (e.type == "keyDown")
			{
				for (var key_keydown:String in keyboard_inputs)
				{
					if (e.keyCode == keyboard_inputs[key_keydown])
					{
						KICO[key_keydown] = true;
					}
				}
			}

			if (e.type == "keyUp")
			{
				for (var key_keyup:String in keyboard_inputs)
				{
					if (e.keyCode == keyboard_inputs[key_keyup])
					{
						KICO[key_keyup] = false;
					}
				}
			}
		}
		private static function reset_keyboard_inputs():void
		{
			keyboard_inputs = Utility.CLONE(key_codes);
		}
	}
}