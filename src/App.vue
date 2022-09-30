<template>
  <Modal v-if="message" @close="message = false" :messageText="messageText" />
  <router-view @message="(messageText: string) => setMessage(messageText)" />
</template>

<script lang="ts">
import { defineComponent } from "vue";
import Modal from "@/components/Modal.vue";

export default defineComponent({
  name: "App",
  components: {
    Modal,
  },
  data() {
    return { message: true, messageText: "" };
  },
  methods: {
    setMessage(messageText: string) {
      this.message = true;
      this.messageText = messageText;
    },
  },
});
</script>

<style>
* {
  box-sizing: border-box;
}
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  max-width: 420px;
  background-color: lightblue;
  border-radius: 20px;
  box-shadow: 5px 5px 10px rgba(0, 0, 0, 0.5);
  position: relative;
}
</style>
