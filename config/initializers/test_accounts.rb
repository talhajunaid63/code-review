# TestAccounts Config
administrators_account_set = TestAccounts::AccountSet.new(
  "Administrator",
  "all",
  ["phone"],
  name: "Administrators",
  token_login_code: "12345",
  token_login_link: "https://uvohealthbeta.herokuapp.com/login"
)
  
org_admins_account_set = TestAccounts::AccountSet.new(
  "OrgAdmin",
  "all",  
  ["name", "phone"],
  name: "Organization Admins",
  token_login_code: "12345",
  token_login_link: "https://uvohealthbeta.herokuapp.com/login"
)

coordinators_account_set = TestAccounts::AccountSet.new(
  "Coordinator",
  "all",  
  ["name", "phone"],
  name: "Coordinators",
  token_login_code: "12345",
  token_login_link: "https://uvohealthbeta.herokuapp.com/login"
)

providers_account_set = TestAccounts::AccountSet.new(
  "Provider",
  "all",  
  ["name", "phone"],
  name: "Providers",
  token_login_code: "12345",
  token_login_link: "https://uvohealthbeta.herokuapp.com/login"
)

patients_account_set = TestAccounts::AccountSet.new(
  "Patient",
  "all",  
  ["name", "phone"],
  name: "Patients",
  token_login_code: "12345",
  token_login_link: "https://uvohealthbeta.herokuapp.com/login"
)
  
TestAccounts.configure do
  self.account_sets << administrators_account_set
  self.account_sets << org_admins_account_set
  self.account_sets << coordinators_account_set
  self.account_sets << providers_account_set
  self.account_sets << patients_account_set
  self.basic_authentication_username = "uvohealth"
  self.basic_authentication_password = "uvohealth"      
  self.support_email = "help@withbetter.com"
end
