# Fork Support Guide

Experimental support for using custom StarLoco forks with this Docker stack.

## What Is Fork Support?

StarLoco Docker lets you replace the default StarLoco repositories, refs, and JAR files with your own or a third-party fork. This is experimental — compatibility is not guaranteed.

## Why Use a Fork?

- Test a custom fork locally
- Try a friend's server code
- Patch the server for testing
- Run an alternative version

## Limitations

This stack is designed for StarLoco. Custom forks must be compatible:
- Same database schema
- Same port layout (login 450, game 5555)
- Same configuration format
- Lua scripts at repository root

If your fork diverges, it won't work with this stack.

## Configuration

Add fork overrides to `.env`:

```bash
# Game server fork
STARLOCO_GAME_REPO=https://github.com/myuser/StarLoco-Game.git
STARLOCO_GAME_REF=v1.0.6
STARLOCO_GAME_JAR=game.jar

# Login server fork
STARLOCO_LOGIN_REPO=https://github.com/myuser/StarLoco-Login.git
STARLOCO_LOGIN_REF=v1.0.1
STARLOCO_LOGIN_JAR=login.jar
```

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `STARLOCO_GAME_REPO` | `https://github.com/StarLoco/StarLoco-Game.git` | Game Git repository |
| `STARLOCO_GAME_REF` | `v1.0.6` | Game tag/branch/commit |
| `STARLOCO_GAME_JAR` | `game.jar` | Game JAR filename |
| `STARLOCO_LOGIN_REPO` | `https://github.com/StarLoco/StarLoco-Login.git` | Login Git repository |
| `STARLOCO_LOGIN_REF` | `v1.0.1` | Login tag/branch/commit |
| `STARLOCO_LOGIN_JAR` | `login.jar` | Login JAR filename |

## Build and Start

After editing `.env`:

```bash
./run.sh start --build
```

This fetches your fork and builds new Docker images.

## Example: Test a Friend's Fork

```bash
STARLOCO_GAME_REPO=https://github.com/friend/StarLoco-Game.git
STARLOCO_GAME_REF=experimental-branch
STARLOCO_LOGIN_REPO=https://github.com/friend/StarLoco-Login.git
STARLOCO_LOGIN_REF=experimental-branch
```

## Troubleshooting Fork Issues

- **Build fails** — check your fork's repository URL and ref exist
- **Server won't start** — verify port layout matches (450, 5555)
- **Database error** — your fork may use a different schema

## Revert to Default

Remove fork variables from `.env` or delete the `.env` file:

```bash
rm .env
cp .env.example .env
./run.sh start --build
```

This restores the default StarLoco build.

## Compatibility Notes

- Test any fork locally before using in production
- Your fork's database schema must match StarLoco's
- Some forks may require environment variable changes
- This is experimental — no support guarantee

## Related Pages

- [Quick Start](quick-start.md)
- [Troubleshooting](troubleshooting.md)
- [FAQ](faq.md)
