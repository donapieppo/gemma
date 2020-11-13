# encoding: UTF-8

require 'csv'

class GemmaReport 

  @@titles = { thing:       "Materiale",
               description: "Descrizione",
               note:        "Note", 
               location:    "Ubicazione",
               number:      "Quantità",
               dnumber:     "Numero ddt",
               actual:      "Quantità",
               total:       "Totale",
               minimum:     "Minimo",
               date:        "Data",
               ddate:       "Data ddt/fattura",
               price:       "Prezzo",
               price_operations:  "Origine Prezzo",
               totalprice:  "Prezzo Totale",
               upn:         "Operatore",
               supplier:    "Fornitore",
               code:        "Codice Fornitore"}

  @@format = { thing:       " %.80s ",
               description: " %.60s ",
               note:        " %.80s", 
               location:    "(%.20s)",
               number:      "%5i ",
               dnumber:     "%5i ",
               actual:      "%5i ",
               total:       "%5i ",
               minimum:     " su %5i ",
               date:        " %10.10s ",
               ddate:       " %10.10s ",
               price:       "\n\r................... %.2f€ ",
               price_operations:  " %s ",
               totalprice:  " %8.2f€ ",
               code:        " - codice %s",
               upn:         " %s" }

  @@operation_to_s = { 'Unload'   => "Scarico",
                       'Load'     => "Carico",
                       'Stock'    => "Giacenza iniziale",
                       'Shift'    => "Spostamento",
                       'Takeover' => 'Carico Manuale' }


  GEMMA_IMAGE_DIR = "#{Rails.root.to_s}/app/javascript/images"

  # titolo del report
  attr_accessor :title
  # i campi da reportare (array di symbols)
  attr_accessor :fields
  # mysql query
  attr_accessor :query

  # SEPARATOR
  # suddiviso. Per esempio in base a :thing. Ogni thing interrompe la precedente
  # All'inizio di stampa :separator_first_line e alla fine si stampa :separator_last_line
  # separator_first_line e separator_last_line sono Hash (si pensi a giacenza, si calcolano
  # indipendentemente dalla @query) e sono identificati di solito tramite un id 
  # in :separator_first_line_field
  attr_accessor :separator
  # se la suddivisone interrompe anche la pagina
  attr_accessor :separator_page_break
  # la prima riga dopo il separatore e la chiave per identificarlo
  attr_accessor :separator_first_line
  attr_accessor :separator_first_line_field
  attr_accessor :separator_last_line
  attr_accessor :separator_last_line_field
  # passiamo direttamente un testo
  attr_accessor :body

  attr_accessor :intro
  attr_accessor :bye_bye
  attr_accessor :footer_title

  # ACCUMULATOR (per ora solo uno totali)
  # accumulatore si somma in accumulator_value
  attr_accessor :accumulator
  attr_accessor :price_accumulator

  attr_reader :initial_space

  def initialize(organization, format = 'pdf')
    @organization = organization
    @format = format
    @accumulator_value = 0
    @price_accumulator_value = 0.0
    @initial_space = (format == 'pdf') ? "\u00A0" : '' # in pdf lo spazio iniziale deve essere un utf 
  end

  def render
    case @format
    when 'pdf'
      @pdf = Prawn::Document.new
      @pdf.font_families.update("LiberationMono" => {
        bold:   "/usr/share/fonts/truetype/liberation/LiberationMono-Regular.ttf",
        normal: "/usr/share/fonts/truetype/liberation/LiberationMono-Italic.ttf",
        italic: "/usr/share/fonts/truetype/liberation/LiberationMono-Bold.ttf"
      })
      @pdf.font "LiberationMono"
      @pdf.font_size = 8
      pdf_head
      pdf_intro
      pdf_body
      pdf_bye_bye
      pdf_pages
      @pdf.render
    when 'csv'
      @allfields = @fields 
      @allfields << @separator
      CSV.generate(col_sep: ";", quote_char: '"') do |csv|
        csv << csv_titles
        ActiveRecord::Base.connection.execute(@query).each(as: :hash) do |record|
          if @fields.include?(:price_operations) and record['price_operations']
            record['price_operations'] = price_operation_to_text(record['price_operations'])
          end
          # FIXME mettere tutto in keys
          csv << @fields.inject([]) do |tmp, f| 
            str = (f == :type) ? @@operation_to_s[record[f.to_s]] : record[f.to_s]
            tmp << str
          end
        end
      end
    when 'txt'
      @pdf = Gemmatxt::Document.new
      @pdf.add_head(@organization, @title)
      pdf_body
      @pdf.render
    else
      raise "format non noto"
    end
  end

  def type
    case @format
    when 'pdf'
      "application/#{@format}"
    when 'csv'
      "text/csv; header=present"
    when 'txt'
      "text/plain; header=present"
    end
  end

  def filename
    @title.downcase.gsub(' ', '_') + ".#{@format}"
  end

  def pdf_head
    @pdf.image "#{GEMMA_IMAGE_DIR}/sigillo1.png", width: 54, height: 52

    @pdf.draw_text "GEMMA: Reportistica del #{Time.now.strftime("%d/%m/%Y")}", 
                   at: [@pdf.bounds.left + 80, @pdf.bounds.top - 10]

    @pdf.draw_text @organization.description, 
                   at: [@pdf.bounds.left + 80, @pdf.bounds.top - 30]

    @pdf.draw_text @title, 
                   at: [@pdf.bounds.left + 80, @pdf.bounds.top - 50], style: :bold

    @pdf.move_down 20
  end

  def pdf_intro
    return if self.intro.blank?
    @pdf.move_down 20
  end

  def pdf_bye_bye
    return if self.bye_bye.blank?
    @pdf.move_down 20
    @pdf.text self.bye_bye 
  end

  def pdf_pages
    @footer_title ||= "Reportistica"
    @pdf.number_pages "GEMMA: #{@footer_title} del #{Time.now.strftime("%d/%m/%Y")}, pagina <page> di <total>", 
                      {at: [@pdf.bounds.right - 250, -10 ]}
  end

  def pdf_body
    if @body
      @pdf.text(@body) 
      return
    end
    old = nil
    first_page = true

    @last_record = false
    ActiveRecord::Base.connection.execute(@query).each(as: :hash) do |record|
      # se abbiamo divisione in gruppi ed e' cambiato il gruppo, finiamo con il vecchio
      if @separator and old != record[@separator.to_s]
        print_last_line

        old = record[@separator.to_s]
        if @separator_page_break 
          first_page or @pdf.start_new_page
          first_page = false
        end
        @pdf.move_down 10
        @pdf.text record[@separator.to_s], align: :left, margin: 30, size: 10, indent_paragraphs: 20
        @pdf.move_down 10

        print_first_line(record)
      end

      if @accumulator and record[@accumulator.to_s]
        @accumulator_value += record[@accumulator.to_s].to_f
      end
      if @price_accumulator and record['price']
        @price_accumulator_value += record['price']
      end

      # FIXME accrocchio !!!
      # l'upn in caso di load diventa il ddt
      if @fields.include?(:type)
        if record['type'] == 'Stock' or record['type'] == 'ArchStock'
          record['upn'] = 'Giacenza iniziale'
        elsif record['type'] == 'Load' or record['type'] == 'ArchLoad'
          record['upn'] = "#{record['gen']} #{record['ddt']} numero #{record['dnumber']} di #{record['supplier']}"
        end
      end
      if @fields.include?(:note)
        record['note'] = "(#{record['note']})" unless record['note'].blank? 
      end
      if @fields.include?(:price_operations) and record['price_operations']
        record['price_operations'] = price_operation_to_text(record['price_operations'])
      end

      # necessari non-breaking space characters all'inizio della stringa
      # report.fields = [:date, :number, :thing, :description, :note]
      line = @fields.inject(@initial_space) do |tot, f| 
        # nel caso di operation saltiamo (vedi sopra)
        if record[f.to_s] and (f != :type) and ! ((f == :price) and (record['price'] == 0.0))
          tot += sprintf(@@format[f], record[f.to_s]) 
        end
        tot
      end
      
      @pdf.text line
      @pdf.move_down 2

      @last_record = record 
    end

    if @last_record 
      # dell'ultimo gruppo 
      print_last_line
    else
      @pdf.text "Non sono presenti dati nel periodo indicato" 
    end
  end

  def csv_titles
    @fields.map {|f| @@titles[f]}
  end

  def print_first_line(record)
    if @separator_first_line and @separator_first_line.has_key?(record[@separator_first_line_field].to_s)
      @pdf.text @separator_first_line[record[@separator_first_line_field].to_s]
      @pdf.move_down 2
    end
  end

  # l'ultima riga con separator deve tenere traccia del vecchio valore (l e' il nuovo)
  # Si pensi separator_last_line = Hash e separator_last_line_field = :thing_id
  def print_last_line
    # se non siamo abbiamo ancora un vecchio gruppo con cui chiudere
    @last_record or return  
    if @last_record and @separator_last_line and @separator_last_line.has_key?(@last_record[@separator_last_line_field].to_s)
      @pdf.text @separator_last_line[@last_record[@separator_last_line_field].to_s]
      @pdf.move_down 2
    end

    if @accumulator
      # FIXME se price o total number
      # @pdf.text "Totale: #{@accumulator_value}€ "
      @pdf.text "Totale: #{@accumulator_value} "
      @accumulator_value = 0
    end
    if @price_accumulator and @price_accumulator_value > 0
      @pdf.move_down 10
      @pdf.text "Spesa Totale: #{@price_accumulator_value} € "
      @price_accumulator_value = 0
    end

  end

  def price_operation_to_text(po)
    YAML::load(po).select{|po| po[:p] > 0}
                  .map{|po| "#{po[:n]} da #{po[:desc]} (#{"%.2f €" % (po[:p].to_f/100) })"}
                    .join(', ')
  end
end


module Gemmatxt
class Document

  def initialize
    @txt = ""
  end

  def text(t, *)
    @txt << t + "\r\n"
    # @txt << "\u2028" # come \n
  end

  def render
    @txt
  end

  def start_new_page
  end

  def font(*)
  end

  def move_down(number)
    number > 5 and @txt << "\r\n"
  end

  def add_head(organization, title)
    @txt << '-' * 80 + "\r\n"
    @txt << "GEMMA: Reportistica del #{Time.now.strftime("%d/%m/%Y")} \r\n" 
    @txt << organization.description + "\r\n"
    @txt << title + "\r\n"
    @txt << '-' * 80 + "\r\n\r\n" 
  end

  alias :image        :font
  alias :draw_text    :font
  alias :number_pages :font
  alias :bounds       :font

end
end
