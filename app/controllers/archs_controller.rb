class ArchsController < ApplicationController
  def index
    authorize :arch
    @years = ArchOperation.years(current_organization)
  end

  def list
    authorize :arch
    @year = params[:report][:year].to_i

    report = GemmaReport.new(current_organization, params[:report][:format])

    report.title     = "Movimenti anno #{@year}"
    report.separator = :thing
    report.fields    = [:type, :date, :number, :upn, :description]
    report.query = "SELECT type, arch_operations.number, COALESCE(recipient, upn) AS upn, 
                           arch_things.name as thing, arch_ddts.name as ddt, gen, arch_ddts.number AS dnumber, 
                           arch_operations.date AS date, suppliers.name AS supplier
                      FROM arch_operations
                      LEFT OUTER JOIN arch_things ON arch_operations.thing_id = arch_things.id 
                      LEFT OUTER JOIN arch_ddts   ON arch_operations.ddt_id   = arch_ddts.id 
                      LEFT OUTER JOIN suppliers   ON arch_ddts.supplier_id    = suppliers.id
                     WHERE arch_operations.organization_id = #{current_organization.id}
                       AND YEAR(arch_operations.date) = #{@year}
                  ORDER BY arch_things.name, arch_operations.date, arch_operations.number DESC"

    send_data report.render, filename: report.filename, type: report.type
  end
end
