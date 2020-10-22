# DECLARE THE DATA SOURCE
# The line below will return the available zones on the current selected region
data "aws_availability_zones" "available_xtianzones" {
  state = "available"
}