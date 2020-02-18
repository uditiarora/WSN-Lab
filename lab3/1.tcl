set ns [new Simulator]

#Define different colors for data flows (for NAM)
$ns color 1 Blue
$ns color 2 Red

#Open the Trace files
set file1 [open out.tr w]
set winfile [open WinFile w]
$ns trace-all $file1

#Open the NAM trace file
set file2 [open out.nam w]
$ns namtrace-all $file2

#Define a 'finish' procedure
proc finish {} {
        global ns file1 file2
        $ns flush-trace
        close $file1
        close $file2
        exec nam out.nam &
        exit 0
}

#Create six nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

$n1 color red
$n1 shape box

#Create links between the nodes
$ns duplex-link $n2 $n3 0.3Mb 100ms DropTail


set lan [$ns newLan "$n0 $n1 $n2" 0.5Mb 40ms LL Queue/DropTail MAC/Csma/Cd Channel]
set lan2 [$ns newLan "$n3 $n4 $n5" 0.5Mb 40ms LL Queue/DropTail MAC/Csma/Cd Channel]

$ns duplex-link-op $n2 $n3 orient right

set tcp [new Agent/TCP/Newreno]
$ns attach-agent $n0 $tcp
set sink [new Agent/TCPSink/DelAck]
$ns attach-agent $n4 $sink
$ns connect $tcp $sink
$tcp set fid_ 1
$tcp set window_ 8000
$tcp set packetSize_ 552

set tcp2 [new Agent/TCP/Newreno]
$ns attach-agent $n5 $tcp2
set sink2 [new Agent/TCPSink/DelAck]
$ns attach-agent $n2 $sink2
$ns connect $tcp2 $sink2
$tcp2 set fid_ 2
$tcp2 set window_ 8000
$tcp2 set packetSize_ 552


#Setup a FTP over TCP connection
set ftp [new Application/FTP]
$ftp attach-agent $tcp


set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2


$ns at 0.0 "$ftp start"
$ns at 5.0 "$ftp stop"
$ns at 6.0 "finish"
$ns run
