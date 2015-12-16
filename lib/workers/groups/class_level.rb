module Workers
  module Groups
    class ClassLevel
      include Sidekiq::Worker

      CLASS_LEVELS = {
        Freshman:   'FR',
        Sophomore:  'SO',
        Junior:     'JR',
        Senior:     'SR'
      }

      def perform
        CLASS_LEVELS.each do |group, col_value|
          GroupSynchronizer.new(group, "SELECT pidm FROM bsv_lum_registered_students WHERE class_level = '#{col_value}'").call
        end
      end
    end
  end
end
