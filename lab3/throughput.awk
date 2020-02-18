#awk -f throughput.awk out.tr
BEGIN {
	sizeofpacketrec = 0
	starttime = 400
	endtime = 0
}
{
	event = $1
	time = $2
	node_id = $3
	pkt_size = $6
	level = $4

if (event == "+" && pkt_size >= 512) 
{
	if (time < starttime) 
	{
		starttime = time
	}
}

if (event == "r" && pkt_size>=512) 
{
	if (time > endtime) 
	{
		endtime = time
	}
	
	hdr_size = pkt_size % 512
	pkt_size -= hdr_size
	
	sizeofpacketrec += pkt_size
}
}
END {
	printf("Start time=%.2f\nEnd Time=%.2f\n",starttime,endtime)
	printf("Average Throughput = %.2f\n",(sizeofpacketrec/(endtime-starttime))*(8/1000))

}



