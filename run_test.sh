#!/bin/sh

HAPROXY_CMD=/usr/local/sbin/haproxy
# AB_CMD=/usr/sbin/ab
AB_CMD=./ab

# input:  number of thin processes
#
# create haproxy config
# start thin with number of processes
# start haproxy
# run `ab` against the haproxy url. static values for -n and -c

processes=$1

if [ -z "$processes" ]; then
    echo "Usage: $0 number_of_thin_processes"
    exit 1
fi

echo "==> Starting thin with $processes processes"
thin -R config.ru -p 3000 -s${processes} -d --stats /stats start

echo "==> Creating haproxy.cfg"
cat haproxy.cfg.base >haproxy.cfg
for ((i=0; i < $processes; i++)) do
    # echo "   server   thin_$i   127.0.0.1:300${i} maxconn 1 check inter 20000 fastinter 1000 fall 1" >> haproxy.cfg
    echo "   server   thin_$i   127.0.0.1:300${i}" >> haproxy.cfg
done

echo "==> Starting haproxy"
$HAPROXY_CMD -f haproxy.cfg &

## prime the processes? ##
for ((i=0; i < 20; i++)) do
    curl http://127.0.0.1:9000/ >/dev/null 2>&1
done

echo "==> Running ab ..."
#$AB_CMD -n 10000 -c 20 http://127.0.0.1:9000/
$AB_CMD -n 10000 -c 20 http://127.0.0.1:3000/

# echo "==> Running httperf ..."
# httperf --hog --num-calls=1000 --num-conns=20 --rate=20 --server 127.0.0.1 --port=9000

echo "==> Stopping haproxy"
kill %1
rm -f haproxy.cfg

echo "==> Stopping thin"
thin -R config.ru -p 3000 -s${processes} -d stop
