#!/bin/bash

./ledger alta_cuenta -u=1 -m=1 -a=0.75
./ledger alta_cuenta -u=2 -m=2 -a=10
./ledger alta_cuenta -u=3 -m=3 -a=200
./ledger realizar_transferencia -o=1 -d=2 -m=1 -a=0.25
./ledger alta_cuenta -u=4 -m=4 -a=50
./ledger realizar_transferencia -o=3 -d=4 -m=3 -a=100
./ledger alta_cuenta -u=5 -m=5 -a=150
./ledger realizar_transferencia -o=2 -d=5 -m=2 -a=5
./ledger alta_cuenta -u=6 -m=6 -a=3
./ledger realizar_transferencia -o=5 -d=6 -m=5 -a=50
./ledger alta_cuenta -u=7 -m=7 -a=1000
./ledger realizar_transferencia -o=7 -d=1 -m=7 -a=200
./ledger alta_cuenta -u=8 -m=8 -a=500
./ledger realizar_transferencia -o=8 -d=3 -m=8 -a=100
./ledger alta_cuenta -u=9 -m=9 -a=0.8
./ledger realizar_transferencia -o=9 -d=4 -m=9 -a=0.3
./ledger alta_cuenta -u=10 -m=10 -a=70
./ledger realizar_transferencia -o=10 -d=2 -m=10 -a=20
./ledger realizar_transferencia -o=6 -d=1 -m=6 -a=1.5
./ledger realizar_transferencia -o=4 -d=5 -m=4 -a=25
