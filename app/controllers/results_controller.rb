class ResultsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_system_admin, only: [:index, :destroy]

  # GET /results
  # GET /results.json
  def index
    result_scope = Result.current
    @order = Result.column_names.collect{|column_name| "results.#{column_name}"}.include?(params[:order].to_s.split(' ').first) ? params[:order] : "results.study_id"
    result_scope = result_scope.order(@order)
    @results = result_scope.page(params[:page]).per( 20 )

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @results }
    end
  end

  # GET /results/1
  # GET /results/1.json
  def show
    @result = Result.current.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @result }
    end
  end

  # GET /results/new
  # GET /results/new.json
  def new
    @result = Result.new

    @reliability_id = ReliabilityId.find_by_unique_id(params[:reliability_id])
    if @reliability_id and @reliability_id.user_id == current_user.id
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @result }
      end
    else
      redirect_to root_path
    end
  end

  # GET /results/1/edit
  def edit
    @result = Result.current.find(params[:id])
  end

  # POST /results
  # POST /results.json
  def create
    MY_LOG.info "Create Params: #{params}"
    @result = Result.new(post_params)
    MY_LOG.info "uid: #{@result.user_id} eid: #{@result.exercise_id} rel_ids: #{ReliabilityId.where(user_id: @result.user_id, exercise_id: @result.exercise_id).empty?}"
    if @result.user_id == current_user.id and ReliabilityId.where(user_id: @result.user_id, exercise_id: @result.exercise_id).empty? == false
      MY_LOG.info "ACCEPTED: #{@result.valid?} #{@result.errors.full_messages}"
      respond_to do |format|
        if @result.save
          MY_LOG.info "SAVED: #{@result.valid?} #{@result.errors.full_messages}"
          format.html { redirect_to @result.exercise, notice: 'Result was successfully created.' }
          format.json { render json: @result, status: :created, location: @result }
        else
          format.html { render action: "new" }
          format.json { render json: @result.errors, status: :unprocessable_entity }
        end
      end
    else
      redirect_to root_path
    end
  end

  # PUT /results/1
  # PUT /results/1.json
  def update
    @result = Result.current.find(params[:id])

    respond_to do |format|
      if @result.update_attributes(post_params)
        format.html { redirect_to @result, notice: 'Result was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @result.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /results/1
  # DELETE /results/1.json
  def destroy
    @result = Result.current.find(params[:id])
    @result.destroy

    respond_to do |format|
      format.html { redirect_to results_url }
      format.json { head :no_content }
    end
  end

  private

  def parse_date(date_string)
    date_string.to_s.split('/').last.size == 2 ? Date.strptime(date_string, "%m/%d/%y") : Date.strptime(date_string, "%m/%d/%Y") rescue ""
  end

  def post_params
    params[:result] ||= {}

    [].each do |date|
      params[:result][date] = parse_date(params[:result][date])
    end

    params[:result].slice(
      :user_id, :study_id, :exercise_id, :rule_id, :result_type, :location, :deleted
    )
  end
end
