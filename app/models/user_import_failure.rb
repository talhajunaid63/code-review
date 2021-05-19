class UserImportFailure < ApplicationRecord
  belongs_to :user_import

  def to_csv_row
    [user_import.headers.map { |v| csv_row[v] }, reason].flatten
  end

  def first_name
    csv_row['first_name']
  end

  def last_name
    csv_row['last_name']
  end

  def reference_number
    csv_row['reference_number']
  end

  def phone_no
    csv_row['phone_no']
  end

  def email
    csv_row['email']
  end
end
