module "data_platform_dev" {
  source = "./modulos/plataforma-datos"

  environment = "dev"
  company     = "demo"
  project     = "data_platform"
}
