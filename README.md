# Custom Apache Airflow Providers

## Requirements
- Docker
- Python 3+
- [uv](https://docs.astral.sh/uv/)
- A Minecraft server with RCON enabled (see [Enabling RCON](#enabling-rcon))

## Installation
1. Clone this repository
   ```bash
   git clone https://github.com/LordBaryhobal/DataComp-Airflow.git
   ```
2. Go into `plugins_dev/mc-notifier`
   ```bash
   cd plugins_dev/mc-notifier
3. Install Python dependencies
   ```bash
   uv sync
   ```
4. Build the package
   ```bash
   uv build
   ```
5. Build and start the docker containers\
   ```bash
   cd ../..
   docker compose up -d --build
   ```

## Using the provider
To learn how to use the provider, please refer to the [presentation](providers_presentation/providers.pdf) (slide 8-10).

## Enabling RCON
To enable RCON on your Minecraft server:
1. Set the following settings in `server.properties`
   ```properties
   enable-rcon=true
   rcon.password=<your-password>
   rcon.port=<rcon-port>
   ```
2. Restart the server

> [!NOTE]
> Make sure Apache Airflow (Docker) can access the RCON port\
> You may need to configure some port-forwarding rule if the server is not on the same machine

For more information on the RCON protocol, please check out the [Minecraft Wiki](https://minecraft.wiki/w/RCON)