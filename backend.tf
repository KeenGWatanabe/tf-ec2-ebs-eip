terraform {
 backend "s3" {
   bucket = "sctp-ce9-tfstate"
   key    = "roger-ce9-module2.4.tfstate" # Replace the value of key to <your suggested name>.tfstat   
   region = "us-east-1"
 }
}