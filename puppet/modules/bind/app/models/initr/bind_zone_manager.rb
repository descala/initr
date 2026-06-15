# Join model assigning a Redmine user as a manager of a single bind zone.
# Many-to-many: a zone can have several managers, a user can manage many zones
# (across bind servers / projects). Drives Initr::BindZone#editable_by?.
class Initr::BindZoneManager < ActiveRecord::Base
  belongs_to :bind_zone, :class_name => "Initr::BindZone"
  belongs_to :user
end
