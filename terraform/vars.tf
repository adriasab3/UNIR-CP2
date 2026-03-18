#variables usadas en el código de terraform
variable "location" {
  type = string
  description = "Región de Azure donde crearemos la infraestructura"
  default = "francecentral" 
}

variable "ssh_user" {
  type = string
  description = "Usuario para hacer ssh"
  default = "adminuser"
}
