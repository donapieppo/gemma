class BatchUnload
  attr_reader :errors, :recipients

  def initialize(user, organization, thing, params)
    @user = user
    @organization = organization
    @thing = thing
    @recipients = params.key?(:recipient_upn) ? params.delete(:recipient_upn).gsub(/\s/, '').split(',').reject { |upn| upn == ''} : []
    @params = params
    @deposit = @thing.deposits.find(@params[:numbers].keys.first.to_i)
    @errors = []
  end

  def validate_recipients
    @errors << 'Troppi pochi indirizzi' if @recipients.size < 2 
    @errors << 'Troppi indirizzi. Limitarsi a 20 indirizzi per volta.' if @recipients.size > 20 
    no_unibo = @recipients.select { |upn| upn !~ /@unibo.it/ }
    @errors << "Gli indirizzi #{no_unibo.join(', ')} non sono mail Unibo." if no_unibo.size > 0
  end

  def validate_number
    necessar = @params[:numbers].values.first.to_i * @recipients.size * -1
    if @deposit.actual < necessar
      @errors << "Non sono presenti sufficienti oggetti per lo scarico. Mi hai dato #{@recipients.size} indirizzi."
    end
  end

  def valid?
    validate_recipients
    validate_number
    @errors.empty?
  end

  def run
    if self.valid?
      @recipients.each do |upn|
        u = @thing.unloads.new(@params)
        u.organization_id = @organization.id
        u.user_id = @user.id
        u.recipient_upn = upn
        u.validate
        u.save
        if u.errors.any?
          @errors << u.errors
        end
      end
    end
  end
end

