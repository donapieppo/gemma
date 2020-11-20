namespace :gemma do
namespace :chiusura do
  require File.dirname(__FILE__) + '/../../chiusura/chiusura'
  require File.dirname(__FILE__) + '/../../chiusura/fixings'
  require File.dirname(__FILE__) + '/../../chiusura/copyings'
  require File.dirname(__FILE__) + '/../../chiusura/stocks'
  require File.dirname(__FILE__) + '/../../chiusura/deletes'
  require File.dirname(__FILE__) + '/../../chiusura/checks'

  # startyear, maxyear, organization_id, description<
  desc "Show chiusure to be done"
  task to_be_done: :environment do
    ActiveRecord::Base.connection.instance_variable_get(:@connection).query('SELECT MIN(YEAR(date)) AS startyear, MAX(YEAR(date)) AS maxyear, organizations.code, organization_id, description FROM operations LEFT JOIN organizations ON organizations.id = operations.organization_id GROUP BY organization_id ORDER BY startyear desc').each do |row| 
      p row
    end
  end

  desc "Salva la situazione attuale (passare org=46)"
  task preclose: :environment do
    # ci interessano gli actual per ora
    c = Gemma::Chiusura.new(ENV['org'], debug: false) 
    (c.year and c.user_id) or exit 0

    File.open('/tmp/chiusura', 'w') do |f|
      c.organization.deposits.each { |deposit| f.puts "#{deposit.id}:#{deposit.actual}"}
    end
  end

  desc "Controlla adesso con la situazione prima (passare org=46)"
  task postclose: :environment do
    c = Gemma::Chiusura.new(ENV['org'], debug: false)
    (c.year and c.user_id) or exit 0

    File.open('/tmp/chiusura', 'r').each do |line|
      line =~ /(\d+):(\d+)/
      (Deposit.find($1).actual == $2.to_i) or raise "#{$1}:#{$2}"
    end
  end

  desc "Chiude (passare org=46)" 
  task close: :environment do
    c = Gemma::Chiusura.new(ENV['org'], debug: false) 
    (c.year and c.user_id) or exit 0

    puts "Organization: #{c.organization.description}"
    puts "Anno: #{c.year}"
    puts "Assegno operazioni di giacenza iniziale a #{c.upn}"

    if c.organization.pricing
      raise "Non si chudono strutture con prezzi"
    end

    (c.year >= Time.now.year) and raise "Troppo presto (anno #{c.year})!"

    c.move_operations_next_year_with_ddt_this_year
    c.copy
    c.stocks
    c.delete
  end

  desc "Verifica (passare org=46)"  
  task check: :environment do
    c = Gemma::Chiusura.new(ENV['org']) 
    (c.year and c.user_id) or exit 0

    puts "Verifica di #{c.organization.description}"
    puts "Anno: #{c.year}"

    c.check_stocks
    c.check_actuals
  end

end
end

