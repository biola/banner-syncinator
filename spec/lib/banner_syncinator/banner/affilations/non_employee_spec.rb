require 'spec_helper'

describe Banner::NonEmployee do
  [Banner::AcceptedStudent, Banner::Alumnus, Banner::Faculty, Banner::Student,
   Banner::ResearchFellow, Banner::Trustee, Banner::FacultyEmeritus,
   Banner::Advisor].each do |klass|
    let(:params) { {} }
    let(:non_employee) { klass.new(params) }
    subject { non_employee }

    describe '#partial_ssn' do
      let(:params) { {SSN: '123-12-1234'} }
      its(:partial_ssn) { should eql '123-12-1234' }
      it{ expect(non_employee.attributes[:partial_ssn]).to eql '123-12-1234' }
    end

    describe '#birth_date' do
      context 'when a date' do
        let(:params) { {DOB: '01/01/1970'} }
        its(:birth_date) { should eql Date.new(1970, 1, 1) }
        it{ expect(non_employee.attributes[:birth_date]).to eql Date.new(1970, 1, 1) }
      end

      context 'when nil' do
        let(:params) { {DOB: nil} }
        its(:birth_date) { should eql nil }
        it{ expect(non_employee.attributes[:birth_date]).to eql nil }
      end
    end

    describe '#country' do
      let(:params) { {NATION: 'USA'} }
      its(:country) { should eql 'USA' }
      it{ expect(non_employee.attributes[:country]).to eql 'USA' }
    end

    describe '#personal_email' do
      context 'valid email' do
        let(:params) { {EMAIL_PERS: 'johnny.doe@example.com'} }
        its(:personal_email) { should eql 'johnny.doe@example.com' }
        it{ expect(non_employee.attributes[:personal_email]).to eql 'johnny.doe@example.com' }
      end

      context 'email with extra leading/trailing spaces' do
        let(:params) { {EMAIL_PERS: ' johnny.doe@example.com '} }
        its(:personal_email) { should eql 'johnny.doe@example.com' }
        it{ expect(non_employee.attributes[:personal_email]).to eql 'johnny.doe@example.com' }
      end
    end
  end
end
