module HelpsHelper
  def help_card(title: "")
    content_tag :div, class: "card my-2" do
      content_tag(:div, title, class: "card-header text-dark bg-light fw-bolder") +
        content_tag(:div, class: "card-body") do
          yield
        end
    end
  end
end
