module Gemma
  class Chiusura
    # Copiamo i dati dell'anno nelle tabelle di archivio
    def copy
      # hash di passaggio per things e ddts
      t_old_new = {}
      d_old_new = {}

      # Thing:
      # si copiano solo e si aggiunge l'anno e il vecchio id
      @organization.things.each do |thing|
        # copiamo solo se abbiamo movimenti nell'anno (trova il primo)
        (thing.operations.where(["YEAR(operations.date) = ?", @year]).count == 0) and next

        # copiamo e sistemiamo i campi particolari
        new_attributes = thing.attributes
        new_attributes.delete("group_id")
        new_attributes.delete("minimum")
        new_attributes.delete("total")
        new_attributes.delete("future_prices")
        new_attributes.delete("lastprice") # ? esiste un prezzo?
        new_attributes.delete("id")
        new_attributes["oldid"] = thing.id
        new_attributes["year"] = @year

        arch_thing = ArchThing.new(new_attributes)
        if !arch_thing.save
          p arch_thing.errors
          raise(new_attributes.inspect)
        end

        t_old_new[thing.id] = arch_thing.id
        puts "copiato thing #{arch_thing.inspect}" if @debug
      end

      # Ddt:
      # si copiano tutti quelli dell'anno in questione semplicemente
      @organization.ddts.where(["YEAR(ddts.date) = ?", @year]).each do |ddt|
        new_attributes = ddt.attributes
        new_attributes.delete("id")
        new_attributes["oldid"] = ddt.id

        arch_ddt = ArchDdt.new(new_attributes)
        arch_ddt.save or raise(new_attributes.inspect)

        d_old_new[ddt.id] = arch_ddt.id
        puts "copiato ddt #{arch_ddt.inspect}" if @debug
      end

      # Operations:
      # si copiano solo cambiando
      # thing_id -> arch_thing
      # ddt_id   -> arch_ddt
      @organization.operations.where(["YEAR(operations.date) = ?", @year]).each do |operation|
        operation.is_shift? and next # gli spostamenti non ci interessano

        new_attributes = operation.attributes
        new_attributes.delete("type")
        new_attributes.delete("from_booking")
        new_attributes.delete("price_operations")
        new_attributes.delete("avoid_history_coherent")
        new_attributes.delete("avoid_price_updating")
        new_attributes.delete("id")
        new_attributes.delete("created_at")
        new_attributes.delete("lab_id")
        new_attributes["upn"] = User.find(operation.user_id).upn
        new_attributes["recipient"] = User.find(operation.recipient_id).upn if operation.recipient_id.to_i > 0
        new_attributes["oldid"] = operation.id
        new_attributes["thing_id"] = t_old_new[operation.thing_id]

        if operation.is_load?
          arch_operation = ArchLoad.new(new_attributes)
          arch_operation.ddt_id = d_old_new[operation.ddt_id]
        elsif operation.is_unload?
          arch_operation = ArchUnload.new(new_attributes)
        elsif operation.is_stock?
          arch_operation = ArchStock.new(new_attributes)
        elsif operation.is_takeover?
          arch_operation = ArchTakeover.new(new_attributes)
        else
          raise "Non riconosco #{operation.inspect}"
        end

        if !arch_operation.save
          p operation
          p arch_operation
          p arch_operation.errors
          raise("Non salvo")
        end
        puts "copiata #{arch_operation.inspect}" if @debug
      end

      # A questo punto abbiamo COPIATO correttamente Ddts e things
      # Per quanto riguarda le operations abbiamo copiato ANCHE la giacenza iniziale (se c'e')
      # tanto SI RAGIONA AD ANNI

      # QUINDI POSSIAMO CANCELLARE TUTTO ddts e moves dell'anno mettendo una
      # nuova giacenza iniziale

      # VERIFICHE DEL LAVORO FATTO SU ARCH
    end
  end
end
