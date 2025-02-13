#!/usr/bin/env /home/rails/gemma3/script/runner

require "chiusura"

c = Chiusura::Chiusura.new

puts "\t\tVERIFICA tre\n\n"

# tutti gli oldid (e quindi a meno di cancellazioni anche gli attuali id)
r1 = c.conn.query("SELECT DISTINCT oldid
                              FROM arch_things
                             WHERE organization_id=#{c.organization_id}")

# per ogni materiale (oldid)
r1.each do |x|
  oldid = x[0].to_i
  puts "verifico oldid=#{oldid}"

  sum = nil
  [2006, 2007, 2008, 2009].each do |year|
    # di quale thing in archivio ci occupiamo
    thing = c.conn.query("SELECT *
                            FROM arch_things
                           WHERE oldid = #{oldid}
                             AND year = #{year}", as: :hash).first
    # se non c'e' nel passato tiro avanti
    thing or next

    # l'id in arch_thing
    thing_id = thing["id"]

    # ci deve essere al piu' una sola giacenza iniziale per tale thing in tale anno
    n = c.conn.query("SELECT COUNT(*) FROM arch_moves WHERE thing_id = #{thing_id} AND operation = 'gi'").first[0].to_i
    (n <= 1) or raise "#{n} giacenze iniziali in #{year} actual thing = #{oldid}"

    # e tale giacenza deve essere prima di ogni altro movimento
    p = c.conn.query("SELECT date FROM arch_moves WHERE thing_id = #{thing_id} AND operation != 'gi'").first
    if p
      prima_data = p[0]
      c.conn.query("SELECT * FROM arch_moves WHERE thing_id = #{thing_id} AND operation = 'gi' and date > '#{prima_data}'").first and raise "ERROR: ho move prima di #{prima_data}"
    end

    # se ho precedente somma controllo questa giacenza iniziale
    if sum && sum.to_i > 0
      g = c.conn.query("SELECT number FROM arch_moves WHERE thing_id = #{thing_id} AND operation = 'gi'").first or raise "manca giacenza iniziale in actual thing = #{oldid} anno #{year}"
      (g[0] == sum) or raise "giacenza iniziale sbagliata"
    end

    # se nessun movimento allora me ne frego
    res = c.conn.query("SELECT SUM(number) FROM arch_moves WHERE thing_id = #{thing_id}").first
    res or next

    # ho trovato la somma dell'anno e la ricordo per confrontarla con
    # la nuova gi anno successivo
    sum = res[0]
  end
end
