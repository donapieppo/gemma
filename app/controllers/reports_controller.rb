class ReportsController < ApplicationController
  def index
    authorize :report
  end

  def form_articoli
    authorize :report
  end

  def articoli 
    authorize :report
    report = GemmaReport.new(current_organization, params[:format])

    report.title     = "Elenco articoli"
    report.fields    = [:thing]
    report.separator = :group_name
    report.separator_page_break = params[:different_pages]

    report.query  = "SELECT things.name as thing, groups.name as group_name
                       FROM things
                       LEFT OUTER JOIN groups ON group_id = groups.id
                      WHERE groups.organization_id = #{current_organization.id}
                   ORDER BY groups.name, things.name"

    send_data report.render, :filename => report.filename, :type => report.type
  end

  #
  # GIACENZE
  # 
  def form_giacenza
    authorize :report
    @locations = current_organization.locations.order(:name)
    @groups    = current_organization.groups
    # se solo uno non c'e' da scegliere :-)
    (@locations.size == 1) and @locations = []
  end

  def giacenza
    authorize :report
    report = GemmaReport.new(current_organization, params[:format])

    location = (params[:location] and params[:location][:id].to_i > 0) ? Location.find(params[:location][:id]) : nil
    group    = (params[:group]    and params[:group][:id].to_i > 0) ? Group.find(params[:group][:id]) : nil

    report.title  =  "Giacenza "
    report.title  +=  " in #{location}" if location
    report.title  +=  " categoria: #{group}" if group

    report.fields = [:actual, :thing]
    report.fields << :location unless (current_organization.locations.size <= 1 or location)

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

    send_data report.render, :filename => report.filename, :type => report.type
  end

  #
  # SOTTOSCORTA
  # 
  def form_sottoscorta
    authorize :report
  end

  def sottoscorta
    authorize :report
    report = GemmaReport.new(current_organization, params[:format])

    report.title  = "Articoli sottoscorta"
    report.fields = [:total, :minimum, :thing]

    report.query = "SELECT things.name as thing, total, minimum 
                      FROM things 
                WHERE things.organization_id = #{current_organization.id}
                  AND total < things.minimum
             ORDER BY things.name"

    send_data report.render, filename: report.filename, type: report.type
  end

  # 
  # SCARICHI
  #
  # scarichi di un certo upn 
  def form_scarichi 
    authorize :report
    @cache_users = User.all_in_cache(current_organization.id)
    @things = current_organization.things.order(:name)
    @groups = current_organization.groups.order(:name)
  end

  def scarichi
    authorize :report
    report = GemmaReport.new(current_organization, params[:format])

    leggi_date

    @user = (params[:user] and params[:user][:id].to_i > 0) ? User.find(params[:user][:id]) : nil
    user_select = @user ? "AND (recipient_id = '#{@user.id}' OR (recipient_id IS NULL AND user_id = '#{@user.id}')) " : ""

    @thing_id = (params[:thing] and params[:thing][:id].to_i > 0) ? params[:thing][:id].to_i : nil
    thing_select = @thing_id ? "AND thing_id = #{@thing_id}" : '' 

    @note = params[:note].blank? ? nil : params[:note].gsub(/[^a-zA-Z0-9 ]/, '')
    note_select = @note ? "AND note LIKE '%#{@note}%'" : ''

    @group_id = (params[:group] and params[:group][:id].to_i > 0) ? params[:group][:id].to_i : nil
    group_select = @group_id ? "AND group_id = #{@group_id}" : '' 

    report.title = "Scarichi"
    report.title += @user ? " da #{@user} " : ''
    report.title += @thing_id ? " di #{Thing.find(@thing_id)}" : ''
    report.title += @note ? " con parola #{@note}" : ''

    report.separator = :upn
    report.separator_page_break = params[:different_pages]

    report.fields = [:date, :number, :thing, :description, :note]
    report.accumulator = :number if (@thing_id or @group_id)
    report.separator = :thing if @group_id

    if current_organization.pricing 
      report.fields += [:price, :price_operations] 
      report.price_accumulator = true
    end

    order = "upn, operations.date"
    order = "upn, things.name, operations.date" if @group_id

    report.query = "SELECT DATE_FORMAT(operations.date,'%e/%m/%Y') AS date, 
                           users.upn, 
                           ABS(number) as number, things.name as thing, description, operations.note, (price/100) AS price, price_operations
                      FROM operations 
           LEFT OUTER JOIN things ON operations.thing_id = things.id 
           LEFT OUTER JOIN users  ON COALESCE(recipient_id, user_id)= users.id 
                     WHERE operations.organization_id = #{current_organization.id}
                       AND operations.date >= '#{@from.to_s}'
                       AND operations.date <= '#{@to.to_s}'
                       AND operations.number < 0  
                       #{user_select}
                       #{thing_select}
                       #{group_select}
                       #{note_select}
                  ORDER BY #{order}"

    send_data report.render, filename: report.filename, type: report.type
  end

  # 
  # RICEVUTE
  #

  def form_receipts
    authorize :report
    @cache_users = User.recipient_cache(current_organization.id, 40)
  end

  def receipt
    authorize :report
    report = GemmaReport.new(current_organization, "pdf")

    leggi_date

    @user = (params[:user] and params[:user][:id].to_i > 0) ? User.find(params[:user][:id]) : nil
    user_select = @user ? "AND (recipient_id = #{@user.id} OR (recipient_id IS NULL AND user_id = #{@user.id})) " : ""
    user_select_bookings = @user ? "AND user_id = #{@user.id} AND from_booking IS NOT NULL" : ""

    report.title = "Ricevuta scarichi del giorno #{I18n.l @from}"
    report.separator_page_break = true
    report.intro = "Il sottoscritto #{@user} dichiara di avere ricevuto il seguente materiale:"
    report.bye_bye = "In fede, #{@user}"
    report.footer_title = "Ricevuta"

    report.fields = [:date, :number, :thing, :description, :note]
    if @thing_id
      report.accumulator = :number
    end
    if current_organization.pricing 
      report.fields = [:date, :number, :thing, :description, :note, :price] 
      report.price_accumulator = true
    end

    report.query = "SELECT DATE_FORMAT(operations.date,'%e/%m/%Y') AS date, 
                           users.upn, 
                           ABS(number) as number, things.name as thing, description, operations.note, (price/100) AS price
                      FROM operations 
           LEFT OUTER JOIN things ON operations.thing_id = things.id 
           LEFT OUTER JOIN users  ON COALESCE(recipient_id, user_id)= users.id 
                     WHERE operations.organization_id = #{current_organization.id}
                           #{params[:bookings] ? user_select_bookings : user_select}
                       AND operations.date = '#{@from.to_s}'
                       AND operations.number < 0  
                  ORDER BY upn, things.name, operations.date"

    send_data report.render, :filename => report.filename, :type => report.type
  end

  #
  # STORICO
  #
  def form_storico
    authorize :report
    @things = current_organization.things.order(:name)
  end

  def storico
    authorize :report
    report = GemmaReport.new(current_organization, params[:format])

    leggi_date

    thing = (params[:thing] and params[:thing][:id].to_i > 0) ? Thing.find(params[:thing][:id].to_i) : nil

    loc_query = ""
    # se ci limitiamo ad un oggetto
    thing and loc_query += " AND operations.thing_id = #{thing.id} "
    # se ci limitiamo ai ddt
    params[:only_loads] and loc_query += " AND operations.type = 'Load'"

    report.title = "Storico "
    thing  and report.title += "di #{thing}"
    report.title += " periodo dal #{I18n.l @from} al #{I18n.l @to}"

    report.separator = :thing
    report.fields    = [:date, :number, :type, :upn] 
    current_organization.pricing and report.fields = [:date, :number, :type, :upn, :price] 
    report.separator_page_break = params[:different_pages]

    report.query = "SELECT DATE_FORMAT(operations.date,'%e/%m/%Y') AS date, 
                           operations.number, type, (price/100) AS price,
                           things.name as thing, things.id AS thing_id, 
                           ddts.name as ddt, ddts.gen, ddts.number AS dnumber, suppliers.name as supplier, 
                           DATE_FORMAT(ddts.date,'%e/%m/%Y') AS ddate, 
                           users.upn
                     FROM operations
                     LEFT OUTER JOIN things     ON operations.thing_id             = things.id
                     LEFT OUTER JOIN ddts       ON operations.ddt_id               = ddts.id 
                     LEFT OUTER JOIN suppliers  ON ddts.supplier_id                = suppliers.id
                     LEFT OUTER JOIN users      ON COALESCE(recipient_id, user_id) = users.id
                    WHERE operations.organization_id = #{current_organization.id}
                          #{loc_query}
                      AND operations.number != 0
                      AND operations.date >= '#{@from.to_s}'
                      AND operations.date <= '#{@to.to_s}'
                 ORDER BY things.name, operations.date"
                    
    # giacenza iniziale al periodo
    query = "SELECT things.id AS thing_id, SUM(number) AS total
               FROM operations 
               LEFT OUTER JOIN things ON operations.thing_id = things.id
              WHERE operations.organization_id = #{current_organization.id}
                #{loc_query}
                AND operations.date < '#{@from.to_s}'
           GROUP BY thing_id"
    report.separator_first_line = Hash.new
    report.separator_first_line_field = 'thing_id'
    ActiveRecord::Base.connection.execute(query).each do |r|
      report.separator_first_line[r[0].to_s] = sprintf("#{report.initial_space}            %5i  Valore iniziale %s ", r[1], I18n.l(@from))
    end

    # giacenza finale al periodo
    query = "SELECT things.id AS thing_id, SUM(number) AS total
               FROM operations 
               LEFT OUTER JOIN things ON operations.thing_id = things.id
              WHERE operations.organization_id = #{current_organization.id}
                #{loc_query}
                AND operations.date <= '#{@to.to_s}'
           GROUP BY thing_id"
    report.separator_last_line = Hash.new
    report.separator_last_line_field = 'thing_id'
    ActiveRecord::Base.connection.execute(query).each do |r|
      report.separator_last_line[r[0].to_s] = sprintf("#{report.initial_space}            %5i  Giacenza %s", r[1], I18n.l(@to))
    end

    send_data report.render, :filename => report.filename, :type => report.type
  end

  #
  # DDT
  #
  def form_ddts
    authorize :report
    @ddts = current_organization.ddts.includes(:supplier).order('number desc').where('YEAR(date) = ?', Date.today.year)
  end

  def ddts
    authorize :report
    ddt_ids       = params[:ddt_ids] ? params[:ddt_ids].map(&:to_i).join(',') : nil
    ddt_ids_query = ddt_ids ? "AND ddts.id IN (#{ddt_ids})" : ''

    report = GemmaReport.new(current_organization, params[:format])

    leggi_date

    report.title = "Carichi"

    report.separator = :ddt
    report.fields    = [:date, :number, :thing] 

    report.query = "SELECT DATE_FORMAT(operations.date,'%e/%m/%Y') AS date, 
                           operations.number, type,
                           things.name as thing, things.id AS thing_id, 
                           concat(ddts.gen, ' ', ddts.name, ' num. ', ddts.number, ' del ', ddts.date, ' - ', suppliers.name) as ddt,
                           ddts.gen, ddts.number AS dnumber, suppliers.name as supplier, 
                           DATE_FORMAT(ddts.date,'%e/%m/%Y') AS ddate 
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

    send_data report.render, :filename => report.filename, :type => report.type
  end

  def form_provision
    authorize :report
  end

  def provision
    authorize :report
    report = GemmaReport.new(current_organization, params[:format])
    leggi_date

    report.title = "Storico per programmazione"
    report.title += " periodo dal #{I18n.l @from} al #{I18n.l @to}"

    report.separator = :thing
    report.fields    = [:date, :number] 
    current_organization.pricing and report.fields << :price

    report.query = "SELECT things.name AS thing, things.id AS thing_id, 
                           SUM(number) AS number
                     FROM operations
                     LEFT OUTER JOIN things ON operations.thing_id = things.id
                    WHERE operations.organization_id = #{current_organization.id}
                      AND operations.number < 0
                      AND operations.date >= '#{@from.to_s}'
                      AND operations.date <= '#{@to.to_s}'
                 GROUP BY things.id"
                    
    # giacenza finale al periodo
    query = "SELECT things.id AS thing_id, SUM(number) AS total
               FROM operations 
               LEFT OUTER JOIN things ON operations.thing_id = things.id
              WHERE operations.organization_id = #{current_organization.id}
                AND operations.date <= '#{@to.to_s}'
           GROUP BY thing_id"
    report.separator_last_line = Hash.new
    report.separator_last_line_field = 'thing_id'
    ActiveRecord::Base.connection.execute(query).each do |r|
      report.separator_last_line[r[0].to_s] = sprintf("#{report.initial_space}            %5i  Giacenza %s", r[1], I18n.l(@to))
    end

    send_data report.render, filename: report.filename, type: report.type
  end

  def unavailable
    authorize :report
  end

  private

  def set_date(y, m, d)
    if Date.valid_date?(y, m, d)
      Date.new(y, m, d)
    else
      Date.today
    end
  end

  # "from"=>{"day"=>"1", "month"=>"1", "year"=>"2015"}, "to"=>{"day"=>"1", "month"=>"2", "year"=>"2015"}
  def leggi_date
    today = Date.today

    params['from'] ||= {day: 1, month: today.month, year: today.year}
    params['to']   ||= {day: today.day, month: today.month, year: today.year}

    @from = set_date(params['from']['year'].to_i, params['from']['month'].to_i, params['from']['day'].to_i)
    @to   = set_date(params['to']['year'].to_i, params['to']['month'].to_i, params['to']['day'].to_i)
  end
end



