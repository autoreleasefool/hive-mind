![Logo](media/HiveMind.png)

# HiveMind

An AI developed to play the Hive board game.

## Components

There are 4 main components which make up the HiveMind AI. This repository contains the main AI logic.

- Client (**Swift**)

  - [hive-client](https://github.com/autoreleasefool/hive-client)
  - iOS app to process state and display moves
  - Lightweight -- primarily encodes basic state and movements
  - GUI to display movements

- Server (**Ruby on Rails**)

  - [hive-server](https://github.com/autoreleasefool/hive-server)
  - Lightweight
  - Receives the game state from the client and forwards it to the engine
  - Passes the suggested move from the engine back to the client

- Engine (**Swift**)

  - [hive-engine](https://github.com/autoreleasefool/hive-engine)
  - Maintains the state of a game
  - Encodable & decodable to pass from client to server and back
  - Provides rules of the games to the AI to allow it to determine valid, playable moves

- HiveMind (**Swift**)
  - Given a game state, explores various moves to determine best play
  - Relies on alpha-beta pruning

---

## Usage

The HiveMind uses a WebSocket for communication. By default, it listens on `ws://localhost:8080`, but you can change the port by providing an alternative through the command line arguments, described below.

To interact with the HiveMind, you can provide various commands over the WebSocket, which it will reply to in turn. The available commands are:

- `[new, n] <IsFirst> <ExplorationTime>`
  - Start a new game
  - `IsFirst` is a `Bool` which indicates if the HiveMind will play first.
  - `ExplorationTime` is a `Double` which specifies the maximum amount of time the HiveMind can explore a state.
- `[move, m] <Movement>`
  - Parse a given `HiveEngine.Movement` (encoded as JSON) and update the HiveMind's internal state. This is how opponent's moves are received
- `[play, p]`
  - Instruct the HiveMind to explore the current state. It will respond with the best move it finds after `ExplorationTime`
- `[quit]`
  - Instruct the HiveMind to end the current game, but remain active to begin another.
- `[exit]`
  - Instruct the HiveMind to quit and end the process.

### Command Line Arguments

- `--port <Int>`, `-p <Int>`: Specify the port which the HiveMind should listen on

---

## Getting Started

1. First, you'll need to grab a couple other repos to build the entire system and play a game of Hive against the HiveMind.
   - [Hive Client](https://github.com/autoreleasefool/hive-client)
   - [Hive Server](https://github.com/autoreleasefool/hive-server)
   - [HiveMind](https://github.com/autoreleasefool/hive-mind)
2. Run the following command to build a debug or release version, respectively:
   - `swift build -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.13"`
   - `swift build -c release -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.13"`
3. Begin an instance with `.build/debug/HiveMind` or `.build/release/HiveMind`

### Requirements

- Swift 5.0+
- macOS 10.13+

## Contributing

1. Install SwiftLint for styling conformance:
   - `brew install swiftlint`
   - Run `swiftlint` from the root of the repository.
   - There should be no errors or violations. If there are, please fix them before opening a PR.
2. Open a PR with your changes 👍

## Notice

Hive Mind is not affiliated with Gen42 Games in any way.
