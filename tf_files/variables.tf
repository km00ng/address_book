variable "image_id" {
  type    = string
  default = ""
}

variable "instance_type" {
  type = string
}

variable "server_port" {
  type = number
}

variable "pub_security_group_name" {
  type = string
}

variable "asg_security_group_name" {
  type = string
}

variable "alb_name" {
  type = string

}

variable "alb_security_group_name" {
  type = string
}

variable "target_group_name" {
  type = string
}

variable "db_security_group_name" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}