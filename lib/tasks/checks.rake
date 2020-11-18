namespace :gemma do
namespace :checks do

  def conn
    ActiveRecord::Base.connection.instance_variable_get(:@connection)
  end

  desc "Only one stock for things"
  task only_one_stock: :environment do
    Thing.find_each do |thing|
      thing.stocks.count > 1 and puts "*** More than one stock in #{thing.inspect} #{thing.organization}"
    end
  end

  desc "Check negative total in moves history"
  task positive_totals_in_history: :environment do
    Deposit.find_each do |deposit|
      num = 0
        deposit.moves.joins(:operation).order('operations.date asc, operations.number desc, operations.id ASC').select('moves.id, moves.number').each do |move|
        num += move.number.to_i
        if num < 0
          puts "*** Inconsistency in #{deposit.inspect} for move #{move.inspect} on #{deposit.thing}"
          p deposit.thing.organization
        end
      end
    end
  end

  desc "Moves numbers sum equal operation number"
  task moves_sum_and_operation_number_are_equal: :environment do
    q = %Q|SELECT operations.id, SUM(moves.number), operations.number 
             FROM moves, operations 
            WHERE operation_id = operations.id 
         GROUP BY operation_id|
    conn.query(q).each do |res|
      if res[1] != res[2] 
        o = Operation.find(res[0])
        p o
        t = Thing.select(:id, :name, :total).find(o.thing.id)
        #puts "***"
        #puts o.organization.name
        puts t.inspect
        puts "o.organization_id=#{o.organization_id} o.type=#{o.type} o.id=#{o.id} t.id=#{t.id} => SUM(moves.number)=#{res[1]} != operations.number=#{res[2]} \t#{o.type}"#
      end
    end 
  end

  desc "Totals is sum of operations"
  task total_is_sum_of_operations: :environment do
    q = %Q|SELECT total, 
                  sum(operations.number) as sum, 
                  operations.thing_id 
             FROM things, operations
            WHERE operations.thing_id = things.id 
         GROUP BY operations.thing_id|
    conn.query(q).each do |res|
      if res[0] != res[1] 
        puts "***"
        t = Thing.find(res[2])
        p t.organization
        p t
      end
    end
  end

  desc "Shifts with 2 moves each"
  task shifts_with_2_moves: :environment do
    Shift.order('date ASC').find_each do |s|
      if s.moves.size != 2
        puts "*** Error: Shift #{s.inspct} does not have two moves"
        p s.organization, s.user, s, s.moves
      end
    end
  end

  desc "Use prices"
  task use_prices: :environment do
  end

  #task check_id_to_upn: :environment do
  #  raise "SURE?"
  #  dsaSearchClient = DsaSearch::Client.new
  #  User.where("id > 4000").each do |user|
  #    # puts "#{user.id}\t#{user.upn} ------------"
  #    dsaSearchClient.find_user(user.id).users.each do |dsauser|
  #      dsauser.id_anagrafica_unica.to_i == user.id.to_i or next
  #      dsauser.upn =~ /@studio.unibo.it/ and next
  #      # puts "#{dsauser.id_anagrafica_unica}\t#{dsauser.upn}"
  #      if user.upn != dsauser.upn
  #        puts "#{user.id}\t#{user.upn} ------------"
  #        puts "#{dsauser.id_anagrafica_unica}\t#{dsauser.upn}"
  #        puts
  #      end
  #    end
  #    sleep 2
  #    puts ""
  #  end
  #end

end
end

