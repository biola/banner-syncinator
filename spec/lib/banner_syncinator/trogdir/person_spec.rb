require 'spec_helper'

describe Trogdir::Person do
  let(:params) { {} }
  subject { Trogdir::Person.new(params) }

  describe '#uuid' do
    let(:params) { {uuid: 12345} }
    its(:uuid) { should eql 12345 }
  end

  describe '#banner_id' do
    let(:params) { {ids: [{type: "banner", identifier: "42"}]} }
    its(:banner_id) { should eql 42 }
  end

  describe '#biola_id' do
    let(:params) { {ids: [{type: "biola_id", identifier: "01234567"}]} }
    its(:biola_id) { should eql 1234567 }
  end

  describe '#banner_udcid' do
    let(:params) { {ids: [{type: "banner_udcid", identifier: "12345678910"}]} }
    its(:banner_udcid) { should eql "12345678910" }
  end

  describe '#last_name' do
    let(:params) { {last_name: 'Cheat'} }
    its(:last_name) { should eql 'Cheat' }
  end

  describe '#first_name' do
    let(:params) { {first_name: 'The'} }
    its(:first_name) { should eql 'The' }
  end

  describe '#middle_name' do
    let(:params) { {middle_name: 'S'} }
    its(:middle_name) { should eql 'S' }
  end

  describe '#preferred_name' do
    let(:params) { {preferred_name: 'The Sneak'} }
    its(:preferred_name) { should eql 'The Sneak' }
  end

  describe '#partial_ssn' do
    let(:params) { {partial_ssn: '1234'} }
    its(:partial_ssn) { should eql '1234' }
  end

  describe '#street_1' do
    let(:params) { {addresses: [{type: 'home', street_1: '1 Field St.'}]} }
    its(:street_1) { should eql '1 Field St.' }
  end

  describe '#street_2' do
    let(:params) { {addresses: [{type: 'home', street_2: 'Apt B'}]} }
    its(:street_2) { should eql 'Apt B' }
  end

  describe '#city' do
    let(:params) { {addresses: [{type: 'home', city: 'Hometown'}]} }
    its(:city) { should eql 'Hometown' }
  end

  describe '#state' do
    let(:params) { {addresses: [{type: 'home', state: 'Strong Badia'}]} }
    its(:state) { should eql 'Strong Badia' }
  end

  describe '#zip' do
    let(:params) { {addresses: [{type: 'home', zip: '12345'}]} }
    its(:zip) { should eql '12345' }
  end

  describe '#country' do
    let(:params) { {addresses: [{type: 'home', country: 'USA'}]} }
    its(:country) { should eql 'USA' }
  end

  describe '#personal_email' do
    let(:params) { {emails: [{type: 'personal', address: 'dacoach@example.com'}]} }
    its(:personal_email) { should eql 'dacoach@example.com' }
  end

  describe '#gender' do
    context "when 'male'" do
      let(:params) { {gender: 'male'} }
      its(:gender) { should eql :male }
    end

    context "when 'female'" do
      let(:params) { {gender: 'female'} }
      its(:gender) { should eql :female }
    end

    context "when nil" do
      let(:params) { {gender: nil} }
      its(:gender) { should eql nil }
    end
  end

  describe '#birth_date' do
    context 'when a date' do
      let(:params) { {birth_date: '1969-12-31'} }
      its(:birth_date) { should eql Date.new(1969, 12, 31) }
    end

    context 'when nil' do
      let(:params) { {birth_date: nil} }
      its(:birth_date) { should eql nil }
    end
  end

  describe '#privacy' do
    context "when 'true'" do
      let(:params) { {privacy: true} }
      its(:privacy) { should eql true }
    end

    context "when 'false'" do
      let(:params) { {privacy: false} }
      its(:privacy) { should eql false }
    end

    context 'when nil' do
      let(:params) { {privacy: nil} }
      its(:privacy) { should eql false }
    end
  end

  describe '#banner_id_id' do
    let(:params) { {ids: [{type: 'banner', id: 1}]} }
    its(:banner_id_id) { should eql 1 }
  end

  describe '#biola_id_id' do
    let(:params) { {ids: [{type: 'biola_id', id: 2}]} }
    its(:biola_id_id) { should eql 2 }
  end

  describe '#banner_udcid_id' do
    let(:params) { {ids: [{type: 'banner_udcid', id: 2}]} }
    its(:banner_udcid_id) { should eql 2 }
  end

  describe '#address_id' do
    let(:params) { {addresses: [{type: 'home', id: 3}]} }
    its(:address_id) { should eql 3 }
  end

  describe '#personal_email_id' do
    let(:params) { {emails: [{type: 'personal', id: 5}]} }
    its(:personal_email_id) { should eql 5 }
  end
end
