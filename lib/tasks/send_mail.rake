#encoding: utf-8
namespace :send_mail do
  desc "send reminder mail"
  task :reminder => :environment  do
    #今日の日付が特定の日付の場合に、メールを送信する。（日付は環境変数にて設定する）
    if Date.today.day == ENV['REMINDER_DATE'].to_i
      User.tender_user_list.each do |user|
        R2reminder.send_reminder_mail(user).deliver;
      end
    end
  end

end
