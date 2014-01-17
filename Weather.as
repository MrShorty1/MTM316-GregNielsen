package {

	import flash.display.MovieClip;
	import flash.events.*;
	import flash.net.*;
	import flash.xml.*;
	import flash.ui.Keyboard;
	import flash.globalization.DateTimeFormatter;
	import fl.motion.MotionEvent;

	public class Weather extends MovieClip {
		
		var myXML: XML;
		var myDays: MovieClip;		
		var dayArray: Array = [];
		
		var weekDayLabels: Array = new Array("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday","Saturday");
		
		var cityInputURL: String;
		var myLoader: URLLoader = new URLLoader();
		var savedCityObject: SharedObject;
		
		public function Weather() {
			readXML();	
			showDay();
			saveFavoriteCities();
		}
		
		public function readXML()
		{
			savedCityObject = SharedObject.getLocal("userCityData");

			if(savedCityObject.data.userCity != null)
			{
				var cityInputURL: String = "http://api.openweathermap.org/data/2.5/forecast/daily?q=" + savedCityObject.data.userCity + "&mode=xml&units=imperial&cnt=7";
				myLoader.load(new URLRequest(cityInputURL));
			}
			else
			{
				myLoader.load(new URLRequest("http://api.openweathermap.org/data/2.5/forecast/daily?q=Salt+Lake+City,UT&mode=xml&units=imperial&cnt=7"));
			}
			myLoader.addEventListener(Event.COMPLETE, processXML);
		}
		
		public function processXML(e: Event): void {
			myXML = new XML(e.target.data);
			
			myDays.CityName.text = myXML.location.name;
			myDays.CityNameInput.text = "Enter City Here";
			
			myDays.CityNameInput.addEventListener(KeyboardEvent.KEY_DOWN, handleCityInput);
			myDays.CityNameInput.addEventListener(MouseEvent.CLICK, handleCityInputClick);
			
			fillAllArrays();
			
			savedCityObject = SharedObject.getLocal("userCityData");
			savedCityObject.data.userCity = myDays.CityName.text;
		}
		
		public function handleCityInput(e: KeyboardEvent)
		{
			if(e.charCode == 13)
			{
				var newCity:String = myDays.CityNameInput.text;
				var cityInputURL: String = "http://api.openweathermap.org/data/2.5/forecast/daily?q=" + newCity + "&mode=xml&units=imperial&cnt=7&&nocache" + new Date().getTime();
				myLoader.load(new URLRequest(cityInputURL));
				displayUpdatedDate();
				
				myDays.CityNameInput.text = "Enter City Here";
				
				myLoader.addEventListener(Event.COMPLETE, processXML);
			}
		}
		
		public function handleCityInputClick(e: MouseEvent)
		{
			myDays.CityNameInput.text = "";
			
			var key: KeyboardEvent;
			
			if(key != null)
			{
				if(key.charCode == 13)
				{
					var newCity:String = myDays.CityNameInput.text;
					var cityInputURL: String = "http://api.openweathermap.org/data/2.5/forecast/daily?q=" + newCity + "&mode=xml&units=imperial&cnt=7&&nocache" + new Date().getTime();
					myLoader.load(new URLRequest(cityInputURL));
					displayUpdatedDate();
					
					myDays.CityNameInput.text = "Enter City Here";
					
					myLoader.addEventListener(Event.COMPLETE, processXML);
				}
			}
		}
		
		public function fillAllArrays()
		{
			dayArray[0] = myDays.Day1;
			dayArray[1] = myDays.Day2;
			dayArray[2] = myDays.Day3;
			dayArray[3] = myDays.Day4;
			dayArray[4] = myDays.Day5;
			dayArray[5] = myDays.Day6;
			dayArray[6] = myDays.Day7;
			
			//todo Refactor to turn all of these methods into one
			getForecastID();
			getCondition();
			getDayName();
			getDate();
			getHigh();
			getLow();
			getMoreInfo();
		}
		
		public function getForecastID()
		{
			for(var i: int = 0; i < 7; i++)
			{
				dayArray[i].gotoAndStop(getForecast(myXML.*.time[i].symbol.@number));
			}
		}
		
		public function getCondition()
		{
			for(var i: int = 0; i < 7; i++)
			{
				dayArray[i].Condition.text = myXML.*.time[i].symbol.@name;
			}
		}
		
		public function getDayName()
		{
			var dateArray: Array;
			var oldDate: String;
			var newDate: Date;
			
			var year: String;
			var month: *;
			var day: String;
			
			for(var i: int = 0; i < 7; i++)
			{
				oldDate = myXML.*.time[i].@day;
				dateArray = oldDate.split("-");
				
				year = dateArray[0];
				month = dateArray[1] - 1;
				day = dateArray[2];
				
				newDate = new Date(year, month, day);
				
				dayArray[i].DayName.text = weekDayLabels[newDate.getDay()];
			}
		}
		
		public function getDate()
		{
			var dateArray: Array;
			var dateAsString: String;
			
			var month: *;
			var day: String;
			var date: Date;
			
			var dayName: String;
			
			for(var i: int = 0; i < 7; i++)
			{
				dateAsString = myXML.*.time[i].@day;
				dateArray = dateAsString.split("-");
				
				month = dateArray[1];
				day = dateArray[2];
				
				dayName = monthNumberToText(month);
				dayArray[i].TheDate.text = dayName + " " + day;
			}
		}
		
		public function monthNumberToText(month: String)
		{
			var monthAsText: String;
			
			if(month == "01")
			{
				monthAsText = "January";
			}
			else if(month == "02")
			{
				monthAsText = "February";
			}
			else if(month == "03")
			{
				monthAsText = "March";
			}
			else if(month == "04")
			{
				monthAsText = "April";
			}
			else if(month == "05")
			{
				monthAsText = "May";
			}
			else if(month == "06")
			{
				monthAsText = "June";
			}
			else if(month == "07")
			{
				monthAsText = "July";
			}
			else if(month == "08")
			{
				monthAsText = "August";
			}
			else if(month == "09")
			{
				monthAsText = "September";
			}
			else if(month == "10")
			{
				monthAsText = "October";
			}
			else if(month == "11")
			{
				monthAsText = "November";
			}
			else if(month == "12")
			{
				monthAsText = "December";
			}
			
			return monthAsText;
		}
		
		public function getHigh()
		{
			for(var i: int = 0; i < 7; i++)
			{
				dayArray[i].HighTemp.text = "H: " + myXML.*.time[i].temperature.@max + " °F";
			}
		}
		
		public function getLow()
		{		
			for(var i: int = 0; i < 7; i++)
			{
				dayArray[i].LowTemp.text = "L: " +  myXML.*.time[i].temperature.@min + " °F";	
			}
		}
		
		public function getMoreInfo()
		{			
			for(var i: int = 0; i < 7; i++)
			{
				dayArray[i].Humidity.text = "+";
				dayArray[i].Humidity.addEventListener(MouseEvent.MOUSE_OUT, btnOutHandler);
			}
			
				dayArray[0].Humidity.addEventListener(MouseEvent.MOUSE_OVER, btn0OverHandler);
				dayArray[1].Humidity.addEventListener(MouseEvent.MOUSE_OVER, btn1OverHandler);
				dayArray[2].Humidity.addEventListener(MouseEvent.MOUSE_OVER, btn2OverHandler);
				dayArray[3].Humidity.addEventListener(MouseEvent.MOUSE_OVER, btn3OverHandler);
				dayArray[4].Humidity.addEventListener(MouseEvent.MOUSE_OVER, btn4OverHandler);
				dayArray[5].Humidity.addEventListener(MouseEvent.MOUSE_OVER, btn5OverHandler);
				dayArray[6].Humidity.addEventListener(MouseEvent.MOUSE_OVER, btn6OverHandler);		
		}
		
		function btn0OverHandler(event)
		{
			dayArray[0].Humidity.text = "Humidity: " + myXML.*.time[0].humidity.@value + "%"
										  + "\nWind: " + myXML.*.time[0].windSpeed.@name + " " + myXML.*.time[0].windDirection.@code
										  + "\nCloud Cover: " + myXML.*.time[0].clouds.@all + "%"
										  + "\nPressure: " + myXML.*.time[0].pressure.@value + " hPa";
		}
		
		function btn1OverHandler(event)
		{
			dayArray[1].Humidity.text = "Humidity: " + myXML.*.time[1].humidity.@value + "%"
										  + "\nWind: " + myXML.*.time[1].windSpeed.@name + " " + myXML.*.time[1].windDirection.@code
										  + "\nCloud Cover: " + myXML.*.time[1].clouds.@all + "%"
										  + "\nPressure: " + myXML.*.time[1].pressure.@value + " hPa";
		}
		
		function btn2OverHandler(event)
		{
			dayArray[2].Humidity.text = "Humidity: " + myXML.*.time[2].humidity.@value + "%"
										  + "\nWind: " + myXML.*.time[2].windSpeed.@name + " " + myXML.*.time[2].windDirection.@code
										  + "\nCloud Cover: " + myXML.*.time[2].clouds.@all + "%"
										  + "\nPressure: " + myXML.*.time[2].pressure.@value + " hPa";
		}
		
		function btn3OverHandler(event)
		{
			dayArray[3].Humidity.text = "Humidity: " + myXML.*.time[3].humidity.@value + "%"
										  + "\nWind: " + myXML.*.time[3].windSpeed.@name + " " + myXML.*.time[3].windDirection.@code
										  + "\nCloud Cover: " + myXML.*.time[3].clouds.@all + "%"
										  + "\nPressure: " + myXML.*.time[3].pressure.@value + " hPa";
		}
		
		function btn4OverHandler(event)
		{
			dayArray[4].Humidity.text = "Humidity: " + myXML.*.time[4].humidity.@value + "%"
										  + "\nWind: " + myXML.*.time[4].windSpeed.@name + " " + myXML.*.time[4].windDirection.@code
										  + "\nCloud Cover: " + myXML.*.time[4].clouds.@all + "%"
										  + "\nPressure: " + myXML.*.time[4].pressure.@value + " hPa";
		}
		
		function btn5OverHandler(event)
		{
			dayArray[5].Humidity.text = "Humidity: " + myXML.*.time[5].humidity.@value + "%"
										  + "\nWind: " + myXML.*.time[5].windSpeed.@name + " " + myXML.*.time[5].windDirection.@code
										  + "\nCloud Cover: " + myXML.*.time[5].clouds.@all + "%"
										  + "\nPressure: " + myXML.*.time[5].pressure.@value + " hPa";
		}
		
		function btn6OverHandler(event)
		{
			dayArray[6].Humidity.text = "Humidity: " + myXML.*.time[6].humidity.@value + "%"
										  + "\nWind: " + myXML.*.time[6].windSpeed.@name + " " + myXML.*.time[6].windDirection.@code
										  + "\nCloud Cover: " + myXML.*.time[6].clouds.@all + "%"
										  + "\nPressure: " + myXML.*.time[6].pressure.@value + " hPa";
		}
		
		function btnOutHandler(e: MouseEvent)
		{
			for(var i: int = 0; i < 7; i++)
			{
				dayArray[i].Humidity.text = "+";
			}
		}
		
		public function getForecast(id:int)
		{
			var forecast: int;
			
			if(id >= 200 && id <= 299)
			{
				forecast = 1;
			}
			else if(id >= 300 && id <= 599)
			{
				forecast = 2;
			}
			else if(id >= 600 && id <= 699)
			{
				forecast = 3;
			}
			else if(id >= 700 && id <= 799)
			{
				forecast = 4;
			}
			else if(id >= 801 && id <= 804)
			{
				forecast = 5;
			}
			else if(id == 800)
			{
				forecast = 6;
			}
			else if(id == 905)
			{
				forecast = 7;
			}
			
			return forecast;
		}
		
		public function displayUpdatedDate()
		{
			var updatedTime = new Date();
			var month: String = monthNumberToText(updatedTime.month);
			
			var dtf: DateTimeFormatter = new DateTimeFormatter("en-US");
			dtf.setDateTimePattern(month + "-dd hh:mm:ssa");
			
			myDays.UpdatedDate.text = "Updated " + dtf.format(updatedTime);
		}
		
		public function showDay()
		{
			myDays = new weather_stage;
			addChild(myDays);
		}
		
		public function saveFavoriteCities()
		{
			myDays.Save1.addEventListener(MouseEvent.CLICK, handleSaveFavoriteCity1);
			myDays.Save2.addEventListener(MouseEvent.CLICK, handleSaveFavoriteCity2);
			myDays.Save3.addEventListener(MouseEvent.CLICK, handleSaveFavoriteCity3);
		}
		
		public function handleSaveFavoriteCity1(event)
		{
			myDays.Favorite1.text = myDays.CityName.text;
			savedCityObject.data.saved1 = myDays.CityName.text;
			
			myDays.Favorite1.addEventListener(MouseEvent.CLICK, handleLoadFavoriteCity1);
		}
		
		public function handleLoadFavoriteCity1(event)
		{
			savedCityObject = SharedObject.getLocal("userCityData");

			if(savedCityObject.data.userCity != null)
			{
				var city: String = "http://api.openweathermap.org/data/2.5/forecast/daily?q=" + savedCityObject.data.saved1 + "&mode=xml&units=imperial&cnt=7";
				myLoader.load(new URLRequest(city));
			}
			else
			{
				trace("Saved City 1 didn't load. There must have been an error.");
			}
			myLoader.addEventListener(Event.COMPLETE, processXML);
		}
		
		public function handleSaveFavoriteCity2(event)
		{
			myDays.Favorite2.text = myDays.CityName.text;
			savedCityObject.data.saved2 = myDays.CityName.text;
			
			myDays.Favorite2.addEventListener(MouseEvent.CLICK, handleLoadFavoriteCity2);
		}
		
		public function handleLoadFavoriteCity2(event)
		{
			savedCityObject = SharedObject.getLocal("userCityData");

			if(savedCityObject.data.userCity != null)
			{
				var city: String = "http://api.openweathermap.org/data/2.5/forecast/daily?q=" + savedCityObject.data.saved2 + "&mode=xml&units=imperial&cnt=7";
				myLoader.load(new URLRequest(city));
			}
			else
			{
				trace("Saved City 2 didn't load. There must have been an error.");
			}
			myLoader.addEventListener(Event.COMPLETE, processXML);
		}
		
		public function handleSaveFavoriteCity3(event)
		{
			myDays.Favorite3.text = myDays.CityName.text;
			savedCityObject.data.saved3 = myDays.CityName.text;
			
			myDays.Favorite3.addEventListener(MouseEvent.CLICK, handleLoadFavoriteCity3);
		}
		
		public function handleLoadFavoriteCity3(event)
		{
			savedCityObject = SharedObject.getLocal("userCityData");

			if(savedCityObject.data.userCity != null)
			{
				var city: String = "http://api.openweathermap.org/data/2.5/forecast/daily?q=" + savedCityObject.data.saved3 + "&mode=xml&units=imperial&cnt=7";
				myLoader.load(new URLRequest(city));
			}
			else
			{
				trace("Saved City 1 didn't load. There must have been an error.");
			}
			myLoader.addEventListener(Event.COMPLETE, processXML);
		}
	}
}