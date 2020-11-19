#!/usr/bin/ruby -w

require "mysql"

organization_id = ARGV[0].to_i
year = ARGV[1].to_i

dbh = Mysql.real_connect("localhost", "gemma", "leos", "gemma")

res = dbh.query("SELECT * FROM moves WHERE organization_id = '#{organization_id}' AND YEAR(date) < '#{year}'")
res.each do |r|
  raise "Trovato #{r.inspect} prima di #{year}"
end

res = dbh.query("SELECT thing_id, sum(number) AS sum FROM moves WHERE organization_id = '#{organization_id}' AND YEAR(date) = '#{year}' GROUP BY thing_id")

puts "insert into ddts set (number='1', organization_id='#{organization_id}', gen='ddt', supplier_id=1, ddt=0, date='#{year}-01-01'"

ddt_id = 1111

res.each(:as => :hash) do |row|  
  thing_id = row['thing_id']
  sum      = row['sum']

  puts "delete from moves where thing_id = #{thing_id} and AND YEAR(date) = '#{year}'"
  puts "insert into moves set (upn='pietro.donatini', thing_id = #{thing_id}, number=#{sum}, date='#{year}-01-01', ip='137.204.134.32', ddt_id=#{ddt_id}, operation='l', organization_id=#{organization_id}"

  # Dobbiamo sostituire all'elenco di moves una giacenza iniziale
end

