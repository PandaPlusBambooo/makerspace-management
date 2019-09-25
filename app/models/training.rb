# == Schema Information
#
# Table name: trainings
#
#  id            :integer          not null, primary key
#  name          :string           not null
#  training_type :string           not null
#  icon          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Training < ApplicationRecord
  TRAINING_TYPES = ['Level 1', 'Level 2', 'Level 3', 'Level 4', 'Paperwork','Woodworking','3D Printing','Crafting','Electronics']

  has_many :user_trainings
  has_many :users, :through => :user_trainings

  validates :name, presence: true
  validates :training_type, inclusion: { in: TRAINING_TYPES }

  def training_type_format
    case self.training_type
    when "Level 1" || 'Woodworking'
      "warning"
    when "Level 2" || '3D Printing'
      "primary"
    when "Level 3" || 'Crafting'
      "info"
    when "Level 4" || 'Electronics'
      "secondary"
    when "Paperwork"
      "danger"
    else
      "default"
    end
  end
end
