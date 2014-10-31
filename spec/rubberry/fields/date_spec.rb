require 'spec_helper'

DATE_FORMATS = Rubberry::Fields::Date::DATE_FORMATS
FORMATS = Rubberry::Fields::Date::FORMATS
FORMATED_DATES = {
  basic_date: '20141029',
  basic_date_time: '20141029T153005.123+0700',
  basic_date_time_no_millis: '20141029T153005+0700',
  basic_ordinal_date: '2014302',
  basic_ordinal_date_time: '2014302T153005.123+0700',
  basic_ordinal_date_time_no_millis: '2014302T153005+0700',
  basic_time: '153005.123+0700',
  basic_time_no_millis: '153005+0700',
  basic_t_time: 'T153005.123+0700',
  basic_t_time_no_millis: 'T153005+0700',
  basic_week_date: '2014W433',
  basic_week_date_time: '2014W433T153005.123+0700',
  basic_week_date_time_no_millis: '2014W433T153005+0700',
  date: '2014-10-29',
  date_hour: '2014-10-29T15',
  date_hour_minute: '2014-10-29T1530',
  date_hour_minute_second: '2014-10-29T153005',
  date_hour_minute_second_fraction: '2014-10-29T153005.123',
  date_hour_minute_second_millis: '2014-10-29T153005.123',
  date_optional_time: '2014-10-29T15:30:05.123',
  date_time: '2014-10-29T15:30:05.123+07:00',
  date_time_no_millis: '2014-10-29T15:30:05+07:00',
  hour: '15',
  hour_minute: '1530',
  hour_minute_second: '153005',
  hour_minute_second_fraction: '15:30:05.123',
  hour_minute_second_millis: '15:30:05.123',
  ordinal_date: '2014-302',
  ordinal_date_time: '2014-302T15:30:05.123+07:00',
  ordinal_date_time_no_millis: '2014-302T15:30:05+07:00',
  time: '15:30:05.123+07:00',
  time_no_millis: '15:30:05+07:00',
  t_time: 'T15:30:05.123+07:00',
  t_time_no_millis: 'T15:30:05+07:00',
  week_date: '2014-W43-3',
  week_date_time: '2014-W43-3T15:30:05.123+07:00',
  weekDateTimeNoMillis: '2014-W43-3T15:30:05+07:00',
  week_year: '2014',
  weekyearWeek: '2014-W43',
  weekyearWeekDay: '2014-W43-3',
  year: '2014',
  year_month: '2014-10',
  year_month_day: '2014-10-29'
}.stringify_keys

describe Rubberry::Fields::Date do
  let(:format_name){ nil }
  let(:options){ { type: 'date', format: format_name } }

  subject{ build_field(:name, options) }

  describe '#type_cast' do
    let(:date){ Date.parse('2014-10-29') }
    let(:datetime){ DateTime.parse('2014-10-29T15:30:05.123+07:00') }

    context 'with invalid format' do
      let(:format_name){ 'date' }
      let(:format){ '%H:%M:%S.%L%:z' }
      let(:value){ '15:30:05.123+07:00' }

      specify{ expect{ subject.type_cast(value) }.to raise_error(
        Rubberry::DateTimeFormatError,
        "Value '15:30:05.123+07:00' has invalid date format. Format: date(%Y-%m-%d)"
      ) }
    end

    (FORMATS.keys - DATE_FORMATS).each do |name|
      context "with time value for #{name} (#{FORMATS[name]}) format" do
        let(:format_name){ name }
        let(:value){ Time.parse('2014-10-29T15:30:05.123+07:00') }
        specify{ expect(subject.type_cast(value)).to eq(value.to_datetime) }
      end

      context "with datetime value for #{name} (#{FORMATS[name]}) format" do
        let(:format_name){ name }
        let(:value){ DateTime.parse('2014-10-29T15:30:05.123+07:00') }
        specify{ expect(subject.type_cast(value)).to eq(value.to_datetime) }
      end

      context "with date value for #{name} (#{FORMATS[name]}) format" do
        let(:format_name){ name }
        let(:value){ Date.parse('2014-10-29') }
        specify{ expect(subject.type_cast(value)).to eq(value.to_datetime) }
      end

      context "with #{FORMATED_DATES[name]} value for #{name} (#{FORMATS[name]}) format" do
        let(:format_name){ name }
        let(:format){ FORMATS[name] }
        let(:value){ FORMATED_DATES[name] }
        let(:result){ DateTime.strptime(value, format) }

        specify{ expect(subject.type_cast(value)).to eq(result) }
      end
    end

    DATE_FORMATS.each do |name|
      context "with time value for #{name} (#{FORMATS[name]}) format" do
        let(:format_name){ name }
        let(:value){ Time.parse('2014-10-29T15:30:05.123+07:00') }
        specify{ expect(subject.type_cast(value)).to eq(value.to_date) }
      end

      context "with datetime value for #{name} (#{FORMATS[name]}) format" do
        let(:format_name){ name }
        let(:value){ DateTime.parse('2014-10-29T15:30:05.123+07:00') }
        specify{ expect(subject.type_cast(value)).to eq(value.to_date) }
      end

      context "with date value for #{name} (#{FORMATS[name]}) format" do
        let(:format_name){ name }
        let(:value){ Date.parse('2014-10-29') }
        specify{ expect(subject.type_cast(value)).to eq(value.to_date) }
      end

      context "with #{FORMATED_DATES[name]} value for #{name} (#{FORMATS[name]}) format" do
        let(:format_name){ name }
        let(:format){ FORMATS[name] }
        let(:value){ FORMATED_DATES[name] }
        let(:result){ Date.strptime(value, format) }

        specify{ expect(subject.type_cast(value)).to eq(result) }
      end
    end
  end

  describe '#elasticize' do

  end
end
