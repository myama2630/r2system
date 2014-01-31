# coding: utf-8
class R2mailer < ActionMailer::Base
  default from: "yescsr2@gmail.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.r2mailer.sendRepairOrderMail.subject
  #
  def sendRepairOrderMail(emails, repair, user)

    @user = user

    @repair = repair

    mail to: emails, subject: "エンジン整備依頼のお知らせ"

    return self
    
  end

end
