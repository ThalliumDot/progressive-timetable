<template>
  <router-view></router-view>
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
