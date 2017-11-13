<template>
<div class="calendar-container">

  <div class="calendar-container__switcher">
    <v-btn flat icon color="white" @click="prevMonth">
      <v-icon>chevron_left</v-icon>
    </v-btn>

    <div class="calendar-container__switcher__details">
      <span>{{ monthNames[month] }}</span>
      <span>{{ year }}</span>
    </div>

    <v-btn flat icon color="white" @click="nextMonth">
      <v-icon>chevron_right</v-icon>
    </v-btn>
  </div>

  <div class="calendar-container__divider"></div>

  <table class="calendar-container__body" cellspacing="0">
    <thead>
    <tr>
      <th>{{ dayNames[0][0] }}</th>
      <th>{{ dayNames[1][0] }}</th>
      <th>{{ dayNames[2][0] }}</th>
      <th>{{ dayNames[3][0] }}</th>
      <th>{{ dayNames[4][0] }}</th>
      <th>{{ dayNames[5][0] }}</th>
      <th>{{ dayNames[6][0] }}</th>
    </tr>
    </thead>
    <tbody>
    <tr
      v-for="week in monthDates"
      :class="{ 'selected-week': selectedWeek == week.weekNumber}"
      @click="selectedWeek = week.weekNumber"
    >
      <td
        v-for="weekDay in week.days"
        :class="{
          'current-day': dateNow.toISOString().substring(0, 10) == weekDay.date.toISOString().substring(0, 10) && weekDay.current_month,
          'not-current-month': !weekDay.current_month
        }"
        class="day"
      >
        {{ weekDay.date.getDate() }}
      </td>
    </tr>
    </tbody>
  </table>

</div>
</template>


<script>
  export default {
    name: 'Calendar',
    props: ['serverDate'],

    data() {
      return {
        dateNow:      '',
        month:        '',
        day:          '',
        year:         '',
        selectedWeek: 0,

        ready: false,
      }
    },

    mounted() {
      // add getWeek() function to Date proto
      Date.prototype.getWeek = function() {
        const onejan = new Date(this.getFullYear(), 0, 1);
        const millisecsInDay = 86400000;
        return Math.ceil((((this - onejan) / millisecsInDay) + onejan.getDay() - 1) / 7);
      };

      let now = new Date();

      this.dateNow      = new Date(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate(),  now.getUTCHours(), now.getUTCMinutes(), now.getUTCSeconds())
      this.selectedWeek = this.dateNow.getWeek()
      this.month        = this.dateNow.getMonth()
      this.day          = this.dateNow.getDate()
      this.year         = this.dateNow.getFullYear()

      this.ready = true
    },

    methods: {
      nextMonth() {
        this.month++

        if (this.month > 11) {
          this.month = 0
          this.year++
        }
      },

      prevMonth() {
        this.month--

        if (this.month < 0) {
          this.month = 11
          this.year--
        }
      },
    },

    computed: {
      monthDates() {
        if (!this.ready) { return }

        const firstDay = new Date(Date.UTC(this.year, this.month))
        let dates = []

        for (let i = 0; i < this.daysPerMonth[firstDay.getMonth()]; i++) {
          let day = {
            current_month: true,
            date: new Date(Date.UTC(this.year, this.month, i + 1)),
          }

          dates.push(day)
        }

        // this manipulations needed because in JS week starts from Sunday
        let dayIndex = firstDay.getDay()

        if (dayIndex === 0) {
          dayIndex = 6 - 1
        }
        else if (dayIndex === 6) {
          dayIndex = 0
        }
        else {
          dayIndex--
        }

        // fill with passed dates if month doesn't starts from monday
        let offset = 0

        while (dayIndex !== 0) {
          let day = {
            current_month: false,
            date: new Date(Date.UTC(firstDay.getFullYear(), firstDay.getMonth(), -offset)),
          }

          offset++
          dayIndex--
          dates.unshift(day)
        }

        // fill with future dates if month doesn't ends at sunday
        offset = 1
        let daysToFill = 0
        if (dates.length % 7 !== 0) {
          daysToFill = (7 - dates.length % 7)
        }

        while (daysToFill !== 0) {
          let day = {
            current_month: false,
            date: new Date(Date.UTC(firstDay.getFullYear(), firstDay.getMonth() + 1, offset)),
          }

          dates.push(day)
          offset++
          daysToFill--
        }

        const datesGrouped = []
        while (dates.length !== 0) {
          datesGrouped.push({
            weekNumber: dates[0].date.getWeek(),
            days:       dates.slice(0, 7),
          })

          dates = dates.slice(7)
        }

        return datesGrouped
      },

      monthNames() {
        return [
          "January",
          "February",
          "March",
          "April",
          "May",
          "June",
          "July",
          "August",
          "September",
          "October",
          "November",
          "December",
        ]
      },

      dayNames() {
        return [
          "Monday",
          "Tuesday",
          "Wednesday",
          "Thursday",
          "Friday",
          "Saturday",
          "Sunday",
        ]
      },

      daysPerMonth() {
        return [
          31,
          this._febNumberOfDays,
          31,
          30,
          31,
          30,
          31,
          31,
          30,
          31,
          30,
          31,
        ]
      },

      _febNumberOfDays() {
        if ((this.year%100 !== 0) && (this.year%4 === 0) || (this.year%400 === 0)){
          return 29;
        }
        else {
          return 28;
        }
      },
    },

    watch: {
      selectedWeek(val) {
        this.$emit('weekChanged', this.monthDates.find(w => { return w.weekNumber === val }))
      }
    },
  }
</script>


<style scoped lang="scss" type="text/scss">

  $border-style: 1px solid transparent;


  .calendar-container {
    background: linear-gradient(to bottom, #3B6186, #516270);
    color: #fff;
    padding: 0 15px;

    &__switcher {
      display: flex;
      justify-content: space-between;
      text-transform: uppercase;
      margin: 5px -10px;

      &__details {
        align-self: center;
        word-spacing: 5px;
      }
    }

    &__divider {
      height: 1px;
      background-color: rgba(255, 255, 255, 0.15);
      margin-bottom: 10px;
    }

    &__body {
      width: 100%;
      border-collapse: separate;
      border-spacing: 0 2px;

      td, th {
        text-align: center;
        padding: 10px;
        position: relative;
        width: 40px;
        transition: all .3s;
      }

      td { line-height: 1; }

      tr {
        cursor: pointer;

        td {
          border-top: $border-style;
          border-bottom: $border-style;

          &:first-child {
            border-left: $border-style;
            border-top-left-radius: 20px;
            border-bottom-left-radius: 20px;
          }

          &:last-child {
            border-right: $border-style;
            border-top-right-radius: 20px;
            border-bottom-right-radius: 20px;
          }
        }

        &.selected-week {
          background-color: rgba(185, 185, 185, 0.15);
        }

        &:hover {
          td {
            background-color: rgba(185, 185, 185, 0.15);

            &:first-child {
              border-top-left-radius: 20px;
              border-bottom-left-radius: 20px;
            }

            &:last-child {
              border-top-right-radius: 20px;
              border-bottom-right-radius: 20px;
            }
          }
        }
      }

      .current-day {
        font-weight: 500;

        &:after {
          content: '';
          display: block;
          position: absolute;
          height: 2px;
          background-color: #fff;
          left: 0;
          right: 0;
          bottom: 0;
          margin: 0 12px;
          box-shadow: 0 0 3px 0 #fff;
        }
      }

      .not-current-month {
        color: rgba(255, 255, 255, 0.4)
      }
    }
  }
</style>
