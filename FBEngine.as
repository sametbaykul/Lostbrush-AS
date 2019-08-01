/*

	------------------------------------------------------------
	- FACEBOOK ENGINE(C) 2014 - 2015
	------------------------------------------------------------
	
	* FULL STATIC
	* INIT : true
	
	v1.0 : 09.08.2014 : Actionscript3 Facebook API kullanılarak hazırlandı.
	
	v2.0 : 09.03.2015 : JSEngine ile desteklenerek sınıf baştan yaratıldı.
	v2.1 : 12.02.2015 : 'id' ve 'no' özellikleri belirlendi.

	by Samet Baykul
	
*/

package lbl
{
	// Flash Library:
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	import flash.system.Security;
	import flash.external.ExternalInterface;
	// LBL Control:
	import lbl.Console;
	// LBL Network:
	import lbl.JSEngine;

	public class FBEngine
	{		
		public static var LOGIN_STATUS:Boolean = false;
		
		private static var permissions:Object;
		private static var CB_interval:uint;
		private static var mobile_support:Boolean;
		
		// Class Info:
		private static var id:String = "FBE";
		private static var no:int = 005;
		
		public function FBEngine():void
		{
			// Full static class
		}
		
		// ----------------------------------------------------------------
		// METHODS:
		// ----------------------------------------------------------------
		
		public static function INIT(Callback:Function, Timeout:uint = 10000):void
		{
			Console.PRINT("FBEngine", "Facebook is initializing....");
			
			var CB_interval:uint; 
			var feedback:Object = create_feedback();
			
			if (Timeout)
			{
				CB_interval = setTimeout(force_callback, Timeout);
			}
			
			JSEngine.CALL("FB_INIT", RC_FB_init, false, Timeout); 
			
			function RC_FB_init(Respond:Object):void
			{
				feedback = Respond;
				
				if (feedback.success)
				{
					if (feedback.result.status == "connected")
					{
						Console.PRINT("FBEngine","Facebook connection is ready.");
						
						LOGIN_STATUS = true;
					}
					else if(feedback.result.status == "not_authorized")
					{
						Console.PRINT("FBEngine", "Facebook has initialized. But not authorized.");
					}
				}
				else
				{
					Console.PRINT("FBEngine","X ERROR > ERROR CODE: 0038 > An error occured while connecting Facebook.", 3, "");
				}
				
				call_RC();
			}
			function call_RC():void
			{
				Console.PRINT("FBEngine", Utility.GET_OBJECT_TREE(feedback, "FBEngine - INIT Feedback"), 1, "");
				
				clearTimeout(CB_interval);
				CB_interval = 0;
				Callback(feedback);
			}
			function force_callback():void
			{
				if (CB_interval)
				{
					Console.PRINT("JSEngine", "- WARNING > Timeout occured on FBEngine - INIT() method during " + Timeout + " miliseconds.", 2, "");
					
					feedback.fail = "Timeout";
					call_RC();
				}
			}
		}
		
		public static function LOGIN(Callback:Function, Timeout:uint = 60000):void
		{
			Console.PRINT("FBEngine", "Logging with Facebook....");
			
			var CB_interval:uint; 
			var feedback:Object = create_feedback();
			
			if (Timeout)
			{
				CB_interval = setTimeout(force_callback, Timeout);
			}	 
			
			if (LOGIN_STATUS)
			{
				Console.PRINT("FBEngine","Facebook is already connected.");
				
				feedback.success = true;
				feedback.result = "Already Connected";
				call_RC();
			}
			else
			{
				Console.PRINT("FBEngine","Logging to Facebook...");
				 
				JSEngine.CALL("FB_LOGIN", RC_FB_login, false, Timeout);
			}
			
			function RC_FB_login(Respond:Object):void
			{
				feedback = Respond;
				
				if (feedback.success)
				{
					if (feedback.result.status == "connected")
					{
						Console.PRINT("FBEngine","You are logged in with Facebook.");
					}
					else if(feedback.result.status == "not_authorized")
					{
						Console.PRINT("FBEngine", "Facebook has not authorized.");
					}
				}
				else
				{
					Console.PRINT("FBEngine","X ERROR > ERROR CODE: 0039 > An error occured while logging with Facebook.", 3, "");
				}
				
				call_RC(feedback);
			}
			function call_RC():void
			{
				Console.PRINT("FBEngine", Utility.GET_OBJECT_TREE(feedback, "FBEngine - LOGIN Feedback"), 1, "");
				
				clearTimeout(CB_interval);
				CB_interval = 0;
				Callback(feedback);
			}
			function force_callback():void
			{
				if (CB_interval)
				{
					Console.PRINT("JSEngine", "- WARNING > Timeout occured on FBEngine - LOGIN() method during " + Timeout + " miliseconds.", 2, "");
					
					feedback.fail = "Timeout";
					call_RC();
				}
			}
		}
		
		public static function LOGOUT(Callback:Function, Timeout:uint = 15000):void
		{
			Console.PRINT("FBEngine", "Logging out from Facebook....");
			
			var CB_interval:uint; 
			var feedback:Object = create_feedback();
			
			if (Timeout)
			{
				CB_interval = setTimeout(force_callback, Timeout);
			}	 
			
			if (LOGIN_STATUS)
			{
				Console.PRINT("FBEngine","Disconnecting from Facebook...");
				
				JSEngine.CALL("FB_LOGOUT", RC_FB_logout, false, Timeout);
			}
			else
			{
				Console.PRINT("FBEngine","Facebook is already disconnected.");
 
				feedback.result = "Already Disconnected";
				call_RC();
			}
			
			function RC_FB_logout(Respond:Object):void
			{
				feedback = Respond;
				
				if (feedback.success)
				{
					Console.PRINT("FBEngine","You are disconnected from Facebook.");
					
					LOGIN_STATUS = false;
				}
				else
				{
					Console.PRINT("FBEngine","X ERROR > ERROR CODE: 0040 > An error occured while disconnecting from Facebook.", 3, "");
				}
				
				call_RC(feedback);
			}
			function call_RC():void
			{
				Console.PRINT("FBEngine", Utility.GET_OBJECT_TREE(feedback, "FBEngine - LOGOUT Feedback"), 1, "");
				
				clearTimeout(CB_interval);
				CB_interval = 0;
				Callback(feedback);
			}
			function force_callback():void
			{
				if (CB_interval)
				{
					Console.PRINT("JSEngine", "- WARNING > Timeout occured on FBEngine - LOGOUT() method during " + Timeout + " miliseconds.", 2, "");
					
					feedback.fail = "Timeout";
					call_RC();
				}
			}
		}
		
		public static function ASK(Path:String, Callback:Function, Timeout:uint = 15000):void
		{
			var path:String = "/" + Path;
			var method:String = "get";
			var CB_interval:uint; 
			var feedback:Object = create_feedback();
			var params_object:Object = new Object();
			
			if (Timeout)
			{
				CB_interval = setTimeout(force_callback, Timeout);
			}	 
			
			if (LOGIN_STATUS)
			{
				Console.PRINT("FBEngine", "'" + Path + "' is asking to Facebook....");

				JSEngine.CALL("FB_API", RC_FB_api, false, Timeout, path, method, params_object);
			}
			else
			{
				Console.PRINT("FBEngine","- WARNING > Before using GraphAPI of Facebook, you must login.", 2, "");
			}
			
			function RC_FB_api(Respond:Object):void
			{
				feedback = Respond;
				
				if (feedback.success)
				{
					if (feedback.result.id)
					{
						Console.PRINT("FBEngine","Information is taken from Facebook.");
					}
					else if(feedback.result.error)
					{
						Console.PRINT("FBEngine", "- WARNING > AuthResponseError on GraphApi", 2, "");
					}
				}
				else
				{
					Console.PRINT("FBEngine","X ERROR > ERROR CODE: 0041 > An error occured while asking on Facebook GraphAPI.", 3, "");
				}
				
				call_RC(feedback);
			}
			function call_RC():void
			{
				Console.PRINT("FBEngine", Utility.GET_OBJECT_TREE(feedback, "FBEngine - ASK - " + Path + "Feedback"), 1, "");
				
				clearTimeout(CB_interval);
				CB_interval = 0;
				Callback(feedback);
			}
			function force_callback():void
			{
				if (CB_interval)
				{
					Console.PRINT("JSEngine", "- WARNING > Timeout occured on FBEngine - ASK() method during " + Timeout + " miliseconds.", 2, "");
					
					feedback.fail = "Timeout";
					call_RC();
				}
			}
		}
		
		public static function GET_PICTURE(Path:String, Width:uint, Height:uint, Type:String, Callback:Function, Timeout:uint = 15000):void
		{
			var path:String = "/" + Path + "/picture";
			var method:String = "get";
			var CB_interval:uint; 
			var feedback:Object = create_feedback();
			var params_object:Object = 
			{
				"redirect": false,
				"width": String(Width),
				"height": String(Height),
				"type": Type
			};
			
			if (Timeout)
			{
				CB_interval = setTimeout(force_callback, Timeout);
			}	 
			
			if (LOGIN_STATUS)
			{
				Console.PRINT("FBEngine", "'" + Path + "' is asking to Facebook....");

				JSEngine.CALL("FB_API", RC_FB_api, false, Timeout, path, method, params_object);
			}
			else
			{
				Console.PRINT("FBEngine","- WARNING > Before using GraphAPI of Facebook, you must login.", 2, "");
			}
			
			function RC_FB_api(Respond:Object):void
			{
				feedback = Respond;
				
				if (feedback.success)
				{
					if (feedback.result.data.url)
					{
						Console.PRINT("FBEngine","Profile picture URL is taken from Facebook.");
					}
					else
					{
						Console.PRINT("FBEngine", "- WARNING > Profile picture URL is missed! ", 2, "");
					}
				}
				else
				{
					Console.PRINT("FBEngine","X ERROR > ERROR CODE: 0042 > An error occured while getting profile picture on Facebook.", 3, "");
				}
				
				call_RC(feedback);
			}
			function call_RC():void
			{
				Console.PRINT("FBEngine", Utility.GET_OBJECT_TREE(feedback, "FBEngine - GET_PICTURE Feedback"), 1, "");
				
				clearTimeout(CB_interval);
				CB_interval = 0;
				Callback(feedback);
			}
			function force_callback():void
			{
				if (CB_interval)
				{
					Console.PRINT("JSEngine", "- WARNING > Timeout occured on FBEngine - GET_PICTURE() method during " + Timeout + " miliseconds.", 2, "");
					
					feedback.fail = "Timeout";
					call_RC();
				}
			}
		}
		
		public static function REQUEST(Message:String, Callback:Function, Action_Type:String = null, Object_ID:int = 0, To:Array = null, Timeout:uint = 15000):void
		{
			var CB_interval:uint; 
			var feedback:Object = create_feedback();
			var params_object:Object = new Object();
			
			params_object.method = "apprequests";
			params_object.message = Message;
			
			if (Action_Type && Object_ID)
			{
				params_object.action_type = Action_Type;
				params_object.object_id = String(Object_ID);
			}
			if (To)
			{
				params_object.to = To.join(",");
			}
			
			if (Timeout)
			{
				CB_interval = setTimeout(force_callback, Timeout);
			}	 
			
			if (LOGIN_STATUS)
			{
				Console.PRINT("FBEngine", "The request is sending with Facebook....");

				JSEngine.CALL("FB_UI", RC_FB_ui, false, Timeout, params_object);
			}
			else
			{
				Console.PRINT("FBEngine","- WARNING > Before using UI of Facebook, you must login.", 2, "");
			}
			
			function RC_FB_ui(Respond:Object):void
			{
				feedback = Respond;
				
				if (feedback.success)
				{
					if (feedback.result.id)
					{
						Console.PRINT("FBEngine","Request was send successfully.");
					}
					else if(feedback.result.error)
					{
						Console.PRINT("FBEngine", "- WARNING > AuthResponseError on UI.", 2, "");
					}
				}
				else
				{
					Console.PRINT("FBEngine","X ERROR > ERROE CODE: 0043 > An error occured while sending request with Facebook.", 3, "");
				}
				
				call_RC(feedback);
			}
			function call_RC():void
			{
				Console.PRINT("FBEngine", Utility.GET_OBJECT_TREE(feedback, "FBEngine - SEND REQUEST - Feedback"), 1, "");
				
				clearTimeout(CB_interval);
				CB_interval = 0;
				Callback(feedback);
			}
			function force_callback():void
			{
				if (CB_interval)
				{
					Console.PRINT("JSEngine", "- WARNING > Timeout occured on FBEngine - SEND_REQUEST() method during " + Timeout + " miliseconds.", 2, "");
					
					feedback.fail = "Timeout";
					call_RC();
				}
			}
		}
		
		// ----------------------------------------------------------------
		// PRIVATE FUNCTIONS:
		// ----------------------------------------------------------------
		
		public static function SCS():void
		{
			Console.ADD_COMMAND("fbeinit", init);
			Console.ADD_COMMAND("fbelogin", login);
			Console.ADD_COMMAND("fbelogout", logout);
			Console.ADD_COMMAND("fbeask", ask);
			Console.ADD_COMMAND("fbegetpicture", get_picture);
			Console.ADD_COMMAND("fberequest", request);
			
			function init():void
			{
				Console.PRINT("FBEngine", "INIT() is testing....", 2);
				INIT(RC_TEST);
			}
			function login():void
			{
				Console.PRINT("FBEngine", "LOGIN() is testing....", 2);
				LOGIN(RC_TEST);
			}
			function logout():void
			{
				Console.PRINT("FBEngine", "LOGOUT() is testing....", 2);
				LOGOUT(RC_TEST);
			}
			function ask(Path:String):void
			{
				Console.PRINT("FBEngine", "ASK() is testing....", 2);
				ASK(Path,RC_TEST);
			}
			function get_picture(Path:String):void
			{
				Console.PRINT("FBEngine", "GET_PICTURE() is testing....", 2);
				GET_PICTURE(Path,32,32,"small",RC_TEST);
			}
			function request(Message:String):void
			{
				Console.PRINT("FBEngine", "REQUEST() is testing....", 2);
				REQUEST(Message, RC_TEST);
			}
			
			function RC_TEST(Respond:Object):void
			{
				Console.PRINT("FBEngine - TEST" , Utility.GET_OBJECT_TREE(Respond, "Respond"), 1, "");
			}
			
		}
		
		private static function create_feedback():Object
		{
			var feedback:Object = new Object();
			feedback.success = false;
			feedback.result = false;
			feedback.fail = false;
			
			return feedback;
		}
	}
}