ActiveadminAddons.setup do |config|
  # Change to "default" if you want to use ActiveAdmin's default select control.
  # config.default_select = "select2"

  # Set default options for DateTimePickerInput. The options you can provide are the same as in
  # xdan's datetimepicker library (https://github.com/xdan/datetimepicker/tree/2.5.4). Yo need to
  # pass a ruby hash, avoid camelCase keys. For example: use min_date instead of minDate key.
  # config.datetime_picker_default_options = {}

  # Set DateTimePickerInput input format. This if for backend (Ruby)
  # config.datetime_picker_input_format = "%Y-%m-%d %H:%M"
end

ActiveAdmin::ResourceController.class_eval do
  def find_resource
    finder = resource_class.is_a?(FriendlyId) ? :slug : :id
    scoped_collection.find_by(finder => params[:id])
  end
end
