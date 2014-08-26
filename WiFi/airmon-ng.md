# AIRMON-NG

To start the `wlan1` in monitor-mode, resulting in `mon0`. For this we can use `airmon-ng`.

~~~bash
$ airmon-ng start wlan1 1 # adding '1' for channel 1

Found 2 processes that could cause trouble.
If airodump-ng, aireplay-ng or airtun-ng stops working after
a short period of time, you may want to kill (some of) them!
-e
PID	Name
1800	NetworkManager
2297	wpa_supplicant


Interface	Chipset		Driver

wlan1		Ralink RT2870/3070	rt2800usb - [phy0]
				(monitor mode enabled on mon0)
~~~

We should now be able to see the `mon0` device also in `ifconfig` and `iwconfig`

~~~bash
# Now check ifconfig and iwconfig
$ ifconfig

mon0      Link encap:UNSPEC  HWaddr 00-C0-CA-59-9E-97-00-00-00-00-00-00-00-00-00-00
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:209 errors:0 dropped:209 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:48245 (47.1 KiB)  TX bytes:0 (0.0 B)

[...]



$ iwconfig

mon0      IEEE 802.11bgn  Mode:Monitor  Tx-Power=20 dBm
          Retry  long limit:7   RTS thr:off   Fragment thr:off
          Power Management:on
          
[...]
~~~

It can be stopped using airmon-ng as well.

~~~bash
$ airmon-ng stop mon0
~~~