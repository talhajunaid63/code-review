[![Build Status](https://semaphoreci.com/api/v1/projects/1096cde2-9955-4327-875d-5fcef2fc3313/2258737/badge.svg)](https://semaphoreci.com/better/uvohealth)

# UvoHealth

UvoHealth is a platform that allows anyone to see a doctor via online video chat affordably, easily and instantly.

UvoHealth is a rails 5 app deployed to Heroku. The live install can be viewed at [app.uvohealth.com](https://app.uvohealth.com/).

Ideally all code is going to follow the following format rules, in early stages the project might break many or all of these rules. But ideally the finally production app should follow these guidelines:

- Classes can be no longer than one hundred lines of code.
  Methods can be no longer than five lines of code.
- Pass no more than four parameters into a method. Hash options are parameters.
- Controllers can instantiate only one object. Therefore, views can only know about one instance variable and views should only send messages to that object (@object.collaborator.value is not allowed).

The best way to ask questions or bring up issues with this repository is to open a GitHub issue against it. However if need be don't hesitate to contact the owner of this repository at [admin@uvohealth.com](mailto:admin@uvohealth.com).
