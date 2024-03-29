resource "aws_lambda_function" "data_ingest" {
  filename = "data_ingest_lambda.zip"

  function_name = "data_ingest"
  role          = data.aws_iam_role.lambda_basic_execution.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  timeout       = 300
  memory_size   = 128

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.data_ingest.name
    }
  }

  # enable logging
  tracing_config {
    mode = "Active"
  }

  source_code_hash = data.archive_file.data_ingest_lambda.output_base64sha256
}

resource "aws_lambda_function_url" "data_ingest_url" {
  function_name      = aws_lambda_function.data_ingest.function_name
  authorization_type = "NONE"
}

resource "aws_cloudwatch_log_group" "data_ingest" {
  name              = "/aws/lambda/${aws_lambda_function.data_ingest.function_name}"
  retention_in_days = 30
}

# data writer
resource "aws_lambda_function" "data_writer" {
  filename = "data_writer_lambda.zip"

  function_name = "data_writer"
  role          = data.aws_iam_role.lambda_basic_execution.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  timeout       = 300
  memory_size   = 128

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.data_ingest.name # should be name of the injest data table
      S3_BUCKET      = aws_s3_bucket.data_writer.id
    }
  }

  # enable logging
  tracing_config {
    mode = "Active"
  }

  source_code_hash = data.archive_file.data_writer_lambda.output_base64sha256

  depends_on = [
    aws_s3_bucket.data_writer
  ]
}

resource "aws_cloudwatch_log_group" "data_writer" {
  name              = "/aws/lambda/${aws_lambda_function.data_writer.function_name}"
  retention_in_days = 30
}
