# HiveMind

An AI developed to play the Hive board game.

## Components

There are 4 main components which make up the HiveMind AI. This repository contains the server and the main AI unit.

* Client (**Swift**)
    * [hivemind-client](https://github.com/josephroqueca/hiveai-client)
    * iOS app to process state and display moves
    * Lightweight -- primarily encodes basic state and movements
    * GUI to display movements

* Server (**Ruby on Rails**)
    * Lightweight
    * Receives the game state from the client and forwards it to the engine
    * Passes the suggested move from the engine back to the client

* Engine (**Swift**)
    * [hive-engine](https://github.com/josephroqueca/hive-engine)
    * Maintains the state of a game
    * Encodable & decodable to pass from client to server and back
    * Provides rules of the games to the AI to allow it to determine valid, playable moves

* HiveMind (**Swift**)
    * Programmed with explicit strategies
    * Given a game state, explores various moves to determine best play
    * Relies on alpha-beta pruning
