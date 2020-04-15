
set val(chan)           Channel/WirelessChannel    ;
set val(prop)			Propagation/TwoRayGround
set val(netif)          Phy/WirelessPhy            ;
set val(mac)            Mac/802_11                 ;
set val(ifq)            Queue/DropTail/PriQueue               ;
set val(ll)             LL                         ;
set val(ant)            Antenna/OmniAntenna        ;
set val(ifqlen)         10000                         ;
set val(nn)             4                        ;
set val(rp)             AODV                       ;
set val(x)              800                ;
set val(y)              800              ;
set val(stop)       25             ;
set val(R)         300
set opt(tr)     out.tr

set ns        [new Simulator]
set tracefd  [open $opt(tr) w]
set windowVsTime2 [open out.tr w]
set namtrace      [open out.nam w]

Phy/WirelessPhy set CPThresh_ 10.0
Phy/WirelessPhy set CSThresh_ 3.65262e-10 ;
Phy/WirelessPhy set RXThresh_ 3.65262e-10 ;
Phy/WirelessPhy set Rb_ 2*1e6
Phy/WirelessPhy set Pt_ 0.2818
Phy/WirelessPhy set freq_ 914e+6
Phy/WirelessPhy set L_ 1.0

Mac/802_11 set dataRate_        1.2e6
Mac/802_11 set RTSThreshold_    3000
$ns trace-all $tracefd 
$ns namtrace-all-wireless $namtrace $val(x) $val(y)
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)
$ns node-config -adhocRouting $val(rp) \
	-llType $val(ll) \
	-macType $val(mac) \
	-ifqType $val(ifq) \
	-ifqLen $val(ifqlen) \
	-antType $val(ant) \
	-propType $val(prop) \
	-phyType $val(netif) \
	-channelType $val(chan) \
	-topoInstance $topo \
	-agentTrace ON \
	-routerTrace ON \
	-macTrace ON \
	-movementTrace ON


	for {set i 0} {$i < $val(nn) } { incr i } {
		set node_($i) [$ns node]    
	}

$node_(0) set X_ 0 
$node_(0) set Y_ 300
$node_(0) set Z_ 300

$node_(1) set X_ 200
$node_(1) set Y_ 300
$node_(1) set Z_ 300

$node_(2) set X_ 400
$node_(2) set Y_ 300
$node_(2) set Z_ 300

$node_(3) set X_ 600
$node_(3) set Y_ 300
$node_(3) set Z_ 300

for {set i 0} {$i<$val(nn)} {incr i} {
	$ns initial_node_pos $node_($i) 30
}

$ns at 10 "$node_(3) setdest 400 1 1000.0"
$ns at 10 "$node_(2) setdest 400 700 1000.0"
set tcp [new Agent/TCP/Newreno]
set tcp [new Agent/UDP]
$tcp set class_ 2
set sink [new Agent/Null]
$ns attach-agent $node_(0) $tcp
$ns attach-agent $node_(3) $sink
$ns connect $tcp $sink
set ftp [new Application/Traffic/CBR]
$ftp attach-agent $tcp
$ns at 0.0 "$ftp start"

$tcp set fid_ 1
$ns color 1 blue


$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "stop"
$ns at $val(stop) "puts \"end simulation\" ; $ns halt"
proc stop {} {

	global ns tracefd namtrace
	$ns flush-trace
	close $tracefd
	close $namtrace

	exec nam out.nam &
	exit 0
}

$ns run
