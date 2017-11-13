import Vue    from 'vue'
import Router from 'vue-router'

import { ShowTimetable } from './views/timetable'

Vue.use(Router)

export default new Router({
  mode: 'history',
  scrollBehavior: () => ({ y: 0 }),
  routes: [
    {
      path: '/',
      name: 'ShowTimetable',
      component: ShowTimetable
    }
  ]
})