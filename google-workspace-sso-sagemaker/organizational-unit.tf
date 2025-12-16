data "aws_organizations_organization" "org" {}

resource "aws_organizations_organizational_unit" "data_scientist" {
  name      = "Data Scientist"
  parent_id = data.aws_organizations_organization.org.roots[0].id
}
