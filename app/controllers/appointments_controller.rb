class AppointmentsController < ApplicationController
  def index
    @user = current_user
    @appointments = @user.appointments.order(day: :asc)

    respond_to do |format|
        format.html
        format.js
    end
  end

  def show
    @user = current_user
    @appointment = @user.appointments.find(params[:id])
  end

  def create
    @invitation = Invitation.find(params[:invitation_id])
    @suggestion = Suggestion.find(params[:suggestion_id])

    @invitee = current_user
    @inviter = @invitation.users.first
    if @inviter == @invitee
      flash[:alert] = "You can't make a date with yourself."
      redirect_to user_invitation_path(current_user, @invitation)
      return
    end

    days_inviter = @invitation.days_inviter
    upcoming_appointments = @inviter.appointments.upcoming
    for v in upcoming_appointments do
      days_inviter.delete(v.day)
    end

    days_invitee = params[:availables_id].split
    @appointment = Appointment.new
    @appointment.users << @inviter << @invitee
    @appointment.suggestion = @suggestion

    for d in days_inviter do
      if days_invitee.include?(d)
        day = d
        break
      end
    end

    if day.nil?
      flash[:error] = "We couldn't find a day that works for both of you!"
      redirect_to edit_user_invitation_path(@invitee, @invitation)
      return
    else
      @appointment.day = day
    end

    if @appointment.save
      # @appointment.send_text_message
      @invitation.confirmed = true
      @invitation.save
      flash[:notice] = "Congratulations! You both are free on #{day}"
      redirect_to user_appointments_path(@invitee)
    else
      flash[:error] = "Failed"
      redirect_to user_invitations_path(@invitee)
    end
  end

  def edit
  end

  def update
  end

  def destroy
    @appointment = Appointment.find(params[:id])

    redirect_to user_appointments_path(current_user) if @appointment.destroy
  end



  private

  def appointment_params
  end
end
