require 'rails_helper'

RSpec.describe Product, type: :model do
  let(:category) { Category.create!(name: 'Electronics') }
  let(:product) { Product.create!(name: 'Laptop', sku: 'LAP001', category: category, reorder_point: 10, lead_time_days: 7) }

  describe '.customer_email_list' do
    it 'exists for a product' do
      expect { product.customer_email_list }.not_to raise_error(NoMethodError)
    end

    context 'when there are NO customers in the list' do
      # No additional data to set up in this scenario
      it 'returns an empty array' do
        expect(product.customer_email_list).to eq([])
      end
    end

    context 'when there are users who purchased the product' do
      let(:location) { Location.create!(name: 'Main Store') }

      # Create user records with dummy data
      let(:purchasing_user_0) {
        User.create!(
          first_name: 'Customer',
          last_name: 'One',
          email: 'customerone@example.com',
          role: 'staff',
          password: 'password123',
          password_confirmation: 'password123'
        )
      }
      let(:purchasing_user_1) {
        User.create!(
          first_name: 'Customer',
          last_name: 'Two',
          email: 'customertwo@example.com',
          role: 'staff',
          password: 'password123',
          password_confirmation: 'password123'
        )
      }

      # Create sales transaction records for the product
      before do
        SalesTransaction.create!(user: purchasing_user_0, product: product, location: location, quantity: 1, transaction_date: Time.current)
        SalesTransaction.create!(user: purchasing_user_1, product: product, location: location, quantity: 2, transaction_date: Time.current)
      end

      # This is what we expect the method to return
      let(:expected_results) {
        [
          'customerone@example.com',
          'customertwo@example.com'
        ]
      }
      it 'returns an array of customer email addresses' do
        expect(product.customer_email_list).to eq(expected_results)
      end
    end
  end
end
