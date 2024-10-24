# variables.tf
# Archivo de Declaración de Variables.

###############################################################################
#
# Programador: Jorge Aureliano Gallegos Esparza.
#
# Fecha Inicio: 18-oct-2024.
# Última Modificación: 22-oct-2024.
#
###############################################################################

# Creamos la LLave de Acceso.
variable "AWS_Key" {
    description = "LLave de Acceso de AWS"
    type = string
}

# Creamos la Clave Secreta.
variable "AWS_Secret" {
    description = "Clave Secreta de AWS"
    type = string
}

# Establecemos la Región.
variable "Region_AWS" {
    description = "Region AWS"
    default = "us-east-1"
}
