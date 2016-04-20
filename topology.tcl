
proc get_next_flow_id { } {

	return [incr ::flowID]
}

proc key { dataSourceNodeNumber dataSinkNodeNumber } {
	return [concat $dataSourceNodeNumber $dataSinkNodeNumber]
}

proc create_trafficSink_for_blue_edge { blueEdge } {
	set ns [Simulator instance]
	set sink [new Agent/TCPSink]
	$ns attach-agent $blueEdge $sink

	return $sink
}


#EXP over UDP connected to LossMonitor (exp packetSize_ 2000  burst_time_ 2.5s  idle_time_ 1s  rate_ 1200k), refer to example2.tcl
proc create_trafficSrc_for_server_10_or_16 {  } {
	#Create an Expoo traffic agent and set its configuration parameters
	set traffic [new Application/Traffic/Exponential]
	$traffic set packetSize_ 2000
	$traffic set burst_time_ 2.5s
	$traffic set idle_time_ 1s
	$traffic set rate_ 1200k

	#return the data source
	return $traffic
}

#CBR over UDP
proc create_trafficSrc_for_server_13 { udp } {
	set ns [Simulator instance]

	#Setup a FTP over TCP connection
	set cbr [new Application/Traffic/CBR]
	$cbr set packetSize_ 800
	$cbr set interval_ 0.005
	$cbr set random_ 1
	$cbr attach-agent $udp


	#return the data source
	return $cbr
}


#FTP over TCP
proc create_trafficSrc_for_server_9 { tcp } {
	#Setup a FTP over TCP connection
	set serverNineFTP [new Application/FTP]
	$serverNineFTP attach-agent $tcp
	$serverNineFTP set type_ FTP

	#return the data source
	return $serverNineFTP
}

#For each destination node for this server
#	-Create a traffic src at the server [returned]
#	-Create a traffic sink at the edge [returned]
#	-Connect the src to the sink





#I need a better name!
proc add-green-duplex-links { lowerIndex upperIndex dest } {
	set ns [Simulator instance]

	for {set i lowerIndex} {$i <= $upperIndex} {incr i} {
		#link the ith node with the destination node
		$ns duplex-link $nodes($i) $nodes($dest) 1Mb 20ms DropTail

		#set the destination's queue size
		$ns queue-limit $nodes($i) $nodes($dest) 10
	}
}

#I need a better name!
proc add_black_duplex_links { lowerIndex upperIndex dest } {
	set ns [Simulator instance]

	for {set i lowerIndex} {$i <= $upperIndex} {incr i} {
		#link the ith node with the destination node
		$ns duplex-link $nodes($i) $nodes($dest) 8Mb 50ms DropTail

		#set the destination's queue size
		$ns queue-limit $nodes($i) $nodes($dest) 15
	}
}

#I need a better name!
proc add_purple_duplex_links { lowerIndex upperIndex dest } {
	set ns [Simulator instance]

	for {set i lowerIndex} {$i <= $upperIndex} {incr i} {
		#link the ith node with the destination node
		$ns duplex-link $nodes($i) $nodes($dest) 2Mb 40ms DropTail

		#set the destination's queue size
		$ns queue-limit $nodes($i) $nodes($dest) 15
	}
}

#They should all be interconnected now... [Test me]
proc interconnect_nodes { } {
	#ROUTER 0

	#connect edges [13-16] to router 0 via green links
	add-green-duplex-links 13 16 0
	#connect router 0 to router 2
	add_black_duplex_links 0 0 2


	#ROUTER 1

	#connect edges [7-12] to router 1 via green links
	add-green-duplex-links 7 12 1
	#connect router 1 to router 2
	add_black_duplex_links 1 1 2
	#connect router 1 to router 3
	add_black_duplex_links 1 1 3

	#ROUTER 2

	#connect router 2 to router 2
	add_black_duplex_links 2 2 3

	#ROUTER 4

	#connect edges [17-20] to router 4 via green links
	add-green-duplex-links 17 20 4
	#connect router 4 to router 2
	add_purple_duplex_links 4 4 2



	#ROUTER 5

	#connect edges [21-24] to router 5 via green links
	add-green-duplex-links 21 24 5
	#connect router 5 to router 3
	add_purple_duplex_links 5 5 3



	#ROUTER 6

	#connect edges [25-27] to router 6 via green links
	add-green-duplex-links 25 27 6
	#connect router 6 to router 3
	add_purple_duplex_links 6 6 3

}


#Main

global array set nodes {}
array set trafficDataSourceAgents {}
array set trafficDataSinkAgents {}
global set flowID 0

# Create simulator object
set ns [new Simulator]

# Create trace file
set tracefd [open topology.tr w]
$ns trace-all $tracefd

#Tell the simulator to use dynamic routing
$ns rtproto DV

set max_nodes 28

#Create our nodes
for {set i 0} {$i < $max_nodes} {incr i} {
	set nodes($i) [$ns node]
}

interconnect_nodes


#Create a traffic source at server 9 for each destination agent connected to server 9
set server $nodes(9)
set serverNineTCPAgent [new Agent/TCP]
set serverEdges "12 14 15 20 23 27"

$serverNineTCPAgent set class_ 2
$ns attach-agent $server $serverNineTCPAgent


foreach edge $serverEdges {

	set trafficSrc [create_trafficSrc_for_server_9 $serverNineTCPAgent]
	set trafficSink [create_trafficSink_for_blue_edge $nodes($edge)]

	set linkKey [key 9 $edge]

	set trafficDataSourceAgents(linkKey) $trafficSrc
	set trafficDataSinkAgents(linkKey) $trafficSink

	#Connect the edge node's data sink to the router's data source
	# TODO: This line is causing a compilation error
	$ns connect $trafficSrc $trafficSink

	#Set a ID for this flow [currently just set linearly]
	$serverNineTCPAgent set fid_ [get_next_flow_id]
}


#Create a traffic source agent at server 13 for each destination agent connected to server 13
set server $nodes(13)
set server13UDP [new Agent/UDP]
set serverEdges "8 11 17 19 21 24 25 26"

$ns attach-agent $server $server13UDP

foreach edge $serverEdges {
	set trafficSrc [create_trafficSrc_for_server_13 $server13UDP]
	# TODO: Function create_trafficSink_for_green_edge does not exist
	set trafficSink [create_trafficSink_for_green_edge $nodes($edge)]

	set trafficDataSourceAgents([key 13 $edge]) $trafficSrc
	set trafficDataSinkAgents([key 13 $edge]) $trafficSink

	#Connect the edge node's data sink to the router's data source
	$ns connect $trafficSrc $trafficSink

	#Set a ID for this flow [currently just set linearly]
	$server13UDP set fid_ [get_next_flow_id]
}



#Create a traffic source agent at server 10 for each destination agent connected to server 10

set server $nodes(10)
set server10UDPAgent [new Agent/UDP]
set serverEdges "18 22"

$ns attach-agent $server $server10UDPAgent

foreach edge $serverEdges {
	set trafficSrc [create_trafficSrc_for_server_10_or_16]
	# TODO: Function create_trafficSink_for_white_edge does not exist
	# Also called on line 275
	set trafficSink [create_trafficSink_for_white_edge $nodes($edge)]

	set trafficDataSourceAgents([key $serverNumber $edge]) $trafficSrc
	set trafficDataSinkAgents([key $serverNumber $edge]) $trafficSink

	#Connect the edge node's data sink to the router's data source
	$ns connect $trafficSrc $trafficSink

	#Set a ID for this flow [currently just set linearly]
	$server10UDPAgent set fid_ [get_next_flow_id]
}


#Create a traffic source agent at server 16 for each destination agent connected to server 16

set server $nodes(16)
set server16UDPAgent [new Agent/UDP]
set serverEdges "18 22"

$ns attach-agent $server $server10UDPAgent

foreach edge $serverEdges {
	set trafficSrc [create_trafficSrc_for_server_10_or_16]
	set trafficSink [create_trafficSink_for_white_edge $nodes($edge)]

	set trafficDataSourceAgents([key $serverNumber $edge]) $trafficSrc
	set trafficDataSinkAgents([key $serverNumber $edge]) $trafficSink

	#Connect the edge node's data sink to the router's data source
	$ns connect $trafficSrc $trafficSink

	#Set a ID for this flow [currently just set linearly]
	$server16UDPAgent set fid_ [get_next_flow_id]
}




#Setup our events

#At time 1, 9->12, 13->8, 9->14 traffic flows start
$ns at 1.0 "
			$trafficDataSourceAgents([key 9 12]) start
			$trafficDataSourceAgents([key 13 8]) start
			$trafficDataSourceAgents([key 9 14]) start
		 "

#At time 2, 13->11, 9->15, 13->17 traffic flows start
$ns at 2.0 "
			$trafficDataSourceAgents([key 13 11]) start
			$trafficDataSourceAgents([key 9 15]) start
			$trafficDataSourceAgents([key 13 17]) start
		 "

#At time 3, 13->19, 9->18, 13->21 traffic flows start
$ns at 3.0 "
			$trafficDataSourceAgents([key 13 19]) start
			$trafficDataSourceAgents([key 9 18]) start
			$trafficDataSourceAgents([key 13 21]) start
		 "

#At time 4, 13->24, 9->20, 13->25 traffic flows start
$ns at 4.0 "
			$trafficDataSourceAgents([key 13 24]) start
			$trafficDataSourceAgents([key 9 20]) start
			$trafficDataSourceAgents([key 13 25]) start
		 "

#At time 5, 9->23, 13->26, 9->27 traffic flows start
$ns at 5.0 "
			$trafficDataSourceAgents([key 9 23]) start
			$trafficDataSourceAgents([key 13 26]) start
			$trafficDataSourceAgents([key 9 27]) start
		 "

#At time 6, 10->18, 16->18 traffic flows start
$ns at 6.0 "
			$trafficDataSourceAgents([key 10 18]) start
			$trafficDataSourceAgents([key 16 18]) start
		 "

#At time 7, link 1-3 goes Down, refer to example4.tcl
$ns at 7.0 "
			$trafficDataSourceAgents([key 9 14]) start
		 "

#At time 8, link 1-3 goes Up, refer to example4.tcl
$ns at 8.0 "
			$trafficDataSourceAgents([key 1 3]) stop
		 "

#At time 10, the simulation stops
$ns at 10.0 "finish"



# Run simulation
$ns run
