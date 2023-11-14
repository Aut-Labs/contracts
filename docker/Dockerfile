# ================
# >> Helper image that buils node_modules
# todo: move completely to foundry and exclude this build step
FROM node:16 as node_modules_builder

WORKDIR /tmp

COPY package.json .
COPY yarn.lock .

RUN yarn install --non-interactive --frozen-lockfile

# ================
# >> Main image
FROM ghcr.io/foundry-rs/foundry

ENV RPC_PORT 8545

WORKDIR /usr/src/app

# todo: add hc loop entrypoint
## RUN apk update && apk add curl

COPY --from=node_modules_builder /tmp/node_modules ./node_modules

COPY docker/entrypoint.sh .
COPY foundry.toml .
COPY lib ./lib
COPY script ./script
COPY contracts ./contracts


RUN chmod +x ./entrypoint.sh


# todo: install solc manually so that forge won't install it each time ruining cached layer
RUN forge build

ENTRYPOINT ["./entrypoint.sh"]
