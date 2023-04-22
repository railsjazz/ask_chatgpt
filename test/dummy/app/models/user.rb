# not perfect code on purpose :)

class User < ApplicationRecord
  attr_accessor :first_name, :last_name

  belongs_to :country
  has_many :projects

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
end
