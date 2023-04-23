# not perfect code on purpose :)

class User < ApplicationRecord
  attr_accessor :first_name, :last_name

  STATUS_ACTIVE   = "active"
  STATUS_INACTIVE = "in_active"

  belongs_to :country
  has_many :projects, foreign_key: :author_id

  # bad code on purpose
  def self.get_report
    result = ["<users>"]
    for user in User.where("id > 0")
      result << "<user>" + "<id>#{user.id}</id>" + "<name>#{user.name}</name>" + "</user>"
    end
    variable = 42
    result += "</users>"
    result.join("\n")
  end

  def full_name
    [first_name, last_name].join
  end

  def say_hello
    "Hello, #{full_name}!"
  end
end
