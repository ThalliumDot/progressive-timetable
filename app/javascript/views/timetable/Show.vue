<template>
<main>

  <v-container fluid class="px-0 pt-0">
    <v-layout row wrap>
      <Calendar
        ref="calendar"
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

            <h5 class="text-xs-center">{{ dayNames[i - 1] }}</h5>

            <div class="lessons">
              <v-card
                ripple
                hover
                class="lesson"
              >
                <v-card-media
                  class="lecture"
                >
                  <p class="subheading text-xs-center lesson__time">8:00 - 9:35</p>
                </v-card-media>

                <v-card-title>
                  <p class="subheading">ДПКСМ</p>
                  <p class="mb-2">ауд. 419</p>
                  <p class="mb-2">Степанов М.М.</p>
                </v-card-title>
              </v-card>

              <v-card
                ripple
                hover
                class="lesson"
              >
                <v-card-media
                  class="practice"
                >
                  <p class="subheading text-xs-center lesson__time">9:45 - 11:20</p>
                </v-card-media>

                <v-card-title>
                  <p class="subheading">ДПКСМ</p>
                  <p class="mb-2">ауд. 404</p>
                  <p class="mb-2">Лосєв М.О.</p>
                </v-card-title>
              </v-card>

              <v-card
                ripple
                hover
                class="lesson"
              >
                <v-card-media
                  class="laboratory"
                >
                  <p class="subheading text-xs-center lesson__time">11:45 - 13:20</p>
                </v-card-media>

                <v-card-title>
                  <p class="subheading">ПКСМ-14</p>
                  <p class="mb-2">ауд. 404</p>
                  <p class="mb-2">Степанов М.М.</p>
                </v-card-title>
              </v-card>
            </div>
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
        dayNames: [],
      }
    },

    mounted() {
      this.dayNames = this.$refs.calendar.dayNames
    },

    methods: {
      displayWeekSchedule(val) {
        this.week = val
      }
    },
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

        .lessons {
          padding: 0 5px;
          margin-top: 50px;

          .lesson {
            position: relative;
            margin-top: 16px;

            .lecture{
              background: linear-gradient(to right, #ffd400, #ffb440);
            }
            .practice{
              background: linear-gradient(to right, #00d81b, #5ac572);
            }
            .laboratory{
              background: linear-gradient(to right, #00adff, #0089ff);
            }

            .lesson__time {
              margin: 0 5px;
              color: #fff;
            }

            p, h6, h5, h4, h3, h2, h1 {
              width: 100%;
            }
          }
        }
      }
    }
  }
</style>
