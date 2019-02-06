# HiveMind

An AI developed to play the Hive board game.

## Components

There are 4 main components which make up the HiveMind AI.

* Tower (Hardware)
    * Hardware to capture the physical game state
    * Built with **Android Things Starter Kit**
        * Pico NXP i.MX7D development board
        * Rainbow HAT
        * Wifi antenna
        * 5" multi-touch display
        * 5MP camera module
    * Physical casing likely to be built with cardboard

* Client (**Kotlin**)
    * Code which runs on the tower
    * Relies on **TensorFlow** to parse images captured by the camera module
    * Lightweight -- primarily encodes basic state and movements
    * GUI to display movements on the display

* Server (**Ruby on Rails**)
    * Lightweight
    * Receives the game state from the client and forwards it to the engine
    * Passes the suggested move from the engine back to the client

* Engine (**Swift**)
    * Programmed with explicit strategies
    * Given a game state, explores various moves to determine best play
    * Might eventually use Hive game archives to evaluate play and learn
