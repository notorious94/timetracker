class PreRegistrationsController < ApplicationController
    layout 'time_tracker'

    def index
        # @pre_registration_all = PreRegistration.where(step_no: 2)
        @pre_registration_all = PreRegistration.where('pre_registrations.step_no = ? OR pre_registrations.step_no = ?', 2, 3)
        @holiday_scheme = HolidayScheme.all
        @weekend_scheme = Weekend.all
        @ttf_list = User.active.where(role: 2)
    end
    def new
        @pre_registration = PreRegistration.new
        @pre_registration_all = PreRegistration.all.where(step_no: 2)
        @holiday_scheme = HolidayScheme.all
        @weekend_scheme = Weekend.all
        @ttf_list = User.active.where(role: 2)
    end

    def create
        pre_registration = PreRegistration.new(pre_registration_params)
        if pre_registration_params[:packReady].to_s == "0"
            pre_registration_params[:packReady] = false
        else
            pre_registration_params[:packReady] = true
        end
        if pre_registration_params[:NdaSigned].to_s == "0"
            pre_registration_params[:NdaSigned] = false
        else
            pre_registration_params[:NdaSigned] = true
        end
        if pre_registration_params[:workstationReady].to_s == "0"
            pre_registration_params[:workstationReady] = false
        else
            pre_registration_params[:workstationReady] = true
        end
        pre_registration.step_no = 2
        if pre_registration.save
            UserMailer.send_new_employee_notification(current_user).deliver
            redirect_to new_pre_registration_path
        end
    end
    def delete
    end
    def destroy
        @pre_registration = PreRegistration.find(params[:id])
        if @pre_registration.present?
            @pre_registration.destroy
        end
        redirect_to new_pre_registration_path
    end
    def edit
        @pre_registration = PreRegistration.find(params[:id])
        @holiday_scheme = HolidayScheme.all
        @weekend_scheme = Weekend.all
        @ttf_list = User.active.where(role: 2)
        if params[:format] != "1"
            @is_for_admin = "23"
        else
            @is_for_admin = "22"
        end
    end
    def show
        @pre_registration = PreRegistration.find(params[:id])
    end
    def update
        pre_registration = PreRegistration.find params[:id]
        if params[:selected] == "23"
            pre_registration.step_no = 2
        end
        if pre_registration_params[:salary_account_details_sent].to_s == "1" && pre_registration_params[:employee_contract_sign].to_s == "1" && pre_registration_params[:id_card_given].to_s == "1" && pre_registration_params[:pic_and_other_relevant_info].to_s == "1" && pre_registration_params[:has_sent_invitation_to_visit_internal_website].to_s == "1"
            pre_registration.step_no = 4
        end
        if pre_registration.update(pre_registration_params)
            if params[:selected] == "23"
                redirect_to pre_registration
                else
                redirect_to new_pre_registration_path
            end
        end
    end
    private
    # Using a private method to encapsulate the permissible parameters is
    # a good pattern since you'll be able to reuse the same permit
    # list between create and update. Also, you can specialize this method
    # with per-user checking of permissible attributes.
    def pre_registration_params
        params.require(:pre_registration).permit(:name,
        :companyEmail,
        :joiningDate,
        :datetime,
        :NdaSigned,
        :user_id,
        :emailGroup,
        :contactNumber,
        :personalEmail,
        :companyEmail,
        :holiday_scheme_id,
        :weekend_id,
        :workstationReady,
        :packReady,
        :salary_account_details_sent,
        :employee_contract_sign,
        :id_card_given,
        :pic_and_other_relevant_info,
        :has_sent_invitation_to_visit_internal_website)
    end
end
