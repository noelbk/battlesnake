# Battlesnake

A Battlesnake game server, work in progress.

Battlesnake.Player.Loader: load a snake player as a docker image from a url
Battlesnake.Player.Instance: start a loaded player docker image, feed it game state, and read moves from stdout
Battlesnake.Game: run several player instances against each other

## Roadmap

O add the docker commands to build images and run them
O add game logic
O add web frontend

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `battlesnake` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:battlesnake, "~> 0.1.0"}]
    end
    ```

  2. Ensure `battlesnake` is started before your application:

    ```elixir
    def application do
      [applications: [:battlesnake]]
    end
    ```

## Author

Noel Burton-Krahn <noel@burton-krahn.com>

## Licence

Copyright © 2016 Noel Burton-Krahn, Released under the MIT license.


