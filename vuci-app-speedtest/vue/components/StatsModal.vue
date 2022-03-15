<template>
  <div>
    <a-button size="large" @click="handleClick" :loading="loading" :disabled="unavailable">
      STATS
    </a-button>
    <a-modal v-model="visible" title="Statistics" :width="1000" :footer="null" centered>
      <div class="search-box">
        <a-input-search placeholder="Search" style="width: 300px" :value="search" @input="handleSearch"/>
      </div>
      <a-table :columns="columns" :data-source="filtered_items.data" :row-key="record => record.id" :pagination="false" @change="handleChange">
        <template slot="downloadSpeed" slot-scope="text">{{ text.toFixed(2) }}</template>
        <template slot="uploadSpeed" slot-scope="text">{{ text.toFixed(2) }}</template>
        <template slot="date" slot-scope="text">{{ `${text.split('T')[0]} ${text.split('T')[1].split(':')[0]}:${text.split('T')[1].split(':')[1]}` }}</template>
      </a-table>
      <div class="pagination">
        <a-pagination v-model="current" :page-size.sync="elements" :total="filtered_items.total" />
      </div>
    </a-modal>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  data () {
    return {
      current: 1,
      elements: 8,
      search: '',
      sort: '',
      sortedInfo: {},
      items: [],
      filtered_items: [],
      loading: false,
      visible: false,
      unavailable: false
    }
  },
  watch: {
    current: function () {
      this.onChange()
    },
    search: function () {
      this.onChange()
    },
    sort: function () {
      this.onChange()
    }
  },
  methods: {
    handleChange (pagination, filters, sorter) {
      this.sortedInfo = sorter
      const key = {
        ascend: 'asc',
        descend: 'desc'
      }
      this.sort = sorter.order != null ? `${sorter.field} ${key[sorter.order]}` : ''
    },
    handleClick () {
      this.loading = true
      this.onChange()
    },
    handleSearch (value) {
      this.search = value.target.value
    },
    onChange () {
      axios.get(`https://networktrafficapi.azurewebsites.net/api/Products?page=${this.current - 1}&elements=${this.elements}&search=${this.search}&sort=${this.sort}`)
        .then(response => {
          this.items = response.data
          this.filtered_items = response.data
          this.visible = true
          this.loading = false
        })
        .catch(_ => {
          this.visible = false
          this.unavailable = true
          this.loading = false
          alert('Remote data server is currently unavailable')
        })
    }
  },
  computed: {
    columns () {
      let { sortedInfo } = this
      sortedInfo = sortedInfo || {}
      const columns = [
        {
          title: 'Router model',
          dataIndex: 'routerModel',
          align: 'center',
          sorter: true,
          sortOrder: sortedInfo.columnKey === 'routerModel' && sortedInfo.order
        },
        {
          title: 'Firmware',
          dataIndex: 'firmware',
          align: 'center',
          sorter: true,
          sortOrder: sortedInfo.columnKey === 'firmware' && sortedInfo.order
        },
        {
          title: 'ISP',
          dataIndex: 'provider',
          align: 'center',
          sorter: true,
          sortOrder: sortedInfo.columnKey === 'provider' && sortedInfo.order
        },
        {
          title: 'Country',
          dataIndex: 'country',
          align: 'center',
          sorter: true,
          sortOrder: sortedInfo.columnKey === 'country' && sortedInfo.order
        },
        {
          title: 'City',
          dataIndex: 'city',
          align: 'center',
          sorter: true,
          sortOrder: sortedInfo.columnKey === 'city' && sortedInfo.order
        },
        {
          title: 'Download, Mbps',
          dataIndex: 'downloadSpeed',
          align: 'center',
          sorter: true,
          sortOrder: sortedInfo.columnKey === 'downloadSpeed' && sortedInfo.order,
          scopedSlots: { customRender: 'downloadSpeed' }
        },
        {
          title: 'Upload, Mbps',
          dataIndex: 'uploadSpeed',
          align: 'center',
          sorter: true,
          sortOrder: sortedInfo.columnKey === 'uploadSpeed' && sortedInfo.order,
          scopedSlots: { customRender: 'uploadSpeed' }
        },
        {
          title: 'Date',
          dataIndex: 'date',
          align: 'center',
          sorter: true,
          width: 150,
          sortOrder: sortedInfo.columnKey === 'date' && sortedInfo.order,
          scopedSlots: { customRender: 'date' }
        }
      ]
      return columns
    }
  }
}
</script>

<style>
.search-box {
  margin-bottom: 10px;
}
.pagination {
  width: 100%;
  text-align: center;
  margin: 20px 0 10px 0;
}
</style>
