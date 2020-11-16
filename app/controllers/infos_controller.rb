class InfosController < ApplicationController
  def index
    authorize :info
    @year = params[:year] ? params[:year].to_i : Date.today.year
    @total_operations = Operation.where("year(date) = ?", @year).count
    @total_operations_arch = ArchOperation.where("year(date) = ?", @year).count
    @count_organization_moves = Operation.find_by_sql("SELECT COUNT(id) as number, organization_id 
                                                         FROM operations 
                                                        WHERE year(date) = #{@year} 
                                                     GROUP BY organization_id 
                                                     ORDER BY number desc")
    @last_organization_moves = Operation.find_by_sql("SELECT MAX(date) as date, organization_id 
                                                        FROM operations 
                                                       WHERE year(date) = #{@year}
                                                    GROUP BY organization_id 
                                                    ORDER BY date desc")
    @logins = Operation.find_by_sql("SELECT count(user_id) as number, users.upn
                                       FROM operations 
                                  LEFT JOIN users on user_id = users.id
                                      WHERE type  = 'Load' AND 
                                            year(date) = #{@year}
                                   GROUP BY upn 
                                   ORDER BY number desc")
    @last_month = Operation.find_by_sql("SELECT COUNT(*) as number, date
                                           FROM operations
                                          WHERE date > (CURDATE() - INTERVAL 30 DAY) 
                                       GROUP BY date")
  end

  def organization
    authorize :info
  end
end
