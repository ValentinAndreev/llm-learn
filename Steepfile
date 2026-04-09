D = Steep::Diagnostic

target :app do
  signature "sig"

  check "app/models"
  check "app/controllers"
  check "app/channels"
  check "app/helpers"
  check "app/jobs"
  check "app/mailers"

  library "date"
  library "json"
  library "securerandom"

  configure_code_diagnostics(D::Ruby.default)
end
