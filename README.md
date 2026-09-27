# terragrunt-live

Terragrunt configs for the WordPress lab. This is the "live" side: it describes what
is actually deployed and where. The Terraform modules themselves live in a separate
repo (vlebediev/terraform-task, modules/ folder) and are pulled in by git-source,
pinned to a tag.

There are deliberately no root .tf files here. provider.tf and backend.tf are
generated from root.hcl at runtime. Each component folder just holds a terragrunt.hcl
that points at a module and passes inputs.

## Layout

    accounts/
      lab-dev/
        account.hcl            # account id
        env.hcl                # environment + module version
        eu-central-1/
          region.hcl           # region
          vpc/                 # created first
          rds/                 # depends on vpc
          webserver/           # wordpress; depends on vpc + rds
    root.hcl                   # backend (S3 + native lock), provider, module source

account.hcl / env.hcl / region.hcl each hold values for their level. root.hcl reads
all three via find_in_parent_folders and builds the backend and provider from them.
To add an environment, copy the account folder and change a couple of values; to add a
region, copy the region folder. root.hcl stays untouched.

State lives in S3 (bucket tfstate-<account>-<region>), one file per folder, with
locking via the S3 native lockfile (no DynamoDB).

## Usage

Credentials for the lab account first:

    aws sso login --profile vlebediev
    export AWS_PROFILE=vlebediev

Whole stack at once, from the region folder:

    cd accounts/lab-dev/eu-central-1
    terragrunt run-all plan
    terragrunt run-all apply

Or one component at a time:

    cd accounts/lab-dev/eu-central-1/vpc
    terragrunt plan
    terragrunt apply

Tear everything down (RDS bills by the hour — don't leave it running):

    cd accounts/lab-dev/eu-central-1
    terragrunt run-all destroy

## Module versions

The module version an environment uses is set in env.hcl:

    modules_version = "v1.0.0"

That is a git tag in the terraform-task repo. Push a new tag there, change this line,
re-plan. dev and prod can sit on different versions.
