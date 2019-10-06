<template>
  <td class="btn-group btn-group-sm">
    <button class="btn" :class="statusName === 'pending' ? 'btn-info' : 'btn-outline-secondary'" :disabled="statusName === 'pending'" @click="pushStatus('pending')">未着手</button>
    <button class="btn" :class="statusName === 'doing' ? 'btn-info' : 'btn-outline-secondary'" :disabled="statusName === 'doing'" @click="pushStatus('doing')">着手中</button>
    <button class="btn" :class="statusName === 'done' ? 'btn-info' : 'btn-outline-secondary'" :disabled="statusName === 'done'" @click="pushStatus('done')">完了</button>
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
    props: ['taskId', 'status'],
    data: function () {
      return {
        statusName: null
      }
    },
    mounted() {
      this.statusName = this.status
    },
    methods: {
      pushStatus(status) {
        const modify = { status: status }
        axiox.patch(`api/tasks/${this.taskId}/status.json`, modify)
          .then(res => {
            this.statusName = status
          })
          .catch(error => {
            console.error('Failed to parsing', error)
          })
      }
    }
  }
</script>

<style scoped>
</style>
