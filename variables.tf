variable "vpc_cidr_block" {
	type = string
}
variable "region" {
	type = string
}
variable "profile" {
	type= string
}
variable "subnet-priv-A" {
	type = string
}
variable "subnet-priv-B" {
	type = string
}
variable "subnet-priv-C" {
	type = string
}
variable "bastion_host_ami" {
	type = string
}
variable "subnet-pub-A" {
	type = string
}
variable "subnet-pub-B" {
	type = string
}
variable "subnet-pub-C" {
	type = string
}
variable "customer_name" {
	type = string
}
variable "db_username" {
	type = string
}
variable "db_password" {
	type = string
}
variable "db_name" {
	type = string
}
variable "domain_name" {
	type = string
}
variable "fileshare-app-image" {
	type = string
}

variable "certificate_arn" {
	type = string
	default = ""
}
variable "tags" {
	type = map(string)
}

variable "keypair_publickey" {
	type = string
	default = ""
}

variable "alb_public_access" {
	type = list(string)
}

variable "subject_alternative_names" {
	type = list(string)
}

