require 'rails_helper'

describe PlacePurchase do
  subject do
    PlacePurchase.call
  end

  before do
    allow_any_instance_of(MakeDiscount).to receive(:call)
    allow_any_instance_of(ChargeCard).to receive(:call)
    allow_any_instance_of(CreatePurchase).to receive(:call)
    allow_any_instance_of(IncrementUserCredits).to receive(:call)
    allow_any_instance_of(SendPurchasePlacedEvent).to receive(:call)
    allow_any_instance_of(CreateUserPromoCode).to receive(:call)
    allow_any_instance_of(SetDropInExpirationDate).to receive(:call)
  end

  it 'calls the MakeDiscount interactor' do
    expect_any_instance_of(MakeDiscount).to receive(:call)
    subject
  end

  it 'calls the ChargeCard interactor' do
    expect_any_instance_of(ChargeCard).to receive(:call)
    subject
  end

  it 'calls the CreatePurchase interactor' do
    expect_any_instance_of(CreatePurchase).to receive(:call)
    subject
  end

  it 'calls the IncrementUserCredits interactor' do
    expect_any_instance_of(IncrementUserCredits).to receive(:call)
    subject
  end

  it 'calls the SendPurchasePlacedEvent interactor' do
    expect_any_instance_of(SendPurchasePlacedEvent).to receive(:call)
    subject
  end

  it 'calls the CreateUserPromoCode interactor' do
    expect_any_instance_of(CreateUserPromoCode).to receive(:call)
    subject
  end

  it 'calls the SetDropInExpirationDate interactor' do
    expect_any_instance_of(SetDropInExpirationDate).to receive(:call)
    subject
  end
end