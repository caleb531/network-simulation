# Calculate number of sent packets per 0.5 seconds for flow 9->27

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
			printf("%f \t %f\n", time2, num_packets) > "9sent.xls";
			time1 = time2;
			num_packets = 0;
		}

		# If packet was received at 2nd hop
		if (action == "r" && packet_ids[packet_id] == "") {
			num_packets++;
			packet_ids[packet_id] = 1;
		}

	}

}
