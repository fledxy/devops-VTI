# terraform { 
#   cloud { 
    
#     organization = "fledxy" 

#     workspaces { 
#       name = "dev" 
#     } 
#   } 
# }

terraform {
  backend "s3" {
    bucket = "fledxytfbucket"
    key    = "dev-tf.tfstate"
    region = "ap-southeast-1"
  }
}