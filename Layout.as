/*

	------------------------------------------------------------
	- LAYOUT(C) 2016
	------------------------------------------------------------
	
	* FULL STATIC
	* INIT : no

	v1.0 : 06.03.2016 : Text nesnelerinde ve sahne alanında mizanpaj düzenlemelerini yapmak için üretildi.

	by Samet Baykul

*/

package lbl
{
	// LBL Core:
	import lbl.MathLab;
	// LBL Control:
	import lbl.Console;
	
	public class Layout
	{

		// ------------------------------------------------------------
		// PROPERTIES :
		// ------------------------------------------------------------
		
		public static var LAOL:Array = new Array();
				
		// Class Info:
		private static var id:String = "LAY";
		private static var no:int = 023;

		public function Layout()
		{
			// Full static class
		}
		
		// ------------------------------------------------------------
		// METHODS :
		// ------------------------------------------------------------
		
		public static function ADD_LAYOUT(Layout_Name:String, Verticals:Array, Horizontals:Array, Method:String = "Absolute", Dimensions:Array = null):void
		{
			var LAO:Object = new Object();
			
			if (check_params())
			{
				prepare_LAO();
				get_method();
				
				LAOL[LAO.name] = LAO;
				
				update_layout_cells(Layout_Name);
			}

			function check_params():Boolean
			{
				if (Method == "Proportional" && !Boolean(Dimensions))
				{
					return false;
					
					trace("Layout imcremental error!");
				}
				else
				{
					return true;
				}
			}
			function prepare_LAO():void
			{
				LAO.name = Layout_Name;
				LAO.cell_number = int((Verticals.length - 1) * (Horizontals.length - 1));
				
				LAO.cells = new Array();
				LAO.X = new Array();
				LAO.Y = new Array();
				LAO.dim = Dimensions;
				LAO.data = new Object();
			}
			function get_method():void
			{
				switch (Method)
				{
					case "Absolute":
						set_layout_abs();
						sort_lines(LAO);
						break;
					case "Incremental":
						set_layout_inc();
						break;
					case "Proportional":
						set_layout_prop();
						sort_lines(LAO);
						break;
				}
				
				function set_layout_abs():void
				{
					LAO.X = Verticals;
					LAO.Y = Horizontals;
				}
				function set_layout_inc():void
				{
					LAO.X = MathLab.INC_TO_ABS(Verticals);
					LAO.Y = MathLab.INC_TO_ABS(Horizontals);
				}
				function set_layout_prop():void
				{
					for (var i:int = 0; i < Verticals.length; i ++)
					{
						LAO.X[i] = Verticals[i] * Dimensions[0];
					}
					for (var j:int = 0; j < Horizontals.length; j ++)
					{
						LAO.Y[j] = Horizontals[j] * Dimensions[1];
					}
				}
			}
			
		}
		public static function UPDATE_LINE(Layout_Name:String, Vertical_or_Horizontal:Boolean, Line_Index:int, New_Value:Number, Method:String = "Absolute", Protect_Dimensions_or_Cells:Boolean = true):void
		{
			var dim:Number = new Number();
			
			if (Vertical_or_Horizontal)
			{
				start_update(LAOL[Layout_Name].X);
				
				if (Boolean(LAOL[Layout_Name].dim))
				{
					dim = LAOL[Layout_Name].dim[0];
				}
			}
			else
			{
				start_update(LAOL[Layout_Name].Y);
				
				if (Boolean(LAOL[Layout_Name].dim))
				{
					dim = LAOL[Layout_Name].dim[1];
				}
			}
			
			function start_update(Lines:Array):void
			{
				if (check_params(Lines))
				{
					if (Protect_Dimensions_or_Cells)
					{
						update_with_protect_dimension(Lines);
					}
					else
					{
						update_with_protect_cells(Lines);
					}
					
					sort_lines(LAOL[Layout_Name]);
					update_layout_cells(Layout_Name);
				}
			}
			function check_params(Lines:Array):Boolean
			{
				if (!Boolean(LAOL[Layout_Name]))
				{
					trace("No found error!");
					
					return false;
				}
				
				if (!Boolean(Lines[Line_Index]))
				{
					trace("Invalid index: " + Line_Index);
					trace(Layout);
					trace("Invalid index");
						
					return false;
				}
				
				return true;
			}
			function update_with_protect_dimension(Lines:Array):void
			{
				switch (Method)
				{
					case "Absolute":
						Lines[Line_Index] = New_Value;
						break;
					case "Incremental":
						Lines[Line_Index] += New_Value;
						break;
					case "Proportional":
						Lines[Line_Index] = New_Value * dim;
						break;
				}
			}
			function update_with_protect_cells(Lines:Array):void
			{
				var difference:Number;
				
				switch (Method)
				{
					case "Absolute":
						Lines[Line_Index] = New_Value;
						difference = New_Value - Lines[Line_Index];
						break;
					case "Incremental":
						Lines[Line_Index] += New_Value;
						difference = New_Value;
						break;
					case "Proportional":
						Lines[Line_Index] = New_Value * dim;
						difference = New_Value - Lines[Line_Index];
						break;
				}
				

				for (var i:int = Line_Index + 1; i < Lines.length; i ++)
				{
					Lines[i] += difference;
				}
			}
		}
		public static function UPDATE_CELL(Layout_Name:String, Cell_Row:int, Cell_Column:int, New_Values:Array, Method:String = "Absolute", Protect_Dimensions_or_Cells:Boolean = true):void
		{
			
		}
		public static function DELETE_LAYOUTS(Layouts_Name_List:Array):void
		{
			
		}
		
		// ------------------------------------------------------------
		// FUNCTIONS :
		// ------------------------------------------------------------
		
		private static function update_layout_cells(LAO_Name:String):void
		{
			for (var i:int = 0; i < LAOL[LAO_Name].X.length - 1; i ++)
			{
				LAOL[LAO_Name].cells[i] = new Array();
					
				for (var j:int = 0; j < LAOL[LAO_Name].Y.length - 1; j ++)
				{
					LAOL[LAO_Name].cells[i][j] = new Object();
					LAOL[LAO_Name].cells[i][j].top_left = new Object();
					LAOL[LAO_Name].cells[i][j].top_right = new Object();
					LAOL[LAO_Name].cells[i][j].bottom_left = new Object();
					LAOL[LAO_Name].cells[i][j].bottom_right = new Object();
						
					LAOL[LAO_Name].cells[i][j].top_left.x = LAOL[LAO_Name].X[i];
					LAOL[LAO_Name].cells[i][j].top_left.y = LAOL[LAO_Name].Y[j];
						
					LAOL[LAO_Name].cells[i][j].top_right.x = LAOL[LAO_Name].X[i + 1];
					LAOL[LAO_Name].cells[i][j].top_right.y = LAOL[LAO_Name].Y[j];
						
					LAOL[LAO_Name].cells[i][j].bottom_left.x = LAOL[LAO_Name].X[i];
					LAOL[LAO_Name].cells[i][j].bottom_left.y = LAOL[LAO_Name].Y[j + 1]
						
					LAOL[LAO_Name].cells[i][j].bottom_right.x = LAOL[LAO_Name].X[i + 1];
					LAOL[LAO_Name].cells[i][j].bottom_right.y = LAOL[LAO_Name].Y[j + 1]
				}
			}
		}
		private static function sort_lines(LAO:Object):void
		{
			LAO.X.sort(16);
			LAO.Y.sort(16);
		}
	}
}