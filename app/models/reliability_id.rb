class ReliabilityId < ActiveRecord::Base
  ##
  # Associations
  belongs_to :study, :conditions => { :deleted => false }
  belongs_to :user, :conditions => { :deleted => false }
  belongs_to :exercise, :conditions => { :deleted => false }
  belongs_to :result, :conditions => { :deleted => false }

  ##
  # Attributes
  attr_accessible :study_id, :unique_id, :user_id, :exercise_id, :result_id

  ##
  # Callbacks
  before_validation :generate_uuid

  ##
  # Database Settings

  ##
  # Scopes
  scope :current, conditions: { deleted: false }

  ##
  # Validations
  validates_uniqueness_of :unique_id
  validates_presence_of :study_id, :user_id, :exercise_id, :unique_id

  ##
  # Class Methods

  ##
  # Instance Methods
  def name
    self.unique_id
  end

  def destroy
    update_column :deleted, true
  end

  def has_result?
    result.nil? ? false : true
  end

  def group
    exercise.groups.joins(:studies).where(:studies => { :id => study.id} ).first
  end

  private

  def generate_uuid
    self[:unique_id] ||= UUID.new.generate
  end
end
