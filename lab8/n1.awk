BEGIN {}
/RTR/ && $7=="message" { print($0)  }
END {}