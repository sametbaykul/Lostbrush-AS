/*

	------------------------------------------------------------
	- FORM INPUT(C) 2014 
	------------------------------------------------------------
	
	* DYNAMIC
	* INIT : Constructor
	
	v1.0 : 14.09.2014
	v1.1 : 01.02.2015 : FI_Feedback nesne özellikleri sadeleştirildi.
	
	v2.0 : 07.02.2015 : 
		Eklenen genel özellikler:
		1. Eklenen "LocalStorage" desteği ve "REMIDNER" algoritması ile girilen inputlar artık local hafızaya alınabilecek. Kullanıcının girdiği değerleri yeniden girmesine gerek kalmayacak.
		2. Artık "TAB_INDEX" ile "TAB" tuşuna duyarlı "FI" ler hazırlayabilirsiniz.
		3. "focusrect" artık sizin kontrolünüzde.
		4. Mobile cihazlar için sanal klavye desteği eklendi.
	v2.1 : 08.02.2015 : SET_TAB_INDEX () metodu eklendi.
	v2.2 : 09.02.2015 : İlk oturumda "remind_list" açılmama sorunu çözüldü.
	v2.3 : 12.02.2015 : SET_FOCUSING() ve SET_FILTER() metodları ile yeni filte animasyonları eklendi. Ayrıca SET_ANIMATION() metodu ile animasyonlar doğrudan değiştirilebilecek. 
	v2.4 : 12.02.2015 : 'id' ve 'no' özellikleri belirlendi.
	
	GELİŞTİRMELER:	- Static duruma getir.
					- Animator.as entegrasyonu sağla.
					- LocalStorage.as entegrasyonunu sadeleştir.


	by Samet Baykul

*/

package lbl
{
	// Flash Library:
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.utils.setInterval;
	import flash.utils.clearInterval;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.filters.GlowFilter;
	import fl.controls.List;
	import fl.accessibility.ListAccImpl;
	// LBL Core:
	import lbl.Utility;
	// LBL Control:
	import lbl.Animator;
	// LBL Network:
	import lbl.LocalStorage;

	public class FormInput
	{
		public var MCFI:MovieClip;
		public var ANI_ICON:Animator;
		public var SPECIFIC_REQUIREMENT:Function;
		public var RESPOND_CALLBACK:Function;
		public var ACD:uint = 500;// Auto Checking Delay
		public var REMINDER:Boolean;

		private var regexp_restriction:RegExp;
		private var regexp_validation:RegExp;
		private var auto_control:Boolean;
		private var status_checking:Boolean;
		private var acd_interval:uint;
		private var memory:Array;
		private var list_checking:Boolean;
		private const LCD:uint = 500;
		private const list_max_height:int = 200;
		private const list_line_height:int = 20; 
		private var Feedback:Object;// Feedback for RESPOND_CALLBACK and SPECIFIC_REQUIREMENT;
		private var anim:String = "No";
		// -> Fine Tunning
		private var color_active:uint = 0x333333;
		private var color_passive:uint = 0xCCCCCC;

		// Class Info:
		private static var id:String = "FOR";
		private static var no:int = 009;
		
		public function FormInput(mcFI:MovieClip, Tab_Index:Number = -1, Auto_Control:Boolean = false, Restriction:String = "General", Reminder:Boolean = true, Focus_Filter_Animation:Boolean = true, Virtual_Keyboard_Support:Boolean = true, Respond_Callback:Function = null, Specific_Requirement:Function = null):void
		{
			MCFI = mcFI;
			auto_control = Auto_Control;
			RESPOND_CALLBACK = Respond_Callback;
			SPECIFIC_REQUIREMENT = Specific_Requirement;
			REMINDER = Reminder;

			CLEAR("All");
			init_virtual_keyboard();
			init_input_restriction(Restriction);
			init_auto_check();
			init_anim_icon();
			init_memory();
			
			SET_TAB_INDEX(Tab_Index);
			SET_REMINDER(Reminder);
			SET_FOCUSING(true);
			SET_FILTER(0);

			function init_virtual_keyboard():void
			{
				MCFI.input_area.needsSoftKeyboard = Virtual_Keyboard_Support;
			}
			function init_input_restriction(Restriction:String):void
			{
				switch (Restriction)
				{
					case "General" :
						regexp_restriction = /A-Za-z0-9 _\-@!"é!'#$%&.,;:\^\+\/\{\}\[\]\(\)\?\*\-\\\//;
						regexp_validation = /([A-Z|a-z|0-9])/;
						break;
					case "Name" :
						regexp_restriction = /A-Za-z0-9_/;
						regexp_validation = /([A-Za-z]{2,})([A-Za-z0-9]+)/;
						break;
					case "Password" :
						regexp_restriction = /A-Za-z0-9_!"é!'#$%&.,;:\^\+\/\{\}\[\]\(\)\?\*\-\\\//;
						regexp_validation = /([A-Za-z0-9_!"é!'#$%&.,;:\^\+\/\{\}\[\]\(\)\?\*\-\/]{6,})/;
						break;
					case "Email" :
						regexp_restriction = /A-Za-z0-9._\-@/;
						regexp_validation = /([a-z0-9._-])@([a-z0-9.-]+)\.([a-z]{2,4})/;
						break;
				}
				MCFI.input_area.restrict = regexp_restriction;
			}
			function init_auto_check():void
			{
				if (auto_control)
				{
					MCFI.addEventListener(KeyboardEvent.KEY_DOWN, auto_check);
				}
			}
			function init_anim_icon():void
			{
				if (Boolean(MCFI.mcA_icon))
				{
					ANI_ICON = new Animator(MCFI.mcA_icon);
				}
			}
			function init_memory():void
			{
				if (REMINDER)
				{
					LocalStorage.START(["UserSystem"]);
					memory = new Array();
					
					if (LocalStorage.TEST_PROP("UserSystem",MCFI.name))
					{
						memory = LocalStorage.DATA["UserSystem"][MCFI.name]
					}
				}
			}
		}

		// ----------------------------------------------------------------
		// METHODS:
		// ----------------------------------------------------------------

		public function GET_DATA():String
		{
			return MCFI.input_area.text;
		}
		public function CHECK(Callback:Function = null):Boolean
		{
			var test_result:Boolean;

			clearInterval(acd_interval);
			status_checking = false;
			ready_feedback();

			Feedback.value = MCFI.input_area.text;

			if (Boolean(Callback))
			{
				Feedback.callback = Callback;
			}

			if (MCFI.input_area.text == "")
			{
				Feedback.result = "Empty";
				test_result = false;
			}
			else if (!regexp_validation.test(MCFI.input_area.text))
			{
				Feedback.result = "Not Valid";
				test_result = false;
			}
			else if (Boolean(SPECIFIC_REQUIREMENT))
			{
				status_checking = true;

				try
				{
					SPECIFIC_REQUIREMENT(Feedback);
				}
				catch (e:Error)
				{
					Console.PRINT("FormInput","- ERROR > ERROR CODE: 0017 > " + Feedback.FI + "'nin SPECIFIC_REQUIREMENT fonksiyonunda bir hata var.",3,"");
				}

				test_result = false;
			}
			else
			{
				Feedback.result = "Available";
				test_result = true;
			}

			if (Boolean(Feedback))
			{
				if (Boolean(Feedback.callback))
				{
					try
					{
						Feedback.callback(Feedback);
					}
					catch (e:Error)
					{
						Console.PRINT("FormInput", "- ERROR > ERROR CODE: 0018 > There is a problem on Respond Callback Function on " +  Feedback.name, 3, "");
					}
				}
			}

			die_feedback();

			return test_result;
		}
		public function PRINT(Area:String, Text:String):void
		{
			switch (Area)
			{
				case "Input" :
					MCFI.input_area.text = Text;
					break;
				case "Warning" :
					MCFI.warning.text = Text;
					break;
				case "All" :
					MCFI.input_area.text = Text;
					MCFI.warning.text = Text;
					break;
			}
		}
		public function ADD_MEMORY():void
		{
			if (REMINDER && Boolean(GET_DATA()))
			{
				if (!LocalStorage.TEST_VALUE("UserSystem", MCFI.name, GET_DATA()))
				{
					LocalStorage.ADD_DATA("UserSystem", MCFI.name, GET_DATA(), true, "Overwrite", true);
					memory = LocalStorage.DATA["UserSystem"][MCFI.name];
					SET_REMINDER(false);
					SET_REMINDER(true);
				}
			}
		}
		public function SET_COLOR(Area:String, Renk:uint):void
		{
			var text_format:TextFormat = new TextFormat();
			text_format.color = Renk;
			switch (Area)
			{
				case "Input" :
					MCFI.input_area.setTextFormat(text_format);
					break;
				case "Warning" :
					MCFI.warning.setTextFormat(text_format);
					break;
				case "All" :
					MCFI.input_area.setTextFormat(text_format);
					MCFI.warning.setTextFormat(text_format);
					break;
			}
		}
		public function SET_ACTIVE(Active:Boolean):void
		{
			if (Active)
			{
				MCFI.input_area.type = TextFieldType.INPUT;
				SET_COLOR("Input", color_active);
				START_AUTO_CHECKING();
			}
			else
			{
				MCFI.input_area.type = TextFieldType.DYNAMIC;
				SET_COLOR("Input", color_passive);
				STOP_AUTO_CHECKING();
			}
		}
		public function CLEAR(Area:String):void
		{
			SET_FILTER(0);
			
			switch (Area)
			{
				case "Input" :
					MCFI.input_area.text = "";
					break;
				case "Warning" :
					MCFI.warning.text = "";
					clear_icon();
					break;
				case "All" :
					MCFI.input_area.text = "";
					MCFI.warning.text = "";
					clear_icon();
					break;
			}

			function clear_icon():void
			{
				if (Boolean(ANI_ICON))
				{
					ANI_ICON.RESET();
				}
			}
		}
		public function SEEN_AS_PASSWORD(Password_Type:Boolean = true):void
		{
			if (Password_Type)
			{
				MCFI.input_area.displayAsPassword = true;
			}
			else
			{
				MCFI.input_area.displayAsPassword = false;
			}
		}
		public function START_AUTO_CHECKING():void
		{
			MCFI.addEventListener(KeyboardEvent.KEY_DOWN, auto_check);
		}
		public function STOP_AUTO_CHECKING():void
		{
			MCFI.removeEventListener(KeyboardEvent.KEY_DOWN, auto_check);
		}
		public function SET_REMINDER(Active:Boolean = true):void
		{
			if (Boolean(MCFI.reminder_list))
			{
				if (Active && Boolean(memory.length))
				{
					ListAccImpl.enableAccessibility();
					MCFI.input_area.doubleClickEnabled = true; 
					MCFI.input_area.addEventListener(MouseEvent.DOUBLE_CLICK, open_reminder);
					MCFI.input_area.addEventListener(KeyboardEvent.KEY_DOWN, auto_reminder);
					MCFI.input_area.addEventListener("focusOut", focus_out_from_input);
					MCFI.reminder_list.addEventListener(Event.CHANGE, get_reminder_list);
					MCFI.reminder_list.addEventListener("focusOut", focus_out_from_list);
				}
				else 
				{
					MCFI.input_area.doubleClickEnabled = false; 
					MCFI.input_area.removeEventListener(MouseEvent.DOUBLE_CLICK, open_reminder);
					MCFI.input_area.removeEventListener(KeyboardEvent.KEY_DOWN, auto_reminder);
					MCFI.input_area.removeEventListener("focusOut", focus_out_from_input);
					MCFI.reminder_list.removeEventListener(Event.CHANGE, get_reminder_list);
					MCFI.reminder_list.removeEventListener("focusOut", focus_out_from_list);
				}
			}
			else
			{
				Console.PRINT("FormInput", "- ERROR > ERROR CODE : 0027 > " + MCFI.name + ".reminder_list object is not found", 3, "");
			}
		}
		public function SET_TAB_INDEX(New_Tab_Index:Number):void
		{
			if (New_Tab_Index == -1)
			{
				MCFI.tabChildren = false;
			}
			else
			{
				// -> Arrow Keys ile liste kontrolü geliştirilebilir.
				MCFI.input_area.tabIndex = New_Tab_Index;
				//MCFI.reminder_list.tabIndex = TAB_INDEX + 0.5;
			}
		}
		public function SET_FOCUSING(Active:Boolean):void
		{
			if (Active)
			{
				MCFI.input_area.addEventListener("focusIn", focus_in);
				MCFI.addEventListener("focusOut", focus_out);
			}
			else
			{
				MCFI.input_area.removeEventListener("focusOut", focus_out);
				MCFI.removeEventListener("focusOut", focus_out);
			}
			
			function focus_in(e:Event):void
			{
				SET_FILTER(1);
			}
			
			function focus_out(e:Event):void
			{
				if (anim == "No")
				{
					SET_FILTER(0);
				}
				else
				{
					SET_ANIMATION(anim);
				}
			}
		}
		public function SET_FILTER(Filter_Number:int):void
		{
			var glow:GlowFilter = new GlowFilter(); 
			glow.blurX = 8; 
			glow.blurY = 8; 
			glow.quality = 2;
			glow.alpha = 0.6;
			
			if (Filter_Number)
			{
				switch (Filter_Number)
				{
					case 1:
						glow.color = 0x0099FF; 
						break;
					case 2:
						glow.color = 0x009900; 
						break;
					case 3:
						glow.color = 0xFF0000; 
						break;
				}
				
				MCFI.input_area.filters = [glow];
			}
			else
			{
				MCFI.input_area.filters = null;
			}
		}
		public function SET_ANIMATION(ANIM:String):void
		{
			anim = ANIM;
			
			switch (anim)
			{
				case "No":
					ANI_ICON.RESET();
					SET_FILTER(0);
					break;
				case "Progress":
					ANI_ICON.ANIMATE("Progress", "Endless");
					SET_FILTER(1);
					break;
				case "Ok":
					ANI_ICON.ANIMATE("Tick");
					SET_FILTER(2);
					break;
				case "Wrong":
					ANI_ICON.ANIMATE("Wrong");
					SET_FILTER(3);
					break;
			}
		}

		// ----------------------------------------------------------------
		// PRIVATE FUNCTIONS:
		// ----------------------------------------------------------------

		private function conclude_test(Feedback:Object):void
		{
			status_checking = false;

			if (Boolean(Feedback.callback))
			{
				try
				{
					Feedback.callback(Feedback);
				}
				catch (e:Error)
				{
					Console.PRINT("FormInput", "- ERROR > ERROR CODE: 0028 > There is a problem on Respond Callback Function on conclude_test!", 3, "");
				}

				die_feedback();
			}
		}
		private function open_reminder(e:MouseEvent):void
		{
			MCFI.reminder_list.removeAll();
			var list_height:int = 0;
							
			for (var i:int; i < memory.length; i ++)
			{
				MCFI.reminder_list.addItem({label:memory[i], data:memory[i]})
				list_height ++;
			}
			
			if (Boolean(list_height))
			{
				MCFI.reminder_list.height = Math.min((list_height * list_line_height), list_max_height);
				open_reminder_list(true);
			}
			else
			{
				open_reminder_list(false);
			}
		}
		private function auto_reminder(e:KeyboardEvent):void
		{
			if (e.keyCode !== 9)
			{
				if (!list_checking)
				{
					list_checking = true;
					var lcd_interval:uint = setInterval(check_input, LCD);
				}
				
				function check_input():void
				{
					if (GET_DATA() !== "" && (MCFI.parent.stage.focus == MCFI.input_area))
					{						
						MCFI.reminder_list.removeAll();
						
						var current_items:Array = Utility.SEARCH_ARRAY_ELEMENTS_BY_VALUE(memory, GET_DATA(), false);
						current_items.sort();
						var list_height:int = 0;
							
						for (var i:int; i < current_items.length; i ++)
						{
							MCFI.reminder_list.addItem({label:current_items[i], data:current_items[i]})
							list_height ++;
						}
						
						if (Boolean(list_height))
						{
							MCFI.reminder_list.height = Math.min((list_height * list_line_height), list_max_height);
							open_reminder_list(true);
						}
						else
						{
							open_reminder_list(false);
						}
					}
					else
					{
						open_reminder_list(false);
					}
					
					clearInterval(lcd_interval);
					list_checking = false;
				}
			}
		}
		private function get_reminder_list(e:Event):void
		{
			PRINT("Input", e.target.selectedItem.data);
			open_reminder_list(false);
			CHECK();
		}
		private function focus_out_from_list(e:Event):void
		{
			if(MCFI.parent.stage.focus !== MCFI.input_area)
			{
				open_reminder_list(false);
			}
		}
		private function focus_out_from_input(e:Event):void
		{
			if(MCFI.parent.stage.focus !== MCFI.reminder_list)
			{
				open_reminder_list(false);
			}
		}
		private function open_reminder_list(Open:Boolean):void
		{
			if (Open)
			{
				Utility.SET_STAGE_DEEPTH([MCFI],true);
				MCFI.reminder_list.visible = true;
			}
			else
			{
				Utility.SET_STAGE_DEEPTH([MCFI],false);
				MCFI.reminder_list.visible = false;
			}
		}
		private function auto_check(e:KeyboardEvent):void
		{
			if (! status_checking)
			{
				if (Boolean(RESPOND_CALLBACK))
				{
					ready_feedback();
					RESPOND_CALLBACK(Feedback);
				}
				acd_interval = setInterval(CHECK,ACD);
				status_checking = true;
			}
			else
			{
				trace("UYARI: Şu anda sorgu, gecikme aşamasında. ACD(Auto Checking Delay): " + ACD);
			}
		}
		private function ready_feedback():void
		{
			if (! Boolean(Feedback))
			{
				Feedback = new Object();
				Feedback.FI = this;
				Feedback.conclude = conclude_test;
				Feedback.name = MCFI.name;
				Feedback.result = "Progress";
				Feedback.value = "";
				
				if (Boolean(RESPOND_CALLBACK))
				{
					Feedback.callback = RESPOND_CALLBACK;
				}
			}
		}
		private function die_feedback():void
		{
			if (Boolean(Feedback))
			{
				Feedback = null;
			}
		}
	}
}