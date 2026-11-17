module "data_platform_dev" {
  source = "./modulos/plataforma-datos"

  environment = "dev"
  project     = "data_platform"
}
