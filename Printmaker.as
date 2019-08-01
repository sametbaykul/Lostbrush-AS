/*

	------------------------------------------------------------
	- PRINTMAKER(C) 2015 - 2016
	------------------------------------------------------------

	* FULL STATIC
	* INIT : no

	v1.0 : 12.08.2015 : Görsel nesneler için pratik grafikler oluşturmak amacıyla üretilmiştir. 
	v1.1 : 03.09.2015 : GET_STYLE() metodu eklendi. Bu metod ile style nesnelerini daha çabuk ve doğru bir şekilde oluşturabilirsiniz.
	v1.2 : 04.09.2015 : Tag özelliği ile artık etiketlere göre işlem yapılabilecek.
	
	v2.0 : 06.09.2015 : SIO nesnesi eklenerek daha esnek ve kararlı bir algoritma sağlandı.
	v2.1 : 12.02.2016 : 'id' ve 'no' özellikleri belirlendi.
	v2.2 : 13.02.2016 : GET_COLOR() metodu ile bazı renklere ait hax değerlerini alabilirsiniz.

	GELİŞTİRMELER:	- İsim güncelle.

	by Samet Baykul

*/

package lbl
{
	// Flash Library:
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Graphics;
	// LBL Control:
	import lbl.Console;

	public class Printmaker
	{

		// ------------------------------------------------------------
		// PROPERTIES :
		// ------------------------------------------------------------
		
		private static var SIO_list:Array = new Array();					// Shape Info Objects List
		private static var color_list:Array = new Array();
				
		// Class Info:
		private static var id:String = "PRI";
		private static var no:int = 017;

		public function Printmaker()
		{
			// Full static class
		}
		
		// ------------------------------------------------------------
		// METHODS :
		// ------------------------------------------------------------
		
		public static function DRAW_LINE(Canvas:MovieClip, Position:Array, Name:String = null, Dynamic_Name:Boolean = false, Tags:Array = null, Style_Object:Object = null):void
		{
			draw_shape(create_SIO("Line", Canvas, Name, Dynamic_Name, Tags, Style_Object));
			
			function draw_shape(Graphic_Shape:Shape):void
			{
				Graphic_Shape.graphics.moveTo(Position[0], Position[1]); 
				Graphic_Shape.graphics.lineTo(Position[2], Position[3]); 
				Graphic_Shape.graphics.endFill();
			}
		}
		
		public static function DRAW_CIRCLE(Canvas:MovieClip, Position:Array, Radius:Number, Name:String = null, Dynamic_Name:Boolean = false, Tags:Array = null, Style_Object:Object = null):void
		{
			draw_shape(create_SIO("Circle", Canvas, Name, Dynamic_Name, Tags, Style_Object));
			
			function draw_shape(Graphic_Shape:Shape):void
			{
				Graphic_Shape.graphics.drawCircle(Position[0], Position[1], Radius);
			}
		}

		public static function CLEAR(Shape_Names:Array):void
		{
			for (var i:int; i < Shape_Names.length; i ++)
			{
				if (Boolean(SIO_list[Shape_Names[i]]))
				{
					SIO_list[Shape_Names[i]].shape.graphics.clear();
					SIO_list[Shape_Names[i]].canvas.removeChild(SIO_list[Shape_Names[i]].shape);
					
					delete SIO_list[Shape_Names[i]];
				}
			}
		}
		
		public static function CLEAR_BY_TAGS(Tags:Array):void
		{
			UPDATE_SHAPES(clear_shape, Tags);
			
			function clear_shape(Param:Object):void
			{
				CLEAR([Param.name]);
			}
		}
		
		public static function CLEAR_ALL():void
		{
			CLEAR_BY_TAGS(["Common"]);
		}
		
		public static function UPDATE_SHAPES(RC:Function, Tags:Array = null, Names:Array = null):void
		{
			var to_update_shape_list:Array = new Array();
			
			if (Boolean(Tags))
			{
				to_update_shape_list = get_SIO_by_tags(Tags);
			}
			
			if (Boolean(Names))
			{
				for (var i:int; i < Names.length; i ++)
				{
					if (get_SIO_by_name(Names[i]))
					{
						to_update_shape_list.push(get_SIO_by_name(Names[i]));
					}
				}
			}
			
			for (var j:int; j < to_update_shape_list.length; j ++)
			{
				try
				{
					RC(to_update_shape_list[j]);
				}
				catch(e:Error)
				{
					Console.PRINT("Printmaker","X ERROR > ERROR CODE : XXXX > An error occured while UPDATE_SHAPES RC function. Please check it.",3,"");
					Console.PRINT("Printmaker","- ERROR DETAIL > " + e.getStackTrace(),2,"");
				}
				
			}
		}
		
		public static function GET_STYLE():Object
		{
			var SO:Object = new Object();
			
			SO.thickness = 1;
			SO.color = 0x000000; 
			SO.alpha = 1;
			SO.pixelHinting = false;
			SO.scaleMode = "none";
			SO.caps = null;
			SO.joints = null;
			SO.miterLimit = 3;
			
			return SO;
		}
		
		public static function GET_COLOR(Color_Name:String):uint
		{
			var hax:uint;

			switch (Color_Name)
			{
				case "Black":
					hax = 0x000000;
					break;
				case "Gray3":
					hax = 0x333333;
					break;
				case "Gray6":
					hax = 0x666666;
					break;
				case "Gray9":
					hax = 0x999999;
					break;
				case "GrayC":
					hax = 0xCCCCCC;
					break;
				case "White":
					hax = 0xFFFFFF;
					break;
				case "Red":
					hax = 0xFF0000;
					break;
				case "Green":
					hax = 0x00FF00;
					break;
				case "Blue":
					hax = 0x0000FF;
					break;
				case "Yellow":
					hax = 0xFFFF00;
					break;
				case "LightBlue":
					hax = 0x00FFFF;
					break;
				case "Purple":
					hax = 0xFF00FF;
					break;
				default:
					
					break;
			}
			
			return hax;
		}
		
		// ------------------------------------------------------------
		// FUNCTIONS :
		// ------------------------------------------------------------
		
		private static function create_SIO(Shape_Type:String, Canvas:MovieClip, Name:String = null, Dynamic_Name = false, Tags:Array = null, Style_Object:Object = null):Shape
		{
			var SIO:Object = new Object();
			
			start_SIO();
			arrange_name();
			arrange_tags();
			
			set_style(SIO.shape, Style_Object);
			SIO_list[SIO.name] = SIO;
			Canvas.addChild(SIO.shape);
			
			return SIO.shape;
			
			function start_SIO():void
			{
				SIO.tags = new Array();
				SIO.shape = new Shape();
				SIO.canvas = Canvas;
				SIO.style = Style_Object;
			}
			function arrange_name():void
			{
				if (!Boolean(Name))
				{	
					SIO.name = Shape_Type + "_" + SIO_list.length;
				}
				else
				{
					if (Dynamic_Name)
					{
						var name_group_index:int;
						
						for (var key:String in SIO_list)
						{
							if (Utility.SEARCH_TEXT(key, Name))
							{
								name_group_index++;
							}
						}
						
						SIO.name = Name + String("_" + name_group_index);
					}
					else
					{
						SIO.name = Name;
					}
				}
				
				if (Boolean(SIO_list[SIO.name]))
				{
					CLEAR([SIO.name]);
				}
			}
			function arrange_tags():void
			{
				if (Boolean(Tags))
				{	
					SIO.tags = Tags;
				}
				
				SIO.tags.push("Common", Shape_Type);
			}
		}
		private static function get_SIO_by_tags(Tags:Array):Array
		{
			var result:Array = new Array();
			
			for (var Name:String in SIO_list)
			{
				if (Utility.TEST_ARRAY_ELEMENTS(SIO_list[Name].tags, Tags))
				{
					result.push(SIO_list[Name]);
				}
			}
			
			return result;
		}
		private static function get_SIO_by_name(Name:String):Object
		{
			if (Boolean(SIO_list[Name]))
			{
				return SIO_list[Name];
			}
			else
			{
				return null;
			}
		}
		private static function set_style(shape:Shape, Style_Object:Object = null):void
		{
			if (Boolean(Style_Object))
			{
				shape.graphics.lineStyle(Style_Object.thickness, Style_Object.color, Style_Object.alpha, Style_Object.pixelHinting, Style_Object.scaleMode, Style_Object.caps, Style_Object.joints, Style_Object.miterLimit);
			}
			else
			{
				shape.graphics.lineStyle(1, 0x000000);
			}
		}
	}
}