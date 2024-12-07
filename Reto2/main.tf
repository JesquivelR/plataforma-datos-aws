module "data_platform_dev" {
    source = "./data_platform_module"
    
    environment = "dev"
    company     = "plataforma-datos"
    project     = "data_platform"
}