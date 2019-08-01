/*
	------------------------------------------------------------
	- MATHLAB(C) 2014  - 2016
	------------------------------------------------------------
	
	* FULL STATIC
	* INIT : false
	
	v1.0 : 14.09.2014
	
	v2.0 : 05.08.2015	: Eski PhysicsEngine(2014), Mobilization(2014), PaketProb(2014), SlideShowEssential(2013) sınıflarından bazı metodlar eklendi.
		Eklenen yeni özellikler:
		1. DISTANCE_POINTS() 							: Koordinatları verilen iki nokta arasındaki uzaklığı hesaplar.
		2. MATH_TO_FLASH_ROTATION() 					: Matematiksel açıyı flash açısına çevirir.
		3. FLASH_TO_MATH_ROTATION() 					: Flash açısını matematiksel açıya çevirir.
		4. TO_ACUTE_ANGLE() 							: Herhangi bir açıyı 0-90 araluğında dar açı ile ifade eder. 
		5. DEGREE_TO_RADIAN()							: Dereceyi radyana çevirir.
		6. RADIAN_TO_DEGREE()							: Radyanı dereceye çevirir.
		7. GET_MIN_FLOOR()								: Verilen ilk sayının, verilen ikinci sayıdan küçük en büyük katlı değeri.
		8. SUM()										: Parametre olarak iletilen sayıları toplar ve sonuç olarak döndürür.
		
	v3.0 : 08,08,2015	: Physics(2015) sınıfı için vektörlerle çalışmayı sağlayan yeni metodlar eklendi:
		Eklenen yeni özellikler:
		1. GET_POINT_REGION()							: Bir noktanın matematiksel koordinat düzlemindeki bölgeyi sayı cinsinden verir. Origindeki nokta 0 değerini döndürür.
		2. GET_ABS_ANGLE()								: Bir vektörün matematiksel koordinat düzlemindeki mutlak açısını derece cinsinden verir.
		3. ADD_ANGLE_TO_VECTOR()						: Bir vektörün belirli bir açıyla döndürülmesiyle elde edilen yeni vektörün indislerini array olarak döndürür.
		4. GET_ANGLE_BTW_TWO_VECTORS()					: İki vektör arasındaki en küçük açıyı verir.
		5. GET_ANGLE_BTW_TWO_VECTORS_IN_COORDINATES()	: Belirli noktaların referans kabul edildiği bir koordinat düzleminde başlangıç ve bitiş noktaları bilinen iki vektörün arasındaki açıyı döndürür.
		6. VECTOR_MAGNITUDE()							: Bir vektörün mutlak büyüklüğünü döndürür.
		7. VECTOR_DOT_PRODUCT()							: İki vektörün skaler çarpımını verir.
		8. VECTOR_SUM()									: İki vektörü toplar.
		9. MAGNITUDE_TO_VECTOR()						: Verilen bir büyüklüğün verilen bir açıya göre parçalarını hesaplar.
	v3.1 : 10.09.2015 	: INFINITY(), EXTREME_VALUE() ve GET_SIGN() metodları eklendi.
	v3.2 : 19.09.2015 	: ADD_COMMANDS() metodu eklendi ve FIND_DIGIT_NUMBER() metodu güncellendi. Artık 10 basamaklı sayılardan daha büyük sayıları da işleyebilir.
	v3.3 : 12.02.2016 	: 'id' ve 'no' özellikleri belirlendi.
	v3.4 : 25.02.2016	: Metod ve fonksiyonlar gruplandırıldı. Ayrıca, bir sayının tabanını değiştirmeyi sağlayan ALTER_RADIX() metodu eklendi.
	v3.5 : 07.03.2016   : INC_TO_ABS() metodu ile incremental diziler absolute dizilere dönüştürülebilir.
	
	by Samet Baykul

*/

package lbl
{
	// LBL Control:
	import lbl.Console;
	
	
	public class MathLab
	{
		// Class Info:
		private static var id:String = "MAT";
		private static var no:int = 011;
		
		public function MathLab()
		{
			// Full static class
		}

		// ----------------------------------------------------------------
		// METHODS:
		// ----------------------------------------------------------------
		
		public static function ADD_COMMANDS():void
		{
			Console.ADD_COMMAND(id, "matar", matar, ["Value:String" , "Input_Radix:int", "Output_Radix:int"], "Alter the radix of a number.");
			
			Console.ADD_COMMAND(id, "matfdn", matfdn);
			Console.ADD_COMMAND(id, "matinc", matinc);
			
			function matar(Param:Array):void
			{
				Console.PRINT_DATA(id, "Altered Radix", ALTER_RADIX(Param[0], Param[1], Param[2]));
			}
			function matfdn(Param:Array):void
			{
				Console.PRINT("MathLab", "Digit Number of " + Param[0] + ": " + FIND_DIGIT_NUMBER(Param[0]), 1);
			}
			function matinc(Param:Array):void
			{
				Console.PRINT_DATA(id, "Inc_Array", INC_TO_ABS(Param));
			}
		}
		
		// Algebraic Methods:
		
		public static function SUM(Number_List:Array):Number
		{
			var sonuc:Number = 0;
			
			for (var i = 0; i < Number_List.length; i++)
			{
				sonuc +=  Number_List[i];
			}
			
			return sonuc;
		}
		public static function FULL_DIVIDE(Value:int, Dividor:int, Section:String = "result"):Number
		{
			var real_result:Number = Value / Dividor;
			var int_result:int = Math.floor(real_result);
			var Result:Number;

			switch (Section)
			{
				case "result" :
					Result = int_result;
					break;
				case "remain" :
					Result = get_remain();
					break;
				case "full" :
					Result = real_result;
					break;
			}

			function get_remain():int
			{
				return (Value - (int_result * Dividor));
			}
			
			return Result;
		}
		public static function INFINITY(Positive:Boolean = true):Number
		{
			if (Positive)
			{
				return Number.POSITIVE_INFINITY;
			}
			else
			{
				return Number.NEGATIVE_INFINITY;
			}
		}
		public static function EXTREME_VALUE(Max_or_Min:Boolean = true):Number
		{
			if (Max_or_Min)
			{
				return Number.MAX_VALUE;
			}
			else
			{
				return Number.MIN_VALUE;
			}
		}
		public static function GET_SIGN(Value:Number):int
		{
			if (Value > 0)
			{
				return 1;
			}
			else if (Value < 0)
			{
				return -1;
			}
			else
			{
				return 0;
			}
		}
		public static function GET_ABSOLUTE_VALUE(Value:Number):Number
		{
			if (Value <= 0)
			{
				return ((-1) * Value);
			}
			else
			{
				return (Value);
			}
		}
		public static function GET_MIN_FLOOR(Num_1:Number,Num_2:Number):Number
		{
			var temp:Number = Num_1;
			
			while ((temp < Num_2))
			{
				temp +=  Num_1;
			}
			
			return temp;
		}
		
		// Numeric Methods:

		public static function GET_NUMBER_VALUES_LIST(Value:int):Array
		{
			var deger:int = GET_ABSOLUTE_VALUE(Value);
			var digit_number:uint = FIND_DIGIT_NUMBER(deger);
			var digit_number_list:Array = new Array();

			for (var i:int = 0; i < digit_number; i++)
			{
				digit_number_list[i] = GET_LAST_DIGIT(LOWER_DIGIT(deger,i));
			}

			return digit_number_list;
		}
		public static function GET_LAST_DIGIT(Value:int):uint
		{
			var deger:int = GET_ABSOLUTE_VALUE(Value);
			var divided_value:int =  deger/(10);
			divided_value = Math.floor(divided_value)*(10);
			var Result = deger - divided_value;
			
			return Result;
		}
		public static function FIND_DIGIT_NUMBER(Value:Number):uint
		{
			var deger:Number = GET_ABSOLUTE_VALUE(Value);
			var digit_number:int = 1;

			divide_by_10();

			function divide_by_10():void
			{
				if (deger >= 10)
				{
					deger = deger / 10;
					digit_number++;
					divide_by_10();
				}
			}

			return digit_number;
		}
		public static function LOWER_DIGIT(Value:Number, Zero_Number:int):Number
		{
			var Result:Number = Value;
			
			for (var i:int = 0; i < Zero_Number; i++)
			{
				Result = Result / 10;
			}
			
			return Result;
		}
		public static function HIGHER_DIGIT(Value:Number, Zero_Number:int):Number
		{
			var Result:Number = Value;
			
			for (var i:int = 0; i < Zero_Number; i++)
			{
				Result = Result * 10;
			}
			
			return Result;
		}
		public static function SET_SIGNIFICANT_FIGURE(Value:Number, Precision:uint):Number
		{
			var Result:Number = int(Value * Math.pow(10,Precision));
			
			Result = Result / Math.pow(10,Precision);
			
			return Result;
		}
		public static function GET_PERIOD_from_COUNTER(Value:int, Capacity:int):int
		{
			return FULL_DIVIDE(Value, Capacity) + 1;
		}
		public static function CONVERT_to_SCORE(Value:int, Digit:int):String
		{
			if (Digit > 0)
			{
				var number_values_list:Array = new Array();
				var digit_number:int = FIND_DIGIT_NUMBER(Value);
				var capacity:int = HIGHER_DIGIT(1, Digit);
				var period:int = GET_PERIOD_from_COUNTER(Value, capacity);
				var score_value:int = FULL_DIVIDE(Value,capacity,"remain");
				var score_value_digit_number:int = FIND_DIGIT_NUMBER(score_value);
				var left_zero_number:int = Digit - score_value_digit_number;

				return add_zero_to_text(String(score_value), left_zero_number);

				function add_zero_to_text(Value_Text:String, Zero_Number:int):String
				{
					var value_text:String = Value_Text;
					var zero_text:String = "";

					for (var i:int = 0; i < Zero_Number; i++)
					{
						zero_text +=  "0";
					}

					return (zero_text + value_text);
				}
			}
			else
			{
				var error_message:String = "X ERROR > ERROR CODE: 0002 > MathLab: 'CONVERT_to_SCORE' metodunda parametre hatası: Digit parametresi 0 dan büyük olmak zorundadır.";
				Console.PRINT("MathLab", error_message, 3, "");
				throw new Error(error_message);
			}
		}
		public static function ALTER_RADIX(Value:String, Input_Radix:int = 10, Output_Radix:int = 16):String
		{
			var Value_Number:Number;
			var Value_Sring:String;
			
			if (Utility.SEARCH_TEXT(Value, "0x"))
			{
				Value_Sring = Utility.SPLIT_TEXT(Value, "0x", 2, 2);
			}
			else
			{
				Value_Sring = Value;
			}
			
			Value_Number = parseInt(Value_Sring, Input_Radix);
			Value_Sring = Value_Number.toString(Output_Radix).toUpperCase();
			
			return Value_Sring;
			
		}
		public static function INC_TO_ABS(Incremental_Array:Array):Array
		{
			var Absolute_Array:Array = new Array();
			
			for (var i:int = 0; i < Incremental_Array.length; i ++)
			{
				Absolute_Array[i] = 0;
						
				for (var j:int = 0; j <= i; j ++)
				{
					Absolute_Array[i] += Number(Incremental_Array[i]);
				}
			}
			
			return Absolute_Array;
		}
		
		// Angle Methods:
		
		public static function GET_ABS_ANGLE(X:Number, Y:Number):Number
		{
			var angle:Number = Math.atan2(Y, X);
     
			if (angle < 0)
			{
				angle += Math.PI * 2;
			}
			 
			return MathLab.RADIAN_TO_DEGREE(angle);
		}
		public static function TO_ACUTE_ANGLE(Aci:Number):Number
		{
			var temp:Number = Aci;
			
			while (temp < 0 || temp > 90)
			{
				if (temp < 0)
				{
					temp = temp + 90;
				}
				else if (temp > 90)
				{
					temp = temp - 90;
				}
			}
			
			return temp;
		}
		public static function DEGREE_TO_RADIAN(Degree:Number)
		{
			var temp:Number;
			temp = Degree * Math.PI / 180;
			
			return temp;
		}
		public static function RADIAN_TO_DEGREE(Rad:Number):Number
		{
			return Rad * (180 / Math.PI);
		}
		public static function MATH_TO_FLASH_ROTATION(r_aci:Number):Number
		{
			var temp:Number;
			temp = (-r_aci+90);
			
			return temp;
		}
		public static function FLASH_TO_MATH_ROTATION(r_aci:Number):Number
		{
			var temp:Number;
			temp = (90 - r_aci);
			
			return temp;
		}
		public static function GET_POINT_REGION(X:Number, Y:Number):int
		{
			var apsis:Boolean = Boolean(X > 0);
			var ordinat:Boolean = Boolean(Y > 0);
			var check_coord:Boolean = Boolean(X * Y);
			
			if (check_coord)
			{
				if (apsis && ordinat)
				{
					return 1;
				}
				else if (!apsis && ordinat)
				{
					return 2;
				}
				else if (!apsis && !ordinat)
				{
					return 3;
				}
				else
				{
					return 4;
				}
			}
			else
			{
				if (apsis)
				{
					return 1;
				}
				else if (ordinat)
				{
					return 2;
				}
				else if (X < 0)
				{
					return 3;
				}
				else if (Y < 0)
				{
					return 4;
				}
				else
				{
					return 0;
				}
			}
		}
		
		// Vector Methods:
		
		public static function DISTANCE_POINTS(A_x:Number, A_y:Number, B_x:Number, B_y:Number):Number
		{
			var distance:Number = 0;
			
			distance = Math.sqrt((A_x-B_x)*(A_x-B_x)+(A_y-B_y)*(A_y-B_y));
			
			return distance;
		}
		public static function VECTOR_MAGNITUDE(X:Number, Y:Number):Number
		{
			return Math.sqrt(Math.pow(X, 2) + Math.pow(Y, 2));
		}
		public static function VECTOR_DOT_PRODUCT(A_X:Number, A_Y:Number, B_X:Number, B_Y:Number):Number
		{
			return Math.pow(A_X + B_X, 2) + Math.pow(A_Y + B_Y, 2);
		}
		public static function VECTOR_SUM(A_X:Number, A_Y:Number, B_X:Number, B_Y:Number):Array
		{
			return [(A_X + B_X), (A_Y + B_Y)];
		}
		public static function MAGNITUDE_TO_VECTOR(Magnitude:Number, Angle:Number):Array
		{
			var result:Array = new Array();
			var X:Number = Math.cos(DEGREE_TO_RADIAN(Angle)) * Magnitude;
			var Y:Number = - Math.sin(DEGREE_TO_RADIAN(Angle)) * Magnitude;
			
			result["x"] = X;
			result["y"] = Y;
			
			return result;
		}
		public static function ADD_ANGLE_TO_VECTOR(X:Number, Y:Number, Angle:Number):Array
		{
			var mag:Number = Math.sqrt(Math.pow(X, 2) + Math.pow(Y, 2));
			var A_angle:Number = GET_ABS_ANGLE(X, Y);
			var B_angle:Number = A_angle + Angle;
			var B_angle_radian:Number = MathLab.DEGREE_TO_RADIAN(B_angle);
			
			var B_X:Number = mag * Math.cos(B_angle_radian);
			var B_Y:Number = mag * Math.sin(B_angle_radian);
			
			return [B_X, B_Y];
		}
		public static function GET_ANGLE_BTW_TWO_VECTORS(Vec_A_X:Number, Vec_A_Y:Number, Vec_B_X:Number, Vec_B_Y:Number):Number
		{
			var abs_angle_A:Number = GET_ABS_ANGLE(Vec_A_X, Vec_A_Y);
			var abs_angle_B:Number = GET_ABS_ANGLE(Vec_B_X, Vec_B_Y);
			
			return abs_angle_B - abs_angle_A;
		}
		public static function GET_ANGLE_BTW_TWO_VECTORS_IN_COORDINATES(Cordinate_X:Number, Cordinate_Y:Number, A_X1:Number, A_Y1:Number, A_X2:Number, A_Y2:Number, B_X1:Number, B_Y1:Number, B_X2:Number, B_Y2:Number):Number
		{
			A_X1 -= Cordinate_X;
			A_Y1 -= Cordinate_Y;
			B_X1 -= Cordinate_X;
			B_Y1 -= Cordinate_Y;
			
			var distance_x:Number = A_X1 - B_X1;
			var distance_y:Number = A_Y1 - B_Y1;

			B_X2 += distance_x;
			B_Y2 += distance_y;
			
			A_X2 -= A_X1
			A_Y2 -= A_Y1
			B_X2 -= A_X1
			B_Y2 -= A_Y1
			
			return GET_ANGLE_BTW_TWO_VECTORS(A_X2, A_Y2, B_X2, B_Y2);
		}
	}
}