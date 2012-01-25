/*
ardREST

A REST interface for the Arduino Ethernet board
inspired by RESTduino

 Created by:
 01/24/2012 by Marcel Hauri, http://m83.ch

 Original idea by: Jason J. Gullickson

*/


#include <SPI.h>
#include <Ethernet.h>

/* DEFINITIONS */
#define BUFSIZE 255

/* CONFIGURATION PARAMETERS */
byte mac[] = {0x90, 0xA2, 0xDA, 0x00, 0xEE, 0xAB};
byte ip[]  = {192,168,250,4};



/* Initialize Webserver on Port 80 */
EthernetServer server(80);


/* PROGRAMM */

void setup() {
    Ethernet.begin(mac, ip);
    server.begin();
}

void loop() {

    char clientline[BUFSIZE];
    int index = 0;

    EthernetClient client = server.available();

    if(client) {
        index = 0;
        while (client.connected()) {
            if (client.available()) {
                char c = client.read();
                if(c != '\n' && c != '\r') {
                    clientline[index] = c;
                    index++;

                    if(index >= BUFSIZE) {
                        index = BUFSIZE -1;
                    }
                    continue;
                }

                String urlString = String(clientline);
                String op = urlString.substring(0,urlString.indexOf(' '));
                urlString = urlString.substring(urlString.indexOf('/'), urlString.indexOf(' ', urlString.indexOf('/')));
                urlString.toCharArray(clientline, BUFSIZE);

                char *pin = strtok(clientline,"/");
                char *value = strtok(NULL,"/");
                char outValue[10] = "MU";

                String jsonOut = String();
                if(pin != NULL) {
                    if(value != NULL) {
                        int selectedPin = atoi (pin);
                        pinMode(selectedPin, OUTPUT);

                        if(strncmp(value, "HIGH", 4) == 0 || strncmp(value, "LOW", 3) == 0) {
                            if(strncmp(value, "HIGH", 4) == 0) {
                                digitalWrite(selectedPin, HIGH);
                            }

                            if(strncmp(value, "LOW", 3) == 0) {
                                digitalWrite(selectedPin, LOW);
                            }
                        } else {
                            int selectedValue = atoi(value);
                            analogWrite(selectedPin, selectedValue);
                        }

                        printOutput(0, client, jsonOutput("status", "success"));

                    } else {
                        if(pin[0] == 'a' || pin[0] == 'A') {
                            int selectedPin = pin[1] - '0';
                            sprintf(outValue,"%d",analogRead(selectedPin));
                        } else if(pin[0] != NULL) {
                            int selectedPin = pin[0] - '0';
                            pinMode(selectedPin, INPUT);
                            int inValue = digitalRead(selectedPin);

                            if(inValue == 0) {
                                sprintf(outValue,"%s","LOW");
                            }

                            if(inValue == 1) {
                                sprintf(outValue,"%s","HIGH");
                            }
                        }

                        printOutput(200, client, jsonOutput(pin, outValue));

                    }
                } else {
                    printOutput(0, client, jsonOutput("status", "ready"));
                }
                break;
            }
        }
        delay(1);

        client.stop();
    }
}

/* FUNCTIONS */
String jsonOutput(String pin, String value) {
    String output = String();
    output += "{\"";
    output += pin;
    output += "\":\"";
    output += value;
    output += "\"}";

    return output;
}

void printOutput(int status, EthernetClient client, String message) {
    switch (status) {
        case 200:
            client.println("HTTP/1.1 200 OK");
            client.println("Content-Type: text/html");
            client.println("Access-Control-Allow-Origin: *");
            client.println();
            client.println(message);
            break;
        default:
            client.println("HTTP/1.1 200 OK");
            client.println("Content-Type: text/html");
            client.println();
            client.println(message);
            break;
    }
    delay(1);
}