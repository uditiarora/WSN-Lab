
Mac/Simple set bandwidth_ 1Mb

set MESSAGE_PORT 42
set BROADCAST_ADDR -1


#set val(chan)           Channel/WirelessChannel    ;#Channel Type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type



#set val(mac)            Mac/802_11                 ;# MAC type
#set val(mac)            Mac                 ;# MAC type
set val(mac)		Mac/Simple


set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         32768                         ;# max packet in ifq


set val(rp) DumbAgent


set ns [new Simulator]

set f [open out.tr w]
$ns trace-all $f
$ns eventtrace-all
set nf [open out.nam w]
$ns namtrace-all-wireless $nf 700 200

# set up topography object
set topo       [new Topography]

$topo load_flatgrid 700 200

$ns color 3 green;
$ns color 8 red;
$ns color 1 black;
$ns color 7 purple;

#
# Create God
#
create-god 3

set mac0 [new Mac/Simple]

$ns node-config -adhocRouting $val(rp) \
                -llType $val(ll) \
                -macType $val(mac) \
                -ifqType $val(ifq) \
                -ifqLen $val(ifqlen) \
                -antType $val(ant) \
                -propType $val(prop) \
                -phyType $val(netif) \
		-channelType Channel/WirelessChannel \
                -topoInstance $topo \
                -agentTrace OFF \
                -routerTrace OFF \
                -macTrace ON \
                -movementTrace OFF 

for {set i 0} {$i < 3} {incr i} {
	set node_($i) [$ns node]
	$node_($i) random-motion 0
}

$node_(0) color black
$node_(1) color black
$node_(2) color black


$node_(0) set X_ 200.0
$node_(0) set Y_ 30.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 330.0
$node_(1) set Y_ 150.0
$node_(1) set Z_ 0.0

$node_(2) set X_ 60.0
$node_(2) set Y_ 30.0
$node_(2) set Z_ 0.0

$ns at 0.25 "$node_(2) setdest 500.0 30.0 10000.0"

# subclass Agent/MessagePassing to make it do flooding

Class Agent/MessagePassing/Flooding -superclass Agent/MessagePassing

Agent/MessagePassing/Flooding instproc recv {source sport size data} {
    $self instvar messages_seen node_
    global ns BROADCAST_ADDR 

    # extract message ID from message
    set message_id [lindex [split $data ":"] 0]
    puts "\nNode [$node_ node-addr] got message $message_id\n"

    if {[lsearch $messages_seen $message_id] == -1} {
	lappend messages_seen $message_id
        $ns trace-annotate "[$node_ node-addr] received {$data} from $source"
        $ns trace-annotate "[$node_ node-addr] sending message $message_id"
	$self sendto $size $data $BROADCAST_ADDR $sport
    } else {
        $ns trace-annotate "[$node_ node-addr] received redundant message $message_id from $source"
    }
}

Agent/MessagePassing/Flooding instproc send_message {size message_id data port} {
    $self instvar messages_seen node_
    global ns MESSAGE_PORT BROADCAST_ADDR

    lappend messages_seen $message_id
    $ns trace-annotate "[$node_ node-addr] sending message $message_id"
    $self sendto $size "$message_id:$data" $BROADCAST_ADDR $port
}



# attach a new Agent/MessagePassing/Flooding to each node on port $MESSAGE_PORT
for {set i 0} {$i < 3} {incr i} {
    set a($i) [new Agent/MessagePassing/Flooding]
    $node_($i) attach  $a($i) $MESSAGE_PORT
    $a($i) set messages_seen {}
}

$ns at 0.1 "$a(0) send_message 500 1 {first_message} $MESSAGE_PORT"
$ns at 0.101 "$a(2) send_message 500 2 {second_message} $MESSAGE_PORT"

$ns at 0.2 "$a(0) send_message 500 11 {eleventh_message} $MESSAGE_PORT"
$ns at 0.2 "$a(2) send_message 500 12 {twelfth_message} $MESSAGE_PORT"

$ns at 0.35 "$a(0) send_message 500 3 {third_message} $MESSAGE_PORT"
$ns at 0.351 "$a(2) send_message 500 4 {fourth_message} $MESSAGE_PORT"

$ns at 0.45 "$a(0) send_message 500 13 {thirteenth_message} $MESSAGE_PORT"
$ns at 0.45 "$a(2) send_message 500 14 {fourteenth_message} $MESSAGE_PORT"

for {set i 0} {$i < 3} {incr i} {
	$ns initial_node_pos $node_($i) 30
	$ns at 4.0 "$node_($i) reset";
}

$ns at 4.0 "finish"
$ns at 4.1 "puts \"NS EXITING...\"; $ns halt"



#INSERT ANNOTATIONS HERE

proc finish {} {
        global ns f nf val
        $ns flush-trace
        close $f
        close $nf

}

puts "Starting Simulation..."

$ns run
