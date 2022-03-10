<template>
  <div class="container">
    <div v-if="connectionStatus === 0">
      <a-spin size="large" />
      <p>Checking connection...</p>
    </div>
    <div v-else-if="connectionStatus === 1">
      <share-results-modal :value="value" @valueChange="handleValueChange"/>
      <div class="test">
        <div class="test-area zoom-in">
          <div class="stats-container">
            <a-row type="flex" justify="center">
              <a-col :span="4">
                <svg xmlns="http://www.w3.org/2000/svg" width="60" height="60" fill="#1890ff" class="bi bi-arrow-down-circle" viewBox="0 0 16 16">
                  <path fill-rule="evenodd" d="M1 8a7 7 0 1 0 14 0A7 7 0 0 0 1 8zm15 0A8 8 0 1 1 0 8a8 8 0 0 1 16 0zM8.5 4.5a.5.5 0 0 0-1 0v5.793L5.354 8.146a.5.5 0 1 0-.708.708l3 3a.5.5 0 0 0 .708 0l3-3a.5.5 0 0 0-.708-.708L8.5 10.293V4.5z"/>
                </svg>
                <div class="stats">
                  <div class="stats-text-header">Download, Mbps</div>
                  <div class="stats-text-stat">{{ downloadSpeed.toFixed(2) }}</div>
                </div>
              </a-col>
              <a-col :span="4">
                <svg xmlns="http://www.w3.org/2000/svg" width="60" height="60" fill="currentColor" class="bi bi-geo-alt" viewBox="0 0 16 16">
                  <path d="M12.166 8.94c-.524 1.062-1.234 2.12-1.96 3.07A31.493 31.493 0 0 1 8 14.58a31.481 31.481 0 0 1-2.206-2.57c-.726-.95-1.436-2.008-1.96-3.07C3.304 7.867 3 6.862 3 6a5 5 0 0 1 10 0c0 .862-.305 1.867-.834 2.94zM8 16s6-5.686 6-10A6 6 0 0 0 2 6c0 4.314 6 10 6 10z"/>
                  <path d="M8 8a2 2 0 1 1 0-4 2 2 0 0 1 0 4zm0 1a3 3 0 1 0 0-6 3 3 0 0 0 0 6z"/>
                </svg>
                <div class="stats">
                  <div class="stats-text-header">IP, Location</div>
                  <div v-if="Object.keys(location).length !== 0" class="stats-text-location"><b>
                    {{ location.connection.ip }} {{location.location.city}}
                  </b></div>
                  <div v-else>-</div>
                </div>
              </a-col>
              <a-col :span="4">
                <svg xmlns="http://www.w3.org/2000/svg" width="60" height="60" fill="#1890ff" class="bi bi-arrow-up-circle" viewBox="0 0 16 16">
                  <path fill-rule="evenodd" d="M1 8a7 7 0 1 0 14 0A7 7 0 0 0 1 8zm15 0A8 8 0 1 1 0 8a8 8 0 0 1 16 0zm-7.5 3.5a.5.5 0 0 1-1 0V5.707L5.354 7.854a.5.5 0 1 1-.708-.708l3-3a.5.5 0 0 1 .708 0l3 3a.5.5 0 0 1-.708.708L8.5 5.707V11.5z"/>
                </svg>
                <div class="stats">
                  <div class="stats-text-header">Upload, Mbps</div>
                  <div class="stats-text-stat">{{ uploadSpeed.toFixed(2) }}</div>
                </div>
              </a-col>
            </a-row>
          </div>
          <div v-if="showStatus" class="status">
            <p>{{ spinnerName }}</p>
          </div>
          <canvas ref="speedGauge" width="1200" height="600"></canvas>
          <div v-if="timers.poolDownload.isRunning" class="action-status blinking">
            <svg xmlns="http://www.w3.org/2000/svg" width="34" height="34" fill="#6060AA" class="bi bi-arrow-down-circle" viewBox="0 0 16 16">
              <path fill-rule="evenodd" d="M1 8a7 7 0 1 0 14 0A7 7 0 0 0 1 8zm15 0A8 8 0 1 1 0 8a8 8 0 0 1 16 0zM8.5 4.5a.5.5 0 0 0-1 0v5.793L5.354 8.146a.5.5 0 1 0-.708.708l3 3a.5.5 0 0 0 .708 0l3-3a.5.5 0 0 0-.708-.708L8.5 10.293V4.5z"/>
            </svg>
          </div>
          <div v-else-if="timers.poolUpload.isRunning" class="action-status blinking">
            <svg xmlns="http://www.w3.org/2000/svg" width="34" height="34" fill="#32a852" class="bi bi-arrow-up-circle" viewBox="0 0 16 16">
              <path fill-rule="evenodd" d="M1 8a7 7 0 1 0 14 0A7 7 0 0 0 1 8zm15 0A8 8 0 1 1 0 8a8 8 0 0 1 16 0zm-7.5 3.5a.5.5 0 0 1-1 0V5.707L5.354 7.854a.5.5 0 1 1-.708-.708l3-3a.5.5 0 0 1 .708 0l3 3a.5.5 0 0 1-.708.708L8.5 5.707V11.5z"/>
            </svg>
          </div>
          <div class="meter-text">{{ speed.toFixed(2) }}</div>
          <div class="unit">Mbps</div>
          <div class="server-text">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" class="bi bi-server" viewBox="0 0 16 16">
              <path d="M1.333 2.667C1.333 1.194 4.318 0 8 0s6.667 1.194 6.667 2.667V4c0 1.473-2.985 2.667-6.667 2.667S1.333 5.473 1.333 4V2.667z"/>
              <path d="M1.333 6.334v3C1.333 10.805 4.318 12 8 12s6.667-1.194 6.667-2.667V6.334a6.51 6.51 0 0 1-1.458.79C11.81 7.684 9.967 8 8 8c-1.966 0-3.809-.317-5.208-.876a6.508 6.508 0 0 1-1.458-.79z"/>
              <path d="M14.667 11.668a6.51 6.51 0 0 1-1.458.789c-1.4.56-3.242.876-5.21.876-1.966 0-3.809-.316-5.208-.876a6.51 6.51 0 0 1-1.458-.79v1.666C1.333 14.806 4.318 16 8 16s6.667-1.194 6.667-2.667v-1.665z"/>
            </svg> Server
            <div v-if="selectedServer !== ''">
              <b>{{ selectedServer.split(':')[0] }}</b>
            </div>
            <div v-else>-</div>
          </div>
        </div>
        <a-space size="large">
          <a-button :type="showStatus ? 'danger' : 'primary'" size="large" @click="startTests">{{ showStatus ? 'STOP' : "START" }}</a-button>
          <server-list-modal
            :servers="filtered_servers"
            :showStatus="showStatus"
            @search="getSearch"
            @getServers="getInitialData"
            @serverSelected="handleServerChange"
            @getOptimal="getOptimalModal"
          />
          <stats-modal/>
        </a-space>
      </div>
    </div>
    <div v-else-if="connectionStatus === -1">
      NO INTERNET CONNECTION!
    </div>
  </div>
</template>

<script>
import ServerListModal from './components/ServerListModal.vue'
import ShareResultsModal from './components/ShareResultsModal.vue'
import StatsModal from './components/StatsModal.vue'
import axios from 'axios'

export default {
  components: {
    ServerListModal,
    ShareResultsModal,
    StatsModal
  },
  data () {
    return {
      ctx: null,
      spinnerName: '',
      backgroundColor: '#E0E0E0',
      foregroundColor: '#6060AA',
      textColor: '#9da19e',
      optimalServer: '',
      selectedServer: '',
      value: '',
      location: {},
      systemInfo: [],
      servers: [],
      filtered_servers: [],
      availableServers: [],
      timeouts: [],
      showStatus: false,
      modalOptimal: false,
      checkingConnection: false,
      downloadFinished: false,
      uploadFinished: false,
      connectionStatus: 0,
      speed: 0,
      maxSpeed: 100,
      downloadSpeed: 0,
      uploadSpeed: 0
    }
  },
  timers: {
    update: { time: 100, immediate: true, repeat: true },
    resetMeter: { time: 10, immediate: true, repeat: true },
    poolServers: { time: 1000, immediate: true, repeat: true },
    poolOptimal: { time: 1000, immediate: true, repeat: true },
    poolDownload: { time: 100, immediate: true, repeat: true },
    poolUpload: { time: 100, immediate: true, repeat: true }
  },
  methods: {
    startTests () {
      console.log(this.systemInfo)
      this.downloadFinished = false
      this.uploadFinished = false
      this.$timer.stop('resetMeter')
      this.spinnerName = ''
      if (this.showStatus) {
        for (var i = 0; i < this.timeouts.length; i++) {
          clearTimeout(this.timeouts[i])
        }
        this.$timer.stop('update')
        this.$timer.stop('resetMeter')
        this.$timer.stop('poolServers')
        this.$timer.stop('poolOptimal')
        this.$timer.stop('poolDownload')
        this.$timer.stop('poolUpload')
        this.showStatus = false
        this.killProcesses()
        this.$timer.start('resetMeter')
        return
      }
      this.showStatus = true
      this.downloadSpeed = 0
      this.uploadSpeed = 0
      this.checkConnection('www.google.com')
      this.waitFor(() => this.connectionStatus !== 0 && !this.checkingConnection).then(() => {
        if (this.connectionStatus !== 1) return
        if (this.selectedServer !== '') {
          this.downloadAndUploadSequence()
          return
        }
        if (Object.keys(this.location).length === 0) this.getLocation()
        if (this.servers.length === 0) this.getServers()
        this.waitFor((_) => Object.keys(this.location).length !== 0 && this.servers.length !== 0)
          .then((_) => {
            this.findServers(this.filteredServersByCountry)
            this.waitFor((_) => this.optimalServer !== '')
              .then((_) => {
                this.downloadAndUploadSequence()
              })
          })
      })
    },
    downloadAndUploadSequence () {
      this.foregroundColor = '#6060AA'
      this.downloadTest(this.selectedServer)
      console.log(this.downloadFinished)
      this.waitFor(() => this.downloadFinished).then(() => {
        this.downloadFinished = false
        this.$timer.stop('update')
        this.downloadSpeed = this.speed
        const resetDownload = setTimeout(() => {
          this.$timer.start('resetMeter')
          this.waitFor((_) => !this.timers.resetMeter.isRunning).then(() => {
            this.uploadTest(this.selectedServer)
            this.foregroundColor = '#32a852'
            this.waitFor(() => this.uploadFinished).then(() => {
              this.uploadFinished = false
              this.$timer.stop('update')
              this.uploadSpeed = this.speed
              const resetUpload = setTimeout(() => {
                this.$timer.start('resetMeter')
                this.waitFor(() => !this.timers.resetMeter.isRunning).then(() => {
                  this.showStatus = false
                  this.$message.success('Tests finished!')
                  // if (this.value !== '1') return
                  // this.postResults(url)
                })
              }, 1000)
              this.timeouts.push(resetUpload)
            })
          })
        }, 1000)
        this.timeouts.push(resetDownload)
      })
    },
    getInitialData () {
      if (Object.keys(this.location).length !== 0 || this.servers.length !== 0) return
      this.showStatus = true
      this.getLocation()
      this.getServers()
      this.waitFor((_) => Object.keys(this.location).length !== 0 && this.servers.length !== 0)
        .then((_) => {
          this.showStatus = false
        })
    },
    getSearch (value) {
      if (value == null || value == '') return
      value = value.toLowerCase()
      this.filtered_servers = this.servers
        .filter((server) =>
          server.country.toLowerCase().includes(value) ||
          server.city.toLowerCase().includes(value) ||
          server.host.toLowerCase().includes(value)
        )
    },
    getOptimalModal () {
      this.modalOptimal = true
      this.findServers(this.filteredServersByCountry)
    },
    handleServerChange (value) {
      this.checkConnection(`${value.host.split(':')[0]}/speedtest/random500x500.jpg`, true)
      this.selectedServer = value.host
    },
    update () {
      this.drawMeter(this.$refs.speedGauge, this.normalizedSpeed, 0)
    },
    resetMeter () {
      const decreaser = this.speed > 0 ? Math.log10(this.speed) : 0
      if (this.speed - decreaser > 1.5) this.speed = this.speed - decreaser
      else {
        this.speed = 0
        this.$timer.stop('resetMeter')
      }
      this.drawMeter(this.$refs.speedGauge, this.normalizedSpeed, 0)
    },
    degToRad (degrees) {
      return degrees * (Math.PI / 180)
    },
    initMeter (meterCanvas) {
      this.ctx = meterCanvas.getContext('2d')
      this.ctx.font = '23px Arial'
      this.ctx.textBaseline = 'top'
      this.ctx.fillStyle = this.textColor
      this.ctx.sizScale = meterCanvas.height * 0.0055
      this.ctx.radius = 220
      this.ctx.centerX = meterCanvas.width / 2
      this.ctx.centerY = meterCanvas.height - 58 * this.ctx.sizScale
      this.ctx.lineWidth = 16 * this.ctx.sizScale
      this.drawMeterBase(meterCanvas)
    },
    drawMeter (meterCanvas, amount, progress, prog) {
      this.ctx.clearRect(0, 0, meterCanvas.width, meterCanvas.height)
      this.drawMeterBase(meterCanvas)
      this.ctx.beginPath()
      this.ctx.strokeStyle = this.foregroundColor
      this.ctx.lineWidth = 16 * this.ctx.sizScale
      this.ctx.arc(
        meterCanvas.width / 2,
        meterCanvas.height - 58 * this.ctx.sizScale,
        meterCanvas.height / 1.8 - this.ctx.lineWidth,
        -Math.PI * 1.1,
        amount * Math.PI * 1.2 - Math.PI * 1.1
      )
      this.ctx.stroke()
      if (typeof progress !== 'undefined') {
        this.ctx.fillStyle = prog
        this.ctx.fillRect(
          meterCanvas.width * 0.3,
          meterCanvas.height - 16 * this.ctx.sizScale,
          meterCanvas.width * 0.4 * progress,
          4 * this.ctx.sizScale
        )
      }
    },
    drawMeterBase (meterCanvas) {
      this.ctx.beginPath()
      this.ctx.strokeStyle = this.backgroundColor
      this.ctx.arc(
        this.ctx.centerX,
        this.ctx.centerY,
        meterCanvas.height / 1.8 - this.ctx.lineWidth,
        -Math.PI * 1.1,
        Math.PI * 0.1
      )
      this.ctx.stroke()
      this.drawTextMarkers(meterCanvas)
    },
    drawTextMarkers () {
      var [innerTickX, innerTickY, iTick, iTickToPrint] = [0, 0, 0, 0]
      this.ctx.beginPath()
      for (iTick = -10; iTick < 200; iTick += 40) {
        innerTickX = this.ctx.radius - (Math.cos(this.degToRad(iTick)) * this.ctx.radius)
        innerTickY = this.ctx.radius - (Math.sin(this.degToRad(iTick)) * this.ctx.radius)
        if (iTick) {
          this.ctx.fillText(iTickToPrint, (this.ctx.centerX - this.ctx.radius - 12) + innerTickX, (this.ctx.centerY - this.ctx.radius - 12) + innerTickY + 5)
        } else if (iTick < 50) {
          this.ctx.fillText(iTickToPrint, (this.ctx.centerX - this.ctx.radius - 12) + innerTickX - 5, (this.ctx.centerY - this.ctx.radius - 12) + innerTickY + 5)
        } else if (iTick < 90) {
          this.ctx.fillText(iTickToPrint, (this.ctx.centerX - this.ctx.radius - 12) + innerTickX, (this.ctx.centerY - this.ctx.radius - 12) + innerTickY)
        } else if (iTick === 90) {
          this.ctx.fillText(iTickToPrint, (this.ctx.centerX - this.ctx.radius - 12) + innerTickX + 4, (this.ctx.centerY - this.ctx.radius - 12) + innerTickY)
        } else if (iTick < 145) {
          this.ctx.fillText(iTickToPrint, (this.ctx.centerX - this.ctx.radius - 12) + innerTickX + 10, (this.ctx.centerY - this.ctx.radius - 12) + innerTickY)
        } else {
          this.ctx.fillText(iTickToPrint, (this.ctx.centerX - this.ctx.radius - 12) + innerTickX + 15, (this.ctx.centerY - this.ctx.radius - 12) + innerTickY + 5)
        }
        iTickToPrint += 20
      }
      this.ctx.stroke()
    },
    waitFor (conditionFunction) {
      const poll = (resolve) => {
        if (conditionFunction()) resolve()
        else {
          const timeout = setTimeout((_) => poll(resolve), 400)
          this.timeouts.push(timeout)
        }
      }
      return new Promise(poll)
    },
    checkConnection (server, checkServer = false) {
      this.checkingConnection = true
      this.$rpc.call('speedtestapi', 'check_connection', { server })
        .then((response) => {
          // console.log(response)
          if (checkServer) {
            // if (response.ok) return
            // this.selectedServer = this.servers[0].host
            // this.$message.error('Selected server is currently unavailable (defaulted to first server of the list)')
            return
          }
          response.ok ? this.connectionStatus = 1 : this.connectionStatus = -1
          this.checkingConnection = false
        })
    },
    getIp () {
      this.$rpc.call('speedtestapi', 'get_ip', { })
        .then((response) => console.log(JSON.parse(response)))
    },
    getLocation () {
      this.spinnerName = 'Getting current location...'
      this.$rpc.call('speedtestapi', 'get_location', { })
        .then((response) => {
          // console.log(response)
          this.location = JSON.parse(response.data)
        })
    },
    getServers () {
      this.spinnerName = 'Acquiring server list...'
      this.$rpc.call('speedtestapi', 'get_servers', { })
        .then((response) => {
          // console.log(response.data)
          this.servers = JSON.parse(response.data)
          this.filtered_servers = this.servers
        })
    },
    findServers (servers) {
      if (this.optimalServer !== '') {
        this.selectedServer = this.optimalServer.server
        return
      }
      if (this.modalOptimal) this.showStatus = true
      this.spinnerName = 'Selecting optimal server...'
      this.$rpc.call('speedtestapi', 'find_servers', { servers })
        .then(response => {
          // console.log(response)
          this.$timer.start('poolServers')
        })
    },
    downloadTest (server) {
      this.spinnerName = 'Measuring download speed...'
      this.$rpc.call('speedtestapi', 'test_download', { server })
        .then(response => {
          // console.log(response)
          this.$timer.start('poolDownload')
          this.$timer.start('update')
        })
    },
    uploadTest (server) {
      this.spinnerName = 'Measuring upload speed...'
      this.$rpc.call('speedtestapi', 'test_upload', { server })
        .then(response => {
          // console.log(response)
          this.$timer.start('poolUpload')
          this.$timer.start('update')
        })
    },
    poolServers () {
      this.$rpc.call('speedtestapi', 'pool_servers', { })
        .then(response => {
          if (response.message) {
            this.$timer.stop('poolServers')
            this.$timer.start('poolOptimal')
          } else {
            // console.log(response)
          }
        })
    },
    killProcesses () {
      this.$rpc.call('speedtestapi', 'kill_processes', { })
        .then(response => {
          console.log(response)
        })
    },
    poolOptimal () {
      this.$rpc.call('speedtestapi', 'pool_optimal', { })
        .then(response => {
          if (response.data != null) {
            this.$timer.stop('poolOptimal')
            const data = JSON.parse(response.data)
            this.optimalServer = data[0]
            this.selectedServer = this.optimalServer.server
            this.availableServers = this.filteredServersByCountry.filter(({ host: s1 }) => data.some(({ server: s2 }) => s2 === s1))
            if (this.modalOptimal) {
              this.showStatus = false
              this.modalOptimal = false
            }
          } else {
            console.log(response)
          }
        })
    },
    poolDownload () {
      this.$rpc.call('speedtestapi', 'pool_download', { })
        .then(response => {
          if (response.data != null) {
            // console.log(response.data)
            if (response.data === 'done') {
              this.spinnerName = 'Download speed measurements done!'
              this.$timer.stop('poolDownload')
              this.downloadFinished = true
              return
            } else if (response.data === 'error') {
              this.$message.error('Could not measure download speed')
              this.$timer.stop('poolDownload')
              this.downloadFinished = true
              return
            }
            const num = parseFloat(response.data)
            this.speed = isNaN(num) ? this.downloadSpeed : num
          } else {
            console.log(response)
          }
        })
    },
    poolUpload () {
      this.$rpc.call('speedtestapi', 'pool_upload', { })
        .then(response => {
          if (response.data != null) {
            // console.log(response.data)
            if (response.data === 'done') {
              this.spinnerName = 'Upload speed measurements done!'
              this.$timer.stop('poolUpload')
              this.uploadFinished = true
              return
            } else if (response.data === 'error') {
              this.$message.error('Could not measure upload speed')
              this.$timer.stop('poolUpload')
              this.uploadFinished = true
              return
            }
            const num = parseFloat(response.data)
            this.speed = isNaN(num) ? this.uploadSpeed : num
          } else {
            console.log(response)
          }
        })
    },
    getSystemInfo () {
      this.$rpc.call('speedtestapi', 'get_router_info')
        .then((response) => {
          this.systemInfo.name = response.data[0].name
          this.systemInfo.firmware = response.data[1].firmware
        })
      this.$system.getInfo().then(({ system, release }) => {
        this.systemInfo.system = system
        this.systemInfo.release = release
      })
    },
    getConfigOption (config, section, option) {
      this.$rpc.call('speedtestapi', 'get_config_option', { config, section, option })
        .then(response => (this.value = response.data))
    },
    setConfigOption (config, section, option, value) {
      this.$rpc.call('speedtestapi', 'set_config_option', { config, section, option, value })
        .then(response => {
          console.log(response)
          this.getConfigOption(config, section, option)
        })
    },
    handleValueChange (value) {
      this.setConfigOption('speedtest', 'speedtest', 'share', value)
    },
    postResults (url) {
      const data = {
        routerModel: this.systemInfo.name,
        operatingSystem: `${this.systemInfo.release.distribution} ${this.systemInfo.release.version}`,
        firmware: this.systemInfo.firmware,
        country: this.location.location.country.name,
        city: this.location.location.city,
        provider: this.location.connection.ip,
        downloadSpeed: this.downloadSpeed,
        uploadSpeed: this.uploadSpeed,
        server: this.selectedServer.split(':')[0]
      }
      axios.post(url, data)
        .then(response => console.log(response))
    }
  },
  computed: {
    normalizedSpeed () {
      if (this.speed / this.maxSpeed > 1) return 1
      return this.speed / this.maxSpeed
    },
    filteredServersByCountry () {
      return this.servers.filter((server) => server.country === this.location.location.country.name)
    }
  },
  created () {
    this.checkConnection('www.google.com')
  },
  mounted () {
    this.getConfigOption('speedtest', 'speedtest', 'share')
    this.waitFor((_) => this.connectionStatus === 1)
      .then((_) => {
        this.initMeter(this.$refs.speedGauge)
        this.getSystemInfo()
      })
  }
}
</script>

<style>
.container {
  padding-top: 12em;
  width: 100%;
  text-align: center;
  margin: auto;
}
.test {
  margin-bottom: 4em;
}
.test-area {
  margin: auto;
  width: 80em;
  height: 40em;
}
.stats-container {
  position: absolute;
  bottom: 36em;
  left: 0;
  width: 100%;
}
.status {
  position: absolute;
  bottom: 24.5em;
  left: 0;
  width: 100%;
  font-size: 18px;
  z-index: 9;
}
.action-status {
  position: absolute;
  bottom: 16em;
  left: 0;
  width: 100%;
  font-size: 18px;
  z-index: 9;
}
.meter-text {
  position: absolute;
  bottom: 3.3em;
  left: 0;
  width: 100%;
  font-size: 4em;
  z-index: 9;
}
.unit {
  position: absolute;
  bottom: 8.1em;
  left: 0;
  width: 100%;
  z-index: 9;
  font-size: 1.5em;
}
.server-text {
  position: absolute;
  bottom: 4.5em;
  left: 0;
  width: 100%;
  z-index: 9;
  font-size: 18px;
}
.buttons {
  position: absolute;
  bottom: 5em;
  left: 0;
  width: 100%;
}
.stats > div {
  display: flex;
  flex-direction: column;
  margin: 0px 5px 0px 5px;
}
.stats-text-header {
  font-size: 18px;
}
.stats-text-location {
  font-size: 18px;
  font-weight: bold;
}
.stats-text-stat {
  font-size: 28px;
  font-weight: bold;
}
.test-area canvas {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  margin-top: 1em;
  z-index: 1;
}
.zoom-in {
  animation: 0.75s ease-out 0s 1 zoomIn forwards;
}
.zoom-out {
  animation: 0.5s ease-out 0s 1 zoomOut forwards;
}
.blinking {
  animation: opacity 2s ease-in-out infinite;
  opacity: 1;
}
@keyframes opacity {
  0% {
    opacity: 1;
  }
  50% {
    opacity: 0.25
  }
  100% {
    opacity: 1;
  }
}
@keyframes zoomIn {
  0% {
    transform: scale(0.25);
    opacity: 0%;
  }
  100% {
    transform: scale(1);
    opacity: 100%;
  }
}
@keyframes zoomOut {
  0% {
    transform: scale(1);
    opacity: 100%;
  }
  100% {
    transform: scale(0.25);
    opacity: 0%;
  }
}
@media all and (max-width: 1200px) {
  .test-area {
    margin: auto;
    width: 60em;
    height: 30em;
  }
  .stats-container {
    bottom: 26em;
  }
  .status {
    bottom: 23em;
    font-size: 14px;
  }
  .action-status {
    bottom: 16em;
    font-size: 13px;
  }
  .meter-text {
    bottom: 3.5em;
    font-size: 3em;
  }
  .unit {
    bottom: 8.1em;
    font-size: 1.2em;
  }
  .server-text {
    bottom: 4.5em;
    font-size: 14px;
  }
}
@media all and (max-width: 768px) {
  .test-area {
    margin: auto;
    width: 40em;
    height: 20em;
  }
}
</style>
