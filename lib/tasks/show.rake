namespace :gemma do
namespace :show do
  # select users.id from admins left join users on users.id = user_id group by user_id;
  desc "Show inactive admins 2023"
  task inactive_admins: :environment do
    from = "2023-01-01"

    DmUniboCommon::Permission.includes(:user).group(:user_id).each do |a|
      c = Operation.where("date > ?", from).where(user_id: a.user_id).count
      c += Operation.where("date > ?", from).where(recipient_id: a.user_id).count
      sleep 1
      puts "#{a.user.upn} - #{a.user.id}" if c == 0
    end
    sleep 60
    puts "ok 1"
    sleep 120
    puts "ok 2"
    sleep 240
    puts "ok 3"
    sleep 480
    puts "ok 4"
  end

  desc "Show active admins 2016"
  task active_users_with_recipient: :environment do
    from = "2015-01-01"
    query = "select upn from users where id in (select distinct(user_id) from operations where date > '#{from}' and recipient_id is not null)"
    ActiveRecord::Base.connection.instance_variable_get(:@connection).query(query).each do |row|
      print row[0] + ","
    end
  end
end
end
