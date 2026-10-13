module "ecr" {
  source = "../../modules/ecr"

  name             = var.repository_name
  environment      = "env-1"
  keep_image_count = var.keep_image_count
}
