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
          <div class="timetable-container__row__navbar">
            <v-card class="timetable-navbar">
              <v-card-title>
                <v-layout row wrap>
                  <v-flex sm12>
                    <v-flex sm6 class="pa-2">
                      <v-select
                        :items="faculties"
                        v-model="faculty"
                        label="Faculty"
                        hide-details
                        single-line
                      ></v-select>
                    </v-flex>
                  </v-flex>

                  <v-flex sm12>
                    <v-layout row wrap>
                      <v-flex sm3 class="pa-2">
                        <v-select
                          :items="courses"
                          v-model="course"
                          label="Course"
                          hide-details
                          single-line
                        ></v-select>
                      </v-flex>

                      <v-flex sm3 class="pa-2">
                        <v-select
                          :items="groups"
                          v-model="group"
                          label="Group"
                          single-line
                          autocomplete
                        ></v-select>
                      </v-flex>
                    </v-layout>
                  </v-flex>
                </v-layout>
              </v-card-title>
            </v-card>
          </div>

          <div
            class="timetable-container__row__item"
            v-if="week"
            v-for="i in 7"
          >
            <h4 class="text-xs-center mt-3">{{ week.days[i - 1].date.getDate() }}</h4>

            <h5 class="text-xs-center">{{ dayNames[i - 1] }}</h5>

            <div class="lessons">
              <v-card hover class="lesson">
                <v-card-media class="lesson_lecture">
                  <p class="subheading text-xs-center lesson__time">8:00 - 9:35</p>
                </v-card-media>

                <v-card-title v-ripple @click.stop="dialog = true">
                  <p class="subheading">ДПКСМ</p>
                  <p class="mb-2">ауд. 419</p>
                  <p class="mb-2">Степанов М.М.</p>
                </v-card-title>
              </v-card>

              <v-card hover class="lesson">
                <v-card-media class="lesson_practice">
                  <p class="subheading text-xs-center lesson__time">9:45 - 11:20</p>
                </v-card-media>

                <v-card-title v-ripple @click.stop="dialog = true">
                  <p class="subheading">ДПКСМ</p>
                  <p class="mb-2">ауд. 404</p>
                  <p class="mb-2">Лосєв М.О.</p>
                </v-card-title>
              </v-card>

              <v-card hover class="lesson">
                <v-card-media class="lesson_laboratory">
                  <p class="subheading text-xs-center lesson__time">11:45 - 13:20</p>
                </v-card-media>

                <v-card-title v-ripple @click.stop="dialog = true">
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


  <v-dialog v-model="dialog" max-width="500">
    <v-card class="lesson-dialog">
      <v-card-media class="lesson_laboratory">
        <h6 class="text-xs-center lesson__time mx-1 my-3">9:45 - 11:20</h6>
      </v-card-media>

      <v-card-title class="headline">Супутникові системи зв'язку і навігації</v-card-title>

      <v-card-text>
        <p class="mb-2">аудиторія &ndash; 404</p>
        <p class="mb-2">Махонін Євген Іванович</p>
      </v-card-text>

      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn color="green darken-1" flat="flat" @click.native="dialog = false">Ok</v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>

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
        dialog: false,
        group:  null,
        groups: ["БСД-11", "БСД-12", "БСД-13", "БСД-14", "СЗД-11", "УБД-11", "БСД-21", "БСД-22", "БСД-23", "БСД-24"],
        faculty: null,
        faculties: ["Навчально-науковий інститут захисту інформації", "Факультет Інформаційних технологій", "Факультет Телекомунікацій", "Навчально-науковий інститут менеджменту та підприємництва", "Загальні", "Навчально-науковий інститут заочного та дистанційного навчання", "Навчально-науковий інститут післядипломної освіти", "ННВЦ", "Навчально-науковий інститут гуманітарних та природничих дисциплін"],
        course: null,
        courses: [1, 2, 3, 4, 5]
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
      flex-wrap: wrap;
      height: 100%;

      &__navbar {
        width: 100%;
        z-index: 9;

        .timetable-navbar {
          border-radius: 0;
        }
      }

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

            .lesson__time {
              margin: 0 5px;
              color: #fff;
              cursor: default;
            }

            p, h6, h5, h4, h3, h2, h1 {
              width: 100%;
            }
          }
        }
      }
    }
  }

  .lesson_lecture{
    background: linear-gradient(to right, #ff8100, #ff511d);
  }
  .lesson_practice{
    background: linear-gradient(to right, #0cbd00, #00a056);
  }
  .lesson_laboratory{
    background: linear-gradient(to right, #0095ff, #0072ff);
  }

  .lesson-dialog {
    min-width: 300px;

    .lesson__time {
      width: 100%;
      color: #fff;
    }
  }
</style>
