# Creaiamo che giacenze iniziali e cancelliamo!

# Abbiamo gia' copiato tutto
# Ora cancelliamo tutto e creiamo le giacenze iniziali

module Gemma
  class Chiusura
    # abbiamo i dati vecchi per ogni thing (NON abbiamo ancora cancellato quello che abbiamo
    # copiato in Arch), prendiamo la somma e la mettiamo come
    # giacenza iniziale. A questa operazione nuova vanno associati moves di giacenza iniziale
    # -> thing_id, sum
    def stocks
      res = @conn.query("SELECT thing_id, sum(number) AS sum
                           FROM operations
                          WHERE organization_id = #{@organization.id}
                            AND YEAR(date) <= #{@year}
                       GROUP BY thing_id")

      res.each(as: :hash) do |row|
        sum = row["sum"].to_i
        thing_id = row["thing_id"].to_i

        (sum == 0) and next
        (sum < 0) and raise "somma negativa sum=#{sum} for thing_id=#{thing_id}"

        # inserimento giacenza iniziale anno succssivo
        # (numero totale somma di moves di cui ci occupiamo dopo)
        last = @conn.query("INSERT INTO operations SET
                                   type     = 'Stock',
                                   note     = 'Giacenza #{@year}',
                                   user_id  = '#{@user_id}',
                                   thing_id = #{thing_id},
                                   number   = #{sum},
                                   date     = '#{@year + 1}-01-01',
                                   organization_id = #{@organization.id}")

        puts "Inserita giacenza iniziale #{sum} per thing_id=#{thing_id}" if @debug

        # id della nuova operation
        last_id = @conn.query("SELECT LAST_INSERT_ID()").first[0].to_i

        # vecchi moves associati all'operaione
        res_move = @conn.query("SELECT deposit_id, sum(moves.number) AS sum
                                  FROM moves, deposits, operations
                                 WHERE operation_id      = operations.id
                                   AND deposit_id        = deposits.id
                                   AND deposits.thing_id = #{thing_id}
                                   AND YEAR(date)        <= #{@year}
                              GROUP BY deposit_id")

        res_move.each(:as => :hash) do |row_move|
          (row_move["sum"].to_i > 0) or next
          new_move = @conn.query("INSERT INTO moves SET
                                               operation_id = #{last_id},
                                               deposit_id   = #{row_move["deposit_id"]},
                                               number       = #{row_move["sum"]}")
          puts "Inserito move #{row_move["sum"]} per deposit_id=#{row_move["deposit_id"]}" if @debug
        end
      end
    end
  end
end
