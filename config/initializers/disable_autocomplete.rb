Rails.application.config.action_view.form_with_generates_ids = true
ActionView::Base.field_error_proc = Proc.new { |html_tag, _| html_tag }
