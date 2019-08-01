/*

	------------------------------------------------------------
	- CAPTCHA(C) 2014 
	------------------------------------------------------------
	
	* DYNAMIC
	* INIT : Constructor
	
	v1.0 : 12.09.2014
	v1.1 : 01.02.2015 : Sınıf globalleştirildi.
	v1.2 : 14.02.2015 : SET_TAB_INDEX() Metodu eklendi.
	v1.3 : 24.02.2015 : "simpleButton" ButtonModule örneği ile değiştirildi.
	v1.4 : 12.02.2015 : 'id' ve 'no' özellikleri belirlendi.
	
	by Samet Baykul

*/

package lbl
{
	// Flash Library:
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import flash.text.TextFieldType;
	// LBL UI:
	import lbl.ButtonModule;

	public class Captcha extends MovieClip
	{
		public var MC_CAPTCHA:MovieClip;
		
		private var BM_refresh:ButtonModule;
		private var deger:String = new String();
		// -> Fine Tunning
		private var max_char:uint = 5;
		private var color_a:uint = 0xFFFFFF; // Actif state rengi
		private var color_p:uint = 0x999999; // Pasif state rengi

		// Class Info:
		private static var id:String = "CAP";
		private static var no:int = 007;
		
		public function Captcha(MC_Captcha:MovieClip, Tab_Index:Number = -1):void
		{
			MC_CAPTCHA = MC_Captcha;
			
			init_BM();
			NEW_CAPTCHA();
			SET_TAB_INDEX(Tab_Index);
			
			function init_BM():void
			{
				BM_refresh = new ButtonModule(MC_CAPTCHA.mcBM_refresh_captcha, yenile, "ok");
			}
		}
		
		public function NEW_CAPTCHA():void
		{
			MC_CAPTCHA.input_captcha.text = "";
			deger = "";
			BM_refresh.LOCK(false);

			var random_code:int;

			for (var i = 0; i < max_char; i++)
			{
				random_code = Math.random() * 61;

				if (random_code < 10)
				{
					deger += String.fromCharCode(uint(random_code + 48));
				}
				else if (random_code >= 10 && random_code < 36)
				{
					deger += String.fromCharCode(uint(random_code + 55));
				}
				else if (random_code >= 36 && random_code < 184)
				{
					deger += String.fromCharCode(uint(random_code + 61));
				}
			}
			MC_CAPTCHA.mc_captcha_image.captcha_text.text = deger;
			MC_CAPTCHA.mc_captcha_image.cacheAsBitmap = true;
		}
		
		public function CHECK():Boolean
		{
			if (MC_CAPTCHA.input_captcha.text == deger)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
		public function SET_ACTIVE(Active:Boolean = true):void
		{
			var text_format:TextFormat = new TextFormat();		
			
			if (Active)
			{
				text_format.color = color_a;
				MC_CAPTCHA.input_captcha.type = TextFieldType.INPUT;
				BM_refresh.LOCK(false);
			}
			else
			{
				text_format.color = color_p;
				MC_CAPTCHA.input_captcha.type = TextFieldType.DYNAMIC;
				BM_refresh.LOCK(true);
			}
			
			MC_CAPTCHA.input_captcha.setTextFormat(text_format);
		}
		
		public function STOP():void
		{
			BM_refresh.LOCK(true);
		}
		
		public function SET_TAB_INDEX(New_Tab_Index:Number):void
		{
			if (New_Tab_Index == -1)
			{
				MC_CAPTCHA.tabChildren = false;
			}
			else
			{
				MC_CAPTCHA.input_captcha.tabIndex = New_Tab_Index;
			}
		}

		private function yenile(Respond:Object):void
		{
			NEW_CAPTCHA();
		}
	}
}