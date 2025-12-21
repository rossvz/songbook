FROM elixir:1.19-otp-28-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV MIX_DEPS_COMPILE_PARTITION_COUNT=4
ENV ERL_AFLAGS="-kernel shell_history enabled"
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
      file tree strace ripgrep jq procps \
      gnupg curl lsb-release ca-certificates git inotify-tools \
      build-essential tzdata tmux sudo npm nodejs python3 \
      libgtk-3-0 libdbus-glib-1-2 libxt6 \
      libvips-dev

RUN install -d /etc/apt/keyrings && \
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc \
      | gpg --dearmor -o /etc/apt/keyrings/postgresql.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/postgresql.gpg] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" \
      > /etc/apt/sources.list.d/pgdg.list

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends postgresql-17 postgresql-client-17 && \
    service postgresql start && \
    sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres';" && \
    service postgresql stop && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user for cloud agents
RUN useradd -m -s /bin/bash ubuntu && \
    echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER ubuntu
WORKDIR /home/ubuntu

RUN mix local.hex --force && mix local.rebar --force

ENV PATH="/home/ubuntu/.local/bin:${PATH}"
