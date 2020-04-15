BEGIN {}
/RTR/ && $7=="AODV" { print($0)  }
END {}
