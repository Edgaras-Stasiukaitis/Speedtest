import Vue from 'vue'
import App from './App.vue'
import axios from 'axios';
import Antd from 'ant-design-vue';
import 'ant-design-vue/dist/antd.css';
import VueTimers from 'vue-timers'

window.axios = axios;
Vue.use(Antd);
Vue.use(VueTimers)

new Vue({
  el: '#app',
  render: h => h(App),
  methods: {
  }
})
