# Calculate number of sent packets per 0.5 seconds for flow 13->21

BEGIN {
	node = 21;
	time1 = 0.0;
	time2 = 0.0;
	num_packets = 0;
}

{
	action = $1;
	time2 = $2;
	from = $3;
	to = $4;
	type = $5;
	pktsize = $6;
	flow_id = $8;
	src = $9;
	dst = $10;
	seq_no = $11;
	packet_id = $12;

	# Replace 0 with the designated flow_id for flow 13->21
	if (flow_id != 0) {
		next;
	}

	if (time2 - time1 > 0.5) {
		printf("%f \t %f\n", time2, num_packets) > "13sent.xls";
		time1 = $2;
		num_packets = 0;
	}

	if (action == "+" && to == node) {
		num_packets++;
	}
}
