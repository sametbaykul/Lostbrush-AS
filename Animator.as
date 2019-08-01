/*

	------------------------------------------------------------
	- ANIMATOR(C) 2014 - 2016 
	------------------------------------------------------------
	
	* FULL STATIC
	* INIT : true
	
	v1.0 : 10.09.2014 : Görsel programlama çözümü amacıyla üretilmiştir.
	v1.1 : 31.01.2015 : Büyük nesneler için AMCL Filtreleme desteği
	v1.2 : 03.02.2015 : ANIM'ler için ANIM_DATA yapılandırması.
	
	v2.0 : 05.02.2015 : 
		Eklenen yeni özellikler:
		1. mcA'lar da artık ANIM gibi davranabilecekler.
		2. TIMER nesnesi için performans iyileştirmesi.
		3. AMCL desteği artık ANIM'ler içerisindeki ANIM_DATA objelerinde de kullanılabilecek. (!) Doğrudan 'instance' a ulaşmanın bir yolu bulunursa bu değiştirilmeli.
	v2.1 : 08.02.2015 : ANIM'ler için kullanılan ANIM_DATA nesnesine "stay_point" adında, animasyonda en son kalınan noktayı veren bir özellik eklendi.
	v2.2 : 08.02.2015 : AMCL nesnesi ve algoritması tamamiyle "Access" sınıfına devredildi. Artık bütün "AMCL" nesnelerine doğrudan "Access" den ulaşılabilecek. Ayrıca benzer teknolojiyi kullanmak isteyen sınıflar da bundan faydalanabilecek.
	v2.3 : 19.02.2015 : Artık "No_Animation" türündeki 'ANIM' ler için de 'Time' davranışı kullanılabilecek.
	v2.4 : 21.02.2015 : "Main_Timer" parametresi "Timer_Link" ile değiştirildi. Artık kendi Animator örnekleri kendilerine özgü TIMER nesnelerini kullanabilecekleri gibi, "Gensys" sınıfının global TIMER nesnesini de kullanabilecekler.
	v2.5 : 08.03.2015 : STOP() ve RESET() metodlarında stabilizasyon güncellemeleri.
	
	v3.0 : 12.07.2015 : 
		Eklenen yeni özellikler:
		1. mcA ve ANIM'ler için yeni DATA nesne desteği eklendi. Bunlar: 
			1. ani -> Geçerli Animator sınıf örneğine başvuru, 
			2. access -> Eğer varsa, geçerli mcA'nın AMCL listesine başvuru, 
			3. mcA -> Geçerli mcA görsel nesnesine başvuru, 
			4. ca -> Current Anim'e başvuru.
			5. Ayrıca stay_point özelliği düzeltildi.
		2. ANIMATE() metodunda "loop" için tam döngü sorunu düzeltildi. Ayrıca "Stopper_Label" ile durdurma için ilk frame'in atlanması şartı getirildi.
		3. ERROR 0014 yeniden düzenlendi ve etki alanı genişletildi.
	v3.1 : 28.07.2015 : "Code_Based" ANIM'lerde ANIMATE() metodunun varlığı gerektiğinden, bu metodun var olmaması durumunda yeni bir hata denetimi eklendi.
	v3.2 : 14.09.2015 : Bazı isimlerde kısaltmalar yapıldı. MC_ANIMATOR -> MCA, CURRENT_ANIM -> ANIM, ANIM -> ANIM_N olarak değiştirildi. Geriye dönük uyumsuzluk sorunları çıktığında bu güncellemeyi dikkate alın.
	v3.3 : 12.02.2016 : 'id' ve 'no' özellikleri belirlendi.
	
	v4.0 : 23.04.2016 : ???
		Eklenen yeni özellikler:
		1. Sınıf tamamiyle yenilendi ve static hale getirildi.
		2. Yeni nesne yönelimli ve Console.as uyumulu esnek ve geliştirilebilir bir sınıf.
		3. Utility.as v.6.0'ın gücü ile yüksek veriyolu kontrolü.
		4. Tek bir ATO (Animation Tree Object) ile artık mcA'lara ve karmaşık anim kodlarına son. Bütün animasyon kontrolü sizde ve hiç olmadığı kadar sezgisel.
		5. Sınıf RCP ve ANIM'leri otomatik olarak sizin yerinize buluyor.
		6. Yeni framerate desteği ile nesne bazında FR kontorlü projelerinizde daha iyi performans optimizasyonu yapmanızı sağlar.
		7. Gelişmiş animasyon kontrolleri.
	
	-> Auto Loading ANIM_DATA
	
	by Samet Baykul

*/

package lbl
{
	// Flash Library:
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	// LBL Core:
	import lbl.MathLab;
	import lbl.Access;
	import lbl.Utility;
	import lbl.Gensys;
	// LBL Control:
	import lbl.Console;
	

	public class Animator
	{
		public static var AOL:Array;				// Animator Object List
		public static var TIMER:Timer;
		
		private static var TO:Object;				// Temporary Object
		private static var TOL:Array; 				// Temporary Object List
		private static var TOPL:Array; 				// Temporary Object Path List

		// Class Info:
		private static var id:String = "ANI";
		private static var no:int = 006;
		
		public function Animator():void
		{
			// Full static class
		}

		// ----------------------------------------------------------------
		// METHODS:
		// ----------------------------------------------------------------
		
		public static function INIT(Timer_Link:String = "Global"):void
		{
			init_props();
			init_timer();
			
			function init_props():void
			{
				AOL = new Array();
			}
			function init_timer():void
			{
				if (Gensys.TIMEL[Timer_Link])
				{
					TIMER = Gensys.TIMEL[Timer_Link];
				}
				else
				{
					TIMER = Gensys.NEW_TIMER(Timer_Link);
				}
			}
		}
		public static function NEW(MC_Animation:MovieClip, Animation_Tree_Object:Object, Self_Timer:Boolean = false, Frame_Rate:uint = 0):void
		{
			var AO:Object = new Object();									// Animator Object
			
			create_AO();
			stop_all_animations();
			update_ATO(AO);
			set_timer();		
			
			function create_AO():void
			{
				AO.name = MC_Animation.name;
				AO.AMC = MC_Animation;										// Animator Movie Clip			
				AO.ATO = Animation_Tree_Object;								// Animation Tree Object
				AO.RCPOL = new Array();										// RCPO List (RCP: Rechangable Part Object)

				AO.self_timer = Self_Timer;
				AO.visible_anims = new Array();
				
				memorise_init_ATO();
				set_fr();
				
				AOL[MC_Animation.name] = AO;
				
				function memorise_init_ATO():void
				{
					AO.INIT_ATO = Utility.CLONE(Animation_Tree_Object);
				}
				function set_fr():void
				{
					if (Frame_Rate == 0)
					{
						AO.FR = Gensys.FRAME_RATE;
					}
					else
					{
						AO.FR = Frame_Rate;
					}
				}
			}
			function stop_all_animations():void
			{
				Utility.STOP_ALL_CHILDREN(AO.AMC);
			}
			function set_timer():void
			{
				set_timer();
				start_timer();
				
				function set_timer():void
				{
					if (Self_Timer)
					{
						AO.timer = Gensys.NEW_TIMER("ANI_" + MC_Animation, int(1000 / AO.FR));
					}
					else
					{
						AO.timer = TIMER;
					}
					
					AO.start = start_timer;
					AO.stop = stop_timer;
				}
				function start_timer():void
				{
					AO.timer.addEventListener(TimerEvent.TIMER, animate);
					
					if (Self_Timer)
					{
						AO.timer.start();
					}
				}
				function stop_timer():void
				{
					AO.timer.removeEventListener(TimerEvent.TIMER, animate);
				
					if (AO.self_timer)
					{
						AO.timer.stop();
					}
				}
				function animate(e:TimerEvent):void
				{
					AO.count = AO.timer.currentCount;

					for each (var RCPO:Object in AO.RCPOL)
					{
						if (RCPO.active)
						{
							RCPO.animation(RCPO.current_anim);
							
							// ->
							//Console.DYNAMIC_DATA(RCPO.name, RCPO);
						}
					}
					
					// ->
					//Console.DYNAMIC_DATA(AO.name, AO);
				}
			}
		}
		public static function DELETE(MC_Animation:MovieClip):void
		{
			if (Boolean(AOL[MC_Animation.name]))
			{
				AOL[MC_Animation.name].stop();
				
				delete AOL[MC_Animation.name];
				
				Utility.COMPRESS_ARRAY(AOL);
			}
			else
			{
				trace("Hata: Böyle bir animasyon Animator.as'de bulunamadı");
			}
		}
		public static function START():void
		{
			for each(var AO:Object in AOL)
			{
				AO.start();
				
				for each(var RCPO in AO.RCPOL)
				{
					if (RCPO.target)
					{
						RCPO.active = true;
					} 
				}
			}
		}
		public static function STOP():void
		{
			for each(var AO:Object in AOL)
			{
				AO.stop();
				
				for each(var RCPO in AO.RCPOL)
				{
					 RCPO.active = false;
				}
			}
		}
		public static function RESET():void
		{
			STOP();
			
			for each(var AO:Object in AOL)
			{
				AO = null;
			}
			
			AOL = new Array();
		}
		
		public static function CHANGE_PART(MC_Animation:MovieClip, Which_Part:String, New_Anim:String, Multiple_Selection:Boolean = false):void
		{
			if (Multiple_Selection && Which_Part == "Self")
			{
				trace("UYARI: Self Multiple_Selection açık iken kullandınız.");
			}
			
			if (Boolean(AOL[MC_Animation.name]))
			{
				TOPL = new Array();
				
				update_TOPL();
				update_ato();

				TOPL = null;
			}
			else
			{
				trace("Hata: Böyle bir animasyon Animator.as'de bulunamadı");
			}
			
			function update_TOPL():void
			{
				TOPL = Utility.SMART_PATH_FINDER(AOL[MC_Animation.name].ATO, Which_Part, true, false, !(Multiple_Selection));
			}
			function update_ato():void
			{
				for (var i:int = 0; i < TOPL.length; i ++)
				{
					Utility.UPDATE_OBJECT_FROM_PATH(AOL[MC_Animation.name].ATO, TOPL[i], New_Anim);
				}
				
				if (TOPL.length)
				{
					update_ATO(AOL[MC_Animation.name]);
				}
				else
				{
					trace("Hata: ANI uyumsuzluğu");
				}
			}
		}
		public static function GET_ANIM(MC_Animation:MovieClip, Which_Part:String):MovieClip
		{
			if (Boolean(AOL[MC_Animation.name]))
			{
				return AOL[MC_Animation.name].RCPOL[Which_Part].current_anim;
			}
			else
			{
				return null;
				
				trace("Hata: Böyle bir animasyon Animator.as'de bulunamadı");
			}
		}
		public static function TEST_ANIM(MC_Animation:MovieClip):Boolean
		{
			return Boolean(AOL[MC_Animation.name]);
		}
		public static function UPDATE_ANIM(MC_Animation:MovieClip, New_ATO:Object, Method:String = "Rebuild"):void
		{
			var ok:Boolean = true;
			
			if (Boolean(AOL[MC_Animation.name]))
			{
				if (Method == "Rebuild")
				{
					AOL[MC_Animation.name].ATO = New_ATO;
				}
				else if (!Boolean(Utility.UPDATE_OBJECT(AOL[MC_Animation.name].ATO, New_ATO, Method)))
				{
					ok = false;
				}
			}
			else
			{
				trace("Hata: Böyle bir animasyon Animator.as'de bulunamadı");
			}
			
			if (ok)
			{
				update_ATO(AOL[MC_Animation.name]);
			}
		}
		public static function RESET_ANIM(MC_Animation:MovieClip):void
		{
			if (Boolean(AOL[MC_Animation.name]))
			{
				AOL[MC_Animation.name].ATO = AOL[MC_Animation.name].INIT_ATO;
				
				update_ATO(AOL[MC_Animation.name]);
			}
			else
			{
				trace("Hata: Böyle bir animasyon Animator.as'de bulunamadı");
			}
		}
		
		public static function ANIMATE_FRAME(MC_Animation:MovieClip, Which_Part:String, Frame_Times:int = 1, Speed:Number = 1, Start_Frame:Object = null, End_Frame:Object = null, Callback:Function = null):void
		{
			animate_anim(MC_Animation, Which_Part, "Frame", Frame_Times, Speed, Start_Frame, End_Frame, null, Callback);
		}
		public static function ANIMATE_LOOP(MC_Animation:MovieClip, Which_Part:String, Loop_Times:int = 1, Speed:Number = 1, Start_Frame:Object = null, End_Frame:Object = null, Callback:Function = null):void
		{
			animate_anim(MC_Animation, Which_Part, "Loop", Loop_Times, Speed, Start_Frame, End_Frame, null, Callback);
		}
		public static function ANIMATE_TIME(MC_Animation:MovieClip, Which_Part:String, Time:int = 1, Speed:Number = 1, Start_Frame:Object = null, End_Frame:Object = null, Callback:Function = null):void
		{
			animate_anim(MC_Animation, Which_Part, "Time", Time, Speed, Start_Frame, End_Frame, null, Callback);
		}
		public static function ANIMATE_SPECIAL(MC_Animation:MovieClip, Which_Part:String, Animation_Function:Function, Trigger_Count:int = 1, Speed:Number = 1, Start_Frame:Object = null, End_Frame:Object = null, Callback:Function = null):void
		{
			animate_anim(MC_Animation, Which_Part, "Special", Trigger_Count, Speed, Start_Frame, End_Frame, Animation_Function, Callback);
		}
		
		
		// ----------------------------------------------------------------
		// PRIVATE FUNCTIONS:
		// ----------------------------------------------------------------
		
		private static function animate_anim(MC_Animation:MovieClip, Which_Part:String, Method:String = "No_Animation", Time_or_Repeat:uint = 1, Speed:Number = 1, Start_Frame:Object = null, End_Frame:Object = null, Special_Animation:Function = null, Callback:Function = null):void
		{
			find_parts();

			function find_parts():void
			{
				if (Boolean(AOL[MC_Animation.name]))
				{
					TOL = new Array();
					TOPL = new Array();
	
					TOPL = Utility.SMART_PATH_FINDER(AOL[MC_Animation.name].ATO, Which_Part, true);
					
					for (var i:int = 0; i < TOPL.length; i ++)
					{
						update_rcp(AOL[MC_Animation.name].RCPOL[TOPL[i]]);
					}
				}
				else
				{
					trace("Hata: Böyle bir animasyon Animator.as'de bulunamadı");
				}
			}
			function update_rcp(RCPO:Object):void
			{
				check_rcp_visibility();
				
				function check_rcp_visibility():void
				{
					if (Utility.SOME_ARRAY_ELEMENTS(AOL[RCPO.AMC.name].visible_anims, [RCPO.current_anim]))
					{
						update_rcpo();
						get_target();
					}
				}
				function update_rcpo():void
				{
					RCPO.active = true;
					RCPO.method = Method;
						
					RCPO.target = Time_or_Repeat;
					RCPO.time_or_repeat = Time_or_Repeat;
					RCPO.callback = Callback;
					RCPO.speed = Speed;
					RCPO.animation = next;
					RCPO.special_animation = null;
					RCPO.start_frame = Start_Frame;
					RCPO.end_frame = End_Frame;
					RCPO.valid_anims = new Array();
					RCPO.frame_progress = 0;
					RCPO.count = 0;
				}
				function get_target():void
				{
					if (Time_or_Repeat == -1)
					{
						RCPO.target = MathLab.EXTREME_VALUE();
					}
				}
				
				function next(ANIM:MovieClip):void
				{
					var playable:Boolean = true;
					
					check_animation_finish();
					check_anim_palayable();
					speed_adjuster();
					set_frame_boundaries();
					move_frame_head();
					
					function check_animation_finish():void
					{
						if (RCPO.target <= RCPO.count)
						{
							RCPO.reset();
						}
						
						if (Boolean(RCPO.callback))
						{
							RCPO.callback(RCPO);
						}
					}
					function check_anim_palayable():void
					{
						if (ANIM.totalFrames == 1 || RCPO.special_animation || !(RCPO.speed))
						{
							playable = false;
						}
					}
					function speed_adjuster():void
					{
						if (playable)
						{
							if (RCPO.frame_progress > -1 && RCPO.frame_progress < 1)
							{
								RCPO.frame_progress += Math.abs(RCPO.speed);
								
								playable = false;
							}
							else
							{
								playable = true;
							}
						}
					}
					function set_frame_boundaries():void
					{
						if (!Boolean(RCPO.start_frame))
						{
							RCPO.start_frame = 1;
						}
						
						if (!Boolean(RCPO.end_frame))
						{
							RCPO.end_frame = ANIM.totalFrames;
						}
					}
					function move_frame_head():void
					{
						if (playable)
						{
							for (var i:int = 0; i < int(RCPO.frame_progress); i)
							{
								if (RCPO.speed > 0)
								{
									go_positive_direction();
								}
								else if (RCPO.speed < 0)
								{
									go_negative_direction();
								}
								
								RCPO.frame_progress --;
							}
						}
						
						update_count("Time");
						
						function go_positive_direction():void
						{
							if (RCPO.start_frame is Number)
							{
								if (ANIM.currentFrame <= RCPO.start_frame)
								{
									ANIM.gotoAndStop(RCPO.start_frame);
								}
							}
							
							if (RCPO.end_frame is Number)
							{
								if (ANIM.currentFrame >= RCPO.end_frame)
								{
									ANIM.gotoAndStop(RCPO.start_frame);
									
									update_count("Loop");
								}
								else
								{
									ANIM.nextFrame();
									
									update_count("Frame");
								}
							}
							else
							{
								if (ANIM.currentFrameLabel <= RCPO.end_frame)
								{
									ANIM.gotoAndStop(RCPO.start_frame);
									
									update_count("Loop");
								}
								else
								{
									ANIM.nextFrame();
									
									update_count("Frame");
								}
							}
						}
						function go_negative_direction():void
						{
							if (RCPO.end_frame is Number)
							{
								if (ANIM.currentFrame >= RCPO.end_frame)
								{
									ANIM.gotoAndStop(RCPO.end_frame);
								}
							}
							
							if (RCPO.start_frame is Number)
							{
								if (ANIM.currentFrame == RCPO.start_frame)
								{
									//trace("loop");

									ANIM.gotoAndStop(RCPO.end_frame);
									
									update_count("Loop");
								}
								else
								{
									//trace("frame");
									
									ANIM.prevFrame();
									
									update_count("Frame");
								}
							}
							else
							{
								if (ANIM.currentFrameLabel == RCPO.start_frame)
								{
									ANIM.gotoAndStop(RCPO.end_frame);
									
									update_count("Loop");
								}
								else
								{
									ANIM.prevFrame();
									
									update_count("Frame");
								}
							}
						}
						function update_count(Param:String):void
						{
							switch (Param)
							{
								case "Frame" :
									check_frame();
									break;
								case "Loop" :
									check_frame();
									check_loop();
									break;
								case "Time" :
									check_time();
									break;
							}
							
							function check_frame():void
							{
								if (RCPO.method == "Frame")
								{
									RCPO.count ++;
								}
							}
							function check_loop():void
							{
								if (RCPO.method == "Loop")
								{
									RCPO.count ++;
								}
							}
							function check_time():void
							{
								if (RCPO.method == "Time")
								{
									RCPO.count ++;
								}
							}
						}
					}
				}
			}
		}
		private static function update_ATO(AO:Object):void
		{
			var path:String = "";
			
			AO.visible_anims = new Array();
			
			next_layer(AO.ATO, path);
			
			update_visible_anims(AO);

			function next_layer(Layer_Object:Object, Parent_Path:String):void
			{
				for (var key:String in Layer_Object)
				{
					if (Layer_Object[key] is String)
					{
						handle_string();
					}
					else if (Utility.GET_OBJECT_LENGTH(Layer_Object[key]))
					{
						handle_object();
					}
				}
				
				function handle_string():void
				{
					if (Layer_Object[key] is String)
					{
						var modified_path:String = Parent_Path;
						
						update_modified_path();
						
						find_RCP();
						
						find_ANIM();
					}
					
					function update_modified_path():void
					{
						if (!Boolean(key == "Self"))
						{
							if (modified_path)
							{
								modified_path += "." + key; 
							}
							else
							{
								modified_path = key;
							}
						}
					}
					function find_RCP():void
					{
						try 
						{
							update_RCP(AO, modified_path, Utility.FIND_OBJECT_FROM_PATH(AO.AMC, modified_path));
						}
						catch (e:Error)
						{
							TOL = Utility.FIND_PATH(Utility.FIND_OBJECT_FROM_PATH(AO.AMC, Parent_Path), key, true);

							for (var i:int = 0; i < TOL.length; i ++)
							{
								if (Boolean(Parent_Path))
								{
									TOL[i] = Utility.FIND_OBJECT_FROM_PATH(AO.AMC, Parent_Path + "." + TOL[i]);
								}
								else
								{
									TOL[i] = Utility.FIND_OBJECT_FROM_PATH(AO.AMC, TOL[i]);
								}
								
								if (!Boolean(TOL[i]))
								{
									delete TOL[i];
									
									Utility.COMPRESS_ARRAY(TOL);
								}
								else
								{
									update_RCP(AO, modified_path, TOL[i]);
								}
							}
						}
					}
					function find_ANIM():void
					{
						try 
						{
							update_ANIM(AO, modified_path, Utility.FIND_OBJECT_FROM_PATH(AO.AMC, modified_path)[Layer_Object[key]]);
						}
						catch (e:Error)
						{
							if (Boolean(TOL))
							{
								for (var j:int = 0; j < TOL.length; j ++)
								{
									TOPL = new Array();
									
									TOPL = Utility.FIND_PATH(TOL[j], Layer_Object[key], true);
									
									for (var k:int = 0; k < TOPL.length; k ++)
									{
										update_ANIM(AO, TOL[j].name, TOL[j][TOPL[k]]);
									}
								}
							}
						}
					}
				}
				function handle_object():void
				{
					update_path(Parent_Path, key);
						
					next_layer(Layer_Object[key], path);
				}
			}
			function update_path(parent_path:String, new_obj_key:String):void
			{
				path = parent_path;
							
				if (Boolean(path))
				{
					path += ".";
				}
							
				path += new_obj_key;
			}
		}
		private static function update_visible_anims(AO:Object):void
		{
			for (var i:int = 0; i < AO.visible_anims.length; i ++)
			{
				if (!Utility.TEST_FAMILY_VISIBILITY(AO.visible_anims[i]))
				{
					delete AO.visible_anims[i]
				}
			}
			
			Utility.COMPRESS_ARRAY(AO.visible_anims);
		}
		private static function update_ANIM(AO:Object, RCP_Name:String, ANIM:MovieClip):void
		{
			ANIM.visible = true;
	
			AO.visible_anims.push(ANIM);
				
			AO.RCPOL[RCP_Name].current_anim = ANIM;
		}
		private static function update_RCP(AO:Object, RCP_Name:String, RCP:MovieClip):void
		{
			if (!Boolean(RCP_Name))
			{
				RCP_Name = "Self";
			}
			
			if (!Boolean(AO.RCPOL[RCP_Name]))
			{
				AO.RCPOL[RCP_Name] = new Object();
			}
			
			update_RCPO(AO.RCPOL[RCP_Name]);
			set_anims_invisible(AO.RCPOL[RCP_Name]);
			
			function update_RCPO(RCPO:Object):void
			{
				RCPO.name = RCP_Name;
				RCPO.AMC = AO.AMC;
				RCPO.RCP = RCP;
				RCPO.ANIM_list = new Array();
				RCPO.reset = reset_rcpo;
				
				for (var i:int; i < RCP.numChildren; i ++)
				{
					RCPO.ANIM_list[RCP.getChildAt(i).name] = RCP.getChildAt(i);
				}
				
				function reset_rcpo():void
				{
					RCPO.active = false;
					RCPO.method = null;
					
					RCPO.target = null;
					RCPO.time_or_repeat = null;
					RCPO.callback = null;
					RCPO.speed = null;
					RCPO.animation = null;
					RCPO.start_frame = null;
					RCPO.end_frame = null;
				}
			}
			function set_anims_invisible(RCPO:Object):void
			{
				for (var mc_name:String in RCPO.ANIM_list)
				{
					RCPO.ANIM_list[mc_name].visible = false;
				}
			}
		}
	}
}