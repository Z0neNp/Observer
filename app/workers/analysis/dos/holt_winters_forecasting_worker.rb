# frozen_string_literal: true

module Workers
  module Analysis
    module Dos
      ##
      # An abstract class that holds necessary methods for any worker performing
      # HoltWintersFrecasting analysis.
      class HoltWintersForecastingWorker < Workers::WorkerWithRedis
        # Performs calculations for a single step in Holt Winters Forecasting Algorithm.
        # [cyber_report_t_minus_m] CyberReport.
        #                          Cyber report at the moment (T-M), M beign a season duration.
        # [cyber_report_t_plus_one_minus_m] CyberReport.
        #                                   Cyber report at the moment (T+1-M).
        # [cyber_report_t_minus_one] CyberReport.
        #                            Cyber report at the moment (T-1).
        # [cyber_report_t] CyberReport.
        #                  Cyber report at the moment T.
        # [actual_value] Integer.
        #                Measured value at the moment T.
        # [return] Void.
        def forecasting_step(
          cyber_report_t_minus_m,
          cyber_report_t_plus_one_minus_m,
          cyber_report_t_minus_one,
          cyber_report_t,
          actual_value
        )
          moment_a = {} # Moment (T-M).
          moment_b = {} # Moment (T+1-M).
          moment_c = {} # Moment (T-1).
          moment_d = { :actual_value => actual_value } # Moment T.
          data_at_moment_t_minus_m(moment_a, cyber_report_t_minus_m)
          logger.debug("#{self.class.name} - #{__method__} - Moment (T-M) : #{moment_a}.")
          data_at_moment_t_plus_one_minus_m(moment_b, cyber_report_t_plus_one_minus_m)
          logger.debug("#{self.class.name} - #{__method__} - Moment (T+1-M) : #{moment_b}.")
          data_at_moment_t_minus_one(moment_c, cyber_report_t_minus_one)
          logger.debug("#{self.class.name} - #{__method__} - Moment (T-1) : #{moment_c}.")
          logger.debug("#{self.class.name} - #{__method__} - Moment T, before calculations : #{moment_d}.")
          aberrant_behavior_at_moment_t(moment_c, moment_d)
          baseline_at_moment_t(moment_a, moment_c, moment_d)
          linear_trend_at_moment_t(moment_c, moment_d)
          seasonal_trend_at_moment_t(moment_a, moment_d)
          estimated_value_for_moment_t(moment_b, moment_d)
          weighted_avg_abs_deviation_for_moment_t(moment_a, moment_c, moment_d)
          confidence_band_upper_value_at_moment_t(moment_a, moment_c, moment_d)
          logger.debug("#{self.class.name} - #{__method__} - Moment T, after calculations : #{moment_d}.")
          update_cyber_report_with_calculations(cyber_report_t, moment_d)
        end

        private

        def data_at_moment_t_minus_one(moment, cyber_report)
          moment[:baseline] = baseline(cyber_report)
          moment[:linear_trend] = linear_trend(cyber_report)
          moment[:estimated_value] = estimated_value(cyber_report)
          moment[:confidence_band_upper_value] = confidence_band_upper_value(cyber_report)
        end

        def data_at_moment_t_minus_m(moment, cyber_report)
          moment[:seasonal_trend] = seasonal_trend(cyber_report)
          moment[:weight_avg_abs_deviation] = weighted_avg_abs_deviation(cyber_report)
        end

        def data_at_moment_t_plus_one_minus_m(moment, cyber_report)
          moment[:seasonal_trend] = seasonal_trend(cyber_report)
        end

        def aberrant_behavior_at_moment_t(moment_c, moment_d)
          moment_d[:aberrant_behavior] = Algorithms::HoltWintersForecasting::Api.instance.aberrant_behavior(
            moment_d[:actual_value],
            moment_c[:confidence_band_upper_value]
          )
        end

        def baseline_at_moment_t(moment_a, moment_c, moment_d)
          moment_d[:baseline] = Algorithms::HoltWintersForecasting::Api.instance.baseline(
            moment_d[:actual_value],
            moment_a[:seasonal_trend],
            moment_c[:baseline],
            moment_c[:linear_trend]
          )
        end

        def linear_trend_at_moment_t(moment_c, moment_d)
          moment_d[:linear_trend] = Algorithms::HoltWintersForecasting::Api.instance.linear_trend(
            moment_d[:baseline],
            moment_c[:baseline],
            moment_c[:linear_trend]
          )
        end

        def seasonal_trend_at_moment_t(moment_a, moment_d)
          moment_d[:seasonal_trend] = Algorithms::HoltWintersForecasting::Api.instance.seasonal_trend(
            moment_d[:actual_value],
            moment_d[:baseline],
            moment_a[:seasonal_trend]
          )
        end

        def confidence_band_upper_value_at_moment_t(moment_a, moment_c, moment_d)
          return moment_d[:confidence_band_upper_value] = moment_d[:estimated_value] unless moment_c[:estimated_value]

          hw_forecasting_api = Algorithms::HoltWintersForecasting::Api.instance
          moment_d[:confidence_band_upper_value] = hw_forecasting_api.confidence_band_upper_value(
            moment_c[:estimated_value],
            moment_a[:weighted_avg_abs_deviation]
          )
        end

        def weighted_avg_abs_deviation_for_moment_t(moment_a, moment_c, moment_d)
          hw_forecasting_api = Algorithms::HoltWintersForecasting::Api.instance
          moment_d[:weighted_avg_abs_deviation] = hw_forecasting_api.weighted_avg_abs_deviation(
            moment_d[:actual_value],
            moment_c[:estimated_value],
            moment_a[:weighted_avg_abs_deviation]
          )
        end

        def estimated_value_for_moment_t(moment_b, moment_d)
          moment_d[:estimated_value] = Algorithms::HoltWintersForecasting::Api.instance.estimated_value(
            moment_d[:baseline],
            moment_d[:linear_trend],
            moment_b[:seasonal_trend]
          )
        end

        def update_cyber_report_with_calculations(report, moment)
          report.actual_value = moment[:actual_value]
          report.baseline = moment[:baseline]
          report.confidence_band_upper_value = moment[:confidence_band_upper_value]
          report.estimated_value = moment[:estimated_value]
          report.aberrant_behavior = moment[:aberrant_behavior]
          report.linear_trend = moment[:linear_trend]
          report.seasonal_trend = moment[:seasonal_trend]
          report.weighted_avg_abs_deviation = moment[:weighted_avg_abs_deviation]
        end

        def baseline(cyber_report)
          return cyber_report.baseline if cyber_report

          nil
        end

        def linear_trend(cyber_report)
          return cyber_report.linear_trend if cyber_report

          nil
        end

        def estimated_value(cyber_report)
          return cyber_report.estimated_value if cyber_report

          nil
        end

        def confidence_band_upper_value(cyber_report)
          return cyber_report.confidence_band_upper_value if cyber_report

          nil
        end

        def seasonal_trend(cyber_report)
          return cyber_report.seasonal_trend if cyber_report

          nil
        end

        def weighted_avg_abs_deviation(cyber_report)
          return cyber_report.weighted_avg_abs_deviation if cyber_report

          nil
        end
      end
    end
  end
end