<template>
<main>

  <v-container fluid class="px-0">
    <v-layout row wrap>
      <Calendar
        @weekChanged="displayWeekSchedule"
      />
      <div class="timetable-container">
        <div class="timetable-container__row">
          <div
            class="timetable-container__row__item"
            v-if="week"
            v-for="i in 7"
          >
            <h4 class="text-xs-center">{{ week.days[i - 1].date.getDate() }}</h4>
            <h5 class="text-xs-center"></h5>
          </div>
        </div>
      </div>
    </v-layout>
  </v-container>

</main>
</template>


<script>
  import Calendar from '../../components/Calendar'

  export default {
    name: 'ShowTimetable',
    components: { Calendar },

    data() {
      return {
        week: null,
      }
    },

    methods: {
      displayWeekSchedule(val) {
        this.week = val
      }
    }
  }
</script>


<style scoped lang="scss" type="text/scss">
  .timetable-container {
    flex: 1;

    &__row {
      display: flex;
      height: 100%;

      &__item {
        width: 14.285714%;

        &:not(:last-child) {
          border-right: 2px solid #000;
          border-image: linear-gradient(to bottom, rgba(0, 0, 0, 0.1), rgba(0, 0, 0, 0)) 1 100%;
        }

        color: rgba(0, 0, 0, 0.25);
      }
    }
  }
</style>
