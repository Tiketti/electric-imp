#require "ws2812.class.nut:2.0.1"

// create a SPI object to use to control the WS2812 LEDs
spi <- hardware.spi257;
// configure SPI to run at 7.5 MHz
spi.configure(MSB_FIRST, 7500);

// instantiate WS2812 class to create object for our 5 LEDs
leds <- WS2812(spi, 5);

// write out frame buffer
leds.draw();

agent.on("updateData", function(lightAmount) {
        lightUpLeds(lightAmount);
    }
)

function switchAllOff() {
    leds <- WS2812(spi, 5);
    leds.fill([0, 0, 0]);
}

function lightUpLeds(count) {
    switchAllOff();

    // fill(color[, start][, end])
    leds <- WS2812(spi, 5);
    leds.fill([10, 10, 10], 0, count-1);

    // write out frame buffer
    leds.draw();
}
