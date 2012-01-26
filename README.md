ardREST
=========

ardREST is based on the idea of Jason J. Gullickson's RESTduino and  is a simple sketch to provide a improved REST-like API for the Arduino Ethernet Board.

Getting Started
---------------

You need an Arduino Ethernet board and the Arduino development tools.

For testing you'll want some hardware to connect to the Arduino (a green or red LED is enough to get started). Connect the LED between pins 9 and ground (GND).

Load the sketch (ardREST.pde) and modify the following lines to match your setup:

byte mac[] = {0x90, 0xA2, 0xDA, 0x00, 0xEE, 0xAB};

This line sets the MAC address of your ethernet board; if your board has one written on it, you should use that instead.

byte ip[]  = {192,168,250,4};

The next line you'll need to modify is this one which sets the IP address; set it to something valid for your network.


Now you're ready to start talking REST to your Arduino!

To turn on the LED attached to pin #9:

http://192.168.250.4/9/HIGH

This will set the pin to the HIGH state and the LED should light.  Next try this:

http://192.168.250.4/100

This will use PWM to illuminate the LED at around 50% brightness (valid PWM values are 0-255).

Now if we connect a switch to pin #9 we can read the digital (on/off) value using this URL:

http://192.168.250.4/9

This returns a tiny chunk of JSON containing the pin requested and its current value:

{"9":"LOW"}

Analog reads are similar; reading the value of Analog pin #1 looks like this:

http://192.168.250.4/a1

...and return the same JSON formatted result as above:

{"a1":"292"}

