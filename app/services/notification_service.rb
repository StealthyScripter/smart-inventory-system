class NotificationService
  def self.notify_supplier_users!(supplier, event_type:, title:, body:)
    supplier.users.find_each do |user|
      Notification.create!(user: user, event_type: event_type, title: title, body: body)
    end
  end
end
