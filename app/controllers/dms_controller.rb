class DmsController < ApplicationController
  before_action :require_login
  before_action :require_confirmed_email

  def new
    @people = Person.where.not(id: current_user.person.id).order(:name)
  end

  def create
    person_ids = [current_user.person.id] + Array(params[:person_ids]).map(&:to_i)
    person_ids = person_ids.uniq.sort

    if person_ids.count < 2
      redirect_to channels_path, alert: "Please select at least one person to message."
      return
    end

    dm = Channel.find_or_create_dm_between(person_ids)
    redirect_to dm, notice: "Direct message created."
  end
end
