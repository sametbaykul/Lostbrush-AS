/*

	------------------------------------------------------------
	- CURSOR(C) 2015
	------------------------------------------------------------
	
	* FULL STATIC
	* INIT : true
	
	v1.0 : 15.09.2015 : İlk defa Map 2015 sınıfı için üretilmiştir. Ancak, daha önce bu sınıf yapısına benzer bir algoritmayı DBEngine 2014 sınıfı kullanmıştı. Temelde benzer algoritma geliştirilerek bu sınıf yaratıldı.
	
		Protocol numaraları ve açıklamaları:
		
		-2 : Operatör, işlemi işlem sırasına almayı reddeder.
		-1 : Operatör, işlemi kabul eder ve sıraya alır. Ancak sıra bu işleme geldiğinde bu işlemi iptal eder.
		 0 : Operatör işlemi sıraya alır. Sıra bu işleme geldiğinde, işlemi tekrar kuyruğun sonuna atar. Bu şekilde işlem dondurulur.
		 1 : Operatör normal bir şekilde işlemi kuyruğun sonuna ekler ve sırası geldiğinde çalıştırır.
		 2 : Operatör bu işlemi ilk sıraya yerleştirir.
		 3 : Operatör diğer bütün işlemlerini iptal eder ve bu işlemi gerçekleştirir.
		 4 : Operatör diğer bütün işlemlerini iptal eder ve bu işlemi gerçekleştirene kadar yeni bir işlemi sıraya almaz.
		 5 : İşlem için yeni bir operator üretilir. İşlem derhal gerçekleştirilir. Ayrıca etiket kontrolünden de muaftır.
		 
		 Etiket Kontrolü: Bir operatör, gelen yeni işlemlerdeki etiketlerden bazılarının önceki işlemlerden en az birinde olduğunu tespit ederse, bu işlemin protokolünü -2 ye düşürme hakkına sahiptir.
	
	v1.1 : 12.02.2016 : 'id' ve 'no' özellikleri belirlendi.
	v1.2 : 21.02.2016 : Sınıfın kullanıma hazır olup olmadığı kontrolü yerleştirildi.
	v1.3 : 20.03.2016 : RUN_CHAIN() metodundaki RC_Chain tetiklenmeme hatası giderildi.
	v1.4 : 23.04.2016 : TIMER yapısı güncellendi.
	
	by Samet Baykul
	
*/


package lbl
{
	// Flash Library:
	import flash.utils.*;
	import flash.events.Event;
	import flash.events.TimerEvent;
	// LBL Core:
	import lbl.Gensys;
	import lbl.Utility;
	import lbl.MathLab;
	// LBL Control:
	import lbl.Console;
		

	public class Processor
	{
		// ------------------------------------------------------------
		// PROPERTIES :
		// ------------------------------------------------------------
		
		public static var TIMER_DEP:Timer;
		public static var TIMER_IND:Timer;
		public static var ACTIVE:Boolean;

		private static var operators:Object;
		private static var started_time:uint;
		private static var ready:Boolean = false;
		private static var ready_m:Boolean = false;
		
		// Class Info:
		private static var id:String = "PRO";
		private static var no:int = 020;
		
		public function Processor()
		{
			// Full static class
		}
		
		// ----------------------------------------------------------------
		// METHODS :
		// ----------------------------------------------------------------
		
		public static function INIT():void
		{
			init_vars();
			init_timer();
			init_commands();
			
			function init_vars():void
			{
				operators = new Object();
				
				ready = true;
			}
			function init_timer():void
			{
				TIMER_DEP = Gensys.TIMEL["Global"];
				TIMER_IND = Gensys.NEW_TIMER("Processor_Clock");
			}
			function init_commands():void
			{
				Console.ADD_COMMAND(id, "prostart", START);
				Console.ADD_COMMAND(id, "prostop", STOP);
			}
		}
		
		public static function START():void
		{
			if (!ACTIVE)
			{
				TIMER_DEP.addEventListener(TimerEvent.TIMER, check_process_dep, false, 0, true);
				TIMER_IND.addEventListener(TimerEvent.TIMER, check_process_ind, false, 0, true);
				TIMER_IND.start();
				
				ACTIVE = true;
				started_time = getTimer();
			}
		}
		
		public static function STOP():void
		{
			if (ACTIVE)
			{
				TIMER_DEP.removeEventListener(TimerEvent.TIMER, check_process_dep);
				TIMER_IND.removeEventListener(TimerEvent.TIMER, check_process_ind);
				TIMER_IND.stop();
				
				ACTIVE = false;
			}
		}
		
		public static function RESET():void
		{
			for (var operator_name:String in operators)
			{
				delete operators[operator_name];
			}
			
			STOP();
		}
		
		public static function ADD(Process:Function, Protocol:int = 1, Operator:String = "Main", Tags:Array = null, Delay:uint = 0, Timeout:uint = 15000, Dependency:Boolean = false):void
		{
			if (check_INIT())
			{
				var process:Object = new_process();
				process.mission = Process;
				process.protocol = Protocol;
				process.operator = Operator;
				process.tags = Tags;
				process.delay = Delay;
				process.timeout_time = Timeout;
				process.dependency = Dependency;
				
				add_new_process(process);
			}
		}
		
		public static function ABORT(Operator_Name:String = "Main", Tags:Array = null):void
		{
			change_process_protocol(-1, Operator_Name, Tags);
		}
		
		public static function FREEZE(Operator_Name:String = "Main", Tags:Array = null):void
		{
			change_process_protocol(0, Operator_Name, Tags);
		}
		
		public static function SET_OPERATOR(Operator_Name:String, Activity:Boolean = true):void
		{
			operators[Operator_Name].activity = Activity;
		}
		
		public static function RUN_CHAIN(Function_List:Array, RC_Chain:Function = null, Step_Function:Function = null):void
		{
			for (var i:int = 0; i < Function_List.length; i ++)
			{
				if (!Boolean(Function_List[i]()))
				{
					break;
				}
				else if (i == Function_List.length - 1)
				{
					if (Boolean(RC_Chain))
					{
						RC_Chain();
					}
				}
				
				if (Boolean(Step_Function))
				{
					Step_Function(i + 1);
				}
			}
		}

		// ------------------------------------------------------------
		// FUNCTIONS :
		// ------------------------------------------------------------
		
		private static function add_new_process(Process:Object):void
		{
			check_available_operator();
			check_tags();
			add_queue();
			
			START();
			
			function check_available_operator():void
			{
				if (Utility.TEST_OBJECT_STANDART(operators, [Process.operator]))
				{
					if (Process.protocol == 5)
					{
						var family_index:int;
							
						for (var operator_name:String in operators)
						{
							if (Utility.SEARCH_TEXT(operator_name, Process.operator))
							{
								family_index++;
							}
						}
						
						Process.operator = Process.operator + String("_" + family_index);
					}
				}
				else
				{
					operators[Process.operator] = new_operator();
				}
			}
			function check_tags():void
			{
				for (var i:int = 0; i < operators[Process.operator].queue.length; i++)
				{
					if (Boolean(Process.tags))
					{
						if (Utility.TEST_ARRAY_ELEMENTS(operators[Process.operator].queue[i].tags, Process.tags))
						{
							Process.protocol = -2;
						}
					}
				}
			}
			function add_queue():void
			{
				for (var i:int = 0; i < operators[Process.operator].queue.length; i++)
				{
					if (operators[Process.operator].queue[i].protocol == 4)
					{
						Process.protocol = -2;
					}
				}
				
				if (Process.protocol == 3 || Process.protocol == 4)
				{
					for (var j:int = 0; j < operators[Process.operator].queue.length; j++)
					{
						delete operators[Process.operator].queue[j];
					}
					
					operators[Process.operator].queue.length = 0;
				}
				
				if (Process.protocol == -1 || Process.protocol == 0 || Process.protocol == 1)
				{
					operators[Process.operator].queue.push(Process);
				}
				else if (Process.protocol >= 2)
				{
					operators[Process.operator].queue.unshift(Process)
				}
			}
		}
		private static function change_process_protocol(New_Protocol:int, Operator_Name:String, Tags:Array = null):void
		{
			if (Boolean(operators))
			{
				if (Boolean(operators[Operator_Name]))
				{
					for (var i:int; i < operators[Operator_Name].queue.length; i++)
					{
						if (Boolean(Tags) && Boolean(operators[Operator_Name].queue[i].tags))
						{
							if (Utility.TEST_ARRAY_ELEMENTS(operators[Operator_Name].queue[i].tags, Tags))
							{
								operators[Operator_Name].queue[i].protocol = New_Protocol;
							}
						}
						else (!Boolean(Tags) && !Boolean(operators[Operator_Name].queue[i].tags))
						{
							operators[Operator_Name].queue[i].protocol = New_Protocol;
						}
					}
				}
			}
		}
		private static function check_process_ind(e:TimerEvent):void
		{
			run_processor(false);
		}
		private static function check_process_dep(e:TimerEvent):void
		{
			run_processor(true);
		}
		private static function run_processor(Dependency:Boolean):void
		{
			for (var operator_name:String in operators)
			{
				if (operators[operator_name].queue.length > 0)
				{
					run_operator(operators[operator_name], Dependency);
				}
				else
				{
					operators[operator_name] = null;
					
					delete operators[operator_name];
				}
			}
			
			if (Utility.GET_OBJECT_LENGTH(operators) == 0)
			{
				STOP();
			}
		}
		private static function run_operator(Operator:Object, Dependency:Boolean):void
		{
			if (Operator.activity)
			{
				if (Operator.queue[0].dependency == Dependency)
				{
					run_process(Operator.queue[0]);
				}
			}
		}
		private static function run_process(Process:Object):void
		{
			if (Process.delay == 0)
			{
				work_on_process();
			}
			else
			{
				if (Process.start_time == 0)
				{
					Process.start_time = getTimer();
				}
			
				if (getTimer() - Process.start_time >= Process.delay)
				{
					work_on_process();
				}
			}

			function work_on_process():void
			{
				Process.finish_time = getTimer();
				Process.run_time = Process.finish_time - Process.add_time;
				
				if (Process.run_time >= Process.timeout_time)
				{
					Process.timeout = true;
					
					if (Process.protocol == 0)
					{
						Process.protocol = 1;
					}
				}
				
				if (Process.protocol > 0)
				{
					try
					{
						Process.mission(Process);
					}
					catch(e:Error)
					{
						Console.PRINT("Processor", "X ERROR > ERROR CODE : XXXX > The process, '" + String(Process.tags) + "' has been corrupted. Please check it.", 3, "");
						Console.PRINT("Processor", "- ERROR DETAILS > " + e.getStackTrace(), 2, "");
					}
				}
				else if (Process.protocol == 0)
				{
					
					operators[Process.operator].queue.push(Process);
				}

				operators[Process.operator].queue.shift();
			}
		}
		private static function new_operator():Object
		{
			var operator:Object = new Object();
			operator.queue = new Array();
			operator.activity = true;
			
			return operator;
		}
		private static function new_process():Object
		{
			var process:Object = new Object();
			process.add_time = getTimer();
			process.start_time = 0;
			process.timeout = false;

			return process;
		}
		private static function get_process_time():Number
		{
			return MathLab.SET_SIGNIFICANT_FIGURE((getTimer() - started_time) / 1000, 2);
		}
		private static function check_INIT():Boolean
		{
			if (!ready && !ready_m)
			{
				trace("Processor is not ready!!!");
				
				ready_m = true;
			}
			
			return ready;
		}
	}

}