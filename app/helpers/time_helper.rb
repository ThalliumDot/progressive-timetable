module TimeHelper
  class << self

    def at(unix_time)
      Time.zone.at(unix_time)
    end

    def current_time
      Time.zone.now
    end
    alias_method :c, :current_time


    def parse(str)
      Time.zone.parse(str)
    end
    alias_method :p, :parse


    def week_start(week, year = Time.zone.now.year)
      Date.commercial(year, week.to_i, 1).to_time
    end
    alias_method :ws, :week_start


    def week_end(week, year = Time.zone.now.year)
      Date.commercial(year, week.to_i, 7).to_time
    end
    alias_method :we, :week_end


    def max_week_of_year(year)
      date = Date.new(year)
      date.wday == 4 || date.leap? && date.wday == 3 ? 53 : 52
    end

  end
end
