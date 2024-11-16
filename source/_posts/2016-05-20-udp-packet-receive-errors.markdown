---
layout: post
title: "udp packet receive errors"
date: 2016-05-20 08:09:35 +0800
comments: true
categories: network
---
## Issue

netstat -s output shows high number of Udp: packet receive errors

Getting high number of UDP packet drops or loss

SNMP trap issue :- SNMP trap seems to be fluctuating on my RHEL server.

## Resolution

Udp: packet receive errors is increased for the following reasons:

* Not enough socket buffer space

* UDP checksum failure

* UDP length mismatch

* IPSec Security Policy failure

## Diagnostic Steps

#### Gather statistics

Run the command netstat -nsu and see the Udp: section:

    netstat -su

    Udp:
        559933412 packets received
        71 packets to unknown port received.
        33861296 packet receive errors    <---- HERE
        7516291 packets sent
    Socket buffer checking:

The current system-wide default socket buffer size can be determined with the commands:

    sysctl net.core.rmem_max
    sysctl net.core.rmem_default

This can be confirmed by watching socket statistics whilst packet receive errors is growing by running ss -nump at regular intervals, for example:

    while true; do ss -nump; sleep 1; done

This will produce output as follows:

    State    Recv-Q Send-Q    Local Address:Port      Peer Address:Port
    ESTAB    0      0           192.168.0.2:4500       192.168.0.1:4500
    users:(("processname",pid=1234,fd=3))
            skmem:(r0,rb212992,t0,tb212992,f4096,w0,o0,bl0)

If the Recv-Q statistic is regularly growing large, such as approading the system-wide rmem_max, then increase the socket buffer size.

Note this means the application is not receiving from the buffer fast enough. It may be necessary to reconfigure or redesign the application to perform better.

## Conclusion

The statistic Udp: packet receive errors is reporting the SNMP MIB called UDP_MIB_INERRORS.

## Commands

* run udp server

        nc -4 -u -l 2389

* cli to server

        echo -n "hello" | nc -u x.x.x.x 2389
