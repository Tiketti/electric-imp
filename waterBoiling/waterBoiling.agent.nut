#require "IFTTT.class.nut:1.0.0"

const SECRET_KEY = "IFTTT_SECRET_KEY";
ifttt <- IFTTT(SECRET_KEY);

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

device.on("water_boiling", sendIfttNotification);
