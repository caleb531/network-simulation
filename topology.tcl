# Create simulator object
set ns [new Simulator]


#Constants

set MAX_NODES 28

#Globals

global nodes

proc red_node { }
{
	set ns [Simulator instance]

	
}

proc green_node {} 
{
	set ns [Simulator instance]
}

proc white_node {}
{
	set ns [Simulator instance]
}


proc init_topology { }
{
	set ns [Simulator instance]

	for {set i 0} {$i < $MAX_NODES} {incr i}
	{
		nodes($i) [$ns node]
	}
	
	#finish the initialization of the topology...
}














#Main





# Create trace file
set tracefd [open topology.tr w]
$ns trace-all $tracefd


init_topology







# Run simulation
$ns run
