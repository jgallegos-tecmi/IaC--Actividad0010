# main.tf
# Archivo Principal de Arranque.

###############################################################################
#
# Programador: Jorge Aureliano Gallegos Esparza.
#
# Fecha Inicio: 18-oct-2024.
# Última Modificación: 23-oct-2024.
#
###############################################################################

# Proveedor con el que Trabajaremos.
provider "aws" {
    access_key = var.AWS_Key
    secret_key = var.AWS_Secret
    region = var.Region_AWS
}
