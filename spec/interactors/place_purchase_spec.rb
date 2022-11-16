require 'rails_helper'

describe PlacePurchase do
  subject do
    PlacePurchase.call
  end

  before do
    allow_any_instance_of(MakeDiscount).to receive(:call)
    allow_any_instance_of(Users::Charge).to receive(:call)
    allow_any_instance_of(Payments::Create).to receive(:call)
    allow_any_instance_of(DropIns::IncrementUserCredits).to receive(:call)
    allow_any_instance_of(Events::PurchasePlaced).to receive(:call)
    allow_any_instance_of(PromoCodes::CreateUserPromoCode).to receive(:call)
    allow_any_instance_of(DropIns::SetExpirationDate).to receive(:call)
    allow_any_instance_of(DropIns::SendPurchaseSlackNotification).to receive(:call)
  end

  it 'calls the MakeDiscount interactor' do
    expect_any_instance_of(MakeDiscount).to receive(:call)
    subject
  end

  it 'calls the Users::Charge interactor' do
    expect_any_instance_of(Users::Charge).to receive(:call)
    subject
  end

  it 'calls the DropIns::IncrementUserCredits interactor' do
    expect_any_instance_of(DropIns::IncrementUserCredits).to receive(:call)
    subject
  end

  it 'calls the Events::PurchasePlaced interactor' do
    expect_any_instance_of(Events::PurchasePlaced).to receive(:call)
    subject
  end

  it 'calls the PromoCodes::CreateUserPromoCode interactor' do
    expect_any_instance_of(PromoCodes::CreateUserPromoCode).to receive(:call)
    subject
  end

  it 'calls the DropIns::SetExpirationDate interactor' do
    expect_any_instance_of(DropIns::SetExpirationDate).to receive(:call)
    subject
  end

  it 'calls the DropIns::SendPurchaseSlackNotification interactor' do
    expect_any_instance_of(DropIns::SendPurchaseSlackNotification).to receive(:call)
    subject
  end
end
