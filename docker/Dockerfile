FROM elixir:1.16.1-alpine AS build

ARG MIX_ENV=prod
ENV MIX_ENV=${MIX_ENV}

WORKDIR /build

COPY mix.exs mix.lock ./
RUN mix deps.get
RUN mix deps.compile

COPY lib/ ./lib
COPY config/ ./config
COPY rel/ ./rel

RUN mix release

FROM erlang:26.2.3.0-alpine

WORKDIR /app
COPY --from=build /build/_build/prod/rel/spectral/ ./
ENTRYPOINT ["/app/bin/spectral", "start"]
