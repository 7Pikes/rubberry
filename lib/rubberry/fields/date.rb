module Rubberry
  module Fields
    class Date < Base
      FORMATS = {
        # A basic formatter for a full date as four digit year, two digit month of year,
        # and two digit day of month (yyyyMMdd).
        basic_date: '%Y%m%d',
        # A basic formatter that combines a basic date and time, separated by a T (yyyyMMdd’T'HHmmss.SSSZ).
        basic_date_time: '%Y%m%dT%H%M%S.%L%z',
        # A basic formatter that combines a basic date and time without millis, separated by a T (yyyyMMdd’T'HHmmssZ).
        basic_date_time_no_millis: '%Y%m%dT%H%M%S%z',
        # A formatter for a full ordinal date, using a four digit year and three digit dayOfYear (yyyyDDD).
        basic_ordinal_date: '%Y%j',
        # A formatter for a full ordinal date and time, using a four digit year and
        # three digit dayOfYear (yyyyDDD’T'HHmmss.SSSZ).
        basic_ordinal_date_time: '%Y%jT%H%M%S.%L%z',
        # A formatter for a full ordinal date and time without millis, using a four digit year and
        # three digit dayOfYear (yyyyDDD’T'HHmmssZ).
        basic_ordinal_date_time_no_millis: '%Y%jT%H%M%S%z',
        # A basic formatter for a two digit hour of day, two digit minute of hour, two digit second of minute,
        # three digit millis, and time zone offset (HHmmss.SSSZ).
        basic_time: '%H%M%S.%L%z',
        # A basic formatter for a two digit hour of day, two digit minute of hour, two digit second of minute,
        # and time zone offset (HHmmssZ).
        basic_time_no_millis: '%H%M%S%z',
        # A basic formatter for a two digit hour of day, two digit minute of hour, two digit second of minute,
        # three digit millis, and time zone off set prefixed by T ('T’HHmmss.SSSZ).
        basic_t_time: 'T%H%M%S.%L%z',
        # A basic formatter for a two digit hour of day, two digit minute of hour, two digit second of minute,
        # and time zone offset prefixed by T ('T’HHmmssZ).
        basic_t_time_no_millis: 'T%H%M%S%z',
        # A basic formatter for a full date as four digit weekyear, two digit week of weekyear,
        # and one digit day of week (xxxx’W'wwe).
        basic_week_date: '%YW%W%u',
        # A basic formatter that combines a basic weekyear date and time, separated by a T (xxxx’W'wwe’T'HHmmss.SSSZ).
        basic_week_date_time: '%YW%W%uT%H%M%S.%L%z',
        # A basic formatter that combines a basic weekyear date and time without millis,
        # separated by a T (xxxx’W'wwe’T'HHmmssZ).
        basic_week_date_time_no_millis: '%YW%W%uT%H%M%S%z',
        # A formatter for a full date as four digit year, two digit month of year,
        # and two digit day of month (yyyy-MM-dd).
        date: '%Y-%m-%d',
        # A formatter that combines a full date and two digit hour of day.
        date_hour: '%Y-%m-%dT%H',
        # A formatter that combines a full date, two digit hour of day, and two digit minute of hour.
        date_hour_minute: '%Y-%m-%dT%H%M',
        # A formatter that combines a full date, two digit hour of day,
        # two digit minute of hour, and two digit second of minute.
        date_hour_minute_second: '%Y-%m-%dT%H%M%S',
        # A formatter that combines a full date, two digit hour of day, two digit minute of hour,
        # two digit second of minute, and three digit fraction of second (yyyy-MM-dd’T'HH:mm:ss.SSS).
        date_hour_minute_second_fraction: '%Y-%m-%dT%H%M%S.%L',
        # A formatter that combines a full date, two digit hour of day, two digit minute of hour,
        # two digit second of minute, and three digit fraction of second (yyyy-MM-dd’T'HH:mm:ss.SSS).
        date_hour_minute_second_millis: '%Y-%m-%dT%H%M%S.%L',
        # A generic ISO datetime parser where the date is mandatory and the time is optional.
        date_optional_time: '%Y-%m-%dT%H:%M:%S.%L',
        # A formatter that combines a full date and time, separated by a T (yyyy-MM-dd’T'HH:mm:ss.SSSZZ).
        date_time: '%Y-%m-%dT%H:%M:%S.%L%:z',
        # A formatter that combines a full date and time without millis, separated by a T (yyyy-MM-dd’T'HH:mm:ssZZ).
        date_time_no_millis: '%Y-%m-%dT%H:%M:%S%:z',
        # A formatter for a two digit hour of day.
        hour: '%H',
        # A formatter for a two digit hour of day and two digit minute of hour.
        hour_minute: '%H%M',
        # A formatter for a two digit hour of day, two digit minute of hour, and two digit second of minute.
        hour_minute_second: '%H%M%S',
        # A formatter for a two digit hour of day, two digit minute of hour, two digit second of minute,
        # and three digit fraction of second (HH:mm:ss.SSS).
        hour_minute_second_fraction: '%H:%M:%S.%L',
        # A formatter for a two digit hour of day, two digit minute of hour, two digit second of minute,
        # and three digit fraction of second (HH:mm:ss.SSS).
        hour_minute_second_millis: '%H:%M:%S.%L',
        # A formatter for a full ordinal date, using a four digit year and three digit dayOfYear (yyyy-DDD).
        ordinal_date: '%Y-%j',
        # A formatter for a full ordinal date and time, using a four digit year and
        # three digit dayOfYear (yyyy-DDD’T'HH:mm:ss.SSSZZ).
        ordinal_date_time: '%Y-%jT%H:%M:%S.%L%:z',
        # A formatter for a full ordinal date and time without millis, using a four digit year and
        # three digit dayOfYear (yyyy-DDD’T'HH:mm:ssZZ).
        ordinal_date_time_no_millis: '%Y-%jT%H:%M:%S%:z',
        # A formatter for a two digit hour of day, two digit minute of hour, two digit second of minute,
        # three digit fraction of second, and time zone offset (HH:mm:ss.SSSZZ).
        time: '%H:%M:%S.%L%:z',
        # A formatter for a two digit hour of day, two digit minute of hour, two digit second of minute,
        # and time zone offset (HH:mm:ssZZ).
        time_no_millis: '%H:%M:%S%:z',
        # A formatter for a two digit hour of day, two digit minute of hour, two digit second of minute,
        # three digit fraction of second, and time zone offset prefixed by T ('T’HH:mm:ss.SSSZZ).
        t_time: 'T%H:%M:%S.%L%:z',
        # A formatter for a two digit hour of day, two digit minute of hour, two digit second of minute,
        # and time zone offset prefixed by T ('T’HH:mm:ssZZ).
        t_time_no_millis: 'T%H:%M:%S%:z',
        # A formatter for a full date as four digit weekyear, two digit week of weekyear,
        # and one digit day of week (xxxx-'W’ww-e).
        week_date: '%Y-W%W-%u',
        # A formatter that combines a full weekyear date and time, separated by a T (xxxx-'W’ww-e’T'HH:mm:ss.SSSZZ).
        week_date_time: '%Y-W%W-%uT%H:%M:%S.%L%:z',
        # A formatter that combines a full weekyear date and time without millis,
        # separated by a T (xxxx-'W’ww-e’T'HH:mm:ssZZ).
        weekDateTimeNoMillis: '%Y-W%W-%uT%H:%M:%S%:z',
        # A formatter for a four digit weekyear.
        week_year: '%Y',
        # A formatter for a four digit weekyear and two digit week of weekyear.
        weekyearWeek: '%Y-W%W',
        # A formatter for a four digit weekyear, two digit week of weekyear, and one digit day of week.
        weekyearWeekDay: '%Y-W%W-%u',
        # A formatter for a four digit year.
        year: '%Y',
        # A formatter for a four digit year and two digit month of year.
        year_month: '%Y-%m',
        # A formatter for a four digit year, two digit month of year, and two digit day of month.
        year_month_day: '%Y-%m-%d'
      }.stringify_keys.freeze

      DATE_FORMATS = %w{basic_date basic_ordinal_date basic_week_date date ordinal_date week_year
        weekyearWeek weekyearWeekDay year year_month year_month_day}

      class ValueProxy < Proxy
        def objectize(value)
          case value
          when ::Time, ::DateTime, ::Date
            (is_date? ? value.to_date : value.to_datetime)
          when ::String
            begin
              (is_date? ? ::Date : ::DateTime).strptime(value, FORMATS[format] || '%Y-%m-%dT%H:%M:%S.%L')
            rescue ::ArgumentError => e
              if e.message =~ /invalid strptime format/
                ::Kernel.raise DateTimeFormatError.new(value, format, FORMATS[format])
              end

              ::Kernel.raise e
            end
          else
            nil
          end
        end

        def elasticize
          return nil unless __target__
          __target__.strftime(FORMATS[format] || '%Y-%m-%dT%H:%M:%S.%L')
        end

        private

        def is_date?
          DATE_FORMATS.include?(format)
        end

        def format
          __field__.options[:format]
        end
      end
    end
  end
end
