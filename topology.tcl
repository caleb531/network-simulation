# Create simulator object
set ns [new Simulator]


#Constants

set MAX_NODES 28

#Globals

global nodes
global traffic_data_source_agents
global traffic_data_sink_agents
global set flowID 0


proc create_traffic_sink_for_white_edge { whiteEdge }
{

	return sink
}


proc create_traffic_sink_for_green_edge { greenEdge }
{

	return sink
}



proc create_traffic_sink_for_blue_edge { blueEdge }
{
	set sink [new Agent/TCPSink]
	$ns attach-agent $blueEdge $sink

	return sink
}


#EXP over UDP connected to LossMonitor (exp packetSize_ 2000  burst_time_ 2.5s  idle_time_ 1s  rate_ 1200k), refer to example2.tcl
proc create_traffic_src_for_server_10_or_16 {  }
{
	#Create an Expoo traffic agent and set its configuration parameters
	set traffic [new Application/Traffic/Exponential]
	$traffic set packetSize_ 2000
	$traffic set burst_time_ 2.5s
	$traffic set idle_time_ 1s
	$traffic set rate_ 1200k

	#return the data source
	return traffic
}

#CBR over UDP
proc create_traffic_src_for_server_13 { udp }
{
	set ns [Simulator instance]
	

	#Setup a FTP over TCP connection
	set cbr [new Application/Traffic/CBR]
	$cbr set packetSize_ 800
	$cbr set interval_ 0.005
	$cbr set random_ 1
	$cbr attach-agent $udp


	#return the data source
	return cbr
}


#FTP over TCP 
proc create_traffic_src_for_server_9 { tcp }
{
	#Setup a FTP over TCP connection
	set ftp [new Application/FTP]
	$ftp attach-agent $tcp
	$ftp set type_ FTP

	#return the data source
	return ftp
}

#For each destination node for this server
#	-Create a traffic src at the server [returned]
#	-Create a traffic sink at the edge [returned]
#	-Connect the src to the sink


proc connect_a_traffic_src_to_each_edge_for_servers_10_or_16 { serverEdges serverNumber}
{
	#Create the application agent for our server...
	set ns [Simulator instance]
	set server = $nodes($serverNumber)
	set tcp [new Agent/TCP]
	
	$tcp set class_ 2
	$ns attach-agent $routerOne $udp

	foreach edge $serverEdges 
	{
		set traffic_src [create_traffic_src_for_server_10_or_16]
		set traffic_sink [create_traffic_sink_for_white_edge $nodes(edge)]

		$traffic_data_source_agents($edge) traffic_src
		$traffic_data_sink_agents($edge) traffic_sink  

		#Connect the edge node's data sink to the router's data source
		$ns connect $traffic_sink $traffic_src

		#Set a ID for this flow [currently just set linearly]
		$tcp set fid_ [get_next_flow_id]
	}
}


#For each destination node for this server
#	-Create a traffic src at the server [returned]
#	-Create a traffic sink at the edge [returned]
#	-Connect the src to the sink

proc connect_a_traffic_src_to_each_edge_for_server_13 { serverEdges }
{
	#Create the application agent for our server...
	set ns [Simulator instance]
	set server = $nodes(13)
	set udp [new Agent/UDP]
	
	$ns attach-agent $server $udp

	foreach edge $serverEdges 
	{
		set traffic_src [create_traffic_src_for_server_13 udp]
		set traffic_sink [create_traffic_sink_for_green_edge $nodes(edge)]

		$traffic_data_source_agents($edge) traffic_src
		$traffic_data_sink_agents($edge) traffic_sink

		#Connect the edge node's data sink to the router's data source
		$ns connect $traffic_sink $traffic_src

		#Set a ID for this flow [currently just set linearly]
		$udp set fid_ [get_next_flow_id]
	}

	return udp
}


#For each destination node for this server
#	-Create a traffic src at the server [returned]
#	-Create a traffic sink at the edge [returned]
#	-Connect the src to the sink

proc connect_a_traffic_src_to_each_edge_for_server_9 { serverEdges }
{
	#Create the application agent for our server...
	set ns [Simulator instance]
	set server = $nodes(9)
	set tcp [new Agent/TCP]

	$tcp set class_ 2
	$ns attach-agent $server $tcp

	foreach edge $serverEdges 
	{
		set traffic_src [create_traffic_src_for_server_9 tcp]
		set traffic_sink [create_traffic_sink_for_blue_edge $nodes(edge)]

		$traffic_data_source_agents($edge) traffic_src
		$traffic_data_sink_agents($edge) traffic_sink

		#Connect the edge node's data sink to the router's data source
		$ns connect $traffic_sink $traffic_src

		#Set a ID for this flow [currently just set linearly]
		$tcp set fid_ [get_next_flow_id]
	}

	return tcp
}







proc get_next_flow_id { } 
{
	return [incr flowID]
}



#I need a better name!
proc add_green_duplex_links { lowerIndex upperIndex dest } 
{
	set ns [Simulator instance]

	for {set i lowerIndex} {$i <= upperIndex} {incr i}
	{
		#link the ith node with the destination node
		$ns duplex-link $nodes($i) $nodes(dest) 1Mb 20ms DropTail

		#set the destination's queue size
		$ns queue-limit $nodes($i) $nodes(dest) 10
	}
}

#I need a better name!
proc add_black_duplex_links { lowerIndex upperIndex dest }
{
	set ns [Simulator instance]

	for {set i lowerIndex} {$i <= upperIndex} {incr i}
	{
		#link the ith node with the destination node
		$ns duplex-link $nodes($i) $nodes(dest) 8Mb 50ms DropTail

		#set the destination's queue size
		$ns queue-limit $nodes($i) $nodes(dest) 15
	}
}

#I need a better name!
proc add_purple_duplex_links { lowerIndex upperIndex dest }
{
	set ns [Simulator instance]

	for {set i lowerIndex} {$i <= upperIndex} {incr i}
	{
		#link the ith node with the destination node
		$ns duplex-link $nodes($i) $nodes(dest) 2Mb 40ms DropTail

		#set the destination's queue size
		$ns queue-limit $nodes($i) $nodes(dest) 15
	}
}

#They should all be interconnected now... [Test me]
proc interconnect_nodes { }
{
	#ROUTER 0

	#connect edges [13-16] to router 0 via green links
	[add_green_duplex_links 13 16 0]
	#connect router 0 to router 2
	[add_black_duplex_links 0 0 2]


	#ROUTER 1

	#connect edges [7-12] to router 1 via green links
	[add_green_duplex_links 7 12 1]
	#connect router 1 to router 2
	[add_black_duplex_links 1 1 2]
	#connect router 1 to router 3
	[add_black_duplex_links 1 1 3]

	#ROUTER 2

	#connect router 2 to router 2
	[add_black_duplex_links 2 2 3]

	#ROUTER 4

	#connect edges [17-20] to router 4 via green links
	[add_green_duplex_links 17 20 4]
	#connect router 4 to router 2
	[add_purple_duplex_links 4 4 2]



	#ROUTER 5

	#connect edges [21-24] to router 5 via green links
	[add_green_duplex_links 21 24 5]
	#connect router 5 to router 3
	[add_purple_duplex_links 5 5 3]



	#ROUTER 6

	#connect edges [25-27] to router 6 via green links
	[add_green_duplex_links 25 27 6]
	#connect router 6 to router 3
	[add_purple_duplex_links 6 6 3]

}

proc create_nodes { }
{
	set ns [Simulator instance]

	#Create our nodes...
	for {set i 0} {$i < $MAX_NODES} {incr i}
	{
		nodes($i) [$ns node]
	}
}





#Main





# Create trace file
set tracefd [open topology.tr w]
$ns trace-all $tracefd

#Then, setup our events 
set ns [Simulator instance]


[create_nodes]
[interconnect_nodes]


set serverNineAppAgent [connect_a_traffic_src_to_each_edge_for_server_9 "12 14 15 20 23 27"]
set server13AppAgent [connect_a_traffic_src_to_each_edge_for_server_13 "8 11 17 19 21 24 25 26"]
set server10AppAgent [connect_a_traffic_src_to_each_edge_for_servers_10_or_16 "18 22" 10]
set server16AppAgent [connect_a_traffic_src_to_each_edge_for_servers_10_or_16 "18 22" 16]


#Setup our events

global traffic_data_source_agents
global traffic_data_sink_agents

#At time 1, 9->12, 13->8, 9->14 traffic flows start
$ns at 1 "
			$traffic_data_source_agents(12) start
			$traffic_data_source_agents(8) start
			$traffic_data_source_agents(14) start
		 "

#At time 2, 13->11, 9->15, 13->17 traffic flows start
$ns at 2 "
			$traffic_data_source_agents(11) start
			$traffic_data_source_agents(15) start
			$traffic_data_source_agents(17) start
		 "

#At time 3, 13->19, 9->18, 13->21 traffic flows start
$ns at 3 "
			$traffic_data_source_agents(19) start
			$traffic_data_source_agents(18) start
			$traffic_data_source_agents(21) start
		 "

#At time 4, 13->24, 9->20, 13->25 traffic flows start
$ns at 4 "
			$traffic_data_source_agents(24) start
			$traffic_data_source_agents(20) start
			$traffic_data_source_agents(25) start
		 "

#At time 5, 9->23, 13->26, 9->27 traffic flows start
$ns at 5 "
			$traffic_data_source_agents(23) start
			$traffic_data_source_agents(26) start
			$traffic_data_source_agents(27) start
		 "

#At time 6, 10->18, 16->18 traffic flows start
$ns at 6 "
			$traffic_data_source_agents(18) start
			$traffic_data_source_agents() start
			$traffic_data_source_agents(17) start
		 "

#At time 7, link 1-3 goes Down, refer to example4.tcl
$ns at 7 "
			$traffic_data_source_agents(3) start
		 "

#At time 8, link 1-3 goes Up, refer to example4.tcl
$ns at 8 "
			$traffic_data_source_agents(3) start
		 "


$ns at 2 "
			$traffic_data_source_agents(11) start
			$traffic_data_source_agents(15) start
			$traffic_data_source_agents(17) start
		 "

#At time 10, ns stops
$ns at 2 "
			$traffic_data_source_agents(11) start
			$traffic_data_source_agents(15) start
			$traffic_data_source_agents(17) start
		 "



# Run simulation
$ns run
