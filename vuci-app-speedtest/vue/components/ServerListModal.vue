<template>
  <div>
    <a-button size="large" :loading="showStatus" @click="showModal">
      SELECT SERVER
    </a-button>
    <a-modal v-model="visible" title="Server list" :width="900" :footer="null" @cancel="clicked=false" centered>
      <div class="search-box">
        <a-space>
          <a-input-search placeholder="Search" style="width: 300px" @input="$emit('search', $event.target.value)"/>
          <a-button type="primary" @click="getOptimal">
            Optimal server
          </a-button>
        </a-space>
      </div>
      <a-table :columns="columns" :data-source="servers" :row-key="record => record.id" :customRow="handleClick"/>
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
      visible: false,
      clicked: false
    }
  },
  watch: {
    servers: function () {
      if (this.clicked) this.visible = true
    }
  },
  methods: {
    showModal () {
      this.clicked = true
      if (this.servers.length === 0) this.$emit('getServers')
      else this.visible = true
    },
    handleClick (record) {
      return {
        on: {
          click: event => {
            this.$emit('serverSelected', record)
            this.visible = false
            this.clicked = false
          }
        }
      }
    },
    getOptimal () {
      this.$emit('getOptimal')
      this.visible = false
      this.clicked = false
    }
  }
}
</script>

<style>
.search-box {
  margin-bottom: 10px;
}
</style>
