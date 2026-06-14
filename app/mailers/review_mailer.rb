class ReviewMailer < ApplicationMailer
  def created(review)
    @review = review
    mail(to: review.supplier.users.pluck(:email), subject: "New review received")
  end
end
