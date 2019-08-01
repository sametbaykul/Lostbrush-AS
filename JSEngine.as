/*

	------------------------------------------------------------
	- JAVASCRIPT ENGINE(C) 2015
	------------------------------------------------------------
	
	* FULL STATIC
	* INIT : no
	
	v1.0 : 06.03.2015 : Harici JavaScript dosyaları ile iletişim kurmak için tasarlanmıştır.
	v1.1 : 12.02.2015 : 'id' ve 'no' özellikleri belirlendi.

	by Samet Baykul
	
*/

package lbl
{
	// Flash Library:
	import flash.external.ExternalInterface;
	import flash.system.Security;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.setInterval;
	import flash.utils.clearInterval;
	// LBL Core:
	import lbl.Access;
	import lbl.Utility;
	// LBL Control:
	import lbl.Console;
	
	
	public class JSEngine 
	{
		
		public static var JS_READY:Boolean = false;

		// Class Info:
		private static var id:String = "JSE";
		private static var no:int = 015;
		
		public function JSEngine() 
		{
			// Full static class
		}
		
		// ----------------------------------------------------------------
		// METHODS:
		// ----------------------------------------------------------------
		
		public static function CONNECT_JS(Callback:Function, Timeout:uint = 10000):void
		{
			var CB_interval:uint = setInterval (force_callback, Timeout);
			var ready_timer:Timer; 
			
			Security.allowDomain("*");

			if (ExternalInterface.available)
			{
				try
				{
					Console.PRINT("JSEngine","Checking Javascript connection....");

					if (is_js_ready())
					{
						Console.PRINT("JSEngine","Javascript connection is ready.");
						
						JS_READY = true;
						call_RC(true);
					}
					else
					{
						ready_timer = new Timer(1000,0);
						ready_timer.addEventListener(TimerEvent.TIMER,timer_handler);
						ready_timer.start();
					}
				}
				catch (error:SecurityError)
				{
					Console.PRINT("JSEngine","X ERROR > ERROR CODE: 0044 > Security error: " + error.message, 3, "");
					
					JS_READY = false;
					call_RC(false);
				}
				catch (error:Error)
				{
					Console.PRINT("JSEngine","X ERROR > ERROR CODE: 0045 > Unknown error occured while connecting JS: " + error.message, 3, "");
					Console.PRINT("JSEngine","- JS_READY > " + JS_READY, 2, "");
					
					JS_READY = false;
					call_RC(false);
				}
			}
			else
			{
				Console.PRINT("JSEngine","- WARNING > 'External interface' is not suitable for your browser.", 2, "");
				
				JS_READY = false;
				call_RC(false);
			}
			function is_js_ready():Boolean
			{
				var is_ready:Boolean = false;
				
				if (ExternalInterface.available)
				{
					is_ready = ExternalInterface.call("TEST_JS_READY");
				}
				
				return is_ready;
			}
			function timer_handler(event:TimerEvent):void
			{
				Console.PRINT("JSEngine","- WARNING > Trying to connect JavaScript again....", 2, "");
				
				var is_ready:Boolean = is_js_ready();

				if (is_ready)
				{
					Console.PRINT("JSEngine","Javascript is connected successfully.");
					
					Timer(event.target).stop();
					JS_READY = true;
					call_RC(true);
				}
			}
			function call_RC(Feedback:Object):void
			{
				clearInterval(CB_interval);
				CB_interval = 0;
				
				if (ready_timer)
				{
					ready_timer.removeEventListener(TimerEvent.TIMER,timer_handler);
					ready_timer.stop();
				}
				
				Callback(Feedback);
			}
			function force_callback():void
			{
				if (CB_interval)
				{
					Console.PRINT("JSEngine", "- WARNING > Timeout occured on CONNECT_JS() method during " + Timeout + " miliseconds.", 2, "");
					
					call_RC(false);
				}
			}
		}
		
		public static function ADD_METHOD(Method_Name:String, Method:Function):void
		{
			Console.PRINT("JSEngine","The method, '" + Method_Name + "' is added to the 'EIML'.");
			
			Access.EIML[Method_Name] = Method;
			ExternalInterface.addCallback(Method_Name, Method);
		}
		
		public static function CALL(Method_Name:String, Callback:Function = null, Return:Boolean = false, Timeout:uint = 10000, ... args):void
		{
			var CB_interval:uint;
			var feedback:Object = create_feedback();
			
			if (Boolean(JS_READY) && Boolean(Callback) && Boolean(Timeout))
			{
				CB_interval = setInterval (force_callback, Timeout); 
			}
			
			Security.allowDomain("*");

			if (JS_READY)
			{
				try
				{
					Console.PRINT("JSEngine","Calling '" + Method_Name + "(" + String(args) +")'....");
					
					if (Boolean(Callback) && Boolean(Return))
					{
						feedback.result = ExternalInterface.call(Method_Name, args);
						
						if (feedback.result)
						{
							feedback.success = true;
						}
						else
						{
							feedback.fail = "Not Returned";
						}
							
						call_RC(feedback);
					}
					else if (Boolean(Callback) && !Boolean(Return))
					{	
						var RC_Method_Name:String = "RC_" + Method_Name;
						Access.EIML[RC_Method_Name] = call_RC;
						ExternalInterface.addCallback(RC_Method_Name, call_RC);
						ExternalInterface.call(Method_Name, args);
					}
					else if (!Boolean(Callback) && !Boolean(Return))
					{
						ExternalInterface.call(Method_Name, args);
						feedback.success = true;
						call_RC(feedback);
					}
					else
					{
						Console.PRINT("JSEngine","X ERROR > ERROR CODE: 0046 > Parameter error on 'CALL_FROM_JS()' method. If 'Return' parameter is 'true', the parameter 'Callback' cannot be 'null'.", 3, "");
						
						feedback.fail = "Parameter Error";
						call_RC(feedback);
					}
				}
				catch (e:Error)
				{
					Console.PRINT("JSEngine","X ERROR > ERROR CODE: 0047 > Unknown error occured while calling a method '" + Method_Name + "'.", 3, "");
					Console.PRINT("JSEngine","- ERROR DETAILS > " + e.message, 2, "");
					Console.PRINT("JSEngine","- JS_READY > " + JS_READY, 2, "");
					
					feedback.fail = "Unknown Error";
					call_RC(feedback);
				}
			}
			else
			{
				Console.PRINT("JSEngine","X ERROR > ERROR CODE: 0048 > JavaScript is not ready. Please use CONNECT_JS() method first", 3, "");
				
				feedback.fail = "Not Ready";
				call_RC(feedback);
			}
			function call_RC(Respond:Object):void
			{
				clearInterval(CB_interval);
				CB_interval = 0;
				
				if (Boolean(Callback))
				{
					Callback(Respond);
				}
			}
			function force_callback():void
			{
				if (CB_interval)
				{
					Console.PRINT("JSEngine", "- WARNING > Timeout occured on CALL_FROM_JS("+ Method_Name +") method during " + Timeout + " miliseconds.", 2, "");
					
					if (Boolean(Callback))
					{
						feedback.fail = "Timeout";
						call_RC(feedback);
					}
				}
			}
		
		}
		
		// ----------------------------------------------------------------
		// PRIVATE FUNCTIONS:
		// ----------------------------------------------------------------
		
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
