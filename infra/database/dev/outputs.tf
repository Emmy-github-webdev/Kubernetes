output "roles" {

  value = keys(postgresql_role.service)

}