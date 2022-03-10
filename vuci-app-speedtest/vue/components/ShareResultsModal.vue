<template>
  <div>
    <a-modal
      title="Data Collection Notice"
      :visible="visible"
      @cancel="handleCancel"
    >
      <p>{{ ModalText }}</p>
      <template slot="footer">
        <a-button key="decline" type="danger" @click="handleDecline" ghost>
          Decline
        </a-button>
        <a-button key="accept" type="primary" @click="handleAccept">
          Accept
        </a-button>
      </template>
    </a-modal>
  </div>
</template>
<script>
export default {
  props: ['value'],
  data () {
    return {
      ModalText: 'By clicking “Accept”, you agree to sharing your personal and measured traffic information for further examination.',
      visible: false
    }
  },
  watch: {
    value: function (newVal, oldVal) {
      if (newVal === '0' || newVal == null) this.visible = true
    }
  },
  methods: {
    handleAccept () {
      this.visible = false
      this.$emit('valueChange', '1')
    },
    handleDecline () {
      this.visible = false
      this.$emit('valueChange', '-1')
    },
    handleCancel () {
      this.visible = false
      this.$emit('valueChange', '0')
    }
  }
}
</script>
