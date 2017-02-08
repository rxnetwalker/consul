require 'rails_helper'

feature 'Residence' do

  let!(:geozone) { create(:geozone) }

  scenario 'Verify resident' do
    user = create(:user)
    login_as(user)

    visit account_path
    click_link 'Verify my account'

    fill_in 'residence_document_number', with: "12345678Z"
    select 'DNI', from: 'residence_document_type'
    select_date '31-December-1980', from: 'residence_date_of_birth'
    fill_in 'residence_postal_code', with: '28013'
    check 'residence_terms_of_service'
    click_button 'Verify residence'

    expect(page).to have_content 'Residence verified'
  end

  scenario 'Initialize the redeemable code with the user redeemable code' do
    user = create(:user, redeemable_code: 'abcde')
    login_as(user)

    visit account_path
    click_link 'Verify my account'

    expect(page).to have_field 'residence_redeemable_code', with: 'abcde'
  end

  scenario 'Verify a resident in Madrid with a redeemable code' do
    code = create(:redeemable_code)
    user = create(:user)
    login_as(user)

    visit account_path
    click_link 'Verify my account'

    fill_in 'residence_document_number', with: "12345678Z"
    select 'DNI', from: 'residence_document_type'
    select_date '31-December-1980', from: 'residence_date_of_birth'
    fill_in 'residence_postal_code', with: '28013'
    fill_in 'residence_redeemable_code', with: code.token

    check 'residence_terms_of_service'

    click_button 'Verify residence'

    expect(page).to have_content 'Your account is verified'
  end

  scenario 'Error on verify' do
    user = create(:user)
    login_as(user)

    visit account_path
    click_link 'Verify my account'

    click_button 'Verify residence'

    expect(page).to have_content /\d errors? prevented the verification of your residence/
  end

  scenario 'Error on postal code not in census' do
    user = create(:user)
    login_as(user)

    visit account_path
    click_link 'Verify my account'

    fill_in 'residence_document_number', with: "12345678Z"
    select 'DNI', from: 'residence_document_type'
    select '1997', from: 'residence_date_of_birth_1i'
    select 'January', from: 'residence_date_of_birth_2i'
    select '1', from: 'residence_date_of_birth_3i'
    fill_in 'residence_postal_code', with: '12345'
    check 'residence_terms_of_service'

    click_button 'Verify residence'

    expect(page).to have_content 'In order to be verified, you must be registered in the municipality of Madrid'
  end

  scenario 'Error on census' do
    user = create(:user)
    login_as(user)

    visit account_path
    click_link 'Verify my account'

    fill_in 'residence_document_number', with: "12345678Z"
    select 'DNI', from: 'residence_document_type'
    select '1997', from: 'residence_date_of_birth_1i'
    select 'January', from: 'residence_date_of_birth_2i'
    select '1', from: 'residence_date_of_birth_3i'
    fill_in 'residence_postal_code', with: '28013'
    check 'residence_terms_of_service'

    click_button 'Verify residence'

    expect(page).to have_content 'The Madrid Census was unable to verify your information'
  end

  scenario '5 tries allowed' do
    user = create(:user)
    login_as(user)

    visit account_path
    click_link 'Verify my account'

    5.times do
      fill_in 'residence_document_number', with: "12345678Z"
      select 'DNI', from: 'residence_document_type'
      select '1997', from: 'residence_date_of_birth_1i'
      select 'January', from: 'residence_date_of_birth_2i'
      select '1', from: 'residence_date_of_birth_3i'
      fill_in 'residence_postal_code', with: '28013'
      check 'residence_terms_of_service'

      click_button 'Verify residence'
      expect(page).to have_content 'The Madrid Census was unable to verify your information'
    end

    click_button 'Verify residence'
    expect(page).to have_content "You have reached the maximum number of attempts. Please try again later."
    expect(current_path).to eq(account_path)

    visit new_residence_path
    expect(page).to have_content "You have reached the maximum number of attempts. Please try again later."
    expect(current_path).to eq(account_path)
  end

  scenario 'Error when trying to verify a deregistered account' do
    create(:user, document_number: '12345678Z', document_type: '1', erased_at: Time.current)

    login_as(create(:user))

    visit account_path
    click_link 'Verify my account'

    fill_in 'residence_document_number', with: "12345678Z"
    select 'DNI', from: 'residence_document_type'
    select_date '31-December-1980', from: 'residence_date_of_birth'
    fill_in 'residence_postal_code', with: '28013'
    check 'residence_terms_of_service'

    click_button 'Verify residence'

    expect(page).to_not have_content 'Residence verified'
    expect(page).to have_content 'has already been taken'
  end
end
