<template>
<div class="calendar-container">

  <table class="calendar-container__body">
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
    <tr v-for="week in currentMonthDates">
      <td v-for="weekDay in week">{{ weekDay }}</td>
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
        dateNow: '',
        month:   '',
        day:     '',
        year:    '',

        ready: false,
      }
    },

    mounted() {
      this.dateNow = new Date()
      this.month   = this.dateNow.getMonth()
      this.day     = this.dateNow.getDate()
      this.year    = this.dateNow.getFullYear()

      this.ready = true
    },

    methods: {

    },

    computed: {
      currentMonthDates() {
        if (!this.ready) { return }

        const firstDay = new Date(this.year, this.month)
        let dates = []

        for (let i = 0; i < this.daysPerMonth[firstDay.getMonth()]; i++) {
          dates.push(i + 1)
        }

        // this manipulations needed because in JS week starts from Sunday
        let dayIndex = firstDay.getDay()

        if (dayIndex === 0) {
          dayIndex = 6
        }
        else if (dayIndex === 6) {
          dayIndex = 0
        }

        // fill with passed dates if month doesn't starts from monday
        let offset = 0,
            index  = dayIndex

        while (dayIndex !== 0) {
          offset++
          dates.unshift(new Date(firstDay.getFullYear(), firstDay.getMonth(), firstDay.getDate() - offset).getDate())
          dayIndex--
        }

        // fill with future dates if month doesn't ends at sunday
        offset = 0
        let daysToFill = (7 - dates.length % 7)

        while (daysToFill !== 0) {
          dates.push(new Date(firstDay.getFullYear(), firstDay.getMonth(), firstDay.getDate() + offset).getDate())
          offset++
          daysToFill--
        }

        const datesGrouped = []
        while (dates.length !== 0) {
          datesGrouped.push(dates.slice(0, 7))
          dates = dates.slice(7)
        }

        return datesGrouped
      },

      nextMonth() { return this.month + 1 },

      prevMonth() { return this.month - 1 },


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
  }
</script>


<style scoped lang="scss" type="text/scss">
  .calendar-container {
    background-color: #3D6181;
    color: #fff;

    td, th {
      text-align: center;
      padding: 5px;
    }

    &__body {
      width: 100%;
    }
  }
</style>
