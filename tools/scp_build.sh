#!/bin/sh

source env.sh
./build_pi.sh
echo "Uploading..."
scp output/udp $SSH_USER@$SSH_IP:$SSH_DIR
echo "Done."