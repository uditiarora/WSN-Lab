BEGIN{counter1 = 0; counter2 = 0;}
$1~/D/&&/RTR/ {counter1++;}
END{print("\nPackets dropped:", counter1)}
