# frozen_string_literal: true

require 'singleton'
require_relative './query_helper.rb'

module Departments
  module Archive
    module Services
      ##
      # This class consumes models that extend Dos::DosReport.
      class IcmpFloodReport
        include Singleton

        # Retrieves persisted {Dos::IcmpFloodReport} in desc order by @created_at [DateTime]
        # @param [Integer] id {FriendlyResource} id, generated by db.
        # @param [Integer] page
        # @param [Integer] page_size
        # @return [Array<Dos::IcmpFloodReport>]
        def latest_reports_by_friendly_resource_id(id, page, page_size)
          records_to_skip = QueryHelper.instance.records_to_skip(page, page_size)
          Dos::IcmpFloodReport.where(
            'friendly_resource_id = ?',
            id,
          ).order('created_at desc').limit(page_size).offset(records_to_skip).to_a
        end

        # @param [Integer] id {Dos::IcmpFloodReport} id, generated by db.
        # @return [Dos::IcmpFloodReport]
        def icmp_flood_report_by_id(id)
          Dos::IcmpFloodReport.find(id)
        end

        # @param [Integer] seasonal_index Received from {Algorithms::HoltWintersForecasting::Api}.
        # @return [Dos::IcmpFloodReport]
        def new_report_object(seasonal_index)
          if seasonal_index
            return Dos::IcmpFloodReport.new(
              seasonal_index: seasonal_index,
              report_type: Shared::AnalysisType::ICMP_DOS_CYBER_REPORT
            )
          end
          throw StandardError.new("#{self.class.name} - #{__method__} - seasonal_index\
            must have a value.")
        end

        # @param [Integer] id {FriendlyResource} id, generated by db.
        # @param [Integer] seasonal_index Received from {Algorithms::HoltWintersForecasting::Api}.
        # @return [Dos::IcmpFloodReport]
        def latest_report_by_friendly_resource_id_and_seasonal_index(id, seasonal_index)
          if id.nil? || seasonal_index.nil?
            throw StandardError.new("#{self.class.name} - #{__method__} - id and seasonal_index\
              must have values.")
          end
          Dos::IcmpFloodReport.where(
            'friendly_resource_id = ? AND seasonal_index = ?',
            id,
            seasonal_index
          ).limit(1).order('created_at desc').to_a.first
        end
      end
    end
  end
end
