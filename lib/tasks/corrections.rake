namespace :gemma do
  namespace :corrections do
    def conn
      ActiveRecord::Base.connection.instance_variable_get(:@connection)
    end

    desc "Fix giacenza iniziale price da arch"
    task fix_arch_prices: :environment do
      raise "BOH"
      Organization.where(pricing: true).each do |o|
        # carichi o stock di attuali thing
        o.things.each do |thing|
          if (stock = thing.stocks.first)
            # uso l'ultima operazione con un prezzo
            # (oppure ultimo carico anche con prezzo zero)
            last_positive_operation = ArchOperation.where(thing_id: ArchThing.from_new(thing).ids)
              .where("price > 0 and number > 0")
              .order("date desc").first

            if last_positive_operation && last_positive_operation.price > 0
              last_price = last_positive_operation.price.to_f / last_positive_operation.number.abs
              stock.update_attribute(:price, last_price * stock.number)
              p stock
            end
          end
        end
      end
    end
  end
end
