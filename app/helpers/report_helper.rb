module ReportHelper
  def report_layout
    content_tag :div, class: "row" do
      concat (
        content_tag :div, class: 'col-sm-4' do
          render partial: 'reports/menu'
        end
      ) 
      concat (
        content_tag :div, class: 'col-sm-8' do
          yield
        end
      )
    end
  end
end
