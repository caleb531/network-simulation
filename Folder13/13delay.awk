# Calculate delay for flow 13->21

BEGIN {

	highest_packet_id = 0;

}

{

	action = $1;
	time = $2;
	from = $3;
	to = $4;
	type = $5;
	pktsize = $6;
	flow_id = $8;
	src = $9;
	dst = $10;
	seq_no = $11;
	packet_id = $12;

	if (int(src) == 13 && int(dst) == 21) {

		if (packet_id > highest_packet_id) {
			highest_packet_id = packet_id;
		}

		if (start_time[packet_id] == 0) {
			start_time[packet_id] = time;
		}

		if (action != "d") {
			end_time[packet_id] = (action == "r") ? time : -1;
		}

	}

}

END {

	for (packet_id = 0; packet_id <= highest_packet_id; packet_id++) {

		start = start_time[packet_id];
		end = end_time[packet_id];

		if (start < end) {
			packet_duration = end - start;
			printf("%f \t %f\n", start, packet_duration) > "13delay.xls";
		}

	}

}
