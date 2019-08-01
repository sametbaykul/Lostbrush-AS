/*
	------------------------------------------------------------
	- DATABASE ENGINE(C) 2014 - 2016
	------------------------------------------------------------
	
	* DYNAMIC
	* INIT : Constructor
	
	v1.0 : 31.10.2014
	v1.1 : 03.02.2015
	v1.2 : 08.02.2015 : Callback Function ile ilgili ciddi bir sorun çözüldü.
	v1.3 : 14.02.2015 : UPDATE_ELEMENT() metodu eklendi.
	v1.4 : 19.02.2015 : Hata kodu "0016" olan bir hata için ayrıntılı bilgi çıkışı eklendi.
	v1.5 : 12.02.2016 : 'id' ve 'no' özellikleri belirlendi.
	
	GELİŞTİRMELER:	- Static duruma getir.
					- Processor.as entegrasyonu sağla. QUEUE_PROCESSING yerine Processor sınıfını kullan.
					- Timeout gibi durumları Processor.as ile çöz.
	
	by Samet Baykul

*/

package lbl
{
	// Flash Library:
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.utils.getTimer;
	import flash.net.URLVariables;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	// LBL Core:
	import lbl.MathLab;
	import lbl.Access;
	import lbl.Utility;
	// LBL Control:
	import lbl.Console;
	

	public class DBEngine
	{
		public var DATABASE:String;
		public var QUEUE_PROCESSING:Array = new Array();

		private var CPPO:Object;							// Current Process Param Object: Şu anda çalıştırılan işlem için PHP tarafına gönderilecek verileri ifade eden nesne.
		private var Feedback:Object;						// Feedback Function için hazırlanan Respond nesnesi.
		private var is_processing_now:Boolean = false;		// İşlecin şu ancda bir işlem üzerinde çalışıp çalışmadığı gösterir.
		private var process_start_time:uint; 				// İşlemin ne zaman başladığını gösterir.
		private var process_finish_time:uint; 				// İşlemin ne zaman bitirildiğini gösterir.
		private var PHP_DP:String;							// PHP Documents Path.
		private var working_php_doc_now:String; 			// İşlecin şu anda birlikte çalıştığı PHP dökümanının veri yolunu gösterir.

		// Class Info:
		private static var id:String = "DBE";
		private static var no:int = 012;

		public function DBEngine():void
		{
			init_p_bridge();
			reset_feedback_object();

			function init_p_bridge():void
			{
				Access.CREATE_PB("DBEngine");
			}
		}

		// ----------------------------------------------------------------
		// METHODS:
		// ----------------------------------------------------------------

		public function CONNECT(Database:String, PHP_Documents_Path:String, Respond_Callback:Function = null, Init_Callback:Function = null, Progress_Callback:Function = null):void
		{
			DATABASE = Database;
			PHP_DP = PHP_Documents_Path;

			var param_object:Object = new Object();
			param_object.Process = "Connect";

			send_param_object_to_queue(param_object, Respond_Callback, Init_Callback, Progress_Callback);
		}
		
		public function SOME_ELEMENT(Table:String, Which_Columns:Array, Search_For:Array, Respond_Callback:Function = null, Init_Callback:Function = null, Progress_Callback:Function = null):void
		{
			if (Which_Columns.length == Search_For.length)
			{
				var param_object:Object = new Object();
				param_object.Process = "SomeElement";
				param_object.Table = Table;
				param_object.Which_Columns = Which_Columns;
				param_object.Search_For = Search_For;

				send_param_object_to_queue(param_object, Respond_Callback, Init_Callback, Progress_Callback);
			}
			else
			{
				Console.PRINT("DBEngine", "X ERROR > ERROR CODE: 0004 > SOME_ELEMENT Methodu Parametre Hatası: Database Querry Testi için 'Which_Columns' ve 'Search_For' dizilerinin sayıları eşit olmak zorundadır.", 3, "");
				throw new Error("ERROR CODE: 0004 > Database Querry Testi için 'Which_Columns' ve 'Search_For' dizilerinin sayıları eşit olmak zorundadır.");
			}
		}
		
		public function UPDATE_ELEMENT(Table:String, Where_Column:Array, Where_Value:Array, Update_Column:Array, Update_Value:Array, Respond_Callback:Function = null, Init_Callback:Function = null, Progress_Callback:Function = null):void
		{
			if ((Where_Column.length == Where_Value.length) && (Update_Column.length == Update_Value.length))
			{
				var param_object:Object = new Object();
				param_object.Process = "UpdateElement";
				param_object.Table = Table;
				param_object.Where_Column = Where_Column;
				param_object.Where_Value = Where_Value;
				param_object.Update_Column = Update_Column;
				param_object.Update_Value = Update_Value;

				send_param_object_to_queue(param_object, Respond_Callback, Init_Callback, Progress_Callback);
			}
			else
			{
				Console.PRINT("DBEngine", "X ERROR > ERROR CODE: 0037 > UPDATE_ELEMENT Methodu Parametre Hatası: Database Querry yeni kayıt için 'Where_Column' ile de 'Where_Value' dizilerinin sayıları eşit olmak zorundadır.", 3, "");
				throw new Error("ERROR CODE: 0037 > Database Querry Testi için 'Where_Column' ile de 'Where_Value' dizilerinin sayıları eşit olmak zorundadır.");
			}
		}
		
		public function NEW_RECORD(Table:String, Record_Columns:Array, Record_Values:Array, Crypto_List:Array, Respond_Callback:Function = null, Init_Callback:Function = null, Progress_Callback:Function = null):void
		{
			if (Record_Columns.length == Record_Values.length)
			{
				var param_object:Object = new Object();
				param_object.Process = "NewRecord";
				param_object.Table = Table;
				param_object.Record_Columns = Record_Columns;
				param_object.Record_Values = Record_Values;
				param_object.Crypto_List = Crypto_List;

				send_param_object_to_queue(param_object, Respond_Callback, Init_Callback, Progress_Callback);
			}
			else
			{
				Console.PRINT("DBEngine", "X ERROR > ERROR CODE: 0005 > NEW_RECORD Methodu Parametre Hatası: Database Querry yeni kayıt için 'Record_Columns' ile de 'Record_Values' dizilerinin sayıları eşit olmak zorundadır.", 3, "");
				throw new Error("ERROR CODE: 0005 > Database Querry Testi için 'Record_Columns' ile de 'Record_Values' dizilerinin sayıları eşit olmak zorundadır.");
			}
		}
		
		public function READ(Table:String, Which_Columns:Array, Search_For:Array, Order_For:String, Order:Boolean, Respond_Callback:Function = null, Init_Callback:Function = null, Progress_Callback:Function = null):void
		{
			if (Which_Columns.length == Search_For.length)
			{
				var param_object:Object = new Object();
				param_object.Process = "Read";
				param_object.Table = Table;
				param_object.Which_Columns = Which_Columns;
				param_object.Search_For = Search_For;
				param_object.Order_For = Order_For;
				param_object.Order = Order;

				send_param_object_to_queue(param_object, Respond_Callback, Init_Callback, Progress_Callback);
			}
			else
			{
				Console.PRINT("DBEngine", "X ERROR > ERROR CODE: 0019 > READ Methodu Parametre Hatası: Database Querry Testi için 'Which_Columns' ve 'Search_For' dizilerinin sayıları eşit olmak zorundadır.", 3, "");
				throw new Error("ERROR CODE: 0019 > Database Querry Testi için 'Which_Columns' ve 'Search_For' dizilerinin sayıları eşit olmak zorundadır.");
			}
		}
		
		public function SEND_MAIL(SMTP_Server:String, From_Email:String, From_Name:String, Subject:String, To_Adress_List:Array, To_Name_List:Array, Mail_Template:String, Mail_Data:Array = null, Respond_Callback:Function = null, Init_Callback:Function = null, Progress_Callback:Function = null):void
		{
			if (To_Adress_List.length == To_Name_List.length)
			{
				var param_object:Object = new Object();
				param_object.Process = "SendMail";
				param_object.SMTP_Server = SMTP_Server;
				param_object.From_Email = From_Email;
				param_object.From_Name = From_Name;
				param_object.Subject = Subject;
				param_object.To_Adress_List = To_Adress_List;
				param_object.To_Name_List = To_Name_List;
				param_object.Mail_Template = Mail_Template;
				param_object.Mail_Data = Mail_Data;
				
				send_param_object_to_queue(param_object, Respond_Callback, Init_Callback, Progress_Callback);
			}
			else
			{
				Console.PRINT("DBEngine", "X ERROR > ERROR CODE: 0015 > SEND_MAIL Methodu Parametre Hatası: 'To_Adress_List' ile 'To_Name_List' parametre uzunlukları aynı olmak zorundadır.", 3, "");
				throw new Error("X ERROR > ERROR CODE: 0015 > SEND_MAIL Methodu Parametre Hatası: 'To_Adress_List' ile 'To_Name_List' parametre uzunlukları aynı olmak zorundadır.");
			}
		}
		
		public function ENCRYPT(Data:Array, Security_Level:uint, Respond_Callback:Function = null, Init_Callback:Function = null, Progress_Callback:Function = null):void
		{
			var param_object:Object = new Object();
			param_object.Process = "Encrypt";
			param_object.Data = Data;
			param_object.Security_Level = Security_Level;

			send_param_object_to_queue(param_object, Respond_Callback, Init_Callback, Progress_Callback);
		}

		// ----------------------------------------------------------------
		// PRIVATE FUNCTIONS:
		// ----------------------------------------------------------------

		private function send_param_object_to_queue(Param_Object:Object, Respond_Callback:Function = null, Init_Callback:Function = null, Progress_Callback:Function = null):void
		{
			Param_Object.Start_Time = getTimer();
			Param_Object.PHP_URL = String(PHP_DP + "/" + Param_Object.Process + ".php");
			Param_Object.Database = DATABASE;
			Param_Object.Protocol = "Regular";
			Param_Object.Respond_Callback = Respond_Callback;
			Param_Object.Init_Callback = Init_Callback;
			Param_Object.Progress_Callback = Progress_Callback;

			add_queue_processing(Param_Object);
			execute_processing();
		}
		private function add_queue_processing(Param_Object:Object):void
		{
			var is_already_in_qp:Boolean = QUEUE_PROCESSING.some(test);// qp: Queue_Processing

			if (! is_already_in_qp)
			{
				QUEUE_PROCESSING.push(Param_Object);
				Console.PRINT("DBEngine", "The process '" + Param_Object.Process + "ing' is added to the queue.");
			}
			else
			{
				Console.PRINT("DBEngine", "- WARNING > The process '" + Param_Object.Process + "ing' is already in queue. So this attemption was ignored.", 2, "");
			}

			function test(element:*, index:int, arr:Array):Boolean
			{
				return (element.Process == Param_Object.Process);
			}
		}
		private function execute_processing():void
		{
			var php_vars:URLVariables;
			var php_file_request:URLRequest;
			var php_loader:URLLoader;

			if (QUEUE_PROCESSING.length && ! is_processing_now)
			{
				CPPO = QUEUE_PROCESSING[0];// Current Process Param Object
				is_processing_now = true;
				reset_feedback_object();
				working_php_doc_now = CPPO.PHP_URL;

				if (CPPO.Init_Callback)
				{
					CPPO.Init_Callback();
				}

				call_php();
				Console.PRINT("DBEngine", "The process '" + CPPO.Process + "ing' is initialized.");
			}
			else
			{
				is_processing_now = false;
			}

			function call_php():void
			{
				switch (CPPO.Protocol)
				{
					case "Regular" :
						create_URL_Variables(CPPO);
						create_URL_Request(CPPO.PHP_URL);
						create_URL_Loader();
						break;
				}
			}
			function create_URL_Variables(Param_Object:Object):void
			{
				php_vars = new URLVariables();
				php_vars.FLASH_DATA = JSON.stringify(Param_Object);
			}
			function create_URL_Request(PHP_URL:String, Method:String = "POST"):void
			{
				php_file_request = new URLRequest(PHP_URL);
				php_file_request.data = php_vars;
				php_file_request.method = URLRequestMethod[Method];
			}
			function create_URL_Loader(DataFormat:String = "VARIABLES"):void
			{
				php_loader = new URLLoader();
				php_loader.dataFormat = URLLoaderDataFormat[DataFormat];
				php_loader.addEventListener(Event.COMPLETE, php_complete);
				php_loader.addEventListener(IOErrorEvent.IO_ERROR, php_io_error);
				php_loader.addEventListener(ProgressEvent.PROGRESS, php_progress);
				CPPO.URL_Loader = php_loader;
				php_loader.load(php_file_request);
			}
		}
		private function php_complete(e:Event):void
		{
			try
			{
				var arrayReceived:Object = JSON.parse(e.target.data.PHP_RESULT);
				Feedback = arrayReceived;
			}
			catch (error:Error)
			{
				Feedback.error_detail.push("JSON Parse Error");
			}

			conclude_process();
		}
		private function conclude_process():void
		{
			var now:uint = getTimer();
			var milsec:uint = now - CPPO.Start_Time;
			var sec:Number = milsec / 1000;
			sec = MathLab.SET_SIGNIFICANT_FIGURE(sec,2);
			Feedback.during = milsec;
			reset_URL_loader_listeners();
			
			// Feedback.error_detail özelliği inceleniyor...
			if (Feedback.error_detail.length == 0)
			{
				Feedback.success = true;
				Console.PRINT("DBEngine", "The process '" + CPPO.Process + "ing' is completed successfully in " + sec + " seconds.\n- The remaining number of operations in the queue: " + (QUEUE_PROCESSING.length - 1));
			}
			else
			{
				Console.PRINT("DBEngine", "- WARNING > The process '" + CPPO.Process + "ing' failed in " + sec + " seconds.\n- The remaining number of operations in the queue: " + (QUEUE_PROCESSING.length - 1),2,"");
				Console.PRINT("DBEngine", "-> There are " + Feedback.error_detail.length + " problems!", 2, "");

				for (var i:int = 0; i < Feedback.error_detail.length; i ++)
				{
					Console.PRINT("DBEngine", "--> " + uint(i+1) + "/" + Feedback.error_detail.length + ". Problem is: " + Feedback.error_detail[i] + ":", 2, "");
					switch (Feedback.error_detail[i])
					{
						case "JSON Parse Error" :
							Console.PRINT("DBEngine", "X ERROR > ERROR CODE: 0006 > Received data from server, cannot parse by the client program. Server side Document Path: '" + working_php_doc_now + "'.", 3, "");
							Console.PRINT("DBEngine", "> Server side Document Path: '" + working_php_doc_now + "'.", 2, "");
							break;
						case "IO Error" :
							Console.PRINT("DBEngine", "X ERROR > ERROR CODE: 0007 > Client program cannot reach to server. Required document is missing. \n- Check the path of this document: '" + working_php_doc_now + "'." , 3, "");
							break;
						case "No Database Error" :
							Console.PRINT("DBEngine", "X ERROR > ERROR CODE: 0008 > Could not find any database to connect. Please check the name of the Database.", 3, "");
							break;
						case "Database Connection Error" :
							Console.PRINT("DBEngine", "X ERROR > ERROR CODE: 0009 > Could not connect the database.", 3, "");
							break;
						case "Query Error" :
							Console.PRINT("DBEngine", "X ERROR > ERROR CODE: 0011 > An error occured during the query processing.", 3, "");
							break;
						case "Query Row Parameter Error" :
							Console.PRINT("DBEngine", "X ERROR > ERROR CODE: 0012 > Wrong parameter has been detected in 'php/Functions/Query.PHP' ", 3, "");
							break;
						default :
							Console.PRINT("DBEngine", "X ERROR > ERROR CODE: 00010 > There is an unkown error. \n- Server side Document Path: '" + working_php_doc_now + "'. \n- Process: '" + CPPO.Process + "'.", 3, "");
							break;
					}
				}
			}
			
			QUEUE_PROCESSING.shift();
			
			try
			{
				if (Boolean(CPPO.Respond_Callback))
				{
					//->
					Console.PRINT("DBEngine", Utility.GET_OBJECT_TREE(Feedback, "DBEngine - " + CPPO.Process + " - Feedback"), 1, "");
					CPPO.Respond_Callback(Feedback);
				}
			}
			catch (e:Error)
			{
				Console.PRINT("DBEngine", "- ERROR > ERROR CODE: 0016 > There is a problem on Respond Callback Function!.\n-> Error Details: " + e, 3, "");
			}
			
			CPPO = null;
			execute_processing();
		}
		private function php_io_error(e:IOErrorEvent):void
		{
			Feedback.error_detail.push("IO Error");
			conclude_process();
		}
		private function php_progress(e:ProgressEvent):void
		{
			Console.PRINT("DBEngine", "Connection is progressing....");

			if (CPPO.Progress_Callback)
			{
				CPPO.Progress_Callback();
			}
		}
		private function reset_URL_loader_listeners():void
		{
			CPPO.URL_Loader.removeEventListener(Event.COMPLETE, php_complete);
			CPPO.URL_Loader.removeEventListener(IOErrorEvent.IO_ERROR, php_io_error);
			CPPO.URL_Loader.removeEventListener(ProgressEvent.PROGRESS, php_progress);
		}
		private function reset_feedback_object():void
		{
			var error_list:Array = new Array();
			Feedback = new Object();
			Feedback.success = false;
			Feedback.result = "Unknown";
			Feedback.error_detail = error_list;
		}
	}
}