Given /^one ddt in date (\d+)\-(\d+)$/ do |date_day, date_month| 
  @ddt = create(:ddt, 
                :organization => @organization,
                :date         => "2009-#{date_month}-#{date_day}")
end
