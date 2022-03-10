<template>
  <div>
    <a-button size="large" @click="handleClick">
      STATS
    </a-button>
    <a-modal v-model="visible" title="Statistics" :width="900" :footer="null" centered>
      <div class="search-box">
        <a-space>
          <a-input-search placeholder="Search" style="width: 300px" @input="search"/>
        </a-space>
      </div>
      <a-table :columns="columns" :data-source="filtered_items" :row-key="record => record.id">
        <template slot="downloadSpeed" slot-scope="text">{{ text.toFixed(2) }}</template>
        <template slot="uploadSpeed" slot-scope="text">{{ text.toFixed(2) }}</template>
        <template slot="date" slot-scope="text">{{ text }}</template>
      </a-table>
    </a-modal>
  </div>
</template>

<script>
import axios from 'axios'

const columns = [
  {
    title: 'Router model',
    dataIndex: 'routerModel'
  },
  {
    title: 'Operating system',
    dataIndex: 'operatingSystem'
  },
  {
    title: 'Provider',
    dataIndex: 'provider'
  },
  {
    title: 'Country',
    dataIndex: 'country'
  },
  {
    title: 'City',
    dataIndex: 'city'
  },
  {
    title: 'Download speed, Mbps',
    dataIndex: 'downloadSpeed',
    scopedSlots: { customRender: 'downloadSpeed' }
  },
  {
    title: 'Upload Speed, Mbps',
    dataIndex: 'uploadSpeed',
    scopedSlots: { customRender: 'uploadSpeed' }
  },
  {
    title: 'Date',
    dataIndex: 'date',
    scopedSlots: { customRender: 'date' }
  }
]
export default {
  data () {
    return {
      columns,
      items: [],
      filtered_items: [],
      visible: false
    }
  },
  methods: {
    handleClick () {
      // axios.get(url)
      //   .then(response => {
      //     this.items = response.data
      //     this.filtered_items = response.data
      //   })
      this.visible = true
    },
    search (value) {
      this.filtered_items = this.items
        .filter((item) =>
          item.routerModel.toLowerCase().includes(value.target.value) ||
          item.operatingSystem.toLowerCase().includes(value.target.value) ||
          item.provider.toLowerCase().includes(value.target.value) ||
          item.country.toLowerCase().includes(value.target.value) ||
          item.city.toLowerCase().includes(value.target.value)
        )
    }
  }
}
</script>

<style>
.search-box {
  margin-bottom: 10px;
}
</style>
