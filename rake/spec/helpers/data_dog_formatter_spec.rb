require 'spec_helper'
require_relative '../../lib/helpers/data_dog_formatter'

module Bosh
  module Helpers
    describe DataDogFormatter do
      subject(:formatter) { DataDogFormatter.new(StringIO.new, sender) }
      let(:sender) { stub(DataDogReporter) }
      let(:example) do
        double(RSpec::Core::Example, metadata:
          {
            description: 'sender',
            execution_result: {run_time: 3.14}
          })
      end

      it { DataDogFormatter.should < RSpec::Core::Formatters::BaseFormatter }

      it 'should reported to DataDog when an example passes' do
        sender.should_receive(:report_on).with(example)
        formatter.example_passed(example)
      end
    end
  end
end
