/*

	------------------------------------------------------------
	- URL LOADER(C) 2015
	------------------------------------------------------------
	
	* FULL STATIC
	* INIT : no
	
	v1.0 : 05.08.2014 : UrlPicture sınıfı yaratıldı.
	
	v2.0 : 17.02.2015
		Eklenen yeni özellikler:
		1. Sınıf ismi UrlLoader olarak değiştiridi.
		2. Sınıf bütünüyle yenilendi.
		3. Yalnızca görsel dosyalar değil, URL ile swf nin çekebileceği bütün dosya sistemleri için kullanılabilir hale getirildi.
		4. Gelişmiş olay dinleyicileri eklendi.
		2. Console desteği eklendi.
		
	v2.1 : 12.02.2015 : 'id' ve 'no' özellikleri belirlendi.
		
	by Samet Baykul
	
*/

package lbl
{
	// Flash Library:
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.system.LoaderContext;
	import flash.system.ApplicationDomain;
	// LBL Control:
	import lbl.Console;
	
	public class UrlLoader
	{
		public static var CONTAINER_LIST:Array = new Array();
		
		public var Image_URL_Request:URLRequest;
		private var Image_Loader:Loader = new Loader();
		private var mc_initial_child_number:int;
		
		// Class Info:
		private static var id:String = "URL";
		private static var no:int = 004;

		public function UrlLoader():void
		{
			// Full static class
		}
		
		public static function LOAD_POLICY(Policy_Name:String):void
		{
			switch(Policy_Name)
			{
				case "Facebook":
					Security.allowDomain("*.facebook.com");
					Security.allowDomain("*.localdomain.net");
					Security.allowDomain("graph.facebook.com");
					Security.allowDomain("profile.ak.fbcdn.net");
					Security.allowDomain("static.ak.fbcdn.net");
					Security.allowInsecureDomain("*");
			
					Security.loadPolicyFile("https://graph.facebook.com/crossdomain.xml");
					Security.loadPolicyFile("https://profile.ak.fbcdn.net/crossdomain.xml");
					break;
			}
		}
		
		public static function LOAD_URL(Container_Names_List:Array, URL_Source_List:Array, Callback:Function = null, Get_Progress_Info:Boolean = false):void
		{
			Console.PRINT("UrlLoader", "New URLs are loading...");
			
			var loader_list:Array = new Array();
			var feedback:Object = new Object();
			
			prepare_feedback();
			create_loaders();

			function create_loaders():void
			{
				for(var i:uint = 0; i < feedback.total_url; i++)
				{
					var context:LoaderContext = new LoaderContext();
					context.applicationDomain = ApplicationDomain.currentDomain;
					context.checkPolicyFile = true;
			
					var new_url_request:URLRequest = new URLRequest(URL_Source_List[i]);
					var new_loader = new Loader();
					new_loader.name = Container_Names_List[i];
					
					loader_list.push(new_loader);
					new_loader.load(new_url_request, context);
					
					new_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loader_done);
					new_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,loader_error);
					new_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,loader_info);
				}
			}
			function loader_done(e:Event):void
			{
				feedback.loaded_url++;
				
				check_conclusion();
			}
			function loader_error(e:IOErrorEvent):void
			{
				Console.PRINT("UrlLoader", "X ERROR > ERROR CODE: 0049 > There is an IO Error while loading picture.", 3, "");
				Console.PRINT("UrlLoader", "> ERROR DETAILS > The loaded part is " + e.target.bytesLoaded + "/" + e.target.bytesTotal + ". IO Error: " + e, 2, "");
				
				feedback.loaded_url++;
			}
			function loader_info(e:ProgressEvent):void
			{
				var loaded_Kb:int = 0;
				var total_Kb:int = 0;
				
				for (var i:uint = 0; i < feedback.total_url; i++)
				{
					feedback[loader_list[i].name].loaded_Kb = int(loader_list[i].contentLoaderInfo.bytesLoaded / 1024);
					feedback[loader_list[i].name].total_Kb = int(loader_list[i].contentLoaderInfo.bytesTotal / 1024);
							 
					loaded_Kb += int(loader_list[i].contentLoaderInfo.bytesLoaded / 1024);
					total_Kb += int(loader_list[i].contentLoaderInfo.bytesTotal / 1024);
				}
				
				feedback.loaded_Kb = loaded_Kb;
				feedback.total_Kb = total_Kb;
				
				if (Get_Progress_Info && Boolean(Callback))
				{
					Callback(feedback);
				}
			}
			function prepare_feedback():void
			{
				feedback.status = "Progress";
				feedback.loaded_Kb = 0;
				feedback.total_Kb = 0;
				feedback.loaded_url = 0;
				feedback.total_url = Container_Names_List.length;
				
				for(var i:uint = 0; i < feedback.total_url; i++)
				{
					feedback[Container_Names_List[i]] = new Object();
					feedback[Container_Names_List[i]].status = "Progress";
					feedback[Container_Names_List[i]].loaded_Kb = 0;
					feedback[Container_Names_List[i]].total_Kb = 0;
				}
			}
			function check_conclusion():void
			{
				if (feedback.loaded_url == feedback.total_url)
				{
					for (var i:uint = 0; i < feedback.total_url; i++)
					{			
						var loader_bytesLoaded:int = loader_list[i].contentLoaderInfo.bytesLoaded / 1024;
						var loader_bytesTotal:int = loader_list[i].contentLoaderInfo.bytesTotal / 1024;
						
						if (loader_bytesLoaded == loader_bytesTotal)
						{
							feedback[loader_list[i].name].status = "Ok";
							CONTAINER_LIST[loader_list[i].name] = new Loader();
							CONTAINER_LIST[loader_list[i].name] = loader_list[i];
						}
						else
						{
							feedback[loader_list[i].name].status = "Fail";
						}
						
						loader_list[i].contentLoaderInfo.removeEventListener(Event.COMPLETE,loader_done);
						loader_list[i].contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,loader_error);
						
						if (Get_Progress_Info)
						{
							loader_list[i].contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,loader_info);
						}
						
						loader_list[i] = null;
					}
					
					feedback.status = "Ok";
					
					if (Boolean(Callback))
					{
						Callback(feedback);
					}
				}
			}
		}
		
		public static function LOAD_URL_BY_STEP(Container_Names_List:Array, URL_Source_List:Array, Callback:Function = null, Get_Progress_Info:Boolean = false):void
		{
			Console.PRINT("UrlLoader", "New URLs are loading...");
			
			var feedback:Object = new Object();
			var current_loader:Loader;
			
			prepare_feedback();
			create_loader(Container_Names_List[0], URL_Source_List[0]);
			
			function create_loader(Container:String, URL_Adress:String):void
			{
				var new_url_request:URLRequest = new URLRequest(URL_Adress);
				
				current_loader = new Loader();
				current_loader.name = Container_Names_List[feedback.loaded_url];
				current_loader.load(new_url_request);
				
				current_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loader_done);
				current_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,loader_error);
				current_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,loader_info);
			}
			function loader_done(e:Event):void
			{
				Console.PRINT("UrlLoader", "New URL is loaded successfully.");
				
				CONTAINER_LIST[Container_Names_List[feedback.loaded_url]] = new Loader();
				CONTAINER_LIST[Container_Names_List[feedback.loaded_url]] = current_loader;
				
				feedback[Container_Names_List[feedback.loaded_url]].status = "Ok";
				next_loader();
			}
			function loader_error(e:IOErrorEvent):void
			{
				Console.PRINT("UrlLoader", "X ERROR > ERROR CODE: 0050 > There is an IO Error while loading picture.", 3, "");
				Console.PRINT("UrlLoader", "> ERROR DETAILS > The loaded part is " + e.target.bytesLoaded + "/" + e.target.bytesTotal + ". IO Error: " + e, 2, "");
				
				current_loader.close();
				feedback[Container_Names_List[feedback.loaded_url]].status = "Fail";
				next_loader();
			}
			function loader_info(e:ProgressEvent):void
			{
				feedback[Container_Names_List[feedback.loaded_url]].loaded_Kb = int(e.bytesLoaded / 1024);
				feedback[Container_Names_List[feedback.loaded_url]].total_Kb = int(e.bytesTotal / 1024);
				feedback.loaded_Kb = int(e.bytesLoaded / 1024);
				feedback.total_Kb = int(e.bytesTotal / 1024);
				
				if (Get_Progress_Info && Boolean(Callback))
				{
					Callback(feedback);
				}
			}
			function next_loader():void
			{
				remove_listeners();
				feedback.loaded_url++;
		
				if (feedback.loaded_url < feedback.total_url)
				{
					create_loader(Container_Names_List[feedback.loaded_url], URL_Source_List[feedback.loaded_url])
				}
				else
				{
					feedback.status = "Ok";
					
					if (Boolean(Callback))
					{
						Callback(feedback);
					}
				}
			}
			function prepare_feedback():void
			{
				feedback.status = "Progress";
				feedback.loaded_Kb = 0;
				feedback.total_Kb = 0;
				feedback.loaded_url = 0;
				feedback.total_url = Container_Names_List.length;
				
				for(var i:uint = 0; i < feedback.total_url; i++)
				{
					feedback[Container_Names_List[i]] = new Object();
					feedback[Container_Names_List[i]].status = "Progress";
					feedback[Container_Names_List[i]].loaded_Kb = 0;
					feedback[Container_Names_List[i]].total_Kb = 0;
				}
			}
			function remove_listeners():void
			{
				current_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,loader_done);
				current_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,loader_error);
				
				if (Get_Progress_Info)
				{
					current_loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,loader_info);
				}
				
				current_loader = null;
			}
		}
		
		public static function GET_BITMAP(Target:MovieClip, Bitmap_Container_Name:String, Clone:Boolean = true):void
		{
			if (Boolean(CONTAINER_LIST[Bitmap_Container_Name]))
			{
				var cloned_bitmap:Bitmap;
				
				if (Clone)
				{
					try
					{
						if (CONTAINER_LIST[Bitmap_Container_Name].content is Bitmap)
						{
							cloned_bitmap = new Bitmap(CONTAINER_LIST[Bitmap_Container_Name].content.bitmapData.clone());
			
							cloned_bitmap.name = Bitmap_Container_Name;
			
							Target.addChild(cloned_bitmap);
						}
					}
					catch(e:Error)
					{
						Console.PRINT("UrlLoader", "X ERROR > ERROR CODE: 0051 > '" + Bitmap_Container_Name + "' cannot be cloned! This bitmap is maybe protected against copying under copyrights.", 3, "");
						Console.PRINT("UrlLoader", "- ERROR DETAILS > " + e, 2, "");
					}
				}
				else if (CONTAINER_LIST[Bitmap_Container_Name] is Loader)
				{
					Target.addChild(CONTAINER_LIST[Bitmap_Container_Name]);
				}
				else
				{
					Console.PRINT("UrlLoader", "X ERROR > ERROR CODE: 0052 > There is no available object which name is '" + Bitmap_Container_Name + "' in 'CONTAINER_LIST'.", 3, "");
				}
			}
			else
			{
				Console.PRINT("UrlLoader", "X ERROR > ERROR CODE: 0053 > There is no container which name is '" + Bitmap_Container_Name + "' in 'CONTAINER_LIST'.", 3, "");
			}
		}
		
		public static function DELETE(Container_Names_List:Array):void
		{
			for(var i:uint = 0; i < Container_Names_List.length; i++)
			{
				CONTAINER_LIST[Container_Names_List[i]].unload();
				CONTAINER_LIST[Container_Names_List[i]] = null;
			}
		}
		
		public static function REMOVE_BITMAP(Target:MovieClip, Bitmap_Name:String):void
		{
			for (var i:uint = 0; i < Target.numChildren; i++)
			{
				if (Target.getChildAt(i) is Bitmap)
				{
					if (Target.getChildAt(i).name == Bitmap_Name)
					{
						Target.removeChildAt(i);
					}
				}
			}
		}
	}
}