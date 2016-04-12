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

proc interconnect_nodes { }
{
	#ROUTER 1
	#[12, 11, 10, 9, 8 and 7 all connect to 1]

	$ns duplex-link $nodes(12) $nodes(1) 1 Mb 20ms DropTail
	$ns queue-limit $nodes(12) $nodes(1) 10

	$ns duplex-link $nodes(11) $nodes(1) 1 Mb 20ms DropTail
	$ns queue-limit $nodes(11) $nodes(1) 10

	$ns duplex-link $nodes(10) $nodes(1) 1 Mb 20ms DropTail
	$ns queue-limit $nodes(10) $nodes(1) 10

	$ns duplex-link $nodes(9) $nodes(1) 1 Mb 20ms DropTail
	$ns queue-limit $nodes(9) $nodes(1) 10

	$ns duplex-link $nodes(8) $nodes(1) 1 Mb 20ms DropTail
	$ns queue-limit $nodes(8) $nodes(1) 10

	$ns duplex-link $nodes(7) $nodes(1) 1 Mb 20ms DropTail
	$ns queue-limit $nodes(7) $nodes(1) 10



	#connect router 1 to neighboring routers [2, 3]
	$ns duplex-link $nodes(1) $nodes(2) 8 Mb 20ms DropTail
	$ns queue-limit $nodes(7) $nodes(1) 10

	$ns duplex-link $nodes(1) $nodes(3) 8 Mb 20ms DropTail
	$ns queue-limit $nodes(7) $nodes(1) 10

	



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







# Run simulation
$ns run
