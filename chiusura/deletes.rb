module Gemma
  class Chiusura
    def delete
      # CANCELLIAMO MOVES OPERATIONS AND DDTS :-)
      @conn.query("DELETE FROM moves
                    WHERE operation_id IN (SELECT id FROM operations
                                            WHERE organization_id = #{@organization.id}
                                              AND YEAR(date) = #{@year})")

      @conn.query("DELETE FROM operations
                    WHERE organization_id = #{@organization.id}
                      AND YEAR(date) = #{@year}")

      @conn.query("DELETE FROM ddts
                    WHERE organization_id = #{@organization.id}
                      AND YEAR(date)      = #{@year}")
    end
  end
end
