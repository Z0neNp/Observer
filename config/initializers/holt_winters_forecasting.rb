# frozen_string_literal: true

require(Rails.root.join('lib', 'algorithms', 'holt_winters_forecasting', 'api.rb'))
require(Rails.root.join('lib', 'algorithms', 'holt_winters_forecasting', 'services', 'icmp_flood.rb'))
require(Rails.root.join('lib', 'algorithms', 'holt_winters_forecasting', 'services', 'validation.rb'))
##
# Our algorithm is in a lib - unaware of inside logic of an app.
# Hence, intialization of necessary constants, i.e. smoothing constants, is done here.
# This is like a "middle ground" where independent parts are aware of themselves for the first time.
Algorithms::HoltWintersForecasting::Services::IcmpFlood.instance.defaults
Algorithms::HoltWintersForecasting::Services::Validation.instance.defaults
holt_winters_api = Algorithms::HoltWintersForecasting::Api.instance
# Alpha denotes baseline smoothing.
mins_in_an_hour = Dos::DosReport::MINUTES_IN_AN_HOUR
secs_in_a_min = Dos::DosReport::SECONDS_IN_A_MINUTE
interval_between_collections = Dos::DosReport::INTERVAL_BETWEEN_COLLECTIONS_IN_SECONDS
season_duration_in_secs = Dos::DosReport::SEASON_DURATION_IN_SECONDS
holt_winters_api.time_unit_in_seconds(Algorithms::HoltWintersForecasting::ICMP_FLOOD, interval_between_collections)
# A guess : last hour of observations should have 90% of "importance".
holt_winters_api.alpha(0.9, mins_in_an_hour * secs_in_a_min / interval_between_collections)
# Beta denotes linear trend smoothing longer than 1 seasonal cycle.
# A guess: last day observations should not have more than 50% of "importance".
holt_winters_api.beta(0.5, season_duration_in_secs / interval_between_collections)
# Gamma denotes seasonal smoothing.
# A guess : last season should not have more than 50% of "importance".
holt_winters_api.gamma(0.5, season_duration_in_secs / interval_between_collections)
# Teta denotes scaling factor for confidence bands.
# Value close to 2 is chosen when missing true positive is more harmful than getting a false positive.
# Value close to 3 is chosen when getting false positive is more harmful than missing true positive.
holt_winters_api.teta(2)
