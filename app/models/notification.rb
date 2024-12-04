class Notification
  attr_accessor :from, :to, :subject

  def initialize(organizations)
    @organizations = organizations
  end

  def send
    @organizations.each do |organization|
      puts "---- analizzo: #{organization.description} dalla data #{@from} -----"

      # prima riempio con elenco di tutti gli scarichi diviso per utente
      all_unloads = Hash.new { |hash, key| hash[key] = [] }

      organization.unloads
        .where(["date >= ? AND date <= ?", @from, @to])
        .order(:date)
        .includes(:thing, :user, :recipient).each do |unload|
        to = (unload.recipient_id ? unload.recipient : unload.user) or raise unload.inspect
        data = unload.date.strftime("%d/%m/%Y")
        num = sprintf("%5d", unload.number.to_i.abs)
        thing = unload.thing.name
        note = (unload.note =~ /\w+/) ? "(#{unload.note})" : ""

        operator = unload.recipient ? "(da #{unload.user.upn})" : ""
        all_unloads[to] << " #{data} - #{num}  #{thing} #{note} #{operator}\n"
      end

      all_unloads.each do |user, elenco|
        puts "Trovato #{user.inspect} con i seguenti unloads:"
        puts elenco
        SystemMailer.notify_unloads(user, organization, @from, @to, @subject, elenco).deliver_now
        sleep 35
      end
    end
  end
end
