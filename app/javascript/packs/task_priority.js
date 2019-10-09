import TurbolinksAdapter from 'vue-turbolinks'
import Vue from 'vue/dist/vue.esm'
import TaskPriority from '../task_priority.vue'

Vue.use(TurbolinksAdapter)

document.addEventListener('turbolinks:load', () => {
  const taskPriorities = document.querySelectorAll('.js-task-priority')
  if (taskPriorities) {
    for (let i = 0; i < taskPriorities.length; i++) {
      let taskPriority = taskPriorities[i]

      const taskId = taskPriority.getAttribute('data-task-id')
      const priority = taskPriority.getAttribute('data-priority')
      new Vue({
        render: h => h(TaskPriority, { props: { taskId: taskId, priority: priority } })
      }).$mount('.js-task-priority')
    }
  }
})
