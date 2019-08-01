/*
	------------------------------------------------------------
	- CONSOLE(C) 2014 - 2016
	------------------------------------------------------------
	
	v1.0 : 14.09.2014
	
	v2.0 : 31.01.2015 : Basit düzeyde Command bölümü eklendi.
	v2.1 : 04.02.2015 : IDENTIFY() metodu için Line_Length parametresi eklendi.
	v2.2 : 20.02.2015 : COMMAND bölümü artık parametre alabiliyor.
	v2.3 : 15.05.2015 : PRINT_DATA() metodu oluşturuldu.
	v2.4 : 07.08.2015 : PRINT_DATA() metodu için "Deep" parametresi eklendi.
	v2.5 : 13.09.2015 : TABLE() metodu eklendi.
	v2.6 : 14.09.2015 : SKIP_LINE() metodu eklendi.
	
	v3.0 : 15.02.2016 : 
		Eklenen yeni özellikler:
		1. Yeni Flash sürümlerinin (Flash Pro CC ve sonrası) artık kullanmadığı TLF Text artık kullanılmayacak. Onun yerine artık Classic Text kullanılıyor.
		2. Classic Text TLF Text'e göre daha iyi performans sağlıyor. Ayrıca SWZ TextField Layout kullanmadığından daha küçük boyutlu swf çıktıları elde ediliyor.
		3. Artık 'önce yarat sonra yaz' metoduna geçildi. Bu da performans artışı sağlıyor. (PRINT metodu hariç)
		4. Verileri tablolamayı sağlayan TABULATE() metodu eklendi.
		5. PRINT_DATA() metodu güncellendi. Artık veriler düzgün bir tabloda gösterilecek. Ayrıca gelişmiş 'filter' desteği eklendi.
		6. GET_DATA() metodu eklendi. PRINT_DATA() metodunun aynısını yapar ancak consola yazdırmak yerine String olarak çıktı verir. (Önce yarat sonra yaz)
		7. TABLE() metodu kaldırılarak yerine DYNAMIC_DATA() metodu eklendi. Bu metod ile dinamik tablolar yaratabilirsiniz. UPDATE_DATA() ile bu verileri güncelleyebilir, REMOVE_DATA() ile kaldırabilirsiniz.
		8. GET_OBJECT_TREE() metodu Utility'den devralındı.
		9. Console için Margin özelliği eklendi.
		10. mcC command bölümünde görsel iyileştirmeler.
		11. "command_line_number" ile "group_number" koordinasyonunu sağlandı.
		12. Bu sürüm ile birlikte her sınıfın bir 'id' ve 'no' static özellikleri belirlendi. Bu değerler sınıflardan gönderilecek olan komutların kimliğini belirlemede kullanılacak.
		13. Command fonksiyon ve metodları geliştirildi. ADD_COMMAND() metodu ile artık command için bilgiler de iletilebilirsiniz.
		14. Command bölümüne numerik komut giriş desteği eklendi.
		15. Command bölümünde boşluklu parametre girişi artık mümkün.
		15. help bölümü iyileştirildi.
		16. Renk formatları zenginleştirildi ve daha esnek duruma getirildi.
		17. PRINT_CLASS_INFO() metodu ile sınıf özelliklerini yazdırın.
		
	v3.1 : 16.02.2016 : UPDATE_DATA() temel veriler için dinamik destek sağlandı.
		
		
	GELİŞTİRMELER:	- TABULATE filter mekanizmasını gözden geçir. Bu filter mekanizmasını Utility'e aktar.
					- Command bölümüne her türlü parametre türüne destek sağla.
					- Tablolarda mizanpaj desteği. Tablolarda cell için 'max width' parametresi ile birden fazla satırlı hücrelere izin ver. 
					- Mizanpaj hücrelerine stil desteği ekle.
					- help bölümünde sınıf aralarında boşluk satırlar olması fonksiyonların bulunmasını kolaylaştırır.
					- Console.as sınıfı birden fazla örnek alabilir.
					- Aktiflik veya kilit özelliklerini güncelle. (AKtiflik Setup.as ile sağlanabilir veya dinamik olarak değiştirilebilir. Kilit ana ekranda bir şifre ile açılabilir olmalı.)
					- Browser üzerinde Console.as sınıfını kontrol et. (Scroll, dokunmatik özellikleri)
		
	by Samet Baykul

*/

package lbl
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.setInterval;
	import flash.utils.clearInterval;
	import flash.utils.getQualifiedClassName;
	
	import lbl.MathLab;
	import lbl.Utility;
	import lbl.InputControl;
	import lbl.Printmaker;

	public class Console
	{
		public static var MC_CONSOLE:MovieClip;
		public static var FORMAT_LIST:Array;
		
		// -> Fine Tuning:
		private static var group_closing_delay:uint = 1000;			// Bir kod grubunun kaç milisaniyenin ardından otomatik olarak kapatılacağını belirler.
		private static var text_program_marker:String = "-> ";		// Her Print ve Command satırı öncesinde program tarafından konulan default satır başı gösterge işareti.
		private static var group_number_digit:int = 3;				// Grup numarası için ayrılan karakter sayısı.
		
		private static var DDL:Array = new Array();					// Dynamic Data List
		private static var CDOL:Array = new Array();				// Command Data Object (CDO) List
		private static var last_printer:String;
		private static var margin:uint = 2;
		private static var code_group_interval:uint;
		private static var just_new_grup:Boolean;	
		private static var title_length:uint;
		private static var group_number:int = 0;
		private static var command_line_number:int = 0;
		private static var full_line_length:int;

		// Class Info:
		private static var id:String = "CON";
		private static var no:int = 008;

		public function Console():void
		{
			// Full Static Class
		}

		// ----------------------------------------------------------------
		// METHODS:
		// ----------------------------------------------------------------

		public static function IDENTIFY(MC_Console:MovieClip, Margin:int = 2, Line_Length:int = 55, Format_List:Array = null):void
		{
			init_vars();
			init_text_formats(Format_List);
			init_command();
			add_code_group();
			init_console_support();
			
			function init_vars():void
			{
				MC_CONSOLE = MC_Console;
				title_length = Line_Length;
				margin = Margin;
			
				full_line_length = Line_Length + Margin;
			}
			function init_text_formats(Format_List:Array):void
			{
				config_FORMAT_LIST();
				
				function config_FORMAT_LIST():void
				{
					FORMAT_LIST = new Array();
					
					FORMAT_LIST["Normal"] = new TextFormat();
					FORMAT_LIST["Bold"] = new TextFormat();
					FORMAT_LIST["Console"] = new TextFormat();
					FORMAT_LIST["Console2"] = new TextFormat();
					FORMAT_LIST["Warning"] = new TextFormat();
					FORMAT_LIST["Error"] = new TextFormat();
				}
				
				if (Boolean(Format_List))
				{
					FORMAT_LIST["Normal"].color = Format_List[0];
					FORMAT_LIST["Bold"].color = Format_List[1];
					FORMAT_LIST["Console"].color = Format_List[2];
					FORMAT_LIST["Console2"].color = Format_List[3];
					FORMAT_LIST["Warning"].color = Format_List[4];
					FORMAT_LIST["Error"].color = Format_List[5];
				}
				else
				{
					FORMAT_LIST["Normal"].color = Printmaker.GET_COLOR("White");
					FORMAT_LIST["Bold"].color = Printmaker.GET_COLOR("White");
					FORMAT_LIST["Console"].color = Printmaker.GET_COLOR("Green");
					FORMAT_LIST["Console2"].color = Printmaker.GET_COLOR("GrayC");
					FORMAT_LIST["Warning"].color = Printmaker.GET_COLOR("Yellow");
					FORMAT_LIST["Error"].color = Printmaker.GET_COLOR("Red");
				}
			}
			function init_command():void
			{
				new_command_line();
				
				InputControl.DEFINE("Console_Command", MC_CONSOLE.command, execute_command, ["Keyboard"]);
			}
			function init_console_support():void
			{
				MathLab.ADD_COMMANDS();
				
				ADD_COMMAND(id, "Clear", CLEAR, null, "Clear console screen.");
				ADD_COMMAND(id, "Help", help, ["Class_ID_List:Array"], "Gives command list.");
				ADD_COMMAND(id, "Info", info, ["Class_ID_List:Array"], "Gives info about the classes.");
				ADD_COMMAND(id, "Print", print, ["Text:String"], "Print something on the screen.");
				ADD_COMMAND(id, "Lock", lock, null, "Lock the command input.");
				ADD_COMMAND("TEMP", "rand", rand, null, "Gives a random numbers.");
				ADD_COMMAND("TEMP", "ranx", ranx, null, "Gives two random numbers.");
				
				ADD_COMMAND(id, "coninfo", coninfo, null, "Overall info about Console.as");
				
				ADD_COMMAND(id, "ddl", ddl, null, "DDL: Dynamic Data List.");
				ADD_COMMAND(id, "cdol", cdol, null, "CDOL: Command Data Object List.");
								
				function print(Param:Array):void
				{
					PRINT("User", Param[0]);
				}
				function info(Param:Array):void
				{
					for (var key:* in CDOL)
					{
						if (Utility.TEST_ARRAY_ELEMENTS(Param, [CDOL[key].class_id]))
						{							
							if (CDOL[key].name != "info")
							{
								if (Utility.SEARCH_TEXT(CDOL[key].name, "info"))
								{
									CDOL[key].command();
								}
							}
						}
					}
				}
				function start():void
				{
					
				}
				function stop():void
				{
					
				}
				function rand(Param:Array):void
				{
					var result:int = Math.random() * Param[0] + 1;
					
					Console.PRINT_DATA("Console", "result", result);   
				}
				function ranx():void
				{
					var XXX:Object = new Object();
					
					XXX.section = int(Math.random() * 2 + 1);
					XXX.line = int(Math.random() * 169 + 1);
					
					Console.PRINT_DATA("Console", "XXX", XXX);   
				}
				function lock():void
				{
					STOP();
					
					PRINT("Console", "The command section is locked.");
				}
				
				function coninfo():void
				{
					var info_matrix:Array = new Array();
					
					info_matrix[0] = ["MC_CONSOLE", MC_CONSOLE.parent.name + "." + MC_CONSOLE.name, "Config", ""];
					info_matrix[1] = ["group_closing_delay", group_closing_delay, "Fine Tunning", ""];
					info_matrix[2] = ["text_program_marker", text_program_marker, "Fine Tunning", ""];
					info_matrix[3] = ["group_number_digit", group_number_digit, "Fine Tunning", ""];
					info_matrix[4] = ["margin", margin, "Private", ""];
					info_matrix[5] = ["code_group_interval", code_group_interval, "Private", ""];
					info_matrix[6] = ["group_number", group_number, "Private", ""];
					info_matrix[7] = ["command_line_number", command_line_number, "Private", ""];
					info_matrix[8] = ["FORMAT_LIST", FORMAT_LIST, "Config", ""];
					
					PRINT_CLASS_INFO("Console", info_matrix);
				}
				function ddl():void
				{
					PRINT_DATA("Console", "DDL", DDL);
				}
				function cdol():void
				{
					PRINT_DATA("Console", "CDOL", CDOL);
				}
			}
		}
		
		public static function ADD_COMMAND(Class_ID:String, Command_Name:String, Command_Itself:Function, Parameteres:Array = null, Help:String = null):void
		{
			if(!Boolean(CDOL[Command_Name]))
			{
				var CDO:Object = new Object();
				
				create_CDO();
				config_params();
				
				CDOL[Command_Name] = CDO;
				
				Utility.SORT_ARRAY(CDOL, "class_id");
			}
			else
			{
				PRINT("Console", "X ERROR > ERROR CODE : XXX > Console: Aynı komutu çoklu yerleştime girişimi!", 3, "");
			}
		
			function create_CDO():void
			{
				CDO.class_id = Class_ID;
				CDO.name = Command_Name;
				CDO.command = Command_Itself;
				CDO.params = null;
				CDO.help = Help;
			}
			function config_params():void
			{
				if (Parameteres)
				{
					CDO.params = "(";
					
					for (var i:int = 1; i <= Parameteres.length; i++)
					{
						CDO.params += String(Parameteres[i-1]);
						
						if (i == Parameteres.length)
						{
							CDO.params += ")";
						}
						else
						{
							CDO.params += ", ";
						}
					}
				}
			}
		}
		 
		public static function PRINT(Printer:String, Info:String, Format:int = 4, Program_Marker:String = "auto"):void
		{
			var first_digit:int;
			var last_digit:int;
			just_new_grup = false;
			
			if (MC_CONSOLE)
			{
				add_title();
				add_program_marker();
				add_body();
				auto_scroll();
				close_code_group(group_closing_delay);
			}

			function close_code_group(Delay:int):void
			{
				if (! code_group_interval)
				{
					code_group_interval = setInterval(add_code_group,Delay);
				}
			}
			function add_title():void
			{
				if (Boolean(Printer))
				{
					if (is_new_title(Printer))
					{
						if (last_printer !== "first_title" && last_printer !== "unknown")
						{
							first_digit = update_digit();
							print_by_times(" ", margin);
							print_by_times("-", title_length);
							print_by_times("\n");
							last_digit = update_digit();
	
							modify_text_format(FORMAT_LIST["Console"], first_digit, last_digit);
						}
	
						// -> Fine Tuning:
						var title_left_line_length:uint = uint(title_length/10);
						var title_right_line_length:uint = Math.max((title_length - (title_left_line_length + Printer.length + 2)),0);
						
						is_title_length_enough();
	
						first_digit = update_digit();
						print_by_times(" ", margin);
						print_by_times("-", title_left_line_length);
						print_by_times(" ");
						print_by_times(Printer);
						print_by_times(" ");
						print_by_times("-", title_right_line_length);
						print_by_times("\n");
						last_digit = update_digit();
	
						modify_text_format(FORMAT_LIST["Console"], first_digit, last_digit);
						last_printer = Printer;
					}
				}

				function is_title_length_enough():void
				{
					var current_title_length:int = title_left_line_length + title_right_line_length + Printer.length + 2;
					
					if (current_title_length > title_length)
					{
						PRINT("Console", "X ERROR > ERROR CODE : 0001 > Console: 'title_length' sınıf özelliği kullanım amacını karşılamıyor: Gereken deger: " + current_title_length + ". Başlık Kapasitesi: " + title_length, 3, "");
						throw new Error(((("X ERROR > ERROR CODE : 0001 > Console: 'title_length' sınıf özelliği kullanım amacını karşılamıyor: Gereken deger: " + current_title_length) + ". Başlık Kapasitesi: ") + title_length));
					}
				}
			}
			function add_program_marker():void
			{
				first_digit = update_digit();
				
				switch (Program_Marker)
				{
					case "auto" :
						print_by_times(" ", margin);
						MC_CONSOLE.console.appendText(text_program_marker);
						last_digit = update_digit();
						break;
					default :
						print_by_times(" ", margin);
						MC_CONSOLE.console.appendText(Program_Marker);
						last_digit = update_digit();
						break;
				}

				modify_text_format(FORMAT_LIST["Console"], first_digit, last_digit);
			}
			function add_body():void
			{
				first_digit = update_digit();
				MC_CONSOLE.console.appendText(Info);
				print_by_times("\n");
				last_digit = update_digit();

				modify_text_format(FORMAT_LIST[get_format(Format)], first_digit, last_digit);
			}
		}
		
		public static function PRINT_DATA(Printer:String, Data_Name:String, Data:*, Filter_Rows:Array = null, Filter_Columns:Array = null):void
		{
			try
			{
				if (Data is Boolean)
				{
					PRINT(Printer, "Boolean  | " + Data_Name + " | " + Data, 1, "");
				}
				else if (Data is uint)
				{
					PRINT(Printer, "uint     | " + Data_Name + " | " + Data, 1, "");
				}
				else if (Data is int)
				{
					PRINT(Printer, "int      | " + Data_Name + " | " + Data, 1, "");
				}
				else if (Data is Number)
				{
					PRINT(Printer, "Number   | " + Data_Name + " | " + Data, 1, "");
				}
				else if (Data is String)
				{
					PRINT(Printer, "String   | " + Data_Name + " | '" + Data + "'", 1, "");
				}
				else if (Data is XML)
				{
					PRINT(Printer, "XML      | " + Data_Name , 1, "");
					PRINT("Console", "- WARNING > PRINT_DATA() function does not support XML data type for now. Please consult the API manager.", 2, "");
				}
				else if (Data is MovieClip)
				{
					PRINT(Printer, "MovieClip| " + Data_Name + " | Path: '" + Data.parent.name + "." + Data.name + "'", 1, "");
					
					//PRINT("Console", "- WARNING > PRINT_DATA() function does not support MovieClip data type for now. Please consult the API manager.", 2, "");
				}
				else if (Data is Array)
				{
					PRINT(Printer, "Array    | " + Data_Name , 1, "");
					PRINT(Printer, TABULATE(get_object_matrix(Data, Data_Name), "Full", margin, 5, null, ["KEY", "VALUE", "TYPE"], NaN, Filter_Rows, Filter_Columns), 1, "");
				}
				else
				{
					PRINT(Printer, "Object   | " + Data_Name , 1, "");
					PRINT(Printer, TABULATE(get_object_matrix(Data, Data_Name), "Full", margin, 5, null, ["KEY", "VALUE", "TYPE"], NaN, Filter_Rows, Filter_Columns), 1, ""); 
				}
			}
			catch(e:Error)
			{
				PRINT(Printer, "X ERROR > ERROR CODE : 0026 > While printing of " + Data_Name + " an error occured!", 3, "");
				PRINT(Printer, "- ERROR DETAILS > " + e.getStackTrace(), 2, "");
			}
		}
		
		public static function GET_DATA(Data_Name:String, Data:*, Filter_Rows:Array = null, Filter_Columns:Array = null):String
		{
			var text:String = "";
			
			try
			{
				if (Data is Boolean)
				{
					text = "Boolean  | " + Data_Name + " | " + Data;
				}
				else if (Data is uint)
				{
					text = "uint     | " + Data_Name + " | " + Data;
				}
				else if (Data is int)
				{
					text = "int      | " + Data_Name + " | " + Data;
				}
				else if (Data is Number)
				{
					text = "Number   | " + Data_Name + " | " + Data;
				}
				else if (Data is String)
				{
					text = "String   | " + Data_Name + " | " + '"' + Data + '"';
				}
				else if (Data is XML)
				{
					text = "XML      | " + Data_Name;
					text += "\n"
					text += "- WARNING > GET_DATA() function does not support XML data type for now. Please consult the API manager.";
				}
				else if (Data is MovieClip)
				{
					text = "MovieClip| " + Data_Name + " | " + Data;
					text += "\n"
					text += "- WARNING > GET_DATA() function does not support MovieClip data type for now. Please consult the API manager.";
				}
				else if (Data is Array)
				{
					text = "Array    | " + Data_Name;
					text += "\n"
					text += TABULATE(get_object_matrix(Data, Data_Name), "Full", 0, 2, null, ["KEY", "VALUE", "TYPE"], NaN, Filter_Rows, Filter_Columns);
				}
				else
				{
					text = "Object    | " + Data_Name;
					text += "\n"
					text += TABULATE(get_object_matrix(Data, Data_Name), "Full", 0, 2, null, ["KEY", "VALUE", "TYPE"], NaN, Filter_Rows, Filter_Columns);
				}
			}
			catch(e:Error)
			{
				text = "X ERROR > ERROR CODE : 0026 > While printing of " + Data_Name + " an error occured!";
				text += "- ERROR DETAILS > " + e.getStackTrace();
			}
			
			return text;
		}
		
		public static function DYNAMIC_DATA(Data_Name:String, Data:*, Filter_Rows:Array = null, Filter_Columns:Array = null):void
		{
			if (!DDL[Data_Name])
			{
				var DDO:Object = new Object();
				
				create_DDO();
				create_win();
				
				DDL[DDO.name] = DDO;
				
				PRINT_DATA("Console", Data_Name, Data, Filter_Rows, Filter_Columns);
			}
			else
			{
				UPDATE_DATA(Data_Name);
			}
			
			function create_DDO():void
			{
				DDO.name = Data_Name;
				DDO.data = Data;
				DDO.filter_rows = Filter_Rows;
				DDO.filter_columns = Filter_Columns;
				DDO.text = GET_DATA(Data_Name, Data, Filter_Rows, Filter_Columns);
			}
			function create_win():void
			{
				DDO.win = new Dynamic_Data_Win as MovieClip;
				DDO.win.DDO_name = Data_Name;
				DDO.win.name = "win_" + Data_Name;
				
				MC_CONSOLE.addChild(DDO.win);
				
				DDO.win.INIT();
				DDO.win.ALL_UNSELECT();
				DDO.win.SELECTED(true);
				DDO.win.head_text.text = "Dynamic Data -> " + Data_Name;
				DDO.win.console.text = DDO.text;
			}
		}
		
		public static function UPDATE_DATA(Data_Name:String, New_Data:* = null):void
		{
			if (DDL[Data_Name])
			{
				if (Boolean(New_Data))
				{
					DDL[Data_Name].data = New_Data;
					DDL[Data_Name].text = GET_DATA(DDL[Data_Name].name, DDL[Data_Name].data, DDL[Data_Name].filter_rows, DDL[Data_Name].filter_columns);
				}
				else
				{
					DDL[Data_Name].text = GET_DATA("", DDL[Data_Name].data, DDL[Data_Name].filter_rows, DDL[Data_Name].filter_columns);
				}
				
				DDL[Data_Name].win.console.text = DDL[Data_Name].text;
			}
		}
		
		public static function REMOVE_DATA(Data_Name:String):void
		{
			if (DDL[Data_Name])
			{
				DDL[Data_Name].win.STOP();
				MC_CONSOLE.removeChild(DDL[Data_Name].win);
				
				delete DDL[Data_Name];
			}

			Utility.COMPRESS_ARRAY(DDL);
		}

		public static function TABULATE(Data:Array, Visual_Type:String = "Default", Table_Margin:int = 2, Cell_Margin:int = 4, Rows:Array = null, Columns:Array = null, Max_Cell_Width:int = NaN, Filter_Rows:Array = null, Filter_Columns:Array = null):String
		{
			var text:String = "\n";
			var columns_width:Array = new Array();
			var row_width:uint = 0;

			try
			{
				init_visual_type();
				print_table();
			}
			catch(e:Error)
			{
				PRINT("Console", "- ERROR > Parameters are invalid or ",2,"");
				PRINT("Console", "- ERROR DETAILS > " + e.getStackTrace(),2,"");
			}
			
			function init_visual_type():void
			{
				switch (Visual_Type)
				{
					case "Simple":
						Rows = null;
						Columns = null;
						filter_rows();
						break;
					case "Full":
						build_rows();
						filter_rows();
						check_table_parameters();
						create_cells();
						print_columns();
						break;
					default: 
						build_rows();
						filter_rows();
						check_table_parameters();
						create_cells();
						break;
				}
			}
			function build_rows():void
			{
				if (!Boolean(Rows))
				{
					Rows = new Array();
					
					for (var i:uint = 0; i < Data.length; i ++)
					{
						Rows[i] = int(i+1) + "/" + Data.length;
					}
				}
			}
			function check_table_parameters():void
			{
				if (!Boolean(Columns))
				{
					var longest_row:int = 0;
					
					Columns = new Array();
					
					for (var j:uint = 0; j < Data.length; j ++)
					{
						for (var k:uint = 0; k < Data[j].length; k ++)
						{
							if (longest_row < Data[j].length)
							{
								longest_row = Data[j].length
							}
						}
					}
					
					for (var l:int = 0; l < longest_row; l ++)
					{
						Columns[l] = String.fromCharCode(int(65 + l));
					}
				}

				row_width = Utility.FIND_LONGEST_ITEM_IN_TEXT(Rows).length + 2;
			}
			function create_cells():void
			{
				for (var h:uint = 0; h < Columns.length; h ++)
				{
					columns_width[h] = Columns[h].length + 2;
				}

				for (var i:uint = 0; i < Data.length; i ++)
				{
					for (var j:uint = 0; j < Data[i].length; j ++)
					{
						if (Data[i][j] is Number)
						{
							if (columns_width[j] < String(int(Data[i][j])).length + 5)
							{
								columns_width[j] = String(int(Data[i][j])).length + 5;
							}
						}
						else if (Data[i][j] is Function)
						{
							if (columns_width[j] < 10)
							{
								columns_width[j] = 10;
							}
						}
						else if (columns_width[j] < String(Data[i][j]).length)
						{
							columns_width[j] = String(Data[i][j]).length;
						}
					}
				}
				for (var k:uint = 0; k < columns_width.length; k ++)
				{
					columns_width[k] += Cell_Margin;
				}
			}
			function print_columns():void
			{
				text += get_by_times(" ", row_width + Table_Margin);
				
				for (var i:uint = 0; i < Columns.length; i ++)
				{
					text += Columns[i];
					text += get_by_times("_", columns_width[i] - Columns[i].length - 1);
					text += " ";
				}
			}
			function print_table():void
			{
				var sub_table:String = "";
				
				for (var i:uint = 0; i < Data.length; i ++)
				{	
					text += "\n" + get_by_times(" ", Table_Margin);
					print_cell(Rows[i], int(row_width - 2));
					text += ": ";

					for (var j:uint = 0; j < Data[i].length; j ++)
					{
						if (!Boolean(Data[i][j]))
						{
							if (Data[i][j] is Boolean)
							{
								print_cell("false", columns_width[j]);
							}
							else
							{
								print_cell("-", columns_width[j]);
							}
						}
						else if ((Data[i][j] is Boolean) || (Data[i][j] is int) || (Data[i][j] is uint) || (Data[i][j] is String))
						{
							print_cell(String(Data[i][j]), columns_width[j]);
						}
						else if (Data[i][j] is Number)
						{
							print_cell(MathLab.SET_SIGNIFICANT_FIGURE(Data[i][j],3), columns_width[j]);
						}
						else if (Data[i][j] is Function)
						{
							print_cell("Function()", columns_width[j]);
						}
						else if (Data[i][j] is MovieClip)
						{
							print_cell(String(Data[i][j].name), columns_width[j]);
						}
						else if (Data[i][j] is Array)
						{
							print_cell("[...]", columns_width[j]);
							
							sub_table = "\n";
							sub_table += get_by_times(" ", Table_Margin + row_width);
							sub_table += " ▼ ";
							sub_table += TABULATE(get_object_matrix(Data[i][j], Data[i][0]), "Default", (Table_Margin + row_width), Cell_Margin, null, ["Key", "Value", "Type"], Max_Cell_Width, Filter_Rows, Filter_Columns);
						}
						else
						{
							print_cell("{...}", columns_width[j]);
							
							sub_table = "\n";
							sub_table += get_by_times(" ", Table_Margin + row_width);
							sub_table += " ▼ ";
							sub_table += TABULATE(get_object_matrix(Data[i][j], Data[i][0]), "Default", (Table_Margin + row_width), Cell_Margin, null, ["Key", "Value", "Type"], Max_Cell_Width, Filter_Rows, Filter_Columns);
						}
					}
					
					if (Boolean(sub_table))
					{
						text += sub_table;
						sub_table = "";
						
						if (i == int(Data.length - 1))
						{
							text += "\n"
						}
					}
				}
			}
			function print_cell(Cell_Data:String, Cell_Width:uint):void
			{
				text += Cell_Data;
				text += get_by_times(" ", Cell_Width - Cell_Data.length);
			}
			function filter_rows():void
			{
				if (Boolean(Filter_Rows))
				{
					for (var i:uint = 0; i < Rows.length; i++)
					{
						if (Utility.TEST_ARRAY_ELEMENTS(Filter_Rows, [Rows[i]]))
						{
							delete Rows[i];
							delete Data[i];
						}
					}
					
					Utility.COMPRESS_ARRAY(Rows);
					Utility.COMPRESS_ARRAY(Data);
				}
				
				if (Boolean(Filter_Columns))
				{					
					for (var j:uint = 0; j < Rows.length; j++)
					{
						for (var k:uint = 0; k < Filter_Columns.length; k++)
						{
							for (var l:uint = 0; l < Filter_Columns[k][0].length; l++)
							{
								if (Utility.TEST_ARRAY_ELEMENTS(Columns, [Filter_Columns[k][0][l]]))
								{
									var column_index:uint = Columns.indexOf(Filter_Columns[k][0][l])

									if (Utility.TEST_ARRAY_ELEMENTS(Filter_Columns[k][1], [Data[j][column_index]]))
									{
										Rows[j] = null;
										Data[j] = null
									}
								}
							}
						}
					}

					Utility.COMPRESS_ARRAY(Rows);
					Utility.COMPRESS_ARRAY(Data);
				}			
			}
			
			return text;
		}	
		
		public static function SKIP_LINE(Number_Line:int = 1):void
		{
			print_by_times("\n", Number_Line);
		}
		
		public static function CLEAR():void
		{
			if (MC_CONSOLE)
			{
				MC_CONSOLE.console.text = "";
				last_printer = "unknown";
				just_new_grup = false;
			}
		}
		
		public static function START():void
		{
			if (MC_CONSOLE)
			{
				InputControl.DEFINE("Console_Command", MC_CONSOLE.command, execute_command, ["Keyboard"]);
				
				MC_CONSOLE.command.type = "input";
			}
		}
		
		public static function STOP():void
		{
			if (MC_CONSOLE)
			{
				InputControl.BREAK_LINKS(["Console_Command"]);

				MC_CONSOLE.command.type = "dynamic";
			}
		}
		
		public static function PRINT_CLASS_INFO(Printer:String, Props:Array):void
		{
			get_type();
			print_info();
					
			function get_type():void
			{
				for (var i:int; i < Props.length; i ++)
				{
					Props[i][4] = Props[i][3];
					Props[i][3] = Props[i][2];
					Props[i][2] = getQualifiedClassName(Props[i][1]);
				}
			}
			function print_info():void
			{
				PRINT(Printer, "All Info:", 1, "");
				SKIP_LINE();
				PRINT(Printer, TABULATE(Props, "Full", margin, 4, null, ["Property", "Value", "Type", "Group", "Info"]), 1, "");
			}
		}
		
		public static function GET_OBJECT_TREE(Main_Object_Name:String, Main_Object:*, Filter:Array = null):String
		{
			if (Boolean(Main_Object_Name))
			{
				Main_Object_Name = "Unknown";
			}
			
			var Text:String = "\n All Elements of '" + Main_Object_Name + "':" + "\n";
			Text +=  "----------------------------------------" + "\n";

			search_elements(Main_Object, Main_Object_Name);
			return Text;

			function search_elements(Target_Object:*, Target_Object_Name:String):void
			{
				var key_list:Array = new Array();
				var value_list:Array = new Array();
				var pass_filter:Boolean = false;

				for (var key:* in Target_Object)
				{
					key_list.push(key);
				}

				for each (var Value:* in Target_Object)
				{
					value_list.push(Value);
				}

				for (var i:uint = 0; i < key_list.length; i++)
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
						if (value_list[i] is Array)
						{
							Text +=  "--ARRAY > In '" + Target_Object_Name + "': " + uint(i+1) + "/" + key_list.length + ". Element:\t Key: '" + key_list[i] + "';\t\t Value: '" + value_list[i] + "'\n";
						}
						else if (value_list[i] is Function)
						{
							Text +=  "--METHOD> In '" + Target_Object_Name + "': " + uint(i+1) + "/" + key_list.length + ". Element:\t Key: '" + key_list[i] + "';\t\t Value: '" + value_list[i] + "'\n";
						}
						else if (value_list[i] is Object)
						{
							Text +=  "--OBJECT> In '" + Target_Object_Name + "': " + uint(i+1) + "/" + key_list.length + ". Element:\t Key: '" + key_list[i] + "';\t\t Value: '" + value_list[i] + "'\n";
						}
					
						if (value_list[i] is Array)
						{
							search_elements(value_list[i], key_list[i]);
						}
						else if (value_list[i] is Function)
						{
							search_elements(value_list[i], key_list[i]);
						}
						else if (value_list[i] is Object)
						{
							search_elements(value_list[i], key_list[i]);
						}
					}

					function test_for_filter(element:*, index:int, arr:Array):Boolean
					{
						return !(element == key_list[i]);
					}
				}
			}
		}

		// ----------------------------------------------------------------
		// PRIVATE FUNCTIONS:
		// ----------------------------------------------------------------
		
		// About printing:
		private static function print_by_times(Text:String, Time:uint = 1):void
		{
			for (var i:int = 0; i < Time; i ++)
			{
				MC_CONSOLE.console.appendText(Text);
			}
		}
		private static function get_by_times(What:String, Times:uint = 0):String
		{
			var text:String = "";
			
			for (var i:uint = 0; i < Times; i++)
			{
				text += What;
			}
			
			return text;
		}
		private static function get_object_matrix(Target_Object:Object, Target_Object_Name:String, Filter_Rows:Array = null, Filter_Columns:Array = null):Array
		{
			var matrix:Array = new Array();
			var keys:Array = new Array();
			var pass_filter:Boolean = true;
			
			get_keys();
			get_values();

			return matrix;
			
			function get_keys():void
			{
				for (var key:* in Target_Object)
				{
					keys.push(key);
				}
				
				keys.sort();
			}
			function get_values():void
			{
				for (var i:int = 0; i < keys.length; i ++)
				{
					matrix[i] = new Array();
						
					if (keys[i] is int)
					{
						matrix[i][0] = Target_Object_Name + "[" + keys[i] + "]";
					}
					else
					{
						matrix[i][0] = Target_Object_Name + "." + keys[i];
					}
					
					matrix[i][1] = Target_Object[keys[i]];
					matrix[i][2] = getQualifiedClassName(Target_Object[keys[i]]);
				}
			}
		}
		
		// About order:
		private static function add_code_group():void
		{
			if ((! just_new_grup) && (group_number != command_line_number))
			{
				group_number = command_line_number;
				
				var first_digit:int;
				var last_digit:int;

				// -> Fine Tuning:
				var title_right_line_length:uint = 3;
				var title_left_line_length:uint = (title_length - (title_right_line_length + group_number_digit));

				first_digit = update_digit();
				print_by_times(" ", margin);
				print_by_times("¯", title_left_line_length);
				print_by_times(MathLab.CONVERT_to_SCORE(group_number, group_number_digit));
				print_by_times("¯", title_right_line_length);
				print_by_times("\n");
				last_digit = update_digit();

				modify_text_format(FORMAT_LIST["Console2"], first_digit, last_digit);
				auto_scroll();
				
				last_printer = "unknown";
			}
			
			just_new_grup = true;
			clearInterval(code_group_interval);
			code_group_interval = 0;
		}
		private static function is_new_title(Printer:String):Boolean
		{
			var Result:Boolean = ! (last_printer == Printer);

			if (last_printer)
			{
				if (last_printer !== "unknown")
				{
					last_printer = Printer;
				}
			}
			else
			{
				last_printer = "first_title";
			}
			return Result;
		}
		private static function new_command_line():void
		{
			command_line_number++;
			MC_CONSOLE.command_line.text = "";
			MC_CONSOLE.command_line.appendText(MathLab.CONVERT_to_SCORE(command_line_number, 3) + text_program_marker);
		}
		private static function auto_scroll():void
		{
			MC_CONSOLE.console.scrollV = MC_CONSOLE.console.maxScrollV;
		}
		private static function modify_text_format(Text_Format:TextFormat, First_Digit:int, Last_Digit:int):void
		{
			if (First_Digit !== Last_Digit)
			{
				MC_CONSOLE.console.setTextFormat(Text_Format, First_Digit, Last_Digit);
			}
		}
		private static function update_digit():int
		{
			return MC_CONSOLE.console.length;
		}
		private static function get_format(No:int):String
		{
			switch (No)
			{
				case 0:
					return "Console";
					break;
				case 1:
					return "Bold";
					break;
				case 2:
					return "Warning";
					break;
				case 3:
					return "Error";
					break;
				case 4:
					return "Console2";
					break;
				case 5:
					return "Normal";
					break;
				default:
					return "Console";
					break;
			}
		}
		
		// About commands:
		private static function execute_command(Feed:Object):void
		{
			if (Feed.Enter)
			{
				if (Boolean(MC_CONSOLE.command.text))
				{
					var body_is_ready:Boolean = false;
					var command_body:String;
					
					get_command_body();
					execute();
					reset();
				}
			}
			
			function get_command_body():void
			{
				command_body = Utility.SPLIT_TEXT(MC_CONSOLE.command.text, " ", 1, 1);
				
				if (Boolean(int(command_body)) || (command_body == "0"))
				{
					for (var key:String in CDOL)
					{
						if (command_body == String(CDOL[key].index))
						{
							command_body = CDOL[key].name;
							body_is_ready = true;
						}
					}
				}
				else
				{
					body_is_ready = true;
				}
			}
			function execute():void
			{
				if (body_is_ready)
				{
					if (MC_CONSOLE.command.text.split(" ").length > 1)
					{
						execute_para_func();
					}
					else
					{
						execute_func();
					}
				}
				else
				{
					PRINT("Console", "The command '" + command_body + "' cannot be executed. Please check the list below:");
					PRINT("Console", get_command_list(), 1, "");
				}
				
				function execute_func():void
				{
					if (CDOL[command_body])
					{
						try
						{
							PRINT("Command", command_body + "();", 2);
									
							CDOL[command_body].command();
						}
						catch(e:Error)
						{
							PRINT("Command", command_body + "();", 3);
							PRINT("Console", "- WARNING > Parameters are invalid or ", 2, "");
							PRINT("Console", "- ERROR DETAILS > " + e.getStackTrace(), 2, "");
						}
					}
					else 
					{
						PRINT("Command", command_body + "();", 3);
						PRINT("Console", "The command '" + command_body + "()' cannot be executed. Please check the list below:");
						PRINT("Console", get_command_list(), 1, "");
					}
				}
				function execute_para_func():void
				{
					var command_parameters_text:String = Utility.SPLIT_TEXT(MC_CONSOLE.command.text, " ", 2);
							
					if (Utility.SEARCH_TEXT(command_parameters_text.charAt(0), " "))
					{
						PRINT("Console", "- WARNING > ...", 2, "");
					}
					else
					{
						var command_parameters_list:Array = command_parameters_text.split(",");
								
						if (CDOL[command_body])
						{
							try
							{
								PRINT("Command", command_body + "(" + String(command_parameters_list) + ");", 2);
										
								CDOL[command_body].command(command_parameters_list);
							}
							catch(e:Error)
							{
								PRINT("Command", command_body + "(" + String(command_parameters_list) + ");", 3);
								PRINT("Console", "- WARNING > Parameters are invalid or ", 2, "");
								PRINT("Command", "- ERROR DETAILS > " + e.getStackTrace(), 2, "");
							}
						}
						else 
						{
							PRINT("Command", command_body + "(" + String(command_parameters_list) + ");", 3);
							PRINT("Console", "The command '" + command_body + "(" + String(command_parameters_list) + ")' cannot be executed. Please check the list below:");
							PRINT("Console", get_command_list(), 1, "");
						}
					}
				}
			}
			function reset():void
			{
				new_command_line();
					
				MC_CONSOLE.command.text = "";
			}
		}
		private static function help(Param:Array = null):void
		{
			PRINT("Command List", get_command_list(Param), 1, "");
			SKIP_LINE();
		}
		private static function get_command_list(Show_Only:Array = null):String
		{
			var txt:String = "";
			var command_matrix:Array = new Array();
			var command_index_list:Array = new Array();
			
			create_command_matrix();
			create_table_txt();
			destroy_vars();
			
			return txt;
			
			function create_command_matrix():void
			{
				for (var key:String in CDOL)
				{
					if (Boolean(Show_Only))
					{
						if (Utility.TEST_ARRAY_ELEMENTS(Show_Only, [CDOL[key].class_id]))
						{
							add_new_command();
						}
					}
					else
					{
						add_new_command();
					}
				}
				
				function add_new_command():void
				{
					var new_command:Array = new Array();
						
					new_command[0] = key;
					new_command[1] = CDOL[key].params;
					new_command[2] = CDOL[key].help;
					new_command[3] = CDOL[key].class_id;
					
					command_matrix[CDOL[key].index] = new_command;
					command_index_list[CDOL[key].index] = CDOL[key].index;
				}
			}
			function create_table_txt():void
			{
				Utility.COMPRESS_ARRAY(command_matrix);
				Utility.COMPRESS_ARRAY(command_index_list);

				txt = TABULATE(command_matrix, "Full", margin, 1, command_index_list, ["Command", "Parameters", "Hint", "Class"]);
			}
			function destroy_vars():void
			{
				command_matrix = null;
				command_index_list = null;
			}
		}
		
		// Others:
		public static function update_DDL():void
		{
			for (var i:int = 0; i < DDL.length; i ++)
			{
				
			}
		}
	}
}