<template>
  <div>
    <a-button size="large" :loading="showStatus" @click="showModal">
      SELECT SERVER
    </a-button>
    <a-modal v-model="visible" title="Server list" :width="900" :footer="null" centered>
      <div class="search-box">
        <a-space>
          <a-input-search placeholder="Search" style="width: 300px" @input="$emit('search', $event.target.value)"/>
          <a-button type="primary" @click="getOptimal">
            Optimal server
          </a-button>
        </a-space>
      </div>
      <a-table :columns="columns" :data-source="servers" rowKey="id" :customRow="handleClick"/>
    </a-modal>
  </div>
</template>

<script>
const columns = [
  {
    title: 'Country',
    dataIndex: 'country',
    key: 'country',
    width: 250
  },
  {
    title: 'City',
    dataIndex: 'city',
    key: 'city',
    width: 250
  },
  {
    title: 'Server',
    dataIndex: 'host',
    key: 'server'
  }
]
export default {
  props: ['servers', 'showStatus'],
  data () {
    return {
      columns,
      visible: false
    }
  },
  methods: {
    showModal () {
      if (this.servers.length === 0) {
        this.$emit('getServers')
        this.waitFor((_) => this.servers.length !== 0)
          .then((_) => (this.visible = true))
        return
      }
      this.visible = true
    },
    handleClick (record) {
      return {
        on: {
          click: event => {
            this.$emit('serverSelected', record)
            this.visible = false
          }
        }
      }
    },
    getOptimal () {
      this.$emit('getOptimal')
      this.visible = false
    },
    waitFor (conditionFunction) {
      const poll = (resolve) => {
        if (conditionFunction()) resolve()
        else setTimeout((_) => poll(resolve), 400)
      }
      return new Promise(poll)
    }
  }
}
</script>

<style>
.search-box {
  margin-bottom: 10px;
}
</style>
