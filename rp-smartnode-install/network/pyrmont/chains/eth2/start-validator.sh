#!/bin/sh
# This script launches ETH2 validator clients for Rocket Pool's docker stack; only edit if you know what you're doing ;)


# RP version number for graffiti
ROCKET_POOL_VERSION="v0.0.9"


# Get graffiti text
GRAFFITI="RP $ROCKET_POOL_VERSION"
if [ ! -z "$CUSTOM_GRAFFITI" ]; then
    GRAFFITI="$GRAFFITI ($CUSTOM_GRAFFITI)"
fi


# Lighthouse startup
if [ "$CLIENT" = "lighthouse" ]; then

    /usr/local/bin/lighthouse validator --network pyrmont --datadir /data/validators/lighthouse --init-slashing-protection --beacon-node "http://$ETH2_PROVIDER" --graffiti "$GRAFFITI"

fi


# Prysm startup
if [ "$CLIENT" = "prysm" ]; then

    /app/validator/validator --accept-terms-of-use --pyrmont --wallet-dir /data/validators/prysm-non-hd --wallet-password-file /data/password --beacon-rpc-provider "$ETH2_PROVIDER" --graffiti "$GRAFFITI"

fi


# Teku startup
if [ "$CLIENT" = "teku" ]; then

    exec /opt/teku/bin/teku validator-client --network=pyrmont --beacon-node-api-endpoint="http://$ETH2_PROVIDER" --validator-keys=/data/validators/teku/keys:/data/validators/teku/passwords --validators-graffiti="$GRAFFITI"

fi


# Nimbus startup
if [ "$CLIENT" = "nimbus" ]; then

    # Split out the provider string and resolve ip address
    ETH2HOST=${ETH2_PROVIDER%%:*}
    ETH2PORT=${ETH2_PROVIDER##*:}
    getentstr=`getent hosts $ETH2HOST`
    ETH2IP=${getentstr%% *}
    
    exec /home/user/nimbus-eth2/build/nimbus_validator_client \
        --non-interactive \
        --validators-dir=/data/validators/nimbus/validators \
        --secrets-dir=/data/validators/nimbus/secrets \
        --rpc-port=$ETH2PORT \
        --rpc-address=$ETH2IP \

fi
