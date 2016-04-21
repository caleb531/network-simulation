# Create simulator object
set ns [new Simulator]

# Create trace file

set traceFile [open traceRouteOfTop.tr w]
$ns trace-all $traceFile

#Tell the simulator to use dynamic routing
$ns rtproto DV

#Define a 'finish' procedure
proc finish {} {
	global traceFile
	set ns [Simulator instance]

	$ns flush-trace
	close $traceFile

	exit 0
}

proc key { sourceNodeNumber destNodeNumber } {
	return [concat $sourceNodeNumber $destNodeNumber]
}


proc create-white-data-connection { sourceNodeNumber destNodeNumber } {
	set ns [Simulator instance]

	global dataSourceAgents
	global dataSourceProtocolAgents
	global dataSinks

	#Create a UDP agent and attach it to the node
	set udp [new Agent/UDP]
	$ns attach-agent $nodes($sourceNodeNumber) $udp

	#Create an Expoo traffic agent and set its configuration parameters
	set traffic [new Application/Traffic/Exponential]
	$traffic set packetSize_ 2000
	$traffic set burst_time_ 2.5s
	$traffic set idle_time_ 1s
	$traffic set rate_ 1200k
        
    # Attach traffic source to the traffic generator
    $traffic attach-agent $udp

    set sink [new Agent/LossMonitor]
    $ns attach-agent $nodes($destNodeNumber) $sink

	#Connect the source and the sink
	$ns connect $udp $sink

	#associate my fresh data source with its link key
	set dataSourceAgents([key $sourceNodeNumber $destNodeNumber]) $traffic
	set dataSourceProtocolAgents([key $sourceNodeNumber $destNodeNumber]) $udp
	set dataSinks([key $sourceNodeNumber $destNodeNumber]) $sink
}

proc create-all-white-data-connections { destNodeNumbers sourceNodeNumber } {
	foreach destNodeNumber $destNodeNumbers {
		create-blue-data-connection $sourceNodeNumber $destNodeNumber
	}
}


proc create-green-data-connection { sourceNodeNumber destNodeNumber } {
	set ns [Simulator instance]

	global dataSourceAgents
	global dataSourceProtocolAgents
	global dataSinks

	#Create a UDP agent and attach it to the node
	set udp [new Agent/UDP]
	$ns attach-agent $nodes($sourceNodeNumber) $udp

	#Create an Expoo traffic agent and set its configuration parameters
	set traffic [new Application/Traffic/CBR]
	$traffic set packetSize_ 500
	$traffic set interval_ 0.005
        
    # Attach traffic source to the traffic generator
    $traffic attach-agent $udp

    set sink [new Agent/Null]
    $ns attach-agent $nodes($destNodeNumber) $sink

	#Connect the source and the sink
	$ns connect $udp $sink

	#associate my fresh data source with its link key
	set dataSourceAgents([key $sourceNodeNumber $destNodeNumber]) $traffic
	set dataSourceProtocolAgents([key $sourceNodeNumber $destNodeNumber]) $udp
	set dataSinks([key $sourceNodeNumber $destNodeNumber]) $sink
}

proc create-all-green-data-connections { destNodeNumbers sourceNodeNumber } {
	foreach destNodeNumber $destNodeNumbers {
		create-blue-data-connection $sourceNodeNumber $destNodeNumber
	}
}


proc create-blue-data-connection { sourceNodeNumber destNodeNumber } {
	set ns [Simulator instance]

	global dataSourceAgents
	global dataSourceProtocolAgents
	global dataSinks

	set tcp [new Agent/TCP]
	$tcp set class_ 2
	$ns attach-agent $nodes($sourceNodeNumber) $tcp

	#Setup a FTP over TCP connection
	set ftp [new Application/FTP]
	$ftp attach-agent $tcp
	$ftp set type_ FTP

	#Setup data sink
	set sink [new Agent/TCPSink]
	$ns attach-agent $nodes($destNodeNumber) $sink

	#associate my fresh data source with its link key
	set dataSourceAgents([key $sourceNodeNumber $destNodeNumber]) $ftp
	set dataSourceProtocolAgents([key $sourceNodeNumber $destNodeNumber]) $tcp
	set dataSinks([key $sourceNodeNumber $destNodeNumber]) $sink
}

proc create-all-blue-data-connections { destNodeNumbers sourceNodeNumber } {
	foreach destNodeNumber $destNodeNumbers {
		create-blue-data-connection $sourceNodeNumber $destNodeNumber
	}
}


#oh god...can I haz a duplex linking method plz???
#I CANZ!!!! THANK YOU MAW!

proc duplex-link-all {edges dest bandwidth latency queueMethod queueLimit} {
	global nodes
	set ns [Simulator instance]

	foreach edge $edges {
		$ns duplex-link $nodes($edge) $nodes($dest) $bandwidth $latency $queueMethod
		$ns queue-limit $nodes($edge) $nodes($dest) $queueLimit
	}
}

set max_nodes 28
array set dataSourceAgents {}
array set dataSourceProtocolAgents {}
array set dataSinks {}

#Create our nodes
for {set i 0} {$i < $max_nodes} {incr i} {
	set nodes($i) [$ns node]
}

#Link up all of our nodes

#Edges first (all linked via green duplex links)
#ROUTER 0
duplex-link-all "13 14 15 16" 0 1Mb 20ms DropTail 10
#ROUTER 1 
duplex-link-all "7 8 9 10 11 12" 1 1Mb 20ms DropTail 10
#ROUTER 4 
duplex-link-all "17 18 19 20" 4 1Mb 20ms DropTail 10
#ROUTER 5 
duplex-link-all "21 22 23 24" 5 1Mb 20ms DropTail 10
#ROUTER 6 
duplex-link-all "25 26 27" 6 1Mb 20ms DropTail 10

#Cores last
#purple duplex links leading
duplex-link-all "0 4" 2 2Mb 40ms DropTail 15
duplex-link-all "5 6" 3 2Mb 40ms DropTail 15

#black duplex links bringing up the rear
duplex-link-all "2" 3 8Mb 50ms DropTail 20
duplex-link-all "2 3" 1 8Mb 50ms DropTail 20

#Create our connections
create-all-blue-data-connections "12 14 15 20 23 27" 9
create-all-green-data-connections "8 11 17 19 21 24 25 26" 13
create-all-white-data-connections "18 22" 10
create-all-white-data-connections "18 22" 16


#Make some events
#At time 1, 9->12, 13->8, 9->14 traffic flows start
$ns at 1.0 "
			$dataSourceAgents([key 9 12]) start
			$dataSourceAgents([key 13 8]) start
			$dataSourceAgents([key 9 14]) start
		 "

#At time 2, 13->11, 9->15, 13->17 traffic flows start
$ns at 2.0 "
			$dataSourceAgents([key 13 11]) start
			$dataSourceAgents([key 9 15]) start
			$dataSourceAgents([key 13 17]) start
		 "

#At time 3, 13->19, 9->18, 13->21 traffic flows start
$ns at 3.0 "
			$dataSourceAgents([key 13 19]) start
			$dataSourceAgents([key 9 18]) start
			$dataSourceAgents([key 13 21]) start
		 "

#At time 4, 13->24, 9->20, 13->25 traffic flows start
$ns at 4.0 "
			$dataSourceAgents([key 13 24]) start
			$dataSourceAgents([key 9 20]) start
			$dataSourceAgents([key 13 25]) start
		 "

#At time 5, 9->23, 13->26, 9->27 traffic flows start
$ns at 5.0 "
			$dataSourceAgents([key 9 23]) start
			$dataSourceAgents([key 13 26]) start
			$dataSourceAgents([key 9 27]) start
		 "

#At time 6, 10->18, 16->18 traffic flows start
$ns at 6.0 "
			$dataSourceAgents([key 10 18]) start
			$dataSourceAgents([key 16 18]) start
		 "

#At time 7, link 1-3 goes Down, refer to example4.tcl
$ns at 7.0 "
			$dataSourceAgents([key 9 14]) stop
		   "

#At time 8, link 1-3 goes Up, refer to example4.tcl
$ns at 8.0 "
			$dataSourceAgents([key 1 3]) start
		 "

#At time 10, the simulation stops
$ns at 10.0 "finish"

#See if stuff is broken
$ns run