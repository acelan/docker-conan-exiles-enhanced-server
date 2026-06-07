# docker-conan-exiles-enhanced-server

A flexible Docker container for Conan Exiles Enhanced (UE5) dedicated server hosting.

## Features

- Installs and updates Conan Exiles Enhanced via DepotDownloader.
- Supports core server startup options through environment variables.
- Supports Steam Workshop mod downloads via `MODS`.
- Adds broad configuration flexibility with generic environment-to-INI overrides.

## Quick start

```bash
cp .env.example .env
docker compose up -d --build
```

## Core environment variables

| Variable | Default | Description |
|---|---|---|
| `PUID` | `1000` | UID used for the `steam` user inside the container |
| `PGID` | `1000` | GID used for the `steam` group inside the container |
| `UPDATE_ON_START` | `true` | Update server files every startup |
| `PORT` | `7777` | Game UDP port |
| `QUERY_PORT` | `27015` | Steam query UDP port |
| `RCON_PORT` | `25575` | RCON TCP port |
| `MAX_PLAYERS` | `40` | Max players |
| `SERVER_NAME` | `Conan Exiles Enhanced Server` | Public server name |
| `SERVER_PASSWORD` | (empty) | Optional server password |
| `RCON_PASSWORD` | (empty) | RCON password |
| `ADMIN_PASSWORD` | (empty) | Admin password written to `ServerSettings.ini` |
| `MODS` | (empty) | Comma-separated Workshop IDs |
| `CONANEXILES_CMD_SWITCHES` | (empty) | Extra launch switches appended to server command |

## Flexible INI overrides

You can override nearly any INI value using environment variables.

### Preferred format

`CONANEXILES_INI_<FILE>__<SECTION>__<KEY>=<VALUE>`

- `<FILE>` can be `Game`, `ServerSettings`, `Engine`, `GameUserSettings`, etc.
- `.ini` is optional in `<FILE>`.
- Overrides are written to `/home/steam/server-files/ConanSandbox/Saved/Config/LinuxServer/<FILE>.ini`.

Examples:

```env
CONANEXILES_INI_ServerSettings__ServerSettings__HarvestAmountMultiplier=2.0
CONANEXILES_INI_ServerSettings__ServerSettings__ResourceRespawnSpeedMultiplier=0.5
CONANEXILES_INI_Game__/Script/EngineSettings.GeneralProjectSettings__ProjectVersion=1.0
```

### Legacy-compatible format

The container also accepts:

`CONANEXILES_<FILE>_<SECTION>_<KEY>=<VALUE>`

This exists for compatibility with the older UE4-oriented image variable style.

## Ports

Expose/forward:

- `7777/udp` game traffic
- `7778/udp` pinger port (`PORT + 1`)
- `27015/udp` Steam query
- `25575/tcp` RCON
