data "aws_iam_policy_document" "glue_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["glue.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "s3_policy_document" {
  statement {
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.datalake.arn,
      "${aws_s3_bucket.datalake.arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "rds_policy_document" {
  #checkov:skip=CKV_AWS_111: El crawler consulta instancias RDS que se crean en el mismo despliegue; en un entorno real se acotan las acciones de escritura.
  #checkov:skip=CKV_AWS_356: Los ARN de los recursos dependen del despliegue; se restringe el recurso al pasar a un entorno real.
  statement {
    effect = "Allow"
    actions = [
      "rds:DescribeDBInstances",
      "rds:DescribeDBClusters",
      "rds:DescribeDBSnapshots",
      "rds:CreateDBInstance",
      "rds:DeleteDBInstance",
      "rds:ModifyDBInstance",
      "rds:RebootDBInstance"
    ]
    resources = ["*"]
  }
}


resource "aws_iam_role" "glue_service_role" {
  name               = "plataforma-datos-glue-service-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.glue_policy_document.json
}

resource "aws_iam_role_policy_attachment" "glue_service_role_policy_attachment" {
  role       = aws_iam_role.glue_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "glue_service_role_policy" {
  name   = "plataforma-datos-glue-service-role-policy-${var.environment}"
  policy = data.aws_iam_policy_document.s3_policy_document.json
  role   = aws_iam_role.glue_service_role.id
}




resource "aws_iam_role_policy" "glue_service_role_policy_rds" {
  name   = "plataforma-datos-glue-service-role-policy-rds-${var.environment}"
  policy = data.aws_iam_policy_document.rds_policy_document.json
  role   = aws_iam_role.glue_service_role.id
}


resource "aws_glue_catalog_database" "s3_db_crawler" {
  name = "s3_db_crawler"
}

resource "aws_glue_classifier" "s3_crawler_classifier" {
  name = "s3_crawler_classifier"

  csv_classifier {
    allow_single_column    = false
    contains_header        = "PRESENT"
    delimiter              = ","
    disable_value_trimming = false
    quote_symbol           = "'"
  }
}

resource "aws_glue_crawler" "s3_crawler" {
  #checkov:skip=CKV_AWS_195: La configuracion de seguridad de Glue exige una llave KMS adicional; no se justifica en una demostracion.
  name          = "s3_crawler"
  role          = aws_iam_role.glue_service_role.arn
  database_name = aws_glue_catalog_database.s3_db_crawler.name

  s3_target {
    path = "s3://${aws_s3_bucket.datalake.bucket}/"
  }
  classifiers = [aws_glue_classifier.s3_crawler_classifier.name]
}