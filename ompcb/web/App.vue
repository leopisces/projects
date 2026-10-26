<template>
  <div class="app-shell">
    <!-- 头部 -->
    <header class="app-header">
      <div class="app-brand">
        <LogoMark class="app-logo" />
        <div class="app-title">OMPCB</div>
      </div>
      <div class="app-title sub">{{ subtitle }}</div>
    </header>

    <!-- 两套台账：BOM 记"这块板要用什么"，库存记"手头实际有什么" -->
    <el-tabs v-model="activeTab" class="app-tabs" @tab-change="onTabChange">
      <el-tab-pane label="BOM 清单" name="bom" lazy>
        <BomPanel @total-change="(n) => (bomTotal = n)" />
      </el-tab-pane>
      <el-tab-pane label="库存台账" name="inventory" lazy>
        <InventoryPanel ref="invRef" @total-change="(n) => (invTotal = n)" />
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import BomPanel from './components/BomPanel.vue'
import InventoryPanel from './components/InventoryPanel.vue'
import LogoMark from './components/LogoMark.vue'

const activeTab = ref('bom')
const bomTotal = ref(0)
const invTotal = ref(0)

const invRef = ref(null)

const subtitle = computed(() =>
  activeTab.value === 'bom' ? `BOM 共 ${bomTotal.value} 条` : `库存共 ${invTotal.value} 种`
)

/**
 * lazy 面板只在首次激活时挂载，之后切回来不会自动重查。
 * 但库存会被 BOM 页的批量出库改变，所以每次切过去刷一次。
 */
function onTabChange(name) {
  if (name === 'inventory') invRef.value?.refresh?.()
}
</script>
