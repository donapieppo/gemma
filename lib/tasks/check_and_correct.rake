namespace :gemma do
  namespace :checks do
    def conn
      ActiveRecord::Base.connection.instance_variable_get(:@connection)
    end

    desc "Moves numbers sum equal operation number"
    task moves_sum_and_operation_number_are_equal_or_correct: :environment do
      q = %|SELECT operations.id, SUM(moves.number), operations.number
             FROM moves, operations
            WHERE operation_id = operations.id
         GROUP BY operation_id|
      conn.query(q).each do |res|
        if res[1] != res[2]
          o = Operation.find(res[0])
          t = o.thing
          puts "o.organization_id=#{o.organization_id} o.id=#{o.id} t.id=#{t.id} => SUM(moves.number)=#{res[1]} != operations.number=#{res[2]} \t#{o.type}"
          if o.is_unload? && o.moves.count == 1
            o.moves.first.update(number: o.number)
            puts "ok"
          else
            p o
            p o.thing.deposits
            p o.moves
          end
        end
      end
    end
  end
end
