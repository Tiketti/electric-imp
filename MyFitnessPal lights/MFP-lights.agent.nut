#require "Dweetio.class.nut:1.0.0"
const POLLING_INTERVAL = 20;
const DWEET_THING_NAME = "mfpconsumedandgoal";
dweetClient <- DweetIO();

// okay, something is very off and division doesn't behave as expected.
// therefore, this funky, despicabe workaround
function getLightAmount(consumed) {
    local ret = 0;
    if(consumed < 500) ret = 1;
    else if (consumed < 900) ret = 2;
    else if (consumed < 1400) ret = 3;
    else if (consumed < 1700) ret = 4;
    else if (consumed >= 2100) ret = 5;

    return ret;
}

function getLatest(callback) {
    local data;

    dweetClient.getLatest(DWEET_THING_NAME, function(response) {
        if (response.statuscode != 200) {
            server.log("Error getting dweet: " + response.statuscode + " - " + response.body);
            return;
        }
        server.log(response.body);
        data = http.jsondecode(response.body)["with"][0];

        callback(data);
    });
}

function poll() {

    getLatest(function (data){
        local consumed = data.content["consumed"].tointeger();
        local goal = data.content["goal"].tointeger();
        local percentage = format("%.1f", (casti2f(consumed) / casti2f(goal)) * 100);
        server.log("latest consumed: " + consumed);
        server.log("latest goal: " + goal);
        server.log("percentage: " + percentage);

        local lightAmount = getLightAmount(data.content["consumed"]);

        imp.wakeup(1, function() {
            device.send("updateData", lightAmount);
        });
    });

    imp.wakeup(POLLING_INTERVAL, poll);
}

poll();


/*
dweetClient.stream(DWEET_THING_NAME, function(thing) {
    server.log("thing:" + thing);
    local arr = split(thing, "{\"");
    local consumed = arr[11].slice(1, arr[11].len() - 1);
    local goal = arr[13].slice(1, arr[13].len() - 2);
    local c = consumed.tointeger();
    local g = goal.tointeger();

    server.log("c: " + c + ", g: " + g);
    local lightAmount = getLightAmount(c);

    //TODO: send also light color
    device.send("updateData", lightAmount);
});
*/
