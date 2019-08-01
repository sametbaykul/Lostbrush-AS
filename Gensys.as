/*

	------------------------------------------------------------
	- GENSYS(C) 2015 - 2016
	------------------------------------------------------------
	
	* FULL STATIC
	* INIT : true
	
	v1.0 : 05.03.2015 : Genel sistem değişkenleri ve ayarları için tasarlanmıştır.
	v1.1 : 12.02.2016 : 'id' ve 'no' özellikleri belirlendi.
	v1.2 : 23.04.2016 : TIMER yapısı güncellendi. Artık Gensys.as, diğer çekirdek sınıflara daha esnek bir zamanlayıcı desteği verebiliyor. Ayrıca benzer metodlar gruplandırıldı.
	
	GELİŞTİRMELER:	- Açılış programlarının bir araya toplanması.
					- FrameRate göstergesi.
					- TotalMemory göstergesi.
					- focus manager eklenebilir.
					- Sağ click menüsü düzenlemesini destekle.

	by Samet Baykul
	
*/

package lbl
{
	// Flash Library:
	import flash.display.Stage;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.filters.BlurFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.utils.Timer;
	import flash.utils.ByteArray;
	// External Library:
	import by.blooddy.crypto.Base64;
	import by.blooddy.crypto.image.JPEGEncoder;
	// LBL Control:
	import lbl.Console;


	public class Gensys
	{
		public static var STAGE:Stage;
		public static var FRAME_RATE:uint;
		public static var TIMEL:Array;

		// Class Info:
		private static var id:String = "GEN";
		private static var no:int = 014;
		
		public function Gensys():void
		{
			// Full static class
		}

		public static function INIT(Sahne:Stage):void
		{
			TIMEL = new Array();
			
			STAGE = Sahne;
			FRAME_RATE = STAGE.frameRate;
			
			NEW_TIMER("Global");
		}
		
		public static function START_TIMER():void
		{
			for each (var TIMER in TIMEL)
			{
				TIMER.start();
			}
		}
		public static function STOP_TIMER():void
		{
			for each (var TIMER in TIMEL)
			{
				TIMER.stop();
			}
		}
		public static function NEW_TIMER(Timer_Link:String, Delay:uint = 0):Timer
		{
			if (!Boolean(TIMEL[Timer_Link]))
			{
				if (Delay == 0)
				{
					TIMEL[Timer_Link] = new Timer(1000 / FRAME_RATE);
				}
				else
				{
					TIMEL[Timer_Link] = new Timer(Delay);
				}
			}
			else
			{
				trace("zaten bu timer var");
			}
			
			return TIMEL[Timer_Link];
		}
		public static function DELETE_TIMER(Timer_Link:String):void
		{
			TIMEL[Timer_Link].stop();
			
			delete TIMEL[Timer_Link];
			
			Utility.COMPRESS_ARRAY(TIMEL);
		}

		public static function SET_FR(New_Value:uint):void
		{
			FRAME_RATE = New_Value;
			
			for each (var TIMER in TIMEL)
			{
				TIMER.delay = 1000 / FRAME_RATE;
			}
		}
		public static function GET_FOCUS():Object
		{
			return STAGE.focus;
		}
		public static function EXPORT_SCREENSHOT(Sahne:Stage):String
		{
			var scale:Number = 0.25;
			var result:String = null;
			
			var blur_filter:BlurFilter = new BlurFilter(3,3,BitmapFilterQuality.HIGH);
			var bitmap_data:BitmapData = new BitmapData(Sahne.stageWidth * scale, Sahne.stageHeight * scale, false, 0x0);
			var matrix:Matrix = new Matrix();
			
			matrix.scale(scale, scale);
			bitmap_data.draw(Sahne, matrix);
			bitmap_data.applyFilter(bitmap_data, bitmap_data.rect, new Point(0, 0), blur_filter);

			var jpeg_bytes:ByteArray = JPEGEncoder.encode(bitmap_data,80);
			
			if (jpeg_bytes)
			{
				var screenshot_Base64:String = Base64.encode(jpeg_bytes);
				
				if (screenshot_Base64)
				{
					result = screenshot_Base64;
				}
			}
			
			return result;
		}

	}

}