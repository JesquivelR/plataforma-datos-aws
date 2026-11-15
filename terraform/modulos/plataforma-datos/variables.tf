variable "availability_zone" {
  description = "Zona de disponibilidad principal"
  type        = string
  default     = "us-west-1a"
}

variable "environment" {
  description = "Ambiente de la aplicación"
  type        = string
}

variable "project" {
  description = "Nombre del proyecto"
  type        = string
}

variable "deletion_protection" {
  description = "Protege la instancia RDS contra borrado. Ponlo en false antes de destruir el entorno de demostracion."
  type        = bool
  default     = true
}
