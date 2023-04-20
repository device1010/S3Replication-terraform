
//backend
terraform {
  backend "s3" {
    # Crear Bucket s3
    bucket = "pribucketga"
    key    = "s3-replicationt.tfstate"
    region = "us-east-1"
    #dynamoBD, Parition key = LockID
    dynamodb_table = "ga-terraformstate"
    //Para tener un mecanismo de manera que dos personas no hagan deploy a la vez
  }
}