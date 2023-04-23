data "archive_file" "data_ingest_lambda" {
  type        = "zip"
  source_file = "../../lambdas/data_ingest/lambda_function.py"

  output_path = "data_ingest_lambda.zip"
}

data "archive_file" "data_writer_lambda" {
  type        = "zip"
  source_file = "../../lambdas/data_writer/lambda_function.py"

  output_path = "data_writer_lambda.zip"
}