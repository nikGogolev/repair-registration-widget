<template>
  <div class="modal_backdrop">
    <div class="modal">
      <header class="modal_header">Вы записаны!</header>
      <div class="modal_text">
        {{ messageText }}
      </div>
      <button type="button" class="btn_close" @click="$emit('close')">
        Close
      </button>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent } from "@vue/runtime-core";

export default defineComponent({
  name: "ErrorModal",
  props: { messageText: { type: String, required: true } },
  emits: ["close"],
});
</script>

<style>
.modal_backdrop {
  position: absolute;
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  background-color: rgba(0, 0, 0, 0.3);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}
.modal {
  background: #ffffff;
  box-shadow: 2px 2px 20px 1px;
  overflow-x: auto;
  display: flex;
  flex-direction: column;
  max-width: 60%;
}
.modal_header {
  padding: 15px;
  display: flex;
  border-bottom: 1px solid #eeeeee;
  color: darkgreen;
  justify-content: space-between;
}
.modal_text {
  padding: 10px;
  margin: 0;
}

.btn_close {
  color: white;
  background: darkgreen;
  border: 1px solid darkgreen;
  border-radius: 2px;
  cursor: pointer;
}
</style>
