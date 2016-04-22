# Calculate average throughput per 0.5 seconds for flow 9->27

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
			throughput = bytes_counter / (time2 - time1);
			printf("%f \t %f\n", time2, throughput) > "13throughput.xls";
			time1 = time2;
			bytes_counter = 0;
		}

		# If packet was received at destination
		if (action == "r" && to == dst) {
			bytes_counter += pktsize;
			num_packets++;
		}

	}

}
