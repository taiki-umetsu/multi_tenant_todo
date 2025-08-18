class PasswordValidator < ActiveModel::EachValidator
  MIN_LENGTH = 8
  MAX_LENGTH = 72

  def validate_each(record, attribute, value)
    return if value.blank?

    unless value =~ /\A[\p{ascii}&&[^\x20]]{#{MIN_LENGTH},#{MAX_LENGTH}}\z/
      record.errors.add(attribute, :invalid, **options.merge(value: value))
    end
  end
end
