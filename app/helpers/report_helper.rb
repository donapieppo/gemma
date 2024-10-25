module ReportHelper
  def report_layout(title: nil)
    content_tag :div, class: "row" do
      concat(
        content_tag(:div, class: "col-sm-4") do
          render partial: "reports/menu"
        end
      )
      concat(
        content_tag(:div, class: "col-sm-8") do
          if title
            concat(
              content_tag(:h2, title, class: "my-4 text-center")
            )
          end
          yield
        end
      )
    end
  end
end
