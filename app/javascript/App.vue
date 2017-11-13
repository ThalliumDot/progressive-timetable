<template>
  <v-app>
    <router-view></router-view>
  </v-app>
</template>

<script>
  import Vue         from 'vue'
  import Vuetify     from 'vuetify'
  import VueResource from 'vue-resource'

  Vue.use(Vuetify)
  Vue.use(VueResource)


  export default {
    name: 'app'
  }
</script>
