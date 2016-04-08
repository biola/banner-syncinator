require 'spec_helper'

describe Workers::Affiliations::Students do
  subject { Workers::Affiliations::Students.new }

  its(:affiliation) { should eql :student }

end
