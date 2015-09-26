#require "APDS9007.class.nut:1.0.0"
#require "LPS25H.class.nut:1.0.0"
#require "Si702x.class.nut:1.0.0"

// notify when humidity rises above this level
const HUMIDITY_TRESHOLD = 65;

// only notify when this time has passed since last notification (30 minutes)
const NOTIFICATION_TRESHOLD = 1800;

// check for humidity every x seconds
const POLLING_INTERVAL = 30;

// timestamp of last notification
notification_sent <- 0;

function initialize() {
    local pressureInterrupt = hardware.pin1;
    server.log("pressureInterrupt: " + pressureInterrupt);

    led <- hardware.pin2;
    led.configure(DIGITAL_OUT, 0);
    server.log("led: " + led);

    local lightInput = hardware.pin5;
    lightInput.configure(ANALOG_IN);
    server.log("lightInput: " + lightInput);

    local lightEnable = hardware.pin7;
    lightEnable.configure(DIGITAL_OUT, 1)
    server.log("lightEnable: " + lightEnable);

    local i2cScl = hardware.pin8;
    server.log("i2cScl: " + i2cScl);

    local i2cSda = hardware.pin9;
    server.log("i2cSda: " + i2cSda);

    hardware.i2c89.configure(CLOCK_SPEED_400_KHZ);
    tempHumidSensor <- Si702x(hardware.i2c89);

    lightSensor <- APDS9007(lightInput, 47000, lightEnable);
    local pressureSensor = LPS25H(hardware.i2c89);

    server.log("pressureSensor instance: " + pressureSensor);
    server.log("tempHumidSensor instance: " + tempHumidSensor);
}

function readAndLogTempAndHumidity() {
    tempHumidSensor.read(function(data) {
        local temperature = format("%0.1f", data.temperature);
        local humidity = format("%0.1f", data.humidity);
        local luxVal = format("%0.1f", lightSensor.read());

        server.log("temperature: " + temperature);
        server.log("humidity: " + humidity);
        server.log("light level (lux):" +  luxVal);

        agent.send("lightTempHumidity", {  "temperature": temperature,
                                            "humidity": humidity,
                                            "light": luxVal
        } );

        if(data.humidity >= HUMIDITY_TRESHOLD) {
            notify(humidity);
        }

        flashLed();
    });
    imp.wakeup(POLLING_INTERVAL, readAndLogTempAndHumidity);
}

function notify(humidity) {
    server.log("notify called");

    if(time() - notification_sent >= NOTIFICATION_TRESHOLD ) {
        notification_sent = time();

        // call agent
        agent.send("water_boiling", humidity);
        server.log("Agent called by notify()");
    }
}

function flashLed() {
    // Turn the LED on (write a HIGH value)
    led.write(1);

    // Pause for half a second
    imp.sleep(1);

    // Turn the LED off
    led.write(0);
}

initialize();
server.log(format("\n*** Polling every " + POLLING_INTERVAL + " seconds ***"));
readAndLogTempAndHumidity();
