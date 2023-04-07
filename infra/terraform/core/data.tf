data "archive_file" "data_ingest_lambda" {
  type        = "zip"
  source_file = "../../data_ingest/lambda_function.py"

  output_path = "data_ingest_lambda.zip"
}