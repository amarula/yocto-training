<script setup>
import TopBar from '../slidev-theme-amarula/components/TopBar.vue'
import BottomBar from '../slidev-theme-amarula/components/BottomBar.vue'
</script>

<template>
  <div class="slidev-layout slide-root">
    <TopBar v-if="$slots.title">
      <template #pageTitle>
        <slot name="title" />
      </template>
    </TopBar>
    <div class="slide-body">
      <div class="slide-content">
        <slot name="body" />
      </div>
    </div>
    <BottomBar />
  </div>
</template>

<style scoped>
.slide-root {
  position: relative;
  width: 100%;
  height: 100%;
  overflow: hidden;
}

.slide-body {
  position: absolute;
  top: 42px;
  bottom: 22px;
  left: 0;
  right: 0;
  padding: 12px 36px;
  overflow-y: auto;
  overflow-x: hidden;
  display: flex;
  flex-direction: column;
}

/* Auto margins center short content and collapse to 0 when it overflows,
   so dense slides start at the top instead of being clipped. */
.slide-content {
  width: 100%;
  margin-block: auto;
}
</style>
