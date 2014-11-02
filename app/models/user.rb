class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  has_many :attendances

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  devise :omniauthable, :omniauth_providers => [:google_oauth2]

  def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    data = access_token.info
    user = User.where(:email => data["email"]).first

    unless user
        user = User.create(name: data["name"],
           email: data["email"],
           password: Devise.friendly_token[0,20]
        )
    end
    user
  end

  def create_attendance
    self.attendances.create(
        :user_id => self.id,
        :datetoday => Date.today,
        :in => Time.now.to_s(:time)
    )
  end

  def find_todays_entry
    todays_entry = Attendance.where(:user_id => self.id, :datetoday => Date.today, :out => nil).first
    todays_entry
  end

  def monthly_total_hour(month)
    self.attendances.where("MONTH(datetoday) =?", month).sum(:total_hours)
  end

  def monthly_average_hour(month)
    total_days_spent_in_office = self.attendances.where("MONTH(datetoday) =?", month).count("datetoday", :distinct => true)
    if total_days_spent_in_office > 0
      monthly_total_hour(month) / total_days_spent_in_office
    end
  end

  def monthly_average_in_time(month)
    total = self.attendances.where("MONTH(datetoday) =? AND first_entry =? ", month, true).average("TIME_TO_SEC(attendances.in)")
    if total.present?
      Time.at(total).utc.strftime("%I:%M %p")
    end
  end

  def update_first_entry(today = Date.today)
    not_first_entry = self.attendances.where("datetoday =? AND first_entry =? ", today, true).count
    if not_first_entry == 0
      todays_first_entry = self.attendances.find_by_datetoday(today)
      todays_first_entry.update_attribute(:first_entry, true)
    end
  end
end
