# Create simulator object
set ns [new Simulator]


#Constants

set MAX_NODES 28

#Globals

global nodes
global set flowID 0

proc make_blue_node { traffic_src }
{
	set ns [Simulator instance]

	set blue_node [$ns node]


}

#Null traffic consumers [they dump the packets they recieve into the dark void]

proc make_green_node { traffic_src } 
{
	set ns [Simulator instance]

	set green_node [$ns node]

	#Attach a UDP Agent to our new green node
	$ns attach-agent $green_node [new Agent/UDP]

	#Attach a null traffic sink to out new green node
	set null_traffic_sink [new Agent/Null]
	$ns attach-agent $green_node $null_traffic_sink

	#Attach the traffic source to our new destination
	$ns connect 

	return green_node
}

proc make_white_node { traffic_src }
{
	set ns [Simulator instance]

	set white_node {$ns node}

	#Create a new LossMonitor Agent
	set loss_monitor_agent = [new Agent/LossMonitor]

	#Attach the new loss monitor to our new white node
	$ns attach-agent $white_node $loss_monitor_agent

}






proc set_events { } 
{
	
}






proc get_next_flow_id { } 
{
	return [incr flowID]
}


#You connect the data source to the data sink
#FTP over TCP connected to TCPSink (As default, the maximum size of a packet that a "tcp" agent can generate is 1KByte. Don’t change it).
proc setup_router_ones_agents {  }
{
	set ns [Simulator instance]
	set routerOne = $nodes(1)

	#Setup a TCP connection
	set tcp [new Agent/TCP]
	$tcp set class_ 2
	$ns attach-agent $routerOne $tcp
	

	#Setup a FTP over TCP connection
	set ftp [new Application/FTP]
	$ftp attach-agent $tcp
	$ftp set type_ FTP

	#return the data source
	return ftp
} 

proc setup_router_one_edge_node {edgeNode router_one_ftp}
{
	set sink [new Agent/TCPSink]
	$ns attach-agent $edgeNode $sink

	return sink
}


proc setup_router_one_edge_agents { router_one_ftp lowerIndex upperIndex }
{
	for {set i lowerIndex} {i <= upperIndex} {incr i}
	{
		set edge_data_sink [setup_router_one_edge_node $nodes(i) router_one_ftp]

		#Connect the router data source to the edge's data sink

		#Connect the edge node's data sink to the router's data source
		$ns connect $edge_data_sink $router_one_ftp

		#Set a ID for this flow [currently just set linearly]
		$tcp set fid_ [get_next_flow_id]
	}
}


#set sink [new Agent/TCPSink]
#	$ns attach-agent $n3 $sink
#	$ns connect $tcp $sink
#	$tcp set fid_ 1


proc setup_agents_and_events_in_topology {} 
{


	

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
proc add_black_duplex_links { dest lowerIndex upperIndex }
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
proc add_purple_duplex_links { dest lowerIndex upperIndex }
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

proc interconnect_nodes { }
{
	#ROUTER 0
	#connect edges [13-16] to router 0 via green links
	[add_green_duplex_links 13 16 0]

	
	#connect router 0 to router 2
	[add_black_duplex_links 2 0 0]


	

	#ROUTER 1
	#connect edges [7-12] to router 1 via green links
	[add_green_duplex_links 7 12 1]

	
	#connect router 1 to router 2
	[add_black_duplex_links 2 1 1]

	#connect router 1 to router 3
	[add_black_duplex_links 3 1 1]



	#ROUTER 2
	#connect router 2 to router 2
	[add_black_duplex_links 3 2 2]



	#ROUTER 4
	#connect edges [17-20] to router 4 via green links
	[add_green_duplex_links 17 20 4]

	
	#connect router 4 to router 2
	[add_purple_duplex_links 2 4 4]



	#ROUTER 5
	#connect edges [21-24] to router 5 via green links
	[add_green_duplex_links 21 24 5]

	
	#connect router 5 to router 3
	[add_purple_duplex_links 3 5 5]



	#ROUTER 6
	#connect edges [25-27] to router 6 via green links
	[add_green_duplex_links 25 27 6]

	
	#connect router 0 to router 2
	[add_black_duplex_links 2 0 0]
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

#setup agents for router 1
#Router 1
set router_one_ftp = [setup_router_ones_agents]
[setup_router_one_edge_agents router_one_ftp 7 13]



#do this for the other routers...









#Setup our events



#At time 1, 9->12, 13->8, 9->14 traffic flows start
$ns at 1 "$cbr start"

#At time 2, 13->11, 9->15, 13->17 traffic flows start
$ns at 2 "$cbr start"

#At time 3, 13->19, 9->18, 13->21 traffic flows start
$ns at 3 "$cbr start"

#At time 4, 13->24, 9->20, 13->25 traffic flows start
$ns at 4 "$cbr start"

#At time 5, 9->23, 13->26, 9->27 traffic flows start
$ns at 5 "$cbr start"

#At time 6, 10->18, 16->18 traffic flows start
$ns at 6 "$cbr start"

#At time 7, link 1-3 goes Down, refer to example4.tcl
$ns at 7 "$cbr start"

#At time 8, link 1-3 goes Up, refer to example4.tcl
$ns at 8 "$cbr start"


$ns at 9 "$cbr start"

#At time 10, ns stops
$ns at 10 "$cbr start"



# Run simulation
$ns run
