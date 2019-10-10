<template>
  <td class="task-name">
    <div v-if="!isEditPriority" @click="isEditPriority = true" id="test-view-priority" class="task-priority-view">
      <span>{{ labels[newPriority ] | noPriority }}</span>
    </div>
    <div v-else>
      <select v-model="newPriority" @change="pushPriority" class="form-control form-control-sm" id="test-select-priority" @blur="isEditPriority = false" v-focus>
        <option v-for="option in options" :key="option.id" :value="option.value">{{ option.label }}</option>
      </select>
    </div>
  </td>
</template>

<script>
  import axiox from 'axios'

  const meta = document.querySelector('meta[name="csrf-token"]')
  axiox.defaults.headers.common = {
    'X-Requested-With': 'XMLHttpRequest',
    'X-CSRF-TOKEN' : meta ? meta.getAttribute('content') : ''
  };

  export default {
    props: ['taskId', 'priority'],
    data: function () {
      return {
        isEditPriority: false,
        newPriority: this.priority,
        options: [
          { id: 1, label: "なし", value: "none" },
          { id: 2, label: "低", value: "low" },
          { id: 3, label: "中", value: "medium" },
          { id: 4, label: "高", value: "high" }
        ]
      }
    },
    mounted() {
      const td = document.querySelector(`#task-${this.taskId} > *:first-child`)
      td.classList.add(`task-priority-${this.priority}`)
    },
    computed: {
      labels() {
        return this.options.reduce(function (a, b) {
          return Object.assign(a, { [b.value]: b.label })
        }, {})
      }
    },
    methods: {
      pushPriority(event) {
        const modify = { priority: event.target.value }
        axiox.patch(`api/tasks/${this.taskId}/priority.json`, modify)
          .then(res => {
            const tdClass = document.querySelector(`#task-${this.taskId} > *:first-child`).classList
            tdClass.remove(`task-priority-${this.priority}`)
            tdClass.add(`task-priority-${event.target.value}`)
            this.isEditPriority = false
          })
          .catch(error => {
            console.log('Failed to parsing', error)
          })
      }
    },
    filters: {
      noPriority(value) {
        if (value !== "なし") return value
        return "-"
      }
    },
    directives: {
      focus: {
        inserted: function (el) {
          el.focus()
        }
      }
    },
  }
</script>

<style scoped>
</style>
