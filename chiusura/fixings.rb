# Sistemazione dei carichi in anni diversi.
# Operazioni in anno nuovo relativi a ddt in anno vecchio
# diventano operazioni in anno vecchio!
#
# se in anno nuovo c'e' stock dobbiamo spostare anche quello :-(

module Gemma
  class Chiusura

    # operazioni in anno successivo al ddt (ddt in @year)
    # le ordino in base alla data cosi' la prima deve venire dopo lo stock 
    # che si potrebbe dover spostare....
    def move_operations_next_year_with_ddt_this_year
      res = @conn.query("SELECT operations.id, thing_id
                           FROM operations, ddts 
                          WHERE operations.organization_id = #{@organization.id} 
                            AND operations.ddt_id          = ddts.id
                            AND YEAR(ddts.date)            = #{@year} 
                            AND YEAR(operations.date)      > #{@year}")
               
      res.each do |row|
        # verifico gli stock in anno nuovo relativi all'oggetto dell'operazione
        stock_res = @conn.query("SELECT operations.id 
                                   FROM operations
                                  WHERE type = 'Stock'
                                    AND YEAR(operations.date) > #{@year}
                                    AND thing_id = #{row[1]}").first
        if stock_res                                    
          puts "cambio anno a stock #{row[0]}" if @debug
          @conn.query("UPDATE operations SET date = '#{@last_year_date}' WHERE id = #{stock_res[0].to_i}") 
        end

        puts "cambio anno a operation #{row[0]}" if @debug
        @conn.query("UPDATE operations SET date = '#{@last_year_date}' WHERE id=#{row[0].to_i}")
      end
    end
  end
end

