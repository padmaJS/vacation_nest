FROM elixir:1.18-otp-25-slim

RUN apt-get update -y && apt-get install -y \
    git \
    build-essential \
    inotify-tools \
    curl \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

RUN apt-get update && apt-get install -y locales \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN mix local.hex --force && \
    mix local.rebar --force

RUN mix archive.install hex phx_new --force

WORKDIR /workspaces/frayt-elixir
