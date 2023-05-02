class ReportsController < ApplicationController
  def index
    authorize :report
  end

  def form_articoli
    authorize :report
  end

  def articoli 
    authorize :report
    report = GemmaReport.new(current_organization, params[:report][:format])

    report.title     = 'Elenco articoli'
    report.fields    = [:thing]
    report.separator = :group_name
    report.separator_page_break = params[:report][:different_pages] == '1'

    report.query  = "SELECT things.name as thing, groups.name as group_name
                       FROM things
                       LEFT OUTER JOIN groups ON group_id = groups.id
                      WHERE groups.organization_id = #{current_organization.id}
                   ORDER BY groups.name, things.name"

    send_data report.render, filename: report.filename, type: report.type
  end

  def form_giacenza
    authorize :report
    @locations = current_organization.locations.order(:name)
    @groups    = current_organization.groups.order(:name)
    # se solo uno non c'e' da scegliere :-)
    @locations = [] if @locations.size == 1
  end

  def giacenza
    authorize :report
    report = GemmaReport.new(current_organization, params[:report][:format])

    location = (params[:report][:location_id].to_i > 0) ? Location.find(params[:report][:location_id]) : nil
    group    = (params[:report][:group_id].to_i > 0) ? Group.find(params[:report][:group_id]) : nil

    report.title  =  "Giacenza "
    report.title  +=  " in #{location}" if location
    report.title  +=  " per la categoria: #{group}" if group

    report.fields = [:actual, :thing]
    report.fields << :location unless (current_organization.locations.size <= 1 || location)

    loc_query   = location ? " AND deposits.location_id = #{location.id} " : ""
    group_query = group    ? " AND things.group_id = #{group.id} " : ""

    report.query = "SELECT things.name as thing, actual, locations.name as location 
                      FROM deposits 
                      LEFT OUTER JOIN things ON deposits.thing_id = things.id 
                      LEFT OUTER JOIN locations ON deposits.location_id = locations.id 
                     WHERE deposits.organization_id = #{current_organization.id}
                           #{loc_query}
                           #{group_query}
                  ORDER BY things.name"

    send_data report.render, filename: report.filename, type: report.type
  end

  def form_sottoscorta
    authorize :report
    @locations = current_organization.locations.order(:name)
    @groups    = current_organization.groups.order(:name)
    # se solo uno non c'e' da scegliere :-)
    @locations = [] if @locations.size == 1
  end

  def sottoscorta
    authorize :report
    report = GemmaReport.new(current_organization, params[:report][:format])

    location = (params[:report][:location_id].to_i > 0) ? Location.find(params[:report][:location_id]) : nil
    group    = (params[:report][:group_id].to_i > 0) ? Group.find(params[:report][:group_id]) : nil

    report.title  = "Articoli sottoscorta "
    report.title  +=  " in #{location}" if location
    report.title  +=  " per la categoria: #{group}" if group

    report.fields = [:total, :minimum, :thing]
    report.fields << :location unless (current_organization.locations.size <= 1 || location)

    loc_query   = location ? " AND deposits.location_id = #{location.id} " : ""
    group_query = group    ? " AND things.group_id = #{group.id} " : ""

    report.query = "SELECT things.name as thing, total, minimum 
                      FROM deposits 
                      LEFT OUTER JOIN things ON deposits.thing_id = things.id 
                      LEFT OUTER JOIN locations ON deposits.location_id = locations.id 
                WHERE things.organization_id = #{current_organization.id}
                  AND total < things.minimum
                      #{loc_query}
                      #{group_query}
                      GROUP BY things.id
             ORDER BY things.name"

    send_data report.render, filename: report.filename, type: report.type
  end

  # scarichi di un certo upn 
  def form_scarichi 
    authorize :report
    @cache_users = User.all_in_cache(current_organization.id)
    @things = current_organization.things.order(:name)
    @groups = current_organization.groups.order(:name)
  end

  def scarichi
    authorize :report
    report = GemmaReport.new(current_organization, params[:report][:format])

    leggi_date

    @user = (params[:report][:user_id].to_i > 0) ? User.find(params[:report][:user_id]) : nil
    user_select = @user ? "AND (recipient_id = '#{@user.id}' OR (recipient_id IS NULL AND user_id = '#{@user.id}')) " : ""

    @thing_id = (params[:report][:thing_id].to_i > 0) ? params[:report][:thing_id].to_i : nil
    thing_select = @thing_id ? "AND thing_id = #{@thing_id}" : '' 

    @note = params[:report][:note].blank? ? nil : params[:report][:note].gsub(/[^a-zA-Z0-9 ]/, '')
    note_select = @note ? "AND note LIKE '%#{@note}%'" : ''

    @group_id = (params[:report][:group_id].to_i > 0) ? params[:report][:group_id].to_i : nil
    group_select = @group_id ? "AND group_id = #{@group_id}" : '' 

    report.title = 'Scarichi'
    report.title += @user ? " da #{@user} " : ''
    report.title += @thing_id ? " di #{Thing.find(@thing_id)}" : ''
    report.title += @note ? " con parola #{@note}" : ''

    report.separator = :upn
    report.separator_page_break = params[:report][:different_pages] == '1'

    report.fields = [:date, :number, :thing, :description, :note]
    report.accumulator = :number if (@thing_id or @group_id)
    report.separator = :thing if @group_id

    if current_organization.pricing 
      report.fields += [:price, :price_operations] 
      report.price_accumulator = true
    end

    order = "upn, operations.date"
    order = "upn, things.name, operations.date" if @group_id

    report.query = "SELECT operations.date AS date, 
                           users.upn, 
                           ABS(number) as number, things.name as thing, description, operations.note, (price/100) AS price, price_operations
                      FROM operations 
           LEFT OUTER JOIN things ON operations.thing_id = things.id 
           LEFT OUTER JOIN users  ON COALESCE(recipient_id, user_id)= users.id 
                     WHERE operations.organization_id = #{current_organization.id}
                       AND operations.date >= '#{@from}'
                       AND operations.date <= '#{@to}'
                       AND operations.number < 0  
                       #{user_select}
                       #{thing_select}
                       #{group_select}
                       #{note_select}
                  ORDER BY #{order}"

    send_data report.render, filename: report.filename, type: report.type
  end

  def form_receipts
    authorize :report
    @cache_users = User.recipient_cache(current_organization.id, 40)
  end

  def receipt
    authorize :report
    report = GemmaReport.new(current_organization, "pdf")

    leggi_date

    @user = params[:report][:user_id].to_i > 0 ? User.find(params[:report][:user_id]) : nil
    user_select = @user ? "AND (recipient_id = #{@user.id} OR (recipient_id IS NULL AND user_id = #{@user.id})) " : ""
    user_select_bookings = @user ? "AND user_id = #{@user.id} AND from_booking IS NOT NULL" : ""

    report.title = "Ricevuta scarichi del giorno #{@from}"
    report.separator_page_break = true
    report.intro = "Il sottoscritto #{@user} dichiara di avere ricevuto il seguente materiale:"
    report.bye_bye = "In fede, #{@user}"
    report.footer_title = 'Ricevuta'

    report.fields = [:date, :number, :thing, :description, :note]
    if @thing_id
      report.accumulator = :number
    end
    if current_organization.pricing 
      report.fields = [:date, :number, :thing, :description, :note, :price] 
      report.price_accumulator = true
    end

    report.query = "SELECT operations.date AS date, 
                           users.upn, 
                           ABS(number) as number, things.name as thing, description, operations.note, (price/100) AS price
                      FROM operations 
           LEFT OUTER JOIN things ON operations.thing_id = things.id 
           LEFT OUTER JOIN users  ON COALESCE(recipient_id, user_id)= users.id 
                     WHERE operations.organization_id = #{current_organization.id}
                           #{params[:bookings] == '1' ? user_select_bookings : user_select}
                       AND operations.date = '#{@from}'
                       AND operations.number < 0  
                  ORDER BY upn, things.name, operations.date"

    send_data report.render, filename: report.filename, type: report.type
  end

  def form_storico
    authorize :report
    @things = current_organization.things.order(:name)
  end

  def storico
    authorize :report
    report = GemmaReport.new(current_organization, params[:report][:format])

    leggi_date

    thing = params[:report][:thing_id].to_i > 0 ? Thing.find(params[:report][:thing_id]) : nil

    loc_query = ''
    # se ci limitiamo ad un oggetto
    loc_query += " AND operations.thing_id = #{thing.id} " if thing
    # se ci limitiamo ai ddt
    loc_query += " AND operations.type = 'Load'" if params[:report][:only_loads] == "1"

    report.title = 'Storico '
    report.title += "di #{thing}" if thing
    report.title += " periodo dal #{@from} al #{@to}"

    report.separator = :thing
    report.fields    = [:date, :number, :type, :upn] 
    report.fields    = [:date, :number, :type, :upn, :price] if current_organization.pricing
    report.separator_page_break = params[:report][:different_pages] == '1'

    report.query = "SELECT operations.date AS date, 
                           operations.number, type, (price/100) AS price,
                           things.name as thing, things.id AS thing_id, 
                           ddts.name as ddt, ddts.gen, ddts.number AS dnumber, suppliers.name as supplier, 
                           ddts.date AS ddate, 
                           users.upn
                     FROM operations
                     LEFT OUTER JOIN things     ON operations.thing_id             = things.id
                     LEFT OUTER JOIN ddts       ON operations.ddt_id               = ddts.id 
                     LEFT OUTER JOIN suppliers  ON ddts.supplier_id                = suppliers.id
                     LEFT OUTER JOIN users      ON COALESCE(recipient_id, user_id) = users.id
                    WHERE operations.organization_id = #{current_organization.id}
                          #{loc_query}
                      AND operations.number != 0
                      AND operations.date >= '#{@from}'
                      AND operations.date <= '#{@to}'
                 ORDER BY things.name, operations.date"
                    
    # giacenza iniziale al periodo
    query = "SELECT things.id AS thing_id, SUM(number) AS total
               FROM operations 
               LEFT OUTER JOIN things ON operations.thing_id = things.id
              WHERE operations.organization_id = #{current_organization.id}
                #{loc_query}
                AND operations.date < '#{@from}'
           GROUP BY thing_id"
    report.separator_first_line = Hash.new
    report.separator_first_line_field = 'thing_id'
    ActiveRecord::Base.connection.execute(query).each do |r|
      report.separator_first_line[r[0].to_s] = sprintf("#{report.initial_space}            %5i  Valore iniziale %s ", r[1], @from)
    end

    # giacenza finale al periodo
    query = "SELECT things.id AS thing_id, SUM(number) AS total
               FROM operations 
               LEFT OUTER JOIN things ON operations.thing_id = things.id
              WHERE operations.organization_id = #{current_organization.id}
                #{loc_query}
                AND operations.date <= '#{@to}'
           GROUP BY thing_id"
    report.separator_last_line = Hash.new
    report.separator_last_line_field = 'thing_id'
    ActiveRecord::Base.connection.execute(query).each do |r|
      report.separator_last_line[r[0].to_s] = sprintf("#{report.initial_space}            %5i  Giacenza %s", r[1], @to)
    end

    send_data report.render, filename: report.filename, type: report.type
  end

  def form_ddts
    authorize :report
    @ddts = current_organization.ddts.includes(:supplier).order('number desc').where('YEAR(date) = ?', Date.today.year).to_a
  end

  # empty selection: "ddt_ids"=>[""] -> ddt_ids = [0]
  def ddts
    authorize :report
    ddt_ids       = params[:report][:ddt_ids].map(&:to_i).join(',')
    ddt_ids_query = "AND ddts.id IN (#{ddt_ids})" # if empty ddts.id IN (0)

    report = GemmaReport.new(current_organization, params[:report][:format])

    leggi_date

    report.title = 'Carichi'

    report.separator = :ddt
    report.fields    = [:date, :number, :thing] 

    report.query = "SELECT operations.date AS date, 
                           operations.number, type,
                           things.name as thing, things.id AS thing_id, 
                           concat(ddts.gen, ' ', ddts.name, ' num. ', ddts.number, ' del ', ddts.date, ' - ', suppliers.name) as ddt,
                           ddts.gen, ddts.number AS dnumber, suppliers.name as supplier, 
                           ddts.date AS ddate 
                     FROM operations
                     LEFT OUTER JOIN things     ON operations.thing_id             = things.id
                     LEFT OUTER JOIN ddts       ON operations.ddt_id               = ddts.id 
                     LEFT OUTER JOIN suppliers  ON ddts.supplier_id                = suppliers.id
                    WHERE operations.organization_id = #{current_organization.id}
                          #{ddt_ids_query}   
                 ORDER BY ddts.number"
                    
    send_data report.render, filename: report.filename, type: report.type
  end

  # single ddit. FIXME
  # get 'reports/ddts/(:id)', to: "reports#ddt", as: 'ddt_report'
  def ddt
    authorize :report
    ddt   = Ddt.includes(:supplier).find(params[:id])
    loads = ddt.loads.includes(:thing)

    report = GemmaReport.new(current_organization, params[:format])
    report.title = "Documento N. #{ddt.number}"

    report.body = "Documento Record N. #{ddt.number} - #{ddt.gen} #{ddt} del #{ddt.date}\r\n"
    report.body << "emesso da #{ddt.supplier}\r\n\r\n\r\n"
    loads.each do |load|
      report.body << sprintf("\u00A0 %6d  ", load.number)
      report.body << load.thing.to_s + "\r\n"
      report.body << "\u00A0         " + load.date.strftime("%Y/%m/%d") + " " # FIXME
      if load.ncia
       report.body << "Rif. CIA " + load.ycia.to_s + "/" + load.ncia + " "
      end
      report.body << load.note
      report.body << "\r\n"
    end

    send_data report.render, filename: report.filename, type: report.type
  end

  def form_provision
    authorize :report
  end

  def provision
    authorize :report
    report = GemmaReport.new(current_organization, params[:report][:format])
    leggi_date

    report.title = 'Storico per programmazione'
    report.title += " periodo dal #{@from} al #{@to}"

    report.separator = :thing
    report.fields    = [:date, :number] 
    current_organization.pricing and report.fields << :price

    report.query = "SELECT things.name AS thing, things.id AS thing_id, 
                           SUM(number) AS number
                     FROM operations
                     LEFT OUTER JOIN things ON operations.thing_id = things.id
                    WHERE operations.organization_id = #{current_organization.id}
                      AND operations.number < 0
                      AND operations.date >= '#{@from}'
                      AND operations.date <= '#{@to}'
                 GROUP BY things.id"
                    
    # giacenza finale al periodo
    query = "SELECT things.id AS thing_id, SUM(number) AS total
               FROM operations 
               LEFT OUTER JOIN things ON operations.thing_id = things.id
              WHERE operations.organization_id = #{current_organization.id}
                AND operations.date <= '#{@to}'
           GROUP BY thing_id"
    report.separator_last_line = Hash.new
    report.separator_last_line_field = 'thing_id'
    ActiveRecord::Base.connection.execute(query).each do |r|
      report.separator_last_line[r[0].to_s] = sprintf("#{report.initial_space}            %5i  Giacenza %s", r[1], @to)
    end

    send_data report.render, filename: report.filename, type: report.type
  end

  def unavailable
    authorize :report
  end

  def bookings
    authorize :report
    report = GemmaReport.new(current_organization, 'pdf')

    report.title = 'Prenotazioni'
    report.separator = :upn

    report.fields = [:date, :number, :thing, :description, :note]
    report.accumulator = :number if (@thing_id or @group_id)
    report.separator = :thing if @group_id

    order = "upn, operations.date"

    # report.query = "SELECT operations.date AS date, 
    #                        users.upn, 
    #                        ABS(number) as number, things.name as thing, description,
    #                        locations.name as location
    #                   FROM operations 
    #        LEFT OUTER JOIN things ON operations.thing_id = things.id 
    #        LEFT OUTER JOIN users  ON COALESCE(recipient_id, user_id)= users.id 
    #        LEFT OUTER JOIN deposits ON deposits.thing_id = things.id
    #        LEFT OUTER JOIN locations ON deposits.location_id = locations.id 
    #                  WHERE operations.organization_id = #{current_organization.id}
    #                    AND operations.type = 'Booking'
    #                    AND operations.number < 0  
    #               ORDER BY date"
    
    report.query = "SELECT operations.date AS date, 
                           users.upn, 
                           ABS(number) as number, things.name as thing, description
                      FROM operations 
           LEFT OUTER JOIN things ON operations.thing_id = things.id 
           LEFT OUTER JOIN users  ON COALESCE(recipient_id, user_id)= users.id 
                     WHERE operations.organization_id = #{current_organization.id}
                       AND operations.type = 'Booking'
                       AND operations.number < 0  
                  ORDER BY date"

    send_data report.render, filename: report.filename, type: report.type
  end

  private

  def leggi_date
    @from = params[:report][:start_date] || Date.today.to_s
    @to   = params[:report][:end_date]   || Date.tomorrow.to_s
  end
end
