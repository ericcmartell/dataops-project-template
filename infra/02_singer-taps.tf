locals {
  # TODO: Specificy ID of tap (without the "tap-" prefix)
  tap_id = "sample"
}

output "singer_summary" { value = module.singer_taps_on_aws.summary }
module "singer_taps_on_aws" {
  # BOILERPLATE HEADER (NO NEED TO CHANGE):
  source        = "git::https://github.com/slalom-ggp/dataops-infra//catalog/aws/singer-taps?ref=master"
  name_prefix   = local.name_prefix
  environment   = module.env.environment
  resource_tags = local.resource_tags

  # ADD OR MODIFY CONFIGURATION HERE:

  local_metadata_path     = "../data/taps"
  data_lake_metadata_path = "s3://${module.data_lake.s3_metadata_bucket}"
  scheduled_timezone      = "PST"
  scheduled_sync_times    = ["0600"]

  taps = [
    # Learn more and browse open source taps at: https://www.singer.io
    {
      id = local.tap_id
      settings = {
        # How far back to backfill:
        start_date = "2019-01-01T00:00:00Z"
      }
      secrets = {
        # TODO: Replace `username` and `password` with the secrets needed by this tap
        username = "../data/taps/.secrets/tap-${local.tap_id}-config.json:username"
        password = "../data/taps/.secrets/tap-${local.tap_id}-config.json:password"
      }
    }
  ]

  data_lake_type          = "S3"
  data_lake_storage_path  = "s3://${module.data_lake.s3_data_bucket}/data/raw"

  # # Target is not needed when data_lake_storage_path is provided:
  # target = {
  #   # Output to S3 CSV by default:
  #   id = "s3-csv"
  #   settings = {
  #     s3_key_prefix = "data/raw/sample-tap/v1/"
  #     s3_bucket     = module.data_lake.s3_data_bucket
  #   }
  #   secrets = {
  #     aws_access_key_id     = "../.secrets/aws-secrets-manager-secrets.yml:S3_CSV_aws_access_key_id"
  #     aws_secret_access_key = "../.secrets/aws-secrets-manager-secrets.yml:S3_CSV_aws_secret_access_key"
  #   }
  # }
}