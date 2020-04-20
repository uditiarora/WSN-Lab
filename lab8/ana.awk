BEGIN {
sent=0;
received=0;
bsent=0;
breceived=0;
}
{
  if($1=="s" && $4=="AGT" && $7=="cbr" && $2>12.25f)
   {
    sent++;
   }
  else if($1=="r" && $4=="AGT" && $7=="cbr" && $2>12.25f)
   {
     received++;
   }
   if($1=="s" && $4=="AGT" && $7=="cbr" && $2<12.25f)
   {
    bsent++;
   }
  else if($1=="r" && $4=="AGT" && $7=="cbr" && $2<12.25f)
   {
     breceived++;
   }
}
END {
 printf "Before ARP : ";
 printf "\n Packet Sent:%d",bsent; 
 printf "\n Packet Received:%d",breceived;
 printf "\n\n After ARP : ";
 printf "\n Packet Sent:%d",sent;
 printf "\n Packet Received:%d",received;
 printf "\n Packet Delivery Ratio:%.2f\n",(received/sent);
 printf "\n\n Total : ";
 printf "\n Packet Sent:%d",sent+bsent;
 printf "\n Packet Received:%d",received+breceived;
 printf "\n Packet Delivery Ratio:%.2f\n",((breceived+received)/(sent+bsent));
}