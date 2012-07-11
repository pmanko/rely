class AssessmentResult < ActiveRecord::Base
  ##
  # Associations
  belongs_to :assessment

  ##
  # Attributes
  attr_accessible :answer, :assessment_id, :deleted, :question_id

  ##
  # Callbacks

  ##
  # Database Settings

  ##
  # Scopes
  scope :current, conditions: { }

  ##
  # Validations

  ##
  # Class Methods

  ##
  # Instance Methods

  private

end