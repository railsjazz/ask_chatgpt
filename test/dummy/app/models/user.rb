class User < ApplicationRecord
  belongs_to :country
  has_many :projects

  # bad code on purpose
  def self.get_report
    result = []
    for user in User.where("id > 0")
      result << "<user>" + "<id>#{user.id}</id>" + "<name>#{user.name}</name>" + "</user>"
    end
    variable = 42
    result.join("\n")
  end
end
