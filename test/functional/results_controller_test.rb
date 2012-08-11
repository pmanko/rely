require 'test_helper'

class ResultsControllerTest < ActionController::TestCase
  setup do
    @result = results(:one)
    @current_user = login(users(:admin))
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:results)
  end

  test "should not get new since no associated study" do
    get :new
    assert_redirected_to root_path
  end

  test "should not create result since admin is not assigned to study" do
    assert_no_difference('Result.count') do
      post :create, result: { deleted: @result.deleted, exercise_id: @result.exercise_id, location: @result.location, rule_id: @result.rule_id, study_id: @result.study_id, result_type: @result.result_type, user_id: @result.user_id }
    end

    assert_redirected_to root_path
  end

  test "should show result" do
    get :show, id: @result
    assert_response :success
  end

  test "should get edit" do
    pending "Should not get edit for not assigned users"
    get :edit, id: @result
    assert_response :success
  end

  test "should update result" do
    pending "Should not update for unassigned users"
    put :update, id: @result, result: { deleted: @result.deleted, exercise_id: @result.exercise_id, location: @result.location, rule_id: @result.rule_id, study_id: @result.study_id, result_type: @result.result_type, user_id: @result.user_id }
    assert_redirected_to result_path(assigns(:result))
  end

  test "should destroy result" do
    assert_difference('Result.count', -1) do
      delete :destroy, id: @result
    end

    assert_redirected_to results_path
  end

  # Scorer Access

  test "should get new with reliability_id if study assigned to current user" do
    login(users(:valid))

    get :new, reliability_id: reliability_ids(:one).unique_id
    assert_not_nil assigns(:reliability_id)
    assert_response :success
  end

  test "should not get new with reliability_id if study not assigned to current user" do
    login(users(:valid))

    get :new, reliability_id: reliability_ids(:three)
    assert_redirected_to root_path
  end

  test "should create result for study assigned to current user" do
    scorer = users(:valid)
    login(scorer)
    exercise = create(:exercise)
    exercise.scorers << scorer
    exercise.save

    MY_LOG.info "errors: #{exercise.errors.full_messages} \neid: #{exercise.id} #{exercise.scorers} | #{scorer} | #{exercise.scorers.include?(scorer)}"
    assert_difference('Result.count') do
      post :create, result: { exercise_id: exercise.id, location: "some location", rule_id: exercise.rule.id, study_id: exercise.all_studies.first, result_type: "rescored", user_id: scorer.id }
    end

    assert_redirected_to exercise_path(assigns(:result).exercise)
  end

  test "should not create result for study not assigned to current user" do
    scorer = users(:valid)
    login(scorer)
    exercise = create(:exercise)
    MY_LOG.info "#{exercise.scorers} | #{scorer} | #{exercise.scorers.include?(scorer)}"

    assert_no_difference('Result.count') do
      post :create, result: { exercise_id: exercise.id, location: "some location", rule_id: exercise.rule.id, study_id: exercise.all_studies.first, result_type: "rescored", user_id: scorer.id }
    end

  end

  test "should update result for study assigned to current user" do
    pending

    login(scorer)
    scorer = users(:valid)
    login(scorer)
    exercise = build(:exercise)
    exercise.scorers << scorer
    exercise.save

    put :update, id: @result, result: { deleted: @result.deleted, exercise_id: @result.exercise_id, location: @result.location, rule_id: @result.rule_id, study_id: @result.study_id, result_type: @result.result_type, user_id: @result.user_id }
    assert_redirected_to result_path(assigns(:result))
  end

  test "should show result by reliability_id if study assigned to current user" do
    pending
    login(users(:valid))


  end

  test "should not show result if study not assigned to current user" do
    pending
    login(users(:valid))

  end

end
