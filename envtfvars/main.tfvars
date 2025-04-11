cidr_block = "10.0.0.0/16"
vpc_name   = "vpc_prod_fledxy"
ec2instances = {
  "vm2" = {
    ec2InstanceName             = "vm2"
    ec2ami                      = "ami-065a492fef70f84b1"
    ec2InstanceType             = "t2.large"
    trusted_ip_ranges           = ["117.1.120.201/32"]
    public_key                  = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINwbucNd50LzTRKcS22YfQRo6sUg13f0qSCCXyX+aAMh trinhthienbao@192.168.81.101.non-exists.ptr.local"
    associate_public_ip_address = true
    ec2Pemfile                  = "/Users/trinhthienbao/Library/CloudStorage/OneDrive-HanoiUniversityofMiningandGeology/Devops_VTI/IaC/privatekey.pem"
    ec2UserConnect              = "ec2-user"
    #  userdata                    = "/Users/trinhthienbao/Library/CloudStorage/OneDrive-HanoiUniversityofMiningandGeology/Devops_VTI/IaC/user-data.yaml"
     security_group = {
         ingress = {
           ssh = {
             from_port   = 22
             to_port     = 22
             protocol    = "tcp"
             cidr_blocks = ["117.1.120.201/32"]
           },
           nginx = {
             from_port   = 80
             to_port     = 80
             protocol    = "tcp"
             cidr_blocks = ["117.1.120.201/32"]
           }
         }
         egress = {
           ssh = {
             from_port   = 22
             to_port     = 22
             protocol    = "-1"
             cidr_blocks = ["117.1.120.201/32"]
           },
 
           http = {
             from_port   = 80
             to_port     = 80
             protocol    = "-1"
             cidr_blocks = ["0.0.0.0/0"]
           }
         }
       }
  }
}