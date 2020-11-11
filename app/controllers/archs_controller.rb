class ArchsController < ApplicationController
  def index
    authorize :arch
    @years = ArchOperation.years(current_organization)
  end

  def list
    authorize :arch
    @year = params[:year].to_i

    report = GemmaReport.new(current_organization, params[:format])

    report.title     = "Movimenti anno #{@year}"
    report.separator = :thing
    report.fields    = [:type, :date, :number, :upn, :description]
    report.query = "SELECT type, arch_operations.number, COALESCE(recipient, upn) AS upn, 
                           arch_things.name as thing, arch_ddts.name as ddt, gen, arch_ddts.number AS dnumber, 
                           DATE_FORMAT(arch_operations.date,'%e/%m/%Y') AS date, suppliers.name AS supplier
                      FROM arch_operations
                      LEFT OUTER JOIN arch_things ON arch_operations.thing_id = arch_things.id 
                      LEFT OUTER JOIN arch_ddts   ON arch_operations.ddt_id   = arch_ddts.id 
                      LEFT OUTER JOIN suppliers   ON arch_ddts.supplier_id    = suppliers.id
                     WHERE arch_operations.organization_id = #{current_organization.id}
                       AND year(arch_operations.date) = #{@year}
                  ORDER BY arch_things.name, arch_operations.date, arch_operations.number DESC"

    send_data report.render, :filename => report.filename, :type => report.type
  end

  # lista dei movimenti di un thing particolare
  # def list_thing
  #   authorize :arch
  #   @year  = params[:year].to_i
  #   @thing = current_organization.arch_things.find(params[:thing_id])

  #   (@thing.year == @year) or raise "anno non coincide"

  #   @fields = [:operation, :date, :number, :upn]
  #   query = "SELECT operation, arch_operations.number, COALESCE(recipient, upn) AS upn, 
  #                   arch_ddts.name as ddt, gen, arch_ddts.number AS dnumber, 
  #                   DATE_FORMAT(arch_operations.date,'%e/%m/%Y') AS date, supplier
  #              FROM arch_operations
  #              LEFT OUTER JOIN arch_ddts   ON arch_operations.ddt_id   = arch_ddts.id 
  #              LEFT OUTER JOIN suppliers   ON arch_ddts.supplier_id    = suppliers.id
  #             WHERE thing_id = #{@thing.id} 
  #               AND year(arch_operations.date) = #{@year}
  #          ORDER BY arch_operations.date"
  #   @res = ActiveRecord::Base.connection.execute(query)

  #   @title = "Storico di #{@thing} nell'anno #{@year}"
  #   if params[:format] == 'csv'
  #     send_csv(@res, @title, ['date', 'number', 'note', 'ddt', 'dnumber', 'supplier', 'upn'])
  #   else
  #     send_report
  #   end
  # end

end

