module Workers
  module Groups
    class International
      include Sidekiq::Worker

      INTERNATIONAL_TYPES = {
        'International Student' => 'international_all',
        'F-1 Visa Holder'       => 'international_f1'
      }

      def perform
        INTERNATIONAL_TYPES.each do |group, col|
          GroupSynchronizer.new(group, "SELECT pidm FROM bsv_lum_registered_students WHERE #{col} = 'Y'").call
        end
      end
    end
  end
end
