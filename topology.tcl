# Create simulator object
set ns [new Simulator]


#Constants

set MAX_NODES 28

#Globals

global nodes

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


proc init_topology { }
{
	[create_nodes]
	[interconnect_nodes]
}














#Main





# Create trace file
set tracefd [open topology.tr w]
$ns trace-all $tracefd


[init_topology]

#Configure agents





# Run simulation
$ns run
