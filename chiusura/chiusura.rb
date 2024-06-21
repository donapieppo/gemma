module Gemma
  class Chiusura
    attr_reader :organization, :year, :last_year_date, :user_id, :upn, :conn

    def initialize(org_id, options = {})
      @organization = Organization.find(org_id.to_i)
      @conn = ActiveRecord::Base.connection.raw_connection

      @year, @user_id = get_year_and_user
      if !(@year && @user_id)
        puts "Non abbiamo operazioni. Puoi cancellare tutto :-)"
        return
      end

      @upn = User.find(@user_id).upn

      @last_year_date = "#{@year}-12-31 20:00"  # mettiamo l'operazione alla fine dell'anno

      check_ddts

      @debug = options[:debug]

      puts "\n\t\tInizializzata chisura anno di #{@organization.description} anno #{@year}\n\n"
    end

    private

    def get_year_and_user
      @conn.query("SELECT MIN(YEAR(date)), user_id
                     FROM operations LEFT JOIN organizations ON organizations.id = operations.organization_id
                    WHERE organization_id=#{@organization.id}").first
    end

    # verifiche includono che non ci siano ddt nell'anno precedente
    def check_ddts
     if @conn.query("SELECT COUNT(id)
                       FROM ddts 
                      WHERE organization_id = #{@organization.id}
                        AND year(date) < #{@year}").first[0].to_i > 0
       puts ""
       puts "SELECT * FROM ddts      WHERE organization_id = #{@organization.id} AND year(date) < #{@year}"
       puts "UPDATE ddts SET date='#{@year}-01-01 08:01' WHERE organization_id = #{@organization.id} AND year(date) = #{@year - 1}"
       puts ""
       raise "Ci sono ddt nell'anno precedente. Puoi eseguire gli update sopra."
     end
    end
  end
end
