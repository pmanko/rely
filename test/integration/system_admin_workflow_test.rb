require 'test_helper'

SimpleCov.command_name "test:integration"

class SystemAdminWorkflowTest < ActionDispatch::IntegrationTest
  def setup
    @user = login_admin
  end

  test "should get list of all exercises" do
    pending
    visit exercises_path
    assert find("tbody").has_selector?("tr", :count => Exercise.current.count)
  end

  test "should be able to launch an exercise" do
    # Setup
    users = create_list(:user, 10)
    groups = create_list(:group_with_studies, 4)
    rule = create(:rule)
    name = "Test Exercise"
    assessment_type = Assessment::TYPES[0]
    description = "Description for a very vital exercise."
    reset_email

    # Creation
    visit exercises_path
    click_on "Create Exercise"


    fill_in "Name", :with => name
    fill_in "Description", :with => description
    select_from_chosen assessment_type[:title], :from => "Assessment Type"
    select_from_chosen rule.name, :from => "Rule"
    groups.each do |group|
      select_from_chosen group.name, :from => "Groups"
    end
    users.each do |user|
      select_from_chosen user.name, :from => "Scorers"
    end
    click_button "Launch Exercise"

    # Show Page
    #show_page
    assert has_content?("Exercise was successfully launched.")
    assert has_content?(@user.name)
    assert has_content?("Assigned At")
    assert has_content?("Completed At")
    assert has_content?(name)
    assert has_content?(description)
    groups.each do |group|
      assert has_content?(group.name)
    end
    users.each do |user|
      assert has_content?(user.name)
    end
    assert has_content?(rule.title)

    # Emails Sent
    assert_equal email_count, users.count
    recipients = email_recipients
    users.each do |user|
      assert recipients.include?(user.email)
    end
  end

  test "should be able to create a group of studies" do
    study_count = 20
    group_name = "Test Group"
    description = "This is a description of group that consists of many studies."
    study_indexes = [0, 2, 4, 8, 11, 13, 19]

    studies = setup_for_group_creation(study_count)
    visit groups_path
    click_on "Create Group"
    fill_in 'Name', :with => group_name
    fill_in 'Description', :with => description
    assert find("#group_study_ids").has_selector?("option", :count => study_count), "Available studies are not all shown in select."

    study_indexes.each do |i|
      select_from_chosen studies[i].long_name, :from => "Studies"
    end
    click_button "Create Group"

    assert has_content?("Group was successfully created.")
    assert has_content?(group_name), "No group name displayed."
    assert has_content?(description), "No description displayed"

    study_indexes.each do |i|
      assert has_content?(studies[i].long_name)
    end
  end

  test "should be able to create a study type" do
    study_type_name = "Test Study Type"
    description = "Study type description is here."

    visit study_types_path
    click_on "Create Study Type"
    fill_in "Name", :with => study_type_name
    fill_in "Description", :with => description
    assert has_no_content?('Deleted'), 'Deleted flag should not show up'

    click_button "Create Study Type"

    assert has_content?("Study type was successfully created."), "No success message shown."
    assert has_content?(study_type_name), "No study type name shown"
    assert has_content?(description), "No study type description shown"
  end

  test "should be able to create study" do
    study_type = create(:study_type)
    study_id = "OIDSTUDY1"
    study_location = "/path/to/somewhere/cool/"

    visit studies_path
    click_on "Create Study"
    fill_in "Original ID", :with => study_id
    fill_in "Location", :with => study_location
    select_from_chosen study_type.name, :from => "Study Type"

    click_button "Create Study"

    assert has_content?("Study was successfully created.")
    assert has_content?(study_type.name)
    assert has_content?(study_id)
    assert has_content?(study_location)
  end

  test "should be able to create rule" do
    title = "Test Rule"
    procedure = "Test rule procedure for how to score these things."

    visit rules_path
    click_on "Create Rule"
    fill_in "Title", :with => title
    fill_in "Procedure", :with => procedure

    click_button "Create Rule"

    assert has_content?("Rule was successfully created.")
    assert has_content?(title)
    assert has_content?(procedure)
  end

  test "should be able to create project" do
    name = "Test Project"
    description = "Test project description is here and very very interesting."
    start_date = DateTime.now()
    end_date = start_date + 2.months
    group_count = 4
    groups = create_list(:group_with_studies, group_count)

    visit projects_path
    click_on "Create Project"

    fill_in "Start Date", :with => start_date.strftime("%m/%d/%Y")
    fill_in "End Date", :with => end_date.strftime("%m/%d/%Y")
    page.execute_script('$("#ui-datepicker-div").hide()')
    fill_in "Name", :with => name
    fill_in "Description", :with => description

    groups.each do |group|
      select_from_chosen group.to_s, :from => "Groups"
    end

    assert has_no_content?('Deleted'), 'Deleted flag should not show up'

    click_button "Create Project"

    assert has_content?("Project was successfully created.")
    assert has_content?(name)
    assert has_content?(description)
    assert has_content?(start_date.strftime("%Y-%m-%d"))
    assert has_content?(end_date.strftime("%Y-%m-%d"))
    groups.each do |group|
      assert has_content?(group.name)
    end
  end


  private

  def setup_for_group_creation(study_count)
    study_type = create(:study_type)
    create_list(:study, study_count, study_type: study_type)
  end

end