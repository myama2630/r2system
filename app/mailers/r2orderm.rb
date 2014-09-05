class R2orderm < ActionMailer::Base
  default from: "yescsr2@gmail.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  # tuika
  #   en.r2orderm.r2orderm.subject
  #
  def r2orderm
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
