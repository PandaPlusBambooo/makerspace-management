class UsersController < ApplicationController
  load_and_authorize_resource

  def index
    respond_to do |format|
      format.html
      format.json { render json: UsersDatatable.new(view_context) }
    end
    @page = if user_search_params[:page].present?
      user_search_params[:page].to_i
    else
      0
    end

    @users = User.order(:first_name, :last_name).limit(User::PAGE_SIZE).offset(@page * User::PAGE_SIZE)
  end

  def coaches
    @users = User.where(user_type: ['Admin', 'Staff']).order(:first_name, :last_name)

  end

  def metrics
    @total_users_created_by_week = User.total_users_created_by_week
    @users_created_by_week = User.users_created_by_week
    @punches_created_by_week = Punch.punches_created_by_week
    @reason_counts = Punch.reason_counts
    @training_counts = UserTraining.training_counts
    @events_count = Event.all.count

    punches_per_day = Punch.where(in: true).group("DATE_TRUNC('day', created_at)").count.sort
    punches_per_work_day_t = {}
    punches_per_day.to_h.each do |key,value|

      # is only on weekdays and not in May through August
      if key.strftime('%u').to_i < 5 && (key.strftime('%m').to_i < 5 || key.strftime('%m').to_i > 8)
        # puts("KEY: #{key}")
        # puts("VALUE: #{value}")
        punches_per_work_day_t[key] = value
        # puts("PER WORK DAY: #{punches_per_work_day_t}")

      end
    end

    puts("PER DAY: #{punches_per_day}")
    puts("PER WORK DAY: #{punches_per_work_day_t}")

    @punches_per_work_day = punches_per_work_day_t.sum{|k,v| v} / punches_per_work_day_t.to_h.keys.count
    

  end

  def show
    @user = User.find(params[:id])


    if @user.slack_user_id.present? && valid_slack_client?
      @slack_username = slack_client.users_info(user: @user.slack_user_id)[:user][:name]
    end
  end

  def edit
    @user = User.find(params[:id])
    @slack_usernames = [] # default to empty array of slack usernames

    if valid_slack_client?
      @slack_usernames = slack_client.users_list()[:members].map { |u| [u[:name], u[:id]] }
      @slack_usernames.insert(0, ["None", ""])
    end
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params)
      redirect_to @user, notice: 'User updated.'
    else
      render 'edit', error: @user.errors
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to @user, notice: 'User created.'
    else
      render 'new', error: @user.errors
    end
  end

  def update_password
    @user = User.find(params[:id])

    if @user.update(user_params)
      redirect_to @user, notice: 'Password updated.'
    else
      render 'password', error: @user.errors
    end
  end

  def password
    @user = User.find(params[:id])
  end

  def destroy
    @user = User.find(params[:id])

    if @user.destroy
      redirect_to users_path, notice: 'User deleted.'
    else
      render 'edit', error: @user.errors
    end
  end

private

  def slack_client
    @slack ||= Slack::Web::Client.new
  end

  def valid_slack_client?
    slack_client.token.present? && slack_client.auth_test
  end

  def user_params
    params.require(:user).permit(permit_params)
  end

  def user_search_params
    params.permit(:page)
  end

  def permit_params
    base =
      [:email,
      :biography,
      :first_name,
      :last_name,
      :slack_user_id,
      :facebook_username,
      :twitter_username,
      :github_username,
      :profile_image_url,
      :position_name,
      :password,
      :password_confirmation,
      :specialties,
      :interests
    ]

    if current_user && current_user.admin?
      base << :member_since
      base << :user_type
    end

    base
  end
end
