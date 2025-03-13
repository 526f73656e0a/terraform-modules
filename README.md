# **Terraform Modules**

## **Overview**

This repository contains a collection of reusable Terraform modules that can be used across multiple projects.  
These modules are designed to provide a standardized and efficient way to manage infrastructure resources.

## **Module Structure**

Each module is contained within its own directory, with the following structure:

```
└── module_name        contains the individual Terraform modules
    ├── README.md      provides documentation for the module
    ├── main.tf        the main Terraform configuration file for the module
    ├── outputs.tf     defines the output values for the module
    └── variables.tf   defines the input variables for the module
```

## **Available Modules**

The following modules are currently available:

- [`s3`](./s3/README.md): creates an S3 Bucket with Checkov best practices

## **Using the Modules**

To use a module in your Terraform configuration, follow these steps:

1. Create a new Terraform configuration file (e.g. `main.tf`)
1. Add the module to your configuration using the `module` keyword, like this:

```terraform
module "s3" {
  source = file("./path/to/module")
  # Or you can use a git ref:
  # source = git@github.com:526f73656e0a/terraform-modules.git?ref=main
  # Input variables for the module
  instance_type = "t2.micro"
  ami           = "ami-abc123"
}
```

3. Replace `./path/to/module` with the actual path to the module directory (e.g. `./modules/ec2-instance`). You can also use a git reference to download the module directly when running terraform init `git@github.com:526f73656e0a/terraform-modules.git?ref=main`
4. Configure the input variables for the module as needed. Examples can be found in the modules respective READMEs

## **Contributing**

To contribute to this repository, please follow these guidelines:

- Fork the repository and create a new branch for your changes
- Make your changes and commit them to your branch
- Submit a pull request to the main repository

## **License**

This repository is licensed under [LICENSE](./LICENSE)

## **Acknowledgments**

This repository was created and maintained by [526f73656e0a](https://github.com/526f73656e0a)
