/*
	------------------------------------------------------------
	- BUTTON MODULE(C) 2013 - 2015 
	------------------------------------------------------------
	
	* DYNAMIC
	* INIT : Constructor
	
	v1.0 : 05.07.2013
	v1.1 : 07.07.2013
	v1.2 : 14.07.2013
	
	v2.0 : 16.08.2014
	v2.1 : 07.09.2014
	v2.2 : 01.03.2015 : ANIM’ler için daha iyi bir buton etkileşimi için “ACTIVE_AREA” eklendi.
	
	v3.0 : 08.02.2015 : 
		Eklenen yeni özellikler:
		1. Sınıf yeniden yapılandırıldı. 2015 algoritma standartlarıyla daha okunabilir, geliştirilebilir ve esnek bir sınıf haline getirildi.
		2. Gruplar arası etkileşim algortiması "Access" sınıfına devredildi. Böylece, sınıfın komplex algortma yükü azaltılırken, ilk kez bu sınıf için üretilen orjinal "IGIL" algoritması diğer sınıflar için de kullanılabilir hale getirildi.
		3. Yeni eklenen "DATA" nesnesi ile artık "MISSION" fonksiyonu için, "LABEL" özelliğinden bağımsız değerler girilebileceksiniz. Böylece butonların runtime da görevleri esnetilebilecek ve çok daha karmaşık görevleri yerine getirebilecek. 
		4. "PUSH()" metodu eklendi.
		5. "TAB_INDEX" özelliği ile "TAB" tuşuna duyarlı butonlar yapmak artık mümkün.
		6. Daha önceden rapor edilen SET_LABEL() hatası düzeltildi.
	v3.1 : 10.02.2015 : SET_LABEL() metodu üzerinde yapılan değişikliklerle, artık "RBM ANIM"'lerinde "LABEL" kullanma zorunluluğu ortadan kalktı. Ayrıca "Behaviour" parametreleri standart yazıma getirildi. "Switch" davranışında değişikliğe gidildi.
	
	v4.0 : 22.02.2015 : 
		Eklenen yeni özellikler:
		1. Sınıf ismi eskiden "RadioButtonModule" iken "ButtonModule" olarak değiştirildi. Çünkü, artık bütün butonların yerine bu sınıf kullanılabilecek.
		2. Eski "Simple" davranışı artık "simpleButton" davranışı şeklinde düzenlendi. 
		3. Eskiden "Simple" olarak kullanılan davranış ise "Tab" davranışı olarak yeniden düzenlendi. 
		4. Yeni "MOUSE_UP" olay dinleyicisi eklendi. 
		5. Yeni "Multi Mission" özelliği ile DATA nesnesine Mouse olaylarına yönelik özel komutlar girebileceksiniz. Yani buton sadece CLICK için değil, diğer olaylarda da eylemlerde bulunabilecek.
		6. IGIL desteği opsiyonel duruma getirildi. Simple ve Switch davranışları için IGIL desteğinin bulunması anlamsız olduğundan bu iyileştirme, bu davranışlar için performans artışı sağlandı.
		7. mcBM standart testi eklenerek sınıf kullanım güvenliği arttırıldı.
		
	v4.1 : 12.02.2015 : 'id' ve 'no' özellikleri belirlendi.
	
	GELİŞTİRMELER:	- İsim güncelle. (-> UIButton)
					- Static duruma getir.
					- Animator.as entegrasyonu sağla.
					- Resim ve Label özellikleri dynamic, kolaylıkla ulaşılabilir olmalı. (Örneğin: Yalnızca ikon şeklinde butonlar yapmak çok kolay olmalı)
	
	by Samet Baykul

*/

package lbl
{
	// Flash Library:
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.display.MovieClip;
	// LBL Core:
	import lbl.Access;
	import lbl.Utility;
	

	public class ButtonModule
	{
		// ------------------------------------------------------------
		// ÖZELLİKLER:
		// ------------------------------------------------------------

		public var MC_BM:MovieClip;
		public var MISSION:Function;
		public var DATA:Object;
		public var LOCK_ALPHA:Number = 0.7;
		public var PUSHED:Boolean;
		public var GRUP:String;
		public var LABEL:String;
		public var KILIT:Boolean;
		
		private var group_list:Array = new Array ();
		private var behaviour:String;
		private var varsayilan:Object;
		private var index_in_group:int;
		
		// Class Info:
		private static var id:String = "BTN";
		private static var no:int = 001;
		
		public function ButtonModule(MC_ButtonModule:MovieClip, Mission:Function, Data:Object, Label:String = "", Group:String = "No", Behaviour:String = "Simple", Tab_Index:Number = -1, Default_Button:Boolean=false, Lock:Boolean=false)
		{
			MC_BM = MC_ButtonModule;
			MISSION = Mission;
			DATA = Data;
			LABEL = Label;
			GRUP = Group;
			KILIT = Lock;
			
			behaviour = Behaviour;
			varsayilan = Default_Button;
		
			init_mc_BM_standarts();
			init_pushed();
			
			if (Group !== "No")
			{
				index_in_group = Access.ADD_TO_IGIL("BM", Group, this);
				group_list = Access.IGIL["BM"][Group];
			}
			else
			{
				index_in_group = 0;
				group_list = [this];
			}
			
			SET_TAB_INDEX(Tab_Index);
			SET_LABEL(Label);
			LOCK(KILIT);
			
			function init_mc_BM_standarts():void
			{
				if (!Boolean(MC_BM.ACTIVE_AREA))
				{
					Console.PRINT("ButtonModule", "X ERROR > ERROR CODE : 0025 > mcBM must have an 'ACTIVE_AREA'. This mcBM is '" + MC_BM.name + "'.", 3, "");
				}
				
			}
			function init_pushed():void
			{
				reset_anim();
				
				if (varsayilan)
				{
					PUSHED = true;
					MC_BM.ANIM_S.visible = true;
				}
				else
				{
					PUSHED = false;
					MC_BM.ANIM_NS.visible = true;
				}
			}
		}

		// ------------------------------------------------------------
		// METHODS:
		// ------------------------------------------------------------

		public function PUSH():void
		{
			do_mission();
		}

		public function SET_PUSHED(Aktiflik:Boolean):void
		{
			if (Aktiflik)
			{
				PUSHED = true;
				through_group("update_anims");
			}
			else
			{
				PUSHED = false;
				through_group("update_anims");
			}
		}

		public function SET_LABEL(New_Label:String, Particular_Label:Array = null):void
		{
			if (Particular_Label)
			{
				for (var i:int = 0; i < Particular_Label.length; i++)
				{
					MC_BM[[Particular_Label][i]].LABEL.text = New_Label;
				}
			}
			else
			{
				
				for (var j:uint = 0; j < MC_BM.numChildren; j++)
				{
					if (MC_BM.getChildAt(j) is MovieClip)
					{
						if(MC_BM.getChildAt(j)["LABEL"])
						{
							MC_BM.getChildAt(j)["LABEL"].text = New_Label;
						}
					}
				}
			}
		}

		public function LOCK(Lock:Boolean):void
		{
			KILIT = Lock;
			
			if (KILIT)
			{
				MC_BM.alpha = LOCK_ALPHA;
				MC_BM.ACTIVE_AREA.removeEventListener(MouseEvent.MOUSE_OVER,btn_over);
				MC_BM.ACTIVE_AREA.removeEventListener(MouseEvent.MOUSE_OUT,btn_out);
				MC_BM.ACTIVE_AREA.removeEventListener(MouseEvent.MOUSE_DOWN,btn_down);
				MC_BM.ACTIVE_AREA.removeEventListener(MouseEvent.MOUSE_UP,btn_up);
				MC_BM.ACTIVE_AREA.removeEventListener(MouseEvent.CLICK,btn_gorev);
			}
			else
			{
				MC_BM.alpha = 1;
				MC_BM.ACTIVE_AREA.addEventListener(MouseEvent.MOUSE_OVER,btn_over);
				MC_BM.ACTIVE_AREA.addEventListener(MouseEvent.MOUSE_OUT,btn_out);
				MC_BM.ACTIVE_AREA.addEventListener(MouseEvent.MOUSE_DOWN,btn_down);
				MC_BM.ACTIVE_AREA.addEventListener(MouseEvent.MOUSE_UP,btn_up);
				MC_BM.ACTIVE_AREA.addEventListener(MouseEvent.CLICK,btn_gorev);
			}
		}
		
		public function SET_TAB_INDEX(New_Tab_Index:Number):void
		{
			if (New_Tab_Index == -1)
			{
				MC_BM.tabChildren = false;
			}
			else
			{
				MC_BM.tabIndex = New_Tab_Index;
			}
		}

		// ------------------------------------------------------------
		// FUNCTIONS:
		// ------------------------------------------------------------

		// -> BUTON OLAYLARI İNCE AYAR: Buton olaylarına buradan ince ayar yapılabilir:
		// -> YENİ BUTON DAVRANIŞLARI: Butonların kendi aralarında yeni davranışlara sahip olması mümkün.
		
		// Mouse olaylarına verilecek tepkilerin belirlenmesi: btn_over, btn_out, btn_down, btn_gorev
		// ------------------------------------------------------------
		private function btn_over(event:MouseEvent):void
		{
			reset_anim();
			do_mouse_event_mission("OVER");
			
			switch (behaviour)
			{
				case "Simple" :
					pos_over(PUSHED);
					break;
				case "Switch" :
					pos_over(PUSHED);
					break;
				case "Tab" :
					pos_over(PUSHED);
					break;
				case "Rise" :
					pos_over(PUSHED);
					through_group("update_anims_over_until_index");
					break;
			}
		}
		private function btn_out(event:MouseEvent):void
		{
			reset_anim();
			do_mouse_event_mission("OUT");
			
			switch (behaviour)
			{
				case "Simple" :
					pos_out(PUSHED);
					break;
				case "Switch" :
					pos_out(PUSHED);
					break;
				case "Tab" :
					pos_out(PUSHED);
					break;
				case "Rise" :
					pos_out(PUSHED);
					through_group("update_anims_out_until_index");
					break;
			}
		}
		private function btn_down(event:MouseEvent):void
		{
			reset_anim();
			do_mouse_event_mission("DOWN");
			
			switch (behaviour)
			{
				case "Simple" :
					pos_down(PUSHED);
					break;
				case "Switch" :
					pos_down(PUSHED);
					break;
				case "Tab" :
					pos_down(PUSHED);
					break;
				case "Rise" :
					pos_down(PUSHED);
					through_group("update_anims_down_until_index");
					break;
			}
		}
		private function btn_up(event:MouseEvent)
		{
			reset_anim();
			do_mouse_event_mission("UP");
			
			switch (behaviour)
			{
				case "Simple" :
					pos_up(PUSHED);
					break;
				case "Switch" :
					pos_up(PUSHED);
					break;
				case "Tab" :
					pos_up(PUSHED);
					break;
				case "Rise" :
					pos_up(PUSHED);
					through_group("update_anims_up_until_index");
					break;
			}
		}
		private function btn_gorev(event:MouseEvent)
		{
			if (Utility.TEST_OBJECT_STANDART(DATA,["CLICK"]))
			{
				MISSION(DATA["CLICK"]);
			}
			else
			{
				do_mission();
			}
		}
		
		// -> ANIM DÜZENLEME ARAÇLARI:
		// Buton tıklandığında görevin nasıl yapılacağını düzenler:
		private function do_mission():void
		{
			switch (behaviour)
			{
				case "Simple" :
					MISSION(DATA);
					break;
				case "Switch" :
					if (PUSHED)
					{
						PUSHED = false;
						through_group("update_anims");
						MISSION(DATA);
					}
					else
					{
						PUSHED = true;
						through_group("update_anims");
						MISSION(DATA);
					}
					break;
				case "Tab" :
					through_group("all_btn_unpushed");
					PUSHED = true;
					through_group("update_anims");
					MISSION(DATA);
					break;
				case "Rise" :
					if (PUSHED)
					{
						through_group("all_btn_unpushed");
						through_group("btn_pushed_until_index");
						through_group("update_anims");
						MISSION(DATA);
					}
					else
					{
						through_group("btn_pushed_until_index");
						through_group("update_anims");
					}
					break;
			}
		}
		private function do_mouse_event_mission(Mouse_Event:String):void
		{
			if (Utility.TEST_OBJECT_STANDART(DATA,[Mouse_Event]))
			{
				MISSION(DATA[Mouse_Event]);
			}
		}
		
		// Geçerli "mcBM" düzenleme fonksiyonları:
		private function pos_over(aktif_mi:Boolean):void
		{
			if (aktif_mi)
			{
				MC_BM.ANIM_SO.visible = true;
			}
			else
			{
				MC_BM.ANIM_NSO.visible = true;
			}
		}
		private function pos_out(aktif_mi:Boolean):void
		{
			if (aktif_mi)
			{
				MC_BM.ANIM_S.visible = true;
			}
			else
			{
				MC_BM.ANIM_NS.visible = true;
			}
		}
		private function pos_down(aktif_mi:Boolean):void
		{
			if (aktif_mi)
			{
				MC_BM.ANIM_SD.visible = true;
			}
			else
			{
				MC_BM.ANIM_NSD.visible = true;
			}
		}
		private function pos_up(aktif_mi:Boolean):void
		{
			if (aktif_mi)
			{
				MC_BM.ANIM_SO.visible = true;
			}
			else
			{
				MC_BM.ANIM_NSO.visible = true;
			}
		}
		private function reset_anim():void
		{
			MC_BM.ANIM_NS.visible = false;
			MC_BM.ANIM_NSD.visible = false;
			MC_BM.ANIM_NSO.visible = false;

			if (MC_BM.ANIM_S)
			{
				MC_BM.ANIM_S.visible = false;
			}
			if (MC_BM.ANIM_SD)
			{
				MC_BM.ANIM_SD.visible = false;
			}
			if (MC_BM.ANIM_SO)
			{
				MC_BM.ANIM_SO.visible = false;
			}
		}
		
		// GRUP düzenleme fonksiyonları:
		private function through_group(What_to_Do):void
		{
			switch (What_to_Do)
			{
				case "all_btn_pushed":
					group_list.forEach(all_btn_pushed);
					break;
				case "all_btn_unpushed":
					group_list.forEach(all_btn_unpushed);
					break;
				case "btn_pushed_until_index":
					group_list.forEach(btn_pushed_until_index);
					break;
				case "update_anims":
					group_list.forEach(update_anims);
					break;
				case "update_anims_over_until_index":
					group_list.forEach(update_anims_over_until_index);
					break;
				case "update_anims_out_until_index":
					group_list.forEach(update_anims_out_until_index);
					break;
				case "update_anims_down_until_index":
					group_list.forEach(update_anims_down_until_index);
					break;
				case "update_anims_up_until_index":
					group_list.forEach(update_anims_up_until_index);
					break;
			}

		}
		
		// "PUSHED" düzenleme fonksiyonları:
		private function all_btn_pushed(element:Object, index:int, arr:Array):void
		{
			element.PUSHED = true;
		}
		private function all_btn_unpushed(element:Object, index:int, arr:Array):void
		{
				element.PUSHED = false;
		}
		private function btn_pushed_until_index(element:Object, index:int, arr:Array):void
		{
				if (index <= index_in_group)
				{
					element.PUSHED = true;
				}
			}
			
		// "ANIM" düzenleme fonksiyonları:
		private function update_anims(element:Object, index:int, arr:Array):void
		{
			element.reset_anim();
			
			if (element.PUSHED)
			{
				if (behaviour !== "Simple")
				{
					element.MC_BM.ANIM_S.visible = true;
				}
			}
			else
			{
				element.MC_BM.ANIM_NS.visible = true;
			}
		}
		private function update_anims_over_until_index(element:Object, index:int, arr:Array):void
		{
			element.reset_anim();
			
			if (index <= index_in_group)
			{
				if (element.PUSHED)
				{
					element.MC_BM.ANIM_SO.visible = true;
				}
				else
				{
					element.MC_BM.ANIM_NSO.visible = true;
				}
			}
		}
		private function update_anims_out_until_index(element:Object, index:int, arr:Array):void
		{
			element.reset_anim();
			
			if (element.PUSHED)
			{
				element.MC_BM.ANIM_S.visible = true;
			}
			else
			{
				element.MC_BM.ANIM_NS.visible = true;
			}
		}
		private function update_anims_down_until_index(element:Object, index:int, arr:Array):void
		{
			element.reset_anim();
			
			if (index <= index_in_group)
			{
				if (element.PUSHED)
				{
					element.MC_BM.ANIM_SD.visible = true;
				}
				else
				{
					element.MC_BM.ANIM_NSD.visible = true;
				}
			}
		}
		private function update_anims_up_until_index(element:Object, index:int, arr:Array):void
		{
			element.reset_anim();
			
			if (index <= index_in_group)
			{
				if (element.PUSHED)
				{
					element.MC_BM.ANIM_SO.visible = true;
				}
				else
				{
					element.MC_BM.ANIM_NSO.visible = true;
				}
			}
		}
		
	}
}