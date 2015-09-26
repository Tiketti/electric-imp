#require "IFTTT.class.nut:1.0.0"
#require "Dweetio.class.nut:1.0.0"

const IFTTT_SECRET_KEY = "IFTTT_SECRET_KEY";
ifttt <- IFTTT(IFTTT_SECRET_KEY);

const DWEET_THING_NAME = "DWEET_THING_NAME";
dweetClient <- DweetIO();

function sendIfttNotification(data) {
    server.log("Agent logged data: " + data);

    // Trigger an event with no values and a callback
    ifttt.sendEvent("water_boiling", function(err, response) {
        if (err) {
            server.error(err);
            return;
        }
        server.log("IFTTT call was successful");
    });
}

function sendToDweet(data) {
    dweetClient.dweet(DWEET_THING_NAME, { "temperature" : data.temperature, "humidity" : data.humidity },
    function(response) {
        server.log("Dweet responded [" + response.statuscode + "] " + response.body);
    });
}

device.on("water_boiling", sendIfttNotification);
device.on("temperatureAndHumidity", sendToDweet);
