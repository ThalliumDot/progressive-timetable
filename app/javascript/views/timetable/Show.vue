<template>
<main>

  <v-container fluid class="px-0">
    <v-layout row wrap>
      <calendar></calendar>
      <v-flex xs12 class="timetable-container">
        <v-card dark flat>
          <v-card-text></v-card-text>
        </v-card>
      </v-flex>
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
        message: 'hello!'
      }
    }
  }
</script>


<style scoped land="scss" type="text/scss">
  .timetable-container {
    flex-basis: 0;
    & > .card {
      border-radius: 0;
      height: 100% !important;
    }
  }
</style>
