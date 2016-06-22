require 'spec_helper'

describe Banner::Person do
  let(:params) { {} }
  let(:person) { Banner::Person.new(params) }
  subject { person }

  describe '#banner_id' do
    let(:params) { {PIDM: 42} }
    its(:banner_id) { should eql 42 }
    it{ expect(person.banner_id).to eql 42 }
  end

  describe '#biola_id' do
    let(:params) { {ID: 1234567} }
    its(:biola_id) { should eql 1234567 }
    it{ expect(person.biola_id).to eql 1234567 }
  end

  describe '#banner_udcid' do
    let(:params) { {UDCID: '12345678910'} }
    its(:banner_udcid) { should eql '12345678910' }
    it{ expect(person.banner_udcid).to eql '12345678910' }
  end

  describe '#last_name' do
    let(:params) { {LNAME: 'Z'} }
    its(:last_name) { should eql 'Z' }
    it{ expect(person.last_name).to eql 'Z' }
  end

  describe '#first_name' do
    let(:params) { {FNAME: 'Coach'} }
    its(:first_name) { should eql 'Coach' }
    it{ expect(person.first_name).to eql 'Coach' }
  end

  describe '#middle_name' do
    let(:params) { {MNAME: 'O'} }
    its(:middle_name) { should eql 'O' }
    it{ expect(person.middle_name).to eql 'O' }
  end

  describe '#preferred_name' do
    let(:params) { {PNAME: 'Coachie'} }
    its(:preferred_name) { should eql 'Coachie' }
    it{ expect(person.preferred_name).to eql 'Coachie' }
  end

  describe '#street_1' do
    let(:params) { {STREET1: '1 Field St.'} }
    its(:street_1) { should eql '1 Field St.' }
    it{ expect(person.street_1).to eql '1 Field St.' }
  end

  describe '#street_2' do
    let(:params) { {STREET2: 'Apt B'} }
    its(:street_2) { should eql 'Apt B' }
    it{ expect(person.street_2).to eql 'Apt B' }
  end

  describe '#city' do
    let(:params) { {CITY: 'Hometown'} }
    its(:city) { should eql 'Hometown' }
    it{ expect(person.city).to eql 'Hometown' }
  end

  describe '#state' do
    let(:params) { {STATE: 'Strong Badia'} }
    its(:state) { should eql 'Strong Badia' }
    it{ expect(person.state).to eql 'Strong Badia' }
  end

  describe '#zip' do
    let(:params) { {ZIP: '12345'} }
    its(:zip) { should eql '12345' }
    it{ expect(person.zip).to eql '12345' }
  end

  describe '#gender' do
    context "when 'M'" do
      let(:params) { {GENDER: 'M'} }
      its(:gender) { should eql :male }
      it{ expect(person.gender).to eql :male }
    end

    context "when 'F'" do
      let(:params) { {GENDER: 'F'} }
      its(:gender) { should eql :female }
      it{ expect(person.gender).to eql :female }
    end

    context "when nil" do
      let(:params) { {GENDER: nil} }
      its(:gender) { should eql nil }
      it{ expect(person.gender).to eql nil }
    end
  end

  describe '#privacy' do
    context "when 'Y'" do
      let(:params) { {CONFID: 'Y'} }
      its(:privacy) { should eql true }
      it{ expect(person.privacy).to eql  true }
    end

    context "when 'N'" do
      let(:params) { {CONFID: 'N'} }
      its(:privacy) { should eql false }
      it{ expect(person.privacy).to eql  false }
    end

    context 'when nil' do
      let(:params) { {CONFID: nil} }
      its(:privacy) { should eql false }
      it{ expect(person.privacy).to eql  false }
    end
  end
end
