#Constants

set MAX_NODES 28









# Create simulator object
set ns [new Simulator]

# Create trace file
set tracefd [open topology.tr w]
$ns trace-all $tracefd



#INITIALIZATION

# Create required 28 nodes

for {set i 0} {$i < $MAX_NODES} {incr i}
{
  nodes($i) [$ns node]
}


#END INITALIZATION






# Run simulation
$ns run
