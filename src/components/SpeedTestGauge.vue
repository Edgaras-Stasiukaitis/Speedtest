<template>
  <div class="container">
    <div class="test">
      <div
        v-show="showButton"
        class="start-btn start-btn-fill zoom-in"
        :class="{ 'zoom-out disabled': animateButton }"
        @click="startTests"
      >
        <p>START</p>
      </div>
      <div v-show="!showButton" class="test-area zoom-in">
        <div class="test-name">{{ testName }}</div>
        <canvas ref="speedGauge" width="700" height="350"></canvas>
        <div class="meter-text">{{ speed.toFixed(2) }}</div>
        <div class="unit">Mbps</div>
      </div>
    </div>
    <a-table v-if="data.length !== 0" :columns="columns" :data-source="data">
      <!-- <span slot="type" slot-scope="type">
        <a-tag
          :key="type"
          :color="type === 'Download' ? 'purple' : 'green'"
        ></a-tag>
        {{ type }}
      </span> -->
    </a-table>
  </div>
</template>

<script>
const columns = [
  {
    title: 'Type',
    dataIndex: 'type',
    key: 'type'
  },
  {
    title: 'Average speed, Mbps',
    dataIndex: 'avgSpeed',
    key: 'avgSpeed'
  },
  {
    title: 'Maximum speed, Mbps',
    dataIndex: 'maxSpeed',
    key: 'maxSpeed'
  },
  {
    title: 'Minimum speed, Mbps',
    dataIndex: 'minSpeed',
    key: 'minSpeed'
  },
  {
    title: 'Date',
    dataIndex: 'date',
    key: 'date'
  }
]
export default {
  data() {
    return {
      columns,
      ctx: null,
      sizScale: 0,
      testName: 'Download',
      backgroundColor: '#E0E0E0',
      foregroundColor: '#6060AA',
      temp: [],
      data: [],
      showButton: true,
      animateButton: false,
      speed: 0,
      maxSpeed: 0
    }
  },
  timers: {
    update: { time: 100, immediate: true, repeat: true },
    resetMeter: { time: 10, immediate: true, repeat: true }
  },
  methods: {
    startTests() {
      this.testName = 'Download'
      this.foregroundColor = '#6060AA'
      this.animateButton = true
      setTimeout(() => {
        this.showButton = false
        this.animateButton = false
        setTimeout(() => this.$timer.start('update'), 750)
      }, 500)
      setTimeout(() => {
        this.$timer.stop('update')
        this.$timer.start('resetMeter')
        this.addToTable('Download')
        this.waitFor((_) => !this.timers.resetMeter.isRunning).then((_) =>
          setTimeout(() => {
            this.foregroundColor = '#1AAA00'
            this.testName = 'Upload'
            this.$timer.start('update')
            setTimeout(() => {
              this.$timer.stop('update')
              this.$timer.start('resetMeter')
              this.addToTable('Upload')
              this.waitFor((_) => !this.timers.resetMeter.isRunning).then(
                (_) => (this.showButton = true)
              )
            }, 5000)
          }, 750)
        )
      }, 5000)
    },
    update() {
      this.speed =
        Math.floor(Math.random() * (500 * 100 - 1 * 100) + 1 * 100) / (1 * 100)
      if (this.speed > this.maxSpeed) this.maxSpeed = this.speed
      this.drawMeter(this.$refs.speedGauge, this.normalize, 0)
      this.temp.push(this.speed)
    },
    resetMeter() {
      if (this.speed - 1 >= 0) this.speed--
      else {
        this.speed = 0
        this.maxSpeed = 0
        this.$timer.stop('resetMeter')
      }
      this.drawMeter(this.$refs.speedGauge, this.normalize, 0)
    },
    addToTable(type) {
      this.data.push({
        key: this.data.length + 1,
        type,
        avgSpeed: (
          this.temp.reduce((prev, curr) => prev + curr) / this.temp.length
        ).toFixed(2),
        maxSpeed: Math.max(...this.temp),
        minSpeed: Math.min(...this.temp),
        date: new Date().toISOString().replace(/T/, ' ').replace(/\..+/, '')
      })
      this.temp = []
    },
    initMeter(meterCanvas) {
      this.ctx = meterCanvas.getContext('2d')
      // var dp = window.devicePixelRatio || 1
      var cw = meterCanvas.width // meterCanvas.clientWidth * dp
      var ch = meterCanvas.height // meterCanvas.clientHeight * dp
      this.sizScale = ch * 0.0055
      if (meterCanvas.width === cw && meterCanvas.height === ch) {
        this.ctx.clearRect(0, 0, cw, ch)
      }
      // else {
      //   meterCanvas.width = cw
      //   meterCanvas.height = ch
      // }
      this.drawMeterBase(meterCanvas)
    },
    drawMeterBase(meterCanvas) {
      this.ctx.beginPath()
      this.ctx.strokeStyle = this.backgroundColor
      this.ctx.lineWidth = 16 * this.sizScale
      this.ctx.arc(
        meterCanvas.width / 2,
        meterCanvas.height - 58 * this.sizScale,
        meterCanvas.height / 1.8 - this.ctx.lineWidth,
        -Math.PI * 1.1,
        Math.PI * 0.1
      )
      this.ctx.stroke()
    },
    drawMeter(meterCanvas, amount, progress, prog) {
      this.drawMeterBase(meterCanvas)
      this.ctx.beginPath()
      this.ctx.strokeStyle = this.backgroundColor
      this.ctx.lineWidth = 16 * this.sizScale
      this.ctx.arc(
        meterCanvas.width / 2,
        meterCanvas.height - 58 * this.sizScale,
        meterCanvas.height / 1.8 - this.ctx.lineWidth,
        -Math.PI * 1.1,
        Math.PI * 0.1
      )
      this.ctx.stroke()
      this.ctx.beginPath()
      this.ctx.strokeStyle = this.foregroundColor
      this.ctx.lineWidth = 16 * this.sizScale
      this.ctx.arc(
        meterCanvas.width / 2,
        meterCanvas.height - 58 * this.sizScale,
        meterCanvas.height / 1.8 - this.ctx.lineWidth,
        -Math.PI * 1.1,
        amount * Math.PI * 1.2 - Math.PI * 1.1
      )
      this.ctx.stroke()
      if (typeof progress !== 'undefined') {
        this.ctx.fillStyle = prog
        this.ctx.fillRect(
          meterCanvas.width * 0.3,
          meterCanvas.height - 16 * this.sizScale,
          meterCanvas.width * 0.4 * progress,
          4 * this.sizScale
        )
      }
    },
    waitFor(conditionFunction) {
      const poll = (resolve) => {
        if (conditionFunction()) resolve()
        else setTimeout((_) => poll(resolve), 400)
      }

      return new Promise(poll)
    }
  },
  computed: {
    normalize() {
      return this.speed / this.maxSpeed
    }
  },
  mounted() {
    this.initMeter(this.$refs.speedGauge)
  }
}
</script>

<style>
.container {
  padding-top: 7.5em;
  width: 100%;
  text-align: center;
  margin: auto;
}
.test {
  margin-bottom: 4em;
}
.test-area {
  display: inline-block;
  width: 50em;
  height: 25em;
  position: relative;
  box-sizing: border-box;
}
.test-name {
  font-size: 2.5em;
  z-index: 9;
}
.meter-text {
  position: absolute;
  bottom: 1.6em;
  left: 0;
  width: 100%;
  font-size: 4.2em;
  z-index: 9;
}
.unit {
  position: absolute;
  bottom: 3.1em;
  left: 0;
  width: 100%;
  z-index: 9;
  font-size: 1.7em;
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
.start-btn {
  cursor: pointer;
  position: relative;
  display: inline-block;
  width: 200px;
  height: 200px;
  margin-left: 12px;
  margin-right: 12px;
  border-radius: 100px;
  overflow: hidden;
}
.start-btn::before,
.start-btn::after {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  height: 100%;
  width: 100%;
  transition: all 0.2s ease;
  border-radius: 100px;
}
.start-btn p {
  position: relative;
  font-size: 35px;
  margin-top: 70px;
  transition: all 0.2s ease;
}
.start-btn-fill::before {
  transition-duration: 0.5s;
  box-shadow: inset 0 0 0 2px #40a9ff;
}
.start-btn-fill:hover::before {
  box-shadow: inset 0 0 0 100px #40a9ff;
}
.disabled {
  pointer-events: none;
  cursor: default;
}
table tr:nth-child(2n) td {
  background-color: rgb(250, 246, 246);
}
.zoom-in {
  animation: 0.75s ease-out 0s 1 zoomIn forwards;
}
.zoom-out {
  animation: 0.5s ease-out 0s 1 zoomOut forwards;
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
@media all and (max-width: 65em) {
  body {
    font-size: 1.5vw;
  }
}
@media all and (max-width: 40em) {
  body {
    font-size: 0.8em;
  }
}
</style>
