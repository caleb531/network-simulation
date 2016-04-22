# Calculate jitter for flow 9->27

BEGIN {

	# Initialization
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

	# Replace 0 with the designated flow_id for flow 9->27
	if (int(src) == 9 && int(dst) == 27) {

		if (packet_id > highest_packet_id) {
			highest_packet_id = packet_id;
		}

		# Record the transmission time
		if (start_time[packet_id] == 0) {
			# Record the sequence number
			pkt_seqno[packet_id] = seq_no;
			start_time[packet_id] = time;
		}


		# Record the receiving time for CBR

		if (action != "d") {

			end_time[packet_id] = (action == "r") ? time : -1;

		}

	}

}

END {

	last_seqno = 0;
	last_delay = 0;
	seqno_diff = 0;

	for (packet_id = 0; packet_id <= highest_packet_id; packet_id++) {

		start = start_time[packet_id];
		end = end_time[packet_id];
		packet_duration = end - start;

		# This check implies that start and end are both not empty
		if (start < end) {

			seqno_diff = pkt_seqno[packet_id] - last_seqno;
			delay_diff = packet_duration - last_delay;
			jitter = (seqno_diff != 0) ? (delay_diff / seqno_diff) : 0;

			printf("%f \t %f\n", start, jitter) > "13jitter.xls";

			last_seqno = pkt_seqno[packet_id];
			last_delay = packet_duration;

		}

	}

}
