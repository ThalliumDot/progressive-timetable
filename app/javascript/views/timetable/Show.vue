<template>
<main>

  <v-container fluid class="px-0">
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
              <div class="lesson lecture">
                <h5 class="text-xs-center lesson__time">8:00 - 9:35</h5>
                <h6>ДПКСМ</h6>
                <p class="mb-2">ауд. 419</p>
                <p class="mb-2">Степанов М.М.</p>
              </div>

              <div class="lesson practice">
                <h5 class="text-xs-center lesson__time">9:45 - 11:20</h5>
                <h6>ДПКСМ</h6>
                <p class="mb-2">ауд. 404</p>
                <p class="mb-2">Лосєв М.О.</p>
              </div>

              <div class="lesson laboratory">
                <h5 class="text-xs-center lesson__time">11:45 - 13:20</h5>
                <h6>ПКСМ-14</h6>
                <p class="mb-2">ауд. 404</p>
                <p class="mb-2">Степанов М.М.</p>
              </div>
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
          border-image: linear-gradient(to bottom, rgba(0, 0, 0, 0.1) 80%, rgba(0, 0, 0, 0)) 1 100%;
        }

        color: rgba(0, 0, 0, 0.25);

        .lessons {
          padding: 0 10px;
          margin-top: 50px;

          .lesson {
            position: relative;
            margin-top: 30px;

            /*&:after {
              content: '';
              position: absolute;
              width: 0;
              height: 0;
              border-left: 10px solid transparent;
              border-right: 10px solid transparent;
              border-bottom: 10px solid black;
              top: -1px;
              right: -6px;
              transform: rotate(45deg);
            }*/

            .lesson__time {
              border-radius: 30px;
              color: #fff;
            }

            &.lecture{
              /*&:after { border-bottom: 10px solid #ff9b00; }*/
              .lesson__time {
                background-color: #ffb440;
              }
            }
            &.practice{
              /*&:after { border-bottom: 10px solid #58b729; }*/
              .lesson__time {
                background-color: #5ac572;
              }
            }
            &.laboratory{
              /*&:after { border-bottom: 10px solid #00aaff; }*/
              .lesson__time {
                background-color: #43c0ff;
              }
            }
          }
        }
      }
    }
  }
</style>
