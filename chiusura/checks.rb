module Gemma
class Chiusura

  # VERIFICA che Stock in archivio operations sia uguale a somme movimenti in arch_operations
  def check_stocks
    # tutti gli oldid (a meno di cancellazioni sono anche gli attuali id)
    r1 = @conn.query("SELECT DISTINCT oldid 
                                 FROM arch_things 
                                WHERE organization_id=#{@organization.id}")

    # per ogni materiale (oldid)
    r1.each do |x|
      oldid = x[0].to_i
      puts "verifico arch_thing #{oldid}"

      # tutte le operazioni su thing con stesso oldid 
      # (ricorda che in arch_things abbiamo ANNI DIVERSI)
      # Ordine per data perche' solo il primo carico iniziale e' tale.
      # Gli altri sono solo promemoria visto che ragioniamo a scomparti stagni di anni
      r2 = @conn.query("SELECT number, YEAR(date) AS year, type 
                          FROM arch_operations, arch_things 
                         WHERE arch_things.oldid = #{oldid} 
                           AND thing_id = arch_things.id 
                      ORDER BY date asc, arch_operations.id asc")

      gia_trovata_prima_giacenza = false 
      sum = 0

      r2.each(:as => :hash) do |x|
        if (x['type'] == 'ArchStock')
          if gia_trovata_prima_giacenza 
            # verifichiamo che i conti tornino
            (sum == x['number'].to_i) or raise "Errore: giacenza iniziale anno #{x['year']} non corretta: sum=#{sum} num=#{x['number']}"
            sum = 0 # ricominciamo (ricorda che questa giacenza viene risommata alla fine di questo ciclo)
          end
        end
        sum += x['number'].to_i
        gia_trovata_prima_giacenza = true # non e' piu' prima giacenza perche' abbiamo gia' iniziato a contare.
      end

      # ora verifichiamo sia uguale alla giacenza iniziale questo anno
      r2 = @conn.query("SELECT number 
                         FROM operations
                        WHERE thing_id  = #{oldid} 
                          AND type = 'Stock'").first

      if r2.nil?
        # OK solo se NON abbiamo giacenza iniziale in anno corrente e finito tutto anni precedenti
        (sum == 0) or raise "in #{oldid} non ho giacenza iniziale ma ho residuo di #{sum}"
      else 
        (r2[0].to_i == sum) or raise "ERRORE gi: archthing #{oldid}: gi=#{r2[0]}, sum=#{sum}"
      end
    end
  end

  # 1) oggetti di adesso
  # 2) recupero dall'oldid tutti gli id in arch
  # 3) ogni anno gli id sono diversi ma devo passare anche per anni per avere l'ordine
  def check_actuals
    r1 = @conn.query("SELECT things.id, total
                         FROM things
                        WHERE organization_id = #{@organization.id}")

    # TOTALS per ogni materiale verifichiamo che i totals siano corretti
    r1.each do |row_thing|
      thing_id = row_thing[0].to_i
      actual   = row_thing[1].to_i
    
      somma = @conn.query("SELECT SUM(number) 
                              FROM operations
                             WHERE thing_id = #{thing_id}").first[0].to_i
      (somma == actual) or raise "somma di thing_id #{thing_id} = #{somma}, actual = #{actual}"
    end
        
    # ACTUAL in deposits
    r1 = @conn.query("SELECT id, actual
                         FROM deposits 
                        WHERE organization_id = #{@organization.id}")
    
    r1.each do |row_deposit|
      deposit_id = row_deposit[0].to_i
      actual     = row_deposit[1].to_i
    
      somma = @conn.query("SELECT SUM(number) 
                              FROM moves
                             WHERE deposit_id = #{deposit_id}").first[0].to_i
      (somma == actual) or raise "somma di deposit_id #{deposit_id} = #{somma}, actual = #{actual}"
    end
  end
end
end

