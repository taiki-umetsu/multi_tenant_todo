class PasswordValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    unless value =~ /\A[\p{ascii}&&[^\x20]]{8,72}\z/
      record.errors.add(attribute, :invalid, **options.merge(value: value))
    end
  end
end
