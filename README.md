### OpenWeatherMap 

This project is a simple weather app based on the [OpenWeatherMap API](http://openweathermap.org/).

It uses a dedicated _wrapper_ for the API that the `ViewController` uses. The wrapper currently allows for accessing to kinds of functionalities:

1. Access the current weather
2. Access the weather forecast for the next X days

It uses closures to return the result to the caller once it the data has been returned from the network.

