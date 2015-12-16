module Workers
  module Groups
    class Residence
      include Sidekiq::Worker

      def perform
        Group.all.each do |group|
          sql = "SELECT DISTINCT pidm FROM bsv_health_center WHERE bh_street1 = '#{group.street1}' AND bh_street3 = '#{group.street3}'"
          GroupSynchronizer.new(group.name, sql).call
        end
      end

      private

      class Group
        attr_reader :name, :building, :floor, :wing

        def initialize(name, building, floor=nil, wing=nil)
          @name = name
          @building = building
          @floor = floor
          @wing = wing
        end

        alias :street1 :building

        def street3
          [floor, wing.to_s.titleize].join(',')
        end

        def self.all
          @all ||= Settings.residence.groups.map do |group|
            Group.new(group.name, group.building, group.floor, group.wing)
          end
        end
      end
    end
  end
end
