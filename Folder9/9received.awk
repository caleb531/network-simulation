# Calculate number of packets received at dst per 0.5 seconds for flow 9->27

BEGIN {
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

	if (int(src) == 9 && int(dst) == 27) {

		if (time2 - time1 > 0.5) {
			printf("%f \t %f\n", time2, num_packets) > "13received.xls";
			time1 = time2;
			num_packets = 0;
		}

		# If packet was received at destination
		if (action == "r" && to == dst) {
			num_packets++;
		}

	}

}
