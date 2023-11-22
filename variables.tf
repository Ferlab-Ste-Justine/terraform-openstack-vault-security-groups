variable "member_group_name" {
  description = "Name to give to the security group of vault members"
  type = string
  default = ""
}

variable "load_balancer_group_name" {
  description = "Name for vault load balancer security group"
  type        = string
}

variable "client_group_ids" {
  description = "Id of client security groups"
  type = list(string)
  default = []
}

variable "bastion_group_ids" {
  description = "Id of bastion security groups"
  type = list(string)
  default = []
}

variable "metrics_server_group_ids" {
  description = "Id of metric servers security groups"
  type = list(string)
  default = []
}