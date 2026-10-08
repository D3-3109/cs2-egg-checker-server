# CS2 Egg Checker Server

Join and check your console for your pet information

## How does this work?

Pets are technically items in your inventory, they don't show up anywhere in your inventory but they are defined as actual items.

When you connect to a server it will receive a list of items you currently have equipped, plus your pet.

The pet includes some information such as time and date when hatched, when your food expires, when it grows to the next stage, the pet age (Egg, Chick, Pullet, Adult), etc.

At the time of writing **the only way** to see this data is through a server or client modifications, Valve has not provided any official way to view this data.

---

Because I don't want to run a full CS2 server (Over 70 GB) and bother with constant updates this simply reimplements the networking.

## Usage

`server.exe <options>`

Options:

- `-dbpath <file>`: Where to write our analytics, sqlite3 file, no analytics if not provided
- `-listen <address>`: What IP to listen on, P2P if not provided

## Building

Requirements: CMake and a C++ compiler with C++23 support

1. `cmake --preset release`
2. `cmake --build --preset release`

## Docker

A container image is built automatically by CI and published to GHCR:

```sh
docker pull ghcr.io/d3-3109/cs2-egg-checker-server:latest
```

Run it (defaults to Steam P2P, no inbound ports needed):

```sh
docker run -d --name cs2-egg-checker \
    -v egg-data:/data \
    ghcr.io/d3-3109/cs2-egg-checker-server:latest

docker logs cs2-egg-checker
# Look for "Connected to Steam servers: <steamid>"
# Players then use: connect <steamid>
```

Or with docker-compose (see `docker-compose.yml`):

```sh
docker compose up -d
```

Configuration via environment variables (extra arguments after the image name are forwarded to the binary verbatim):

| Variable | Effect |
| --- | --- |
| `DBPATH` | Path for the SQLite analytics file (default `/data/egg.db`) |
| `LISTEN` | Address to listen on, e.g. `0.0.0.0:27015`; leave empty for Steam P2P |

To accept direct IP connections set `LISTEN=0.0.0.0:27015` and publish the UDP
port (`-p 27015:27015/udp`). In the default P2P mode the container only needs
outbound UDP to the Steam network and works behind NAT without any port
forwarding.

> Note: new GHCR packages are private by default. Either mark the package
> public (Package settings → Change visibility) or `docker login ghcr.io` on the
> host with a PAT that has `read:packages` before pulling.
