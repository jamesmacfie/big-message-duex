class SettingsController < ApplicationController
  before_action :require_login
  before_action :set_person

  def edit
  end

  def update
    if @person.update(person_params)
      redirect_to edit_settings_path, notice: "Profile updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_person
    @person = current_user.person
  end

  def person_params
    params.require(:person).permit(:name, :description, :theme, :avatar)
  end
end
