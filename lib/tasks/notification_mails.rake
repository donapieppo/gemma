# ogni inizio di giornata
# 0 05 * * *     rails    RAILS_ENV=production bundle exec rake gemma:notifications:day
# ogni domenica
# 3 15 * * 0     rails    RAILS_ENV=production bundle exec rake gemma:notifications:week
# ogni primo del mese
# 2 37 1 * *     rails    RAILS_ENV=production bundle exec rake gemma:notifications:month

# FIXME le date ora sono date e non piu' datetime :-))))
namespace :gemma do
namespace :notifications do
  desc "invio notifiche scarichi di ieri"
  task day: :environment do
    notifications = Notification.new(Organization.where(sendmail: "d").all)
    notifications.from = Date.yesterday
    notifications.to = Date.yesterday
    notifications.subject = "Riassunto scarico materiale di consumo."
    notifications.send
  end

  # cron di domenica: scarichi da domenica scorsa e sabato questo compreso
  desc "invio notifiche scarichi settimanali"
  task week: :environment do
    notifications = Notification.new(Organization.where(sendmail: "w").all)
    today = Date.today
    # today - today.day = most recent Sunday
    # in app/model/Notification si usa <= e >= da lunedi incluso a domenica inclusa
    notifications.from = today - today.wday - 6
    notifications.to = today - today.wday
    notifications.subject = "Riassunto settimanale scarico materiale di consumo."
    notifications.send
  end

  desc "invio notifiche scarichi mensili"
  task month: :environment do
    notifications = Notification.new(Organization.where(sendmail: "m").all)
    notifications.from = (Date.today.change(day: 1) - 1.month)
    notifications.to = Date.yesterday
    notifications.subject = "Riassunto mensile scarico materiale di consumo."
    notifications.send
  end

  desc "mailing list for active admins"
  task active_user_mail_list: :environment do
    mail_list = []
    Admin.where("authlevel >= 30").group(:user_id).each do |admin|
      user = admin.user
      if user.loads.where('year(date) = "2018"').any?
        mail_list << user.upn
      end
    end
    sleep 10
    puts mail_list.join(", ")
    sleep 60
    puts "ok 1"
    sleep 120
    puts "ok 2"
    sleep 240
    puts "ok 3"
    sleep 480
    puts "ok 4"
  end
end
end
