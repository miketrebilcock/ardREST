/*
ardREST

A REST API for the Arduino Ethernet board
inspired by RESTduino

Created by:
01/24/2012 by Marcel Hauri, http://m83.ch

Original idea by: Jason J. Gullickson's RESTduino

Source:
https://github.com/m83/ardREST

*/


#include <SPI.h>
#include <Ethernet.h>

/* DEFINITIONS */
#define BUFSIZE 255

/* CONFIGURATION PARAMETERS */
byte mac[] = {0x90, 0xA2, 0xDA, 0x00, 0xEE, 0xAB};
byte ip[]  = {192,168,250,4};

// define usable pins on the board
int digitalPins[] = {3, 5, 6, 7, 8, 9};
int analogPins[]  = {0, 1, 2, 3, 4, 5};


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
                        // write value
                        int selectedPin = atoi (pin);
                        char* selectedValue = 0;
                        pinMode(selectedPin, OUTPUT);

                        if(strncmp(value, "HIGH", 4) == 0 || strncmp(value, "LOW", 3) == 0) {
                            if(strncmp(value, "HIGH", 4) == 0) {
                                char* selectedValue = value;
                                digitalWrite(selectedPin, HIGH);
                                printOutput(200, client, jsonOutput(pin, "HIGH", "success"));
                            }

                            if(strncmp(value, "LOW", 3) == 0) {
                                char* selectedValue = value;
                                digitalWrite(selectedPin, LOW);
                                printOutput(200, client, jsonOutput(pin, "LOW", "success"));
                            }
                        } else {
                            int selectedValue = atoi(value);
                            analogWrite(selectedPin, selectedValue);

                            printOutput(200, client, jsonOutput(pin, value, "success"));
                        }
                    } else {
                        // read current value
                        if(pin[0] == 'a' || pin[0] == 'A') {
                            int selectedPin = pin[1] - '0';
                            sprintf(outValue,"%d",analogRead(selectedPin));
                            printOutput(200, client, jsonOutput(pin, outValue, "success"));
                        } else if(pin[0] != NULL) {
                            int selectedPin = pin[0] - '0';
                            pinMode(selectedPin, OUTPUT);
                            int inValue = digitalRead(selectedPin);

                            if(inValue == 0) {
                                sprintf(outValue,"%s","LOW");
                                printOutput(200, client, jsonOutput(pin, "LOW", "success"));
                            }

                            if(inValue == 1) {
                                sprintf(outValue,"%s","HIGH");
                                printOutput(200, client, jsonOutput(pin, "HIGH", "success"));
                            }
                        }
                    }
                } else {
                    printOutput(0, client, "");
                }
                break;
            }
        }
        delay(1);

        client.stop();
    }
}

/* FUNCTIONS */
String jsonOutput(String pin, String value, String status) {
    String output = String();
    output += "ardREST({\"";
    output += "status\":\"";
    output += status;
    output += "\",\r\n \"";
    output += "pin\":\"";
    output += pin;
    output += "\",\r\n \"";
    output += "value\":\"";
    output += value;
    output += "\"})";

    return output;
}

void printOutput(int status, EthernetClient client, String message) {
    switch (status) {
        case 200:
            client.println("HTTP/1.1 200 OK");
            client.println("Content-Type: application/json");
            client.println("Access-Control-Allow-Origin: *");
            client.println();
            client.println(message);
            break;
        default:
            client.println("HTTP/1.1 200 OK");
            client.println("Content-Type: application/json");
            client.println("Access-Control-Allow-Origin: *");
            client.println();
            break;
    }
}
