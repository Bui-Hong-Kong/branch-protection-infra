module "ecr" {
  source = "../../modules/ecr"

  name             = var.repository_name
  environment      = "env-2"
  keep_image_count = var.keep_image_count
}
