import TurbolinksAdapter from 'vue-turbolinks'
import Vue from 'vue/dist/vue.esm'
import TaskStatus from '../task_status.vue'

Vue.use(TurbolinksAdapter)

document.addEventListener('turbolinks:load', () => {
  const taskStatuses = document.querySelectorAll('.js-task-status')
  if (taskStatuses) {
    for (let i = 0; i < taskStatuses.length; i++) {
      let taskStatus = taskStatuses[i]

      const taskId = taskStatus.getAttribute('data-task-id')
      const status = taskStatus.getAttribute('data-status')
      new Vue({
        render: h => h(TaskStatus, { props: { taskId: taskId, status: status } })
      }).$mount('.js-task-status')
    }
  }
})
