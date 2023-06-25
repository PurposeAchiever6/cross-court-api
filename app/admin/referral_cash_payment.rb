ActiveAdmin.register ReferralCashPayment do
  menu parent: 'Users', priority: 5
  actions :index, :show

  includes :referral

  scope 'All', :all
  scope 'Pending', :pending, default: true
  scope 'Already Addressed', :addressed

  filter :referral
  filter :created_at

  action_item :paid, only: [:show], if: -> { referral_cash_payment.pending? } do
    link_to 'Mark As Paid Referral Cash Payment',
            action_admin_referral_cash_payment_path(id: params[:id], action_type: :paid),
            method: :post,
            data: { confirm: 'Are you sure you want to mark as paid this referral payment?' }
  end

  action_item :ignore, only: [:show], if: -> { referral_cash_payment.pending? } do
    link_to 'Ignore Referral Cash Payment',
            action_admin_referral_cash_payment_path(id: params[:id], action_type: :ignore),
            method: :post,
            data: { confirm: 'Are you sure you want to ignore this referral payment?' }
  end

  index do
    selectable_column
    id_column
    column 'User to be paid', &:referral
    tag_column :status
    number_column :amount, as: :currency
    column 'Referred friend', &:referred
    column :created_at

    actions
  end

  show do
    attributes_table do
      row 'User to be paid', &:referral
      row :status
      number_row :amount, as: :currency
      row 'Referred friend', &:referred
      row :user_promo_code
      row :updated_at
      row :created_at
    end
  end

  member_action :action, method: :post do
    action_type = params[:action_type]&.to_sym
    referral_cash_payment = ReferralCashPayment.find(params[:id])

    case action_type
    when :ignore
      ReferralCashPayments::Ignore.call(referral_cash_payment:)
      notice = 'Referral payment ignored successfully'
    when :paid
      ReferralCashPayments::Paid.call(referral_cash_payment:)
      notice = 'Referral payment marked as paid successfully'
    else
      raise 'Unkown action type'
    end

    redirect_to admin_referral_cash_payments_path, notice:
  rescue StandardError => e
    flash[:error] = e.message
    redirect_to admin_referral_cash_payment_path(id: params[:id])
  end
end
